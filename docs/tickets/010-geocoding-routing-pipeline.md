# Ticket 010: Geocoding & Routing Pipeline

## Description
Implement the PostGIS geocoding and pgRouting route calculation services, plus their Solid Queue background jobs. This is the async pipeline that runs after order creation: geocode addresses to coordinates, compute the route, then transition the order from `processing` to `open`. On failure, transition to `error`.

## Acceptance Criteria
- [ ] `Geo::Geocoder` service converts address strings to lat/lng coordinates using PostGIS geocoding functions (Tiger Geocoder `ST_Geocode` or imported address data lookup)
- [ ] `Geo::RouteCalculator` service computes shortest-path route using pgRouting `pgr_dijkstra` over OSM road network
- [ ] Route calculation produces: GeoJSON polyline (`ST_AsGeoJSON`), distance in meters (`ST_Length`), and estimated duration
- [ ] `GeocodeJob` (Solid Queue, `critical` queue):
  - Receives order ID
  - Geocodes pickup and dropoff addresses
  - Stores coordinates in PostGIS Point columns on DeliveryOrder
  - On success: enqueues `RouteCalculationJob`
  - On failure: transitions order to `error` state, notifies customer
- [ ] `RouteCalculationJob` (Solid Queue, `critical` queue):
  - Receives order ID
  - Computes route between pickup and dropoff coordinates
  - Stores route_geometry (LineString), estimated_distance_meters, estimated_duration_seconds
  - On success: enqueues `PriceEstimationJob` (ticket 011) or transitions to `open` if price exists
  - On failure: transitions order to `error` state
- [ ] Jobs are idempotent — safe to retry
- [ ] Order creation (from ticket 008) now enqueues `GeocodeJob` after persisting the order

## Dependencies
- **003** — Database schema with PostGIS columns must exist
- **008** — Order creation service to wire into
- **009** — Solid Queue must be configured

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `app/services/geo/geocoder.rb` — PostGIS geocoding service
- `app/services/geo/route_calculator.rb` — pgRouting route calculation service
- `app/jobs/geocode_job.rb` — async geocoding job (queue_as :critical)
- `app/jobs/route_calculation_job.rb` — async route calculation job (queue_as :critical)
- `app/services/orders/creator.rb` — modify to enqueue `GeocodeJob` after creation

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
