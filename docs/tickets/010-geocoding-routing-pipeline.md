# Ticket 010: Geocoding & Routing Pipeline

## Description
Implement the PostGIS geocoding and pgRouting route calculation services, plus their Sidekiq workers. This is the async pipeline that runs after order creation: geocode addresses to coordinates, compute the route, then transition the order from `processing` to `open`. On failure, transition to `error`.

## Acceptance Criteria
- [ ] `Geo::Geocoder` service converts address strings to lat/lng coordinates using PostGIS geocoding functions (Tiger Geocoder `ST_Geocode` or imported address data lookup)
- [ ] `Geo::RouteCalculator` service computes shortest-path route using pgRouting `pgr_dijkstra` over OSM road network
- [ ] Route calculation produces: GeoJSON polyline (`ST_AsGeoJSON`), distance in meters (`ST_Length`), and estimated duration
- [ ] `GeocodeWorker` (Sidekiq, `critical` queue):
  - Receives order ID
  - Geocodes pickup and dropoff addresses
  - Stores coordinates in PostGIS Point columns on DeliveryOrder
  - On success: enqueues `RouteCalculationWorker`
  - On failure: transitions order to `error` state, notifies customer
- [ ] `RouteCalculationWorker` (Sidekiq, `critical` queue):
  - Receives order ID
  - Computes route between pickup and dropoff coordinates
  - Stores route_geometry (LineString), estimated_distance_meters, estimated_duration_seconds
  - On success: enqueues `PriceEstimationWorker` (ticket 011) or transitions to `open` if price exists
  - On failure: transitions order to `error` state
- [ ] Workers are idempotent — safe to retry
- [ ] Order creation (from ticket 008) now enqueues `GeocodeWorker` after persisting the order

## Dependencies
- **003** — Database schema with PostGIS columns must exist
- **008** — Order creation service to wire into
- **009** — Sidekiq must be configured

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `app/services/geo/geocoder.rb` — PostGIS geocoding service
- `app/services/geo/route_calculator.rb` — pgRouting route calculation service
- `app/workers/geocode_worker.rb` — async geocoding worker
- `app/workers/route_calculation_worker.rb` — async route calculation worker
- `app/services/orders/creator.rb` — modify to enqueue `GeocodeWorker` after creation

## Technical Notes
- **Geocoding approach (MVP):** If Tiger Geocoder is not set up, use a simplified approach:
  - Option A: Import a local address/POI dataset and query with `ST_DWithin` + text matching
  - Option B: Use a geocoding lookup table seeded with known addresses
  - Option C: For demo purposes, parse lat/lng from a structured address format
- **pgRouting setup requires OSM data import:**
  1. Download regional OSM extract (.osm.pbf) from Geofabrik
  2. Import with `osm2pgrouting` into `ways` and `ways_vertices_pgr` tables
  3. Route query: `SELECT * FROM pgr_dijkstra('SELECT gid AS id, source, target, cost, reverse_cost FROM ways', start_vid, end_vid)`
  4. Convert result to geometry: join with `ways` table and use `ST_MakeLine` to build the route LineString
- **Finding nearest road network vertex:** `SELECT id FROM ways_vertices_pgr ORDER BY the_geom <-> ST_SetSRID(ST_MakePoint(lng, lat), 4326) LIMIT 1`
- Store route as `ST_AsGeoJSON(route_geometry)` for frontend consumption
- Duration estimation: sum of pgRouting `cost` values (typically in seconds based on road speed)
