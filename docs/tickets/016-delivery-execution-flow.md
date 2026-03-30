# Ticket 016: Delivery Execution Flow

## Description
Implement the full delivery status lifecycle with a state machine and status transition service. Each transition triggers specific background tasks (notifications, location polling, ETA recalculation). Drivers advance through statuses via the Active Delivery view.

## Acceptance Criteria
- [ ] State machine on `DeliveryOrder` using AASM or state_machines gem:
  - `open` → `accepted` (via acceptance — ticket 015)
  - `accepted` → `pickup_in_progress`
  - `pickup_in_progress` → `in_transit`
  - `in_transit` → `completed`
  - Any active state → `cancelled` (with conditions per PRD: only before pickup starts for customer)
- [ ] Invalid transitions are rejected with clear error messages
- [ ] `Orders::StatusTransitioner` service validates and executes transitions with side effects
- [ ] Side effects per transition (via background tasks):
  | Transition | Tasks |
  |---|---|
  | `open` → `accepted` | Customer notification, feed invalidation, route caching, **PaymentAuthorizationJob** (authorize estimated amount) |
  | `accepted` → `pickup_in_progress` | Customer notification ("Driver heading to pickup"), start location polling, **request GPS permission from driver's device; begin continuous GPS tracking via `navigator.geolocation.watchPosition`** |
  | `pickup_in_progress` → `in_transit` | Customer notification ("Items picked up"), recalculate ETA |
  | `in_transit` → `completed` | Customer notification ("Delivery complete"), stop location polling, **stop GPS tracking**, mark driver available, **PaymentCaptureJob** (capture final amount), **create DriverEarning record** |
  | Any → `cancelled` | **PaymentRefundJob** (void auth or refund if captured), notify counterpart, re-open or mark cancelled, cleanup |
- [ ] `ActiveDelivery.tsx` page for drivers: full-screen layout with current status display and "Next Status" action button
- [ ] On `accepted` → `pickup_in_progress` transition: frontend requests GPS permission via `navigator.geolocation.watchPosition({ enableHighAccuracy: true })`; GPS tracking begins automatically
- [ ] `ActiveDelivery.tsx` shows GPS permission request modal on delivery start
- [ ] If GPS permission is denied: persistent warning banner displayed; manual location update available as degraded fallback
- [ ] On `in_transit` → `completed`: GPS tracking session stopped via `navigator.geolocation.clearWatch`
- [ ] Status buttons are context-aware (show correct next action label)
- [ ] `StaleDeliveryMonitorJob` (Solid Queue, `maintenance` queue): flags deliveries with no status update for 30+ minutes

## Dependencies
- **015** — Order must be accepted/assigned before delivery can begin
- **029** — Payment processing flow (for payment job triggers on transitions)

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `Gemfile` — add `aasm` or `state_machines` gem
- `app/models/delivery_order.rb` — state machine definition with transition guards
- `app/services/orders/status_transitioner.rb` — transition logic with side effect orchestration
- `app/controllers/delivery_orders_controller.rb` — `update_status` action
- `app/jobs/stale_delivery_monitor_job.rb` — scheduled monitoring job
- `frontend/pages/Driver/ActiveDelivery.tsx` — active delivery view with status controls and GPS permission flow
- `frontend/hooks/useGpsTracking.ts` — GPS session management hook (wraps navigator.geolocation.watchPosition)

## Technical Notes
- AASM example:
  ```ruby
  include AASM
  aasm column: :status do
    state :processing, initial: true
    state :open, :accepted, :pickup_in_progress, :in_transit, :completed, :cancelled, :expired, :error

    event :mark_open do
      transitions from: :processing, to: :open
    end
    event :accept do
      transitions from: :open, to: :accepted
    end
    event :start_pickup do
      transitions from: :accepted, to: :pickup_in_progress
    end
    event :start_transit do
      transitions from: :pickup_in_progress, to: :in_transit
    end
    event :complete do
      transitions from: :in_transit, to: :completed
    end
    event :cancel do
      transitions from: [:open, :accepted], to: :cancelled
    end
  end
  ```
- The `StatusTransitioner` service should enqueue background tasks AFTER the status is saved (use `after_commit` or enqueue post-save)
- On `completed`: mark driver as `is_available: true` again in their profile
- The ActiveDelivery page should show: current status with visual timeline, prominent action button for next status, order summary, and (later) embedded map
- Status update API should respond in < 300ms (PRD requirement) — all side effects are async
- GPS tracking uses `navigator.geolocation.watchPosition({ enableHighAccuracy: true, maximumAge: 5000, timeout: 10000 })`
- GPS positions are sent to the existing location ingestion endpoint (`POST /api/assignments/:id/location`) at 5-10 second intervals via the `useGpsTracking` hook
- Payment job integration: the StatusTransitioner must enqueue PaymentAuthorizationJob on acceptance, PaymentCaptureJob on completion, and PaymentRefundJob on cancellation (see ticket 029)
