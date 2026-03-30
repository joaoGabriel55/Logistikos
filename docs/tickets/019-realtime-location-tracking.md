# Ticket 019: Real-Time Location Tracking

## Description
Implement the full real-time location tracking pipeline: driver location ingestion (buffered via Redis), ETA recalculation via pgRouting, stale location detection, and live map updates on the frontend. This enables the live driver marker on the map during active deliveries.

## Acceptance Criteria
- [ ] `Api::LocationsController` accepts driver location updates (lat, lng, timestamp) — responds in < 200ms
- [ ] Location updates are buffered in Redis (not written directly to PostgreSQL)
- [ ] `LocationFlushJob` (Solid Queue, `default` queue): flushes Redis buffer to Assignment table every 10-15 seconds (batch write)
- [ ] `EtaRecalculationJob` (Solid Queue, `default` queue): recalculates ETA via pgRouting (`pgr_dijkstra` from driver's current position to dropoff) every 30-60 seconds for active deliveries
- [ ] `StaleLocationDetectorJob` (Solid Queue, `maintenance` queue): checks for active deliveries where `last_location_updated_at` > 60 seconds ago, sets `location_stale: true`
- [ ] Frontend `useDriverLocation` hook polls driver location endpoint every 5-15 seconds
- [ ] `DriverMarker` updates position on map when new location received
- [ ] Stale location shows a warning badge on the map ("Location data may be outdated")
- [ ] `usePolling` generic hook for configurable polling intervals
- [ ] Location API endpoint: `GET /api/assignments/:id/location` returns lat, lng, eta, stale status, source
- [ ] **`useGpsTracking` hook** wraps `navigator.geolocation.watchPosition()` with `enableHighAccuracy: true`
- [ ] Hook returns: `{ position, error, permissionState, isTracking, startTracking, stopTracking }`
- [ ] GPS permission state checked via `navigator.permissions.query({ name: 'geolocation' })`
- [ ] `useGpsTracking` hook sends position to `POST /api/assignments/:id/location` at configurable interval (default 5-10s)
- [ ] If GPS unavailable or denied: hook returns error state; UI shows degraded mode warning
- [ ] Positions sent to backend include `source: 'gps'` field to distinguish from any manual updates
- [ ] Location ingestion endpoint accepts `source` parameter ('gps' | 'manual')

## Dependencies
- **016** — Delivery must be in active status (pickup_in_progress or in_transit)
- **018** — Map components for rendering driver position

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `app/controllers/api/locations_controller.rb` — location update ingestion + location query endpoint
- `app/jobs/location_flush_job.rb` — Redis to PostgreSQL batch flush
- `app/jobs/eta_recalculation_job.rb` — pgRouting ETA recalculation
- `app/jobs/stale_delivery_monitor_job.rb` — stale location detection (may extend from ticket 016)
- `frontend/hooks/useDriverLocation.ts` — polling hook for driver location (consumer/customer side)
- `frontend/hooks/useGpsTracking.ts` — GPS-sourced location producer hook (driver side)
- `frontend/hooks/usePolling.ts` — generic polling utility hook
- `config/routes.rb` — location API routes

## Technical Notes
- **Redis buffering pattern:**
  ```ruby
  # On location update:
  Redis.current.set("location:assignment:#{assignment_id}", { lat:, lng:, timestamp: }.to_json)

  # Flush job (every 10-15s):
  keys = Redis.current.keys("location:assignment:*")
  keys.each do |key|
    data = JSON.parse(Redis.current.get(key))
    assignment = Assignment.find(key.split(":").last)
    assignment.update!(driver_location: factory.point(data["lng"], data["lat"]), last_location_updated_at: Time.current, location_stale: false)
    Redis.current.del(key)
  end
  ```
- **ETA recalculation:** Use the same pgRouting query as ticket 010, but from driver's current position to dropoff
- **Stale detection:** `Assignment.where(location_stale: false).where("last_location_updated_at < ?", 60.seconds.ago).update_all(location_stale: true)`
- Frontend polling with TanStack Query:
  ```tsx
  const { data } = useQuery({
    queryKey: ['driver-location', assignmentId],
    queryFn: () => fetch(`/api/assignments/${assignmentId}/location`).then(r => r.json()),
    refetchInterval: 10000, // 10 seconds
  })
  ```
- Location update ingestion must be fast (< 200ms) — just write to Redis and return
- Security: only allow location updates from the assigned driver; only share location with delivery participants
- **GPS source hook pattern:**
  ```tsx
  // useGpsTracking hook (driver side — location producer):
  const useGpsTracking = (assignmentId: string, interval = 8000) => {
    const watchRef = useRef<number | null>(null);
    // navigator.geolocation.watchPosition with enableHighAccuracy: true
    // Throttle sends to POST /api/assignments/:id/location at interval
    // Include source: 'gps' in payload
    // Cleanup on unmount: navigator.geolocation.clearWatch(watchRef.current)
    return { position, error, permissionState, isTracking, startTracking, stopTracking };
  }
  ```
- **Note:** `useGpsTracking` (driver, writes to backend) is separate from `useDriverLocation` (customer, polls from backend) — they serve different purposes
