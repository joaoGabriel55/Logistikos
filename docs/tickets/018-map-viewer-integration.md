# Ticket 018: Map Viewer Integration (Mapbox GL JS)

## Description
Build the reusable map component system using Mapbox GL JS. This includes the base map viewer, location pins, route polyline rendering, and driver marker components. The map is used in three contexts: order detail preview, active delivery view (driver), and customer order tracking.

## Acceptance Criteria
- [ ] `MapViewer.tsx` — base map component using Mapbox GL JS with configurable center, zoom, and style
- [ ] `LocationPins.tsx` — pickup (green) and dropoff (red) markers at correct coordinates
- [ ] `RoutePolyline.tsx` — renders GeoJSON LineString from backend-cached route data as a colored polyline on the map
- [ ] `DriverMarker.tsx` — animated/styled marker for driver's current position, distinguishable from location pins
- [ ] Map is interactive: pinch-zoom, pan, auto-center on relevant bounds
- [ ] Map auto-fits bounds to show both pins and route when loaded
- [ ] Components are reusable across three contexts:
  - **Order Detail** (ticket 015): static pins + route preview
  - **Active Delivery** (ticket 016): full-screen map + live driver marker
  - **Customer Tracking** (ticket 023): route + live driver position
- [ ] Mapbox token loaded from environment variable (`MAPBOX_TOKEN`)
- [ ] Map loads in < 3 seconds (PRD non-functional requirement)
- [ ] Graceful handling when map data is unavailable (show placeholder)

## Dependencies
- **006** — UI components for loading states and layout
- **010** — Route GeoJSON data from the geocoding/routing pipeline

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `frontend/components/map/MapViewer.tsx` — base Mapbox GL JS map wrapper
- `frontend/components/map/LocationPins.tsx` — pickup/dropoff markers
- `frontend/components/map/RoutePolyline.tsx` — GeoJSON route line rendering
- `frontend/components/map/DriverMarker.tsx` — live driver position marker
- `package.json` — add `mapbox-gl` and `@types/mapbox-gl`

## Technical Notes
- Install `mapbox-gl` npm package and import the CSS
- Initialize map with:
  ```tsx
  const map = new mapboxgl.Map({
    container: containerRef.current,
    style: 'mapbox://styles/mapbox/streets-v12',
    center: [lng, lat],
    zoom: 13,
    accessToken: import.meta.env.VITE_MAPBOX_TOKEN
  })
  ```
- Route polyline from GeoJSON:
  ```tsx
  map.addSource('route', { type: 'geojson', data: routeGeoJSON })
  map.addLayer({ id: 'route', type: 'line', source: 'route', paint: { 'line-color': '#000e24', 'line-width': 4 } })
  ```
- Auto-fit bounds: use `map.fitBounds(bounds, { padding: 50 })` with all points
- DriverMarker should use a custom HTML marker (not default pin) — style with DESIGN.md secondary color
- The Mapbox token should be a VITE env var (`VITE_MAPBOX_TOKEN`) so it's available in frontend code
- This is the **only** Mapbox usage in the entire stack — backend uses PostGIS/pgRouting
- Handle cleanup: `map.remove()` on component unmount to prevent memory leaks
