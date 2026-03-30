# Ticket 024: Testing Suite

## Description
Write comprehensive RSpec tests covering core business logic per PRD section 16. This includes unit tests for models, services, and jobs, plus integration tests for critical async pipelines. Set up test infrastructure with FactoryBot, Shoulda Matchers, Database Cleaner, and Solid Queue testing mode.

## Acceptance Criteria
- [ ] **Test infrastructure configured:**
  - RSpec as test framework
  - FactoryBot with factories for all models
  - Shoulda Matchers for model validation tests
  - Database Cleaner for test database management
  - Solid Queue Testing inline mode for integration tests
  - Test database with PostGIS extension enabled
- [ ] **Unit tests — Models:**
  - User: validations, role enum, associations
  - DriverProfile: validations, vehicle_type enum, spatial scopes (`available`, `within_radius`)
  - DeliveryOrder: validations, status enum, state machine transitions (valid + invalid)
  - OrderItem: validations, size enum
  - Assignment: validations, associations
  - Notification: validations, notification_type enum, scopes
- [ ] **Unit tests — Services:**
  - `Orders::Creator`: creates order with items, sets processing status
  - `Orders::Acceptor`: optimistic locking, race condition handling, assignment creation
  - `Orders::StatusTransitioner`: valid transitions succeed, invalid transitions fail
  - `Pricing::Estimator`: distance-based pricing, load/vehicle multipliers
  - `Matching::DriverMatcher`: spatial query returns correct drivers, vehicle compatibility
  - `Geo::Geocoder`: address to coordinates conversion
  - `Geo::RouteCalculator`: route computation returns geometry + distance + duration
- [ ] **Unit tests — AI services:**
  - `Ai::NlOrderParser`: parses structured output, handles invalid input
  - `Ai::OrderRanker`: ranking produces sorted results, fallback works
- [ ] **Integration tests:**
  - Order creation → geocoding → routing → pricing → matching → `open` (full pipeline with Solid Queue inline)
  - Order acceptance → notification → feed invalidation
  - Driver location update → ETA recalculation
  - Authentication flow (OmniAuth test mode)
  - Inertia page rendering (correct component receives correct props)
- [ ] All tests pass (`bundle exec rspec` exits with 0)

## Dependencies
- **016** — Full lifecycle must exist to test end-to-end flows

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `spec/rails_helper.rb` — RSpec configuration with PostGIS, FactoryBot, Shoulda, Database Cleaner
- `spec/spec_helper.rb` — base RSpec config
- `spec/factories/users.rb`
- `spec/factories/driver_profiles.rb`
- `spec/factories/delivery_orders.rb`
- `spec/factories/order_items.rb`
- `spec/factories/assignments.rb`
- `spec/factories/notifications.rb`
- `spec/models/user_spec.rb`
- `spec/models/driver_profile_spec.rb`
- `spec/models/delivery_order_spec.rb`
- `spec/models/order_item_spec.rb`
- `spec/models/assignment_spec.rb`
- `spec/models/notification_spec.rb`
- `spec/services/orders/creator_spec.rb`
- `spec/services/orders/acceptor_spec.rb`
- `spec/services/orders/status_transitioner_spec.rb`
- `spec/services/pricing/estimator_spec.rb`
- `spec/services/matching/driver_matcher_spec.rb`
- `spec/services/geo/geocoder_spec.rb`
- `spec/services/geo/route_calculator_spec.rb`
- `spec/jobs/geocode_job_spec.rb`
- `spec/jobs/route_calculation_job_spec.rb`

## Technical Notes
- FactoryBot factories for spatial data:
  ```ruby
  factory :driver_profile do
    location { RGeo::Geographic.spherical_factory(srid: 4326).point(-34.87, -8.05) }
  end
  ```
- Solid Queue testing inline mode for integration tests:
  ```ruby
  Solid Queue::Testing.inline! do
    # Jobs execute immediately
  end
  ```
- Stub LLM API calls in AI service tests — don't make real API calls in tests
- For race condition testing on order acceptance, use threads or database-level simulation
- PostGIS must be enabled in the test database (`CREATE EXTENSION IF NOT EXISTS postgis`)
- Gemfile test group: `rspec-rails`, `factory_bot_rails`, `shoulda-matchers`, `database_cleaner-active_record`
