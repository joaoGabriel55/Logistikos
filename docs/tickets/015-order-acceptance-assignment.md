# Ticket 015: Order Acceptance & Assignment

## Description
Build the order acceptance logic with optimistic locking to prevent race conditions. When a driver accepts an order, an Assignment record is created, the order is removed from the marketplace, and background tasks handle notifications and route caching. The frontend provides instant optimistic feedback.

## Acceptance Criteria
- [ ] `Orders::Acceptor` service handles acceptance with optimistic locking (`SELECT ... FOR UPDATE` or version column)
- [ ] Only one driver can accept a given order — concurrent attempts get a clear "already taken" error
- [ ] Assignment record is created with: order_id, driver_id, accepted_at timestamp
- [ ] Order status transitions from `open` to `accepted`
- [ ] Order is removed from marketplace (no longer visible in other drivers' feeds)
- [ ] `AssignmentsController#create` handles the acceptance request
- [ ] Background tasks triggered on acceptance:
  - Customer notification ("Driver accepted your order")
  - Feed invalidation (remove from all driver feed caches)
  - Route snapshot (cache full route polyline if not already cached)
- [ ] `OrderDetail.tsx` page shows order details with map preview and "Accept" button
- [ ] Optimistic UI: button shows "Accepted" immediately, confirmation follows
- [ ] Error handling: if order already taken, show friendly message and redirect to feed
- [ ] Acceptance is < 3 taps from the feed (PRD UX requirement)

## Dependencies
- **013** — Feed must exist (driver navigates from feed to order detail)
- **012** — Notification system must be in place for customer notification

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `app/services/orders/acceptor.rb` — acceptance logic with optimistic locking
- `app/controllers/assignments_controller.rb` — create action
- `app/models/assignment.rb` — validations, associations
- `app/models/delivery_order.rb` — add locking support (lock_version column or explicit row lock)
- `frontend/pages/Driver/OrderDetail.tsx` — order detail page with Accept button
- `config/routes.rb` — add assignment routes

## Technical Notes
- Optimistic locking approach (recommended):
  ```ruby
  DeliveryOrder.transaction do
    order = DeliveryOrder.lock("FOR UPDATE").find(order_id)
    raise AlreadyAcceptedError unless order.open?
    order.update!(status: :accepted)
    Assignment.create!(delivery_order: order, driver: current_user, accepted_at: Time.current)
  end
  ```
- Alternative: use Rails `lock_version` column for optimistic locking (raises `StaleObjectError`)
- The "Accept" button should be prominent — use the primary gradient CTA per DESIGN.md
- Order detail should show: full address details, item list, price, map preview (static pins + route)
- Background tasks are enqueued after the transaction commits (use `after_commit` callback or explicit enqueue after transaction)
- Feed invalidation worker should remove the order from Redis feed cache
