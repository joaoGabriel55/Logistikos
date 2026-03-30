# Ticket 026: Polish, Seed Data & Demo Prep

## Description
Final preparation for the live demo and submission. Create rich seed data, perform a UI polish pass, ensure all error states are handled, and verify the complete end-to-end flow works on the deployed environment. This is the last ticket before submission.

## Acceptance Criteria
- [ ] **Seed data** (`db/seeds.rb`) creates:
  - 3-5 customer users with Google OAuth mock data
  - 5-8 driver users with varied profiles (different vehicles, locations, availability)
  - 10-15 delivery orders in various states (processing, open, accepted, in_transit, completed)
  - Assignments for accepted/active orders with realistic location data
  - Notifications for each driver/customer
  - Addresses use real-ish locations in the operational region (e.g., Recife neighborhoods)
  - Payment methods for customer users (mock tokens via MockAdapter)
  - Payment records linked to orders: `authorized` for accepted orders, `captured` for completed orders
  - DriverEarning records for completed deliveries (with realistic gross/platform_fee/net amounts)
  - Consent records for all users (terms_of_service, location_tracking, payment_processing)
- [ ] `rails db:seed` runs without errors and populates meaningful demo data
- [ ] **UI polish pass:**
  - All loading states use `LoadingSpinner` component
  - All empty states use `EmptyState` component with helpful messaging
  - Error states show user-friendly messages (not raw error text)
  - Form validation errors are clear and visible
  - Touch interactions are smooth (no janky transitions)
  - All screens render correctly on 375px-428px viewports
- [ ] **Error handling audit:**
  - Network errors show retry prompts
  - 404 pages use `NotFound.tsx`
  - Failed background tasks show appropriate user feedback
  - LLM unavailability falls back gracefully (no broken screens)
- [ ] **End-to-end verification on deployed environment:**
  - Customer adds payment method (mock token) → creates order → order processes → appears in driver feed
  - Order creation blocked if customer has no payment method
  - Driver accepts order → payment authorized → customer notified → tracking starts
  - Driver advances through status lifecycle → customer sees updates on map
  - Delivery completes → payment captured → driver earning created → visible in driver profile
  - Order cancellation → payment voided/refunded correctly
  - Map displays correctly with pins, route, and live marker
  - GPS tracking flow: permission request, tracking active during delivery, stops on completion
  - AI features work (NL order parsing, smart pricing, ETA narratives)
- [ ] **Optimistic UI verification:** all status updates feel instant
- [ ] `NotFound.tsx` page exists for unmatched routes

## Dependencies
- All prior tickets including **027-031** (payments, privacy — feature-complete app)

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `db/seeds.rb` — comprehensive demo data
- `frontend/pages/Shared/NotFound.tsx` — 404 page
- Various UI files for polish fixes (as discovered during audit)

## Technical Notes
- Seed data should tell a story: some orders just created (processing), some waiting for drivers (open), some mid-delivery (in_transit), some completed — this makes the demo feel alive
- Use `RGeo::Geographic.spherical_factory(srid: 4326).point(lng, lat)` for seed location data
- Example Recife coordinates for seeds:
  - Boa Viagem: -34.8951, -8.1235
  - Casa Forte: -34.9196, -8.0359
  - Recife Antigo: -34.8714, -8.0631
  - Boa Vista: -34.8808, -8.0609
- For the demo, pre-compute routes for seed orders so map previews work immediately
- Test the full flow on the production URL before demo day
- Have a "reset demo data" script or rake task for quick environment reset
- Screenshots for README: capture key screens during this polish phase (order feed, map viewer, payment flow, driver profile with earnings)
- Seed payment methods should use MockAdapter tokens (e.g., `mock_pm_<uuid>`) with realistic card_last_four and card_brand values
- Seed consent records: create `terms_of_service` and `location_tracking` consents for all users, plus `payment_processing` for customers
- DriverEarning seed data: `net_amount_cents = gross_amount_cents - (gross_amount_cents * PLATFORM_FEE_PERCENT / 100)`
