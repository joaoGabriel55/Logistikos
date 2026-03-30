You are a backend debugging specialist for **Logistikos**. The order creation pipeline is the most complex flow — spanning multiple async Sidekiq workers, PostGIS/pgRouting, and state transitions. Use this command to diagnose pipeline issues.

## Input
$ARGUMENTS — an order ID, or a symptom description (e.g., "order stuck in processing", "route not calculated", "drivers not notified")

## Order Creation Pipeline (Expected Flow)
```
Customer submits order
  → Order created with status: `processing`
  → GeocodeWorker (PostGIS geocoding) converts addresses to coordinates
    → RouteCalculationWorker (pgRouting) computes route polyline + distance
      → PriceEstimationWorker (if no suggested price) calculates recommended price
        → DriverMatchWorker (PostGIS ST_DWithin) finds eligible drivers
          → NotificationDispatchWorker fans out notifications
            → Order transitions to status: `open`
```

If any worker fails, the order should transition to `error` status.

## Debugging Steps

### Step 1: Identify the Order State
```ruby
# Rails console or direct query
order = DeliveryOrder.find(<order_id>)
puts order.status
puts order.pickup_location   # nil = geocoding didn't run
puts order.dropoff_location  # nil = geocoding didn't run
puts order.route_geometry    # nil = routing didn't run
puts order.estimated_distance_meters
puts order.estimated_price
puts order.created_at
```

Determine where in the pipeline the order stalled based on which fields are populated.

### Step 2: Check Sidekiq Worker Execution
1. Check Sidekiq dashboard or logs for failed workers related to this order
2. Check the dead-letter queue: `Sidekiq::DeadSet.new.each { |job| puts job.display_class }`
3. Check retry queue: `Sidekiq::RetrySet.new.each { |job| puts job.display_class }`
4. Look for specific worker failures in Rails logs:
   ```bash
   grep "order_id.*<ID>" log/development.log | tail -50
   ```

### Step 3: Verify PostGIS Data Integrity
```sql
-- Check if geocoding produced valid coordinates
SELECT id, status,
  ST_AsText(pickup_location) as pickup,
  ST_AsText(dropoff_location) as dropoff
FROM delivery_orders WHERE id = <order_id>;

-- Check if route geometry exists and is valid
SELECT id,
  ST_IsValid(route_geometry) as valid_route,
  ST_AsGeoJSON(route_geometry) as geojson,
  estimated_distance_meters
FROM delivery_orders WHERE id = <order_id>;

-- Verify the OSM road network is available for routing
SELECT count(*) FROM ways;
SELECT count(*) FROM ways_vertices_pgr;
```

### Step 4: Verify Driver Matching
```sql
-- Check if any eligible drivers exist near the pickup location
SELECT dp.user_id, dp.vehicle_type, dp.is_available,
  ST_Distance(dp.location::geography, do.pickup_location::geography) as distance_meters
FROM driver_profiles dp, delivery_orders do
WHERE do.id = <order_id>
  AND dp.is_available = true
  AND ST_DWithin(dp.location::geography, do.pickup_location::geography, 20000)
ORDER BY distance_meters;
```

### Step 5: Check State Machine Transitions
```ruby
order = DeliveryOrder.find(<order_id>)
# Check if the order can transition
puts order.may_open?        # Should be true if in 'processing'
puts order.aasm.current_state
# Check for validation errors blocking transition
order.open!  # Will raise if blocked — check the error
```

### Step 6: Check Notifications
```sql
-- Verify notifications were created for this order
SELECT id, user_id, notification_type, is_read, created_at
FROM notifications
WHERE order_id = <order_id>
ORDER BY created_at;
```

### Step 7: Check Assignment (if order is accepted)
```sql
SELECT a.*, ST_AsText(a.driver_location) as driver_pos,
  a.cached_eta_seconds, a.location_stale
FROM assignments a
WHERE a.order_id = <order_id>;
```

## Common Issues & Fixes

| Symptom | Likely Cause | Fix |
|---|---|---|
| Stuck in `processing` | GeocodeWorker failed | Check address validity, PostGIS geocoder setup |
| Geocoded but no route | RouteCalculationWorker failed | Check pgRouting setup, OSM data imported |
| Route exists but no price | PriceEstimationWorker failed | Check pricing service, LLM availability |
| Open but no notifications | DriverMatchWorker found 0 drivers | Check driver availability and radius |
| `error` status | A worker raised an unhandled exception | Check Sidekiq dead-letter queue |
| Duplicate acceptance | Missing optimistic lock | Verify `SELECT ... FOR UPDATE` in acceptor service |

## Output
Produce a diagnosis report with:
1. **Order state** — current status and populated fields
2. **Pipeline progress** — which workers completed successfully
3. **Root cause** — what failed and why
4. **Suggested fix** — specific action to resolve the issue
