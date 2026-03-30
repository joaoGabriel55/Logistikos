# Ticket 012: Driver Matching & Notification Fan-Out

## Description
Build the driver matching service that uses PostGIS spatial queries to find eligible drivers for a new order, then fan out in-app notifications to each matched driver. This is the final step in the order creation pipeline — after matching completes, the order transitions to `open` and appears in driver feeds.

## Acceptance Criteria
- [ ] `Matching::DriverMatcher` service finds eligible drivers using:
  - `ST_DWithin` — drivers within their preferred radius of the pickup location
  - Vehicle compatibility — driver's vehicle can handle the order's load size
  - Availability — driver `is_available: true`
- [ ] `DriverMatchJob` (Solid Queue, `critical` queue):
  - Receives order ID
  - Calls `DriverMatcher` to get eligible driver list
  - Enqueues `NotificationDispatchJob` with the list
  - Transitions order to `open` status
- [ ] `NotificationDispatchJob` (Solid Queue, `default` queue):
  - Creates Notification records in batch for all matched drivers
  - Notification type: `new_order`
  - Message includes order summary (pickup area, load size, price)
- [ ] Vehicle compatibility matrix:
  - motorcycle: small only
  - car: small, medium
  - van: small, medium, large
  - truck: small, medium, large, bulk
- [ ] If no drivers match, order still transitions to `open` (drivers may become available later)
- [ ] Jobs are idempotent — duplicate runs don't create duplicate notifications

## Dependencies
- **007** — DriverProfile with location and vehicle type must exist
- **010** — Geocoded order with pickup coordinates needed for spatial query
- **011** — Price must be set before notifying drivers

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/services/matching/driver_matcher.rb` — spatial matching service
- `app/jobs/driver_match_job.rb` — matching orchestration job (queue_as :critical)
- `app/jobs/notification_dispatch_job.rb` — batch notification creation (queue_as :default)
- `app/models/notification.rb` — ensure `new_order` notification type
- `app/jobs/price_estimation_job.rb` — modify to chain `DriverMatchJob`

## Technical Notes
- Spatial query for matching:
  ```ruby
  DriverProfile
    .available
    .where("ST_DWithin(location::geography, ?::geography, radius_preference * 1000)", pickup_point)
    .where(vehicle_type: compatible_vehicles_for(order_size))
  ```
- `compatible_vehicles_for` maps order max item size to vehicle types per the compatibility matrix
- Batch insert notifications using `insert_all` for performance (avoid N+1 inserts)
- Idempotency: check if notifications already exist for this order before creating
- The notification message should be concise for quick scanning: "New delivery: Boa Viagem → Casa Forte | Medium | R$ 45"
- This job is the final step in the pipeline: `GeocodeJob → RouteCalculationJob → PriceEstimationJob → DriverMatchJob`
