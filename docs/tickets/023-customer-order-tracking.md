# Ticket 023: Customer Order Tracking & List

## Description
Build the customer-facing order views: a list of all orders and the detailed tracking page with embedded map, live driver position, status timeline, and AI ETA narratives. This is the customer's primary interface for monitoring their deliveries.

## Acceptance Criteria
- [ ] `OrderList.tsx` page showing all customer's orders with:
  - Status badge per order
  - Pickup/dropoff addresses
  - Price
  - Creation date
  - Tap to navigate to tracking/detail
- [ ] `OrderTracking.tsx` page for active orders with:
  - Embedded `MapViewer` showing route polyline + pickup/dropoff pins + live driver marker
  - Status timeline (visual thread showing completed/current/upcoming steps)
  - AI ETA narrative text (from ticket 022)
  - Estimated time remaining
  - Driver info (name, vehicle type)
  - Order summary (items, addresses, price)
- [ ] Real-time updates via polling (TanStack Query, 5-10s interval)
- [ ] Map auto-centers on driver position during active delivery
- [ ] `Dashboard.tsx` as shared landing page — routes to order list or feed based on role
- [ ] For completed orders: show completion summary (no live tracking)
- [ ] For processing/open orders: show processing indicator or "Waiting for driver" state
- [ ] Route timeline component uses DESIGN.md spec: thin line icons + 1px vertical line using `surface-dim`

## Dependencies
- **018** — Map components for embedded map viewer
- **019** — Location tracking for live driver position
- **022** — ETA narratives for contextual updates
- **017** — Notifications for status update alerts

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `frontend/pages/Customer/OrderList.tsx` — customer's order list
- `frontend/pages/Customer/OrderTracking.tsx` — detailed tracking with map + timeline + narrative
- `frontend/pages/Shared/Dashboard.tsx` — role-based landing page
- `app/controllers/delivery_orders_controller.rb` — `show` action with serialized spatial data for customer view

## Technical Notes
- The tracking page combines multiple data sources:
  - Order data (via Inertia props from controller)
  - Driver location (via polling with `useDriverLocation` hook)
  - ETA narrative (included in location polling response or separate endpoint)
- Status timeline component:
  ```tsx
  const steps = ['Order Placed', 'Driver Assigned', 'Pickup', 'In Transit', 'Delivered']
  // Render with connected vertical line, completed steps in primary color, current step pulsing
  ```
- Route timeline should follow DESIGN.md: thin line icons + 1px vertical line in `surface-dim` (#d9dadc)
- For non-active orders (processing, open, completed), show appropriate static views without live map
- Dashboard routing logic: `current_user.customer? ? OrderList : OrderFeed`
- Polling should stop when delivery is completed (no need to keep fetching location)
