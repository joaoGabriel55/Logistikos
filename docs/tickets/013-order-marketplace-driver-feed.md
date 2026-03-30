# Ticket 013: Order Marketplace / Driver Feed

## Description
Build the driver order feed — the **core feature** of the platform. The feed shows open delivery orders with pre-computed pickup distances using PostGIS spatial queries. Each order card displays key information for quick decision-making. Includes a Redis-based feed cache layer for performance.

## Acceptance Criteria
- [ ] `DeliveryOrdersController#index` serves open orders as Inertia props for drivers
- [ ] Each order includes pre-computed pickup distance from driver's current location (`ST_DistanceSphere`)
- [ ] Order cards display: pickup distance, delivery distance, load summary, size classification, price, scheduled/immediate indicator
- [ ] `OrderFeed.tsx` page renders a scrollable list of `OrderCard` components
- [ ] `OrderCard.tsx` follows DESIGN.md:
  - No border separation — use `spacing-5` (1.1rem) vertical white space
  - Intentional asymmetry: data left, price right
  - Priority loads show `secondary_fixed` (#ffdbce) vertical accent bar (4px left)
  - Quick-Scan badges for load type (e.g., "LTL", "BULK") using `tertiary_container` style
  - `OrderStatusBadge` component for status display
- [ ] `PriceBreakdown.tsx` shows price with AI-estimated label when applicable
- [ ] Feed loads in under 2 seconds (PRD non-functional requirement)
- [ ] Redis feed cache stores pre-computed feed data; invalidated on order creation/acceptance/expiry
- [ ] Empty state shown when no orders match driver's profile

## Dependencies
- **007** — Driver profile (vehicle type, location for distance calc)
- **008** — Orders must exist in the system
- **012** — Orders must be in `open` status after pipeline completes
- **006** — UI components (MobileLayout, BottomNav, EmptyState)

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `app/controllers/delivery_orders_controller.rb` — `index` action with spatial distance computation
- `app/serializers/delivery_order_serializer.rb` — include distance, items summary, status
- `frontend/pages/Driver/OrderFeed.tsx` — feed page with polling refresh
- `frontend/components/orders/OrderCard.tsx` — individual order card
- `frontend/components/orders/OrderStatusBadge.tsx` — status indicator badge
- `frontend/components/orders/PriceBreakdown.tsx` — price display with AI label

## Technical Notes
- Distance calculation in the controller/query:
  ```ruby
  DeliveryOrder.open.select(
    "delivery_orders.*",
    "ST_DistanceSphere(pickup_location, ST_SetSRID(ST_MakePoint(#{driver_lng}, #{driver_lat}), 4326)) AS pickup_distance_meters"
  ).order("pickup_distance_meters ASC")
  ```
- Use parameterized queries (not string interpolation) for security — the above is pseudocode
- Redis cache key per driver: `feed:driver:#{driver_id}` with TTL of 30 seconds
- Feed cache is a denormalized JSON array — invalidate on order status changes
- The `OrderCard` should show a truncated item list (first 2-3 items + "and X more")
- Consider Inertia partial reloads for feed refresh without full page reload
- The feed should also be accessible via polling endpoint for TanStack Query (JSON format)
