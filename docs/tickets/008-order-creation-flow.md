# Ticket 008: Order Creation Flow (Customer)

## Description
Build the delivery order creation form for customers. This includes the controller, service object, form components, and Inertia page. Orders are created in `processing` state with an immediate 201 response — heavy work (geocoding, routing, pricing) happens asynchronously in later tickets.

## Acceptance Criteria
- [ ] `DeliveryOrdersController#new` renders the `OrderCreate.tsx` Inertia page
- [ ] `DeliveryOrdersController#create` calls `Orders::Creator` service and returns 201 immediately
- [ ] `Orders::Creator` service validates input, creates DeliveryOrder with `processing` status, and creates associated OrderItems
- [ ] **OrderCreate.tsx** page with complete form:
  - Pickup address input (`AddressInput` component)
  - Drop-off address input (`AddressInput` component)
  - Delivery type toggle (Immediate / Scheduled with datetime picker)
  - Item list (dynamic add/remove via `ItemListInput` component)
  - Each item: name, quantity, size category (Small/Medium/Large/Bulk)
  - Optional description textarea
  - Optional suggested price input
- [ ] Form validates required fields client-side before submission
- [ ] Inertia form submission with validation errors flowing back from Rails
- [ ] After successful creation, customer sees confirmation with processing indicator
- [ ] `DeliveryOrderSerializer` serializes order data as Inertia props
- [ ] UI follows DESIGN.md: 56px input height, no borders, surface hierarchy, primary gradient submit button
- [ ] Order creation is blocked if the customer has no valid (non-expired, default) payment method on file — shows a prompt to add one first (payment method guard implemented via ticket 030)

## Dependencies
- **004** — Authentication (customer must be logged in)
- **006** — UI components (MobileLayout, Button, BottomSheet)

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `app/services/orders/creator.rb` — order creation service object
- `app/controllers/delivery_orders_controller.rb` — new/create actions
- `app/serializers/delivery_order_serializer.rb` — Inertia props serialization
- `frontend/pages/Customer/OrderCreate.tsx` — order creation page
- `frontend/components/forms/OrderForm.tsx` — main form component
- `frontend/components/forms/AddressInput.tsx` — address input with label
- `frontend/components/forms/ItemListInput.tsx` — dynamic item list (add/remove items)
- `config/routes.rb` — add delivery order routes

## Technical Notes
- Use Inertia's `useForm` hook for form state management and submission
- The `Orders::Creator` service should be a plain Ruby object (PORO) that:
  1. Validates required fields
  2. Creates the DeliveryOrder record with `status: :processing`
  3. Creates associated OrderItem records
  4. Returns a result object with success/failure and the order
- Background task enqueuing (geocoding, routing) is NOT part of this ticket — that's ticket 010
- `AddressInput` is a text input for MVP — autocomplete can be added later
- `ItemListInput` allows adding multiple items with a "+" button and removing with "x"
- The form should use `router.post` via Inertia for submission
- Validation errors from Rails automatically appear in the Inertia form via `usePage().props.errors`
- **Payment method guard:** PRD Section 8 requires "Customers must have a valid payment method on file before creating an order." The `Orders::Creator` service (or controller `before_action`) should check for a default, non-expired payment method. This guard is fully implemented in ticket 030 (Payment UI) — the order creation flow will be updated at that point
