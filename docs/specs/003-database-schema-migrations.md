# Product Specification: Database Schema & Migrations

## Overview

This specification defines the complete database schema and migration structure for the Logistikos marketplace platform. The implementation establishes the foundational data model that supports all core business flows: order creation, driver assignment, real-time tracking, payments, and notifications.

## Problem Statement

The Logistikos platform requires a robust, scalable database schema that:
- Supports spatial operations for location-based features (driver radius, distance calculations, route planning)
- Manages complex state transitions for delivery orders
- Handles secure payment processing with gateway abstraction
- Enables real-time location tracking with efficient spatial indexing
- Protects user PII through encryption and data protection mechanisms
- Maintains audit trails for compliance (GDPR/LGPD)

## Goals & Success Metrics

### Goals
1. Establish a complete ActiveRecord data model with all domain entities
2. Enable PostGIS and pgRouting extensions for spatial operations
3. Implement proper indexing for performance-critical queries
4. Ensure data integrity through foreign key constraints and validations
5. Support privacy-by-design with encrypted PII fields

### Success Metrics
- All migrations run cleanly on PostgreSQL 16+ with PostGIS 3.4
- Spatial queries (radius matching, distance calculations) execute in < 50ms
- Schema supports all user flows defined in the PRD
- PII fields are properly encrypted and filtered from logs
- Database passes CI pipeline validation

## User Personas

### Customer
- Creates delivery orders with pickup/dropoff locations
- Tracks delivery progress with real-time driver location
- Manages payment methods securely

### Driver
- Maintains profile with vehicle type and availability
- Discovers orders within their working radius
- Updates location during active deliveries
- Receives earnings after platform fee deduction

### System
- Processes background tasks (geocoding, routing, notifications)
- Manages payment lifecycle (authorize, capture, refund)
- Maintains audit logs and consent records

## Feature Requirements

### [STORY-001] Enable Spatial Extensions
**As a** System
**I want** PostGIS and pgRouting extensions enabled
**So that** the application can perform spatial operations and route calculations

#### Acceptance Criteria
- [ ] Given a fresh database, When migration 001_enable_postgis runs, Then PostGIS extension is created
- [ ] Given a fresh database, When migration 001_enable_postgis runs, Then pgRouting extension is created
- [ ] Given extensions are enabled, When checking version, Then PostGIS 3.4+ is confirmed
- [ ] Given extensions are enabled, When checking version, Then pgRouting is confirmed
- [ ] Given migration has run once, When run again, Then it is idempotent (no errors)

#### Domain Constraints
- **Affected statuses**: N/A - infrastructure setup
- **User roles**: System
- **Map implications**: Enables all map features
- **AI feature**: Enables route-based price estimation

#### Technical Notes
- Migration: `db/migrate/001_enable_postgis.rb`
- SQL: `CREATE EXTENSION IF NOT EXISTS postgis; CREATE EXTENSION IF NOT EXISTS pgrouting;`
- Verification: `bin/rails db:postgis:verify` rake task
- Used by: All spatial queries, pgRouting route calculations

#### Priority: Must
#### Story Points: 1

---

### [STORY-002] Create Users Table
**As a** Customer or Driver
**I want** my account information stored securely
**So that** I can authenticate and use the platform

#### Acceptance Criteria
- [ ] Given the users table is created, When a record is saved, Then name and email are encrypted at rest
- [ ] Given a user has role 'customer', When checked, Then they cannot access driver features
- [ ] Given a user has role 'driver', When checked, Then they can access driver features
- [ ] Given email is encrypted deterministically, When searching by email, Then exact matches work
- [ ] Given OAuth fields exist, When user signs in via Google, Then provider and uid are stored
- [ ] Given password_digest exists, When using has_secure_password, Then authentication works

#### Domain Constraints
- **Affected statuses**: N/A - authentication layer
- **User roles**: Customer, Driver
- **Map implications**: User authentication required for map access
- **AI feature**: User preferences for AI personalization

#### Technical Notes
- Migration: `db/migrate/002_create_users.rb`
- Model: `app/models/user.rb`
- Columns: id, name (encrypted), email (encrypted, deterministic), password_digest, role (enum), provider, uid, timestamps
- Associations: has_one :driver_profile, has_many :delivery_orders, has_many :payment_methods
- Encryption: `encrypts :name; encrypts :email, deterministic: true, downcase: true`
- Filter: `self.filter_attributes = %i[name email password_digest]`

#### Priority: Must
#### Story Points: 2

---

### [STORY-003] Create Driver Profiles Table
**As a** Driver
**I want** my vehicle and availability information stored
**So that** I receive relevant delivery orders

#### Acceptance Criteria
- [ ] Given a driver profile exists, When location is updated, Then PostGIS Point is stored
- [ ] Given location uses SRID 4326, When coordinates are saved, Then standard GPS format is used
- [ ] Given is_available is true, When checked, Then driver appears in active driver queries
- [ ] Given radius_preference is 10km, When orders are matched, Then only orders within 10km are shown
- [ ] Given vehicle_type is 'motorcycle', When orders are filtered, Then only compatible orders appear
- [ ] Given a GiST index exists on location, When spatial queries run, Then performance is optimal

#### Domain Constraints
- **Affected statuses**: Affects order visibility in 'open' status
- **User roles**: Driver
- **Map implications**: Driver location shown on map during delivery
- **AI feature**: Vehicle type affects AI price estimation

#### Technical Notes
- Migration: `db/migrate/003_create_driver_profiles.rb`
- Model: `app/models/driver_profile.rb`
- Columns: user_id (FK), vehicle_type (enum), is_available, radius_preference, location (st_point, SRID 4326), last_location_updated_at
- Spatial index: `add_index :driver_profiles, :location, using: :gist`
- Vehicle types: motorcycle, car, van, truck
- Scope: `scope :available, -> { where(is_available: true) }`

#### Priority: Must
#### Story Points: 2

---

### [STORY-004] Create Delivery Orders Table
**As a** Customer
**I want** my delivery requests stored with location data
**So that** drivers can discover and fulfill them

#### Acceptance Criteria
- [ ] Given an order is created, When status is set, Then it follows the defined lifecycle
- [ ] Given pickup/dropoff locations are Points, When stored, Then SRID 4326 is used
- [ ] Given route_geometry is a LineString, When stored, Then the full route path is preserved
- [ ] Given estimated_distance_meters exists, When calculated, Then ST_Length is used on route
- [ ] Given all location columns have GiST indexes, When spatial queries run, Then performance is optimal
- [ ] Given status changes, When transitions occur, Then only valid transitions are allowed
- [ ] Given scheduled_at is set, When queried, Then scheduled vs immediate orders are distinguishable

#### Domain Constraints
- **Affected statuses**: All order statuses (processing → open → accepted → pickup_in_progress → in_transit → completed)
- **User roles**: Customer (creator), Driver (assignee)
- **Map implications**: Order locations and route displayed on map
- **AI feature**: Route data used for AI price estimation and ETA predictions

#### Technical Notes
- Migration: `db/migrate/004_create_delivery_orders.rb`
- Model: `app/models/delivery_order.rb`
- Columns:
  - id, created_by (FK to users), status (enum), timestamps
  - pickup_address, dropoff_address, description
  - pickup_location (st_point), dropoff_location (st_point), route_geometry (line_string)
  - estimated_distance_meters, estimated_duration_seconds
  - scheduled_at, price, estimated_price, delivery_type (enum)
- Status enum: processing, open, accepted, pickup_in_progress, in_transit, completed, cancelled, expired, error
- Delivery type enum: immediate, scheduled
- Spatial indexes on: pickup_location, dropoff_location, route_geometry

#### Priority: Must
#### Story Points: 3

---

### [STORY-005] Create Order Items Table
**As a** Customer
**I want** to specify multiple items in my delivery order
**So that** drivers understand the load requirements

#### Acceptance Criteria
- [ ] Given an order has multiple items, When saved, Then all items are associated with the order
- [ ] Given size is an enum, When set, Then only valid sizes (small/medium/large/bulk) are accepted
- [ ] Given quantity is specified, When saved, Then positive integers are enforced
- [ ] Given an order is deleted, When cascade occurs, Then all order items are deleted

#### Domain Constraints
- **Affected statuses**: Affects order creation in 'processing' status
- **User roles**: Customer
- **Map implications**: Load size affects vehicle compatibility
- **AI feature**: Item details used in AI price estimation

#### Technical Notes
- Migration: `db/migrate/005_create_order_items.rb`
- Model: `app/models/order_item.rb`
- Columns: id, order_id (FK), name, quantity, size (enum), timestamps
- Size enum: small, medium, large, bulk
- Association: belongs_to :delivery_order
- Validation: validates :quantity, numericality: { greater_than: 0 }

#### Priority: Must
#### Story Points: 1

---

### [STORY-006] Create Assignments Table
**As a** Driver
**I want** my accepted orders tracked
**So that** the system knows I'm responsible for the delivery

#### Acceptance Criteria
- [ ] Given an assignment is created, When saved, Then order and driver are linked uniquely
- [ ] Given driver_location is updated, When GPS coordinates arrive, Then PostGIS Point is stored
- [ ] Given last_location_updated_at is tracked, When > 60 seconds old, Then location_stale is true
- [ ] Given cached_eta_seconds exists, When ETA is recalculated, Then value is updated
- [ ] Given a GiST index exists on driver_location, When tracking queries run, Then performance is optimal
- [ ] Given an order is accepted, When assignment created, Then accepted_at timestamp is set

#### Domain Constraints
- **Affected statuses**: Created when order transitions from 'open' to 'accepted'
- **User roles**: Driver
- **Map implications**: Driver location shown in real-time on customer's map
- **AI feature**: Location history used for AI ETA predictions

#### Technical Notes
- Migration: `db/migrate/006_create_assignments.rb`
- Model: `app/models/assignment.rb`
- Columns: id, order_id (FK), driver_id (FK), accepted_at, driver_location (st_point), last_location_updated_at, cached_eta_seconds, location_stale, timestamps
- Unique index: `add_index :assignments, :order_id, unique: true`
- Spatial index: `add_index :assignments, :driver_location, using: :gist`
- Association: belongs_to :delivery_order, belongs_to :driver (class_name: 'User')

#### Priority: Must
#### Story Points: 2

---

### [STORY-007] Create Notifications Table
**As a** User (Customer or Driver)
**I want** to receive notifications about order events
**So that** I stay informed about delivery status

#### Acceptance Criteria
- [ ] Given a notification is created, When saved, Then user and order are properly linked
- [ ] Given notification_type is set, When saved, Then only valid enum values are accepted
- [ ] Given is_read is false, When user views notification, Then it's marked as read
- [ ] Given is_expired is true, When notifications are fetched, Then expired ones are excluded
- [ ] Given an order status changes, When notification is created, Then message reflects the change

#### Domain Constraints
- **Affected statuses**: Notifications created on all status transitions
- **User roles**: Customer, Driver
- **Map implications**: Notifications may trigger map view updates
- **AI feature**: Notification text may include AI-generated ETA narratives

#### Technical Notes
- Migration: `db/migrate/007_create_notifications.rb`
- Model: `app/models/notification.rb`
- Columns: id, user_id (FK), order_id (FK), notification_type (enum), message, is_read, is_expired, timestamps
- Notification types: new_order, order_accepted, status_update, delivery_complete, payment_authorized, payment_captured
- Scope: `scope :unread, -> { where(is_read: false, is_expired: false) }`
- Workers: NotificationDispatchWorker, NotificationExpiryTask

#### Priority: Must
#### Story Points: 2

---

### [STORY-008] Create Payments Table
**As a** System
**I want** to track payment lifecycle for each order
**So that** financial transactions are properly recorded

#### Acceptance Criteria
- [ ] Given a payment is created, When order is accepted, Then status is 'authorized'
- [ ] Given a payment is captured, When delivery completes, Then status is 'captured'
- [ ] Given amounts are in cents, When stored, Then no floating-point errors occur
- [ ] Given gateway_payment_id exists, When gateway responds, Then external reference is stored
- [ ] Given metadata is JSONB, When gateway data is stored, Then it's queryable
- [ ] Given timestamps exist, When payment events occur, Then audit trail is maintained

#### Domain Constraints
- **Affected statuses**: Authorized on 'accepted', captured on 'completed', refunded on 'cancelled'
- **User roles**: Customer (payer), Driver (earner)
- **Map implications**: Payment status may affect map feature availability
- **AI feature**: Payment amounts used in AI pricing models

#### Technical Notes
- Migration: `db/migrate/008_create_payments.rb`
- Model: `app/models/payment.rb`
- Columns: id, delivery_order_id (FK), customer_id (FK), driver_id (FK, nullable), amount_cents, currency, status (enum), gateway_provider, gateway_payment_id, authorized_at, captured_at, refunded_at, metadata (jsonb), timestamps
- Status enum: pending, authorized, captured, refunded, voided, failed
- Workers: PaymentAuthorizationWorker, PaymentCaptureWorker, PaymentRefundWorker

#### Priority: Must
#### Story Points: 2

---

### [STORY-009] Create Payment Methods Table
**As a** Customer
**I want** my payment methods stored securely
**So that** I can pay for deliveries without re-entering card details

#### Acceptance Criteria
- [ ] Given a payment method is created, When saved, Then gateway_token is encrypted at rest
- [ ] Given card details are tokenized, When stored, Then only last_four and brand are visible
- [ ] Given is_default is true, When multiple methods exist, Then only one is default
- [ ] Given expires_at is past, When payment is attempted, Then expired cards are rejected
- [ ] Given gateway_provider is set, When processing, Then correct adapter is used

#### Domain Constraints
- **Affected statuses**: Required before order can transition from 'processing' to 'open'
- **User roles**: Customer
- **Map implications**: N/A
- **AI feature**: N/A

#### Technical Notes
- Migration: `db/migrate/009_create_payment_methods.rb`
- Model: `app/models/payment_method.rb`
- Columns: id, user_id (FK), gateway_provider, gateway_token (encrypted), card_last_four, card_brand, is_default, expires_at, timestamps
- Encryption: `encrypts :gateway_token`
- Validation: Only one default per user
- Security: PCI DSS compliance via tokenization

#### Priority: Must
#### Story Points: 2

---

### [STORY-010] Create Driver Earnings Table
**As a** Driver
**I want** my earnings tracked per delivery
**So that** I understand my income after platform fees

#### Acceptance Criteria
- [ ] Given a delivery is completed, When payment is captured, Then earning record is created
- [ ] Given platform fee is 15%, When calculated, Then net_amount = gross - (gross * 0.15)
- [ ] Given amounts are in cents, When stored, Then precision is maintained
- [ ] Given paid_out_at is null, When earnings are pending, Then payout status is clear
- [ ] Given a driver views earnings, When filtered by date, Then accurate totals are shown

#### Domain Constraints
- **Affected statuses**: Created when order reaches 'completed' status
- **User roles**: Driver
- **Map implications**: N/A
- **AI feature**: Earning patterns used in AI order recommendations

#### Technical Notes
- Migration: `db/migrate/010_create_driver_earnings.rb`
- Model: `app/models/driver_earning.rb`
- Columns: id, driver_id (FK), payment_id (FK), delivery_order_id (FK), gross_amount_cents, platform_fee_cents, net_amount_cents, paid_out_at, timestamps
- Calculation: Platform fee from PLATFORM_FEE_PERCENT env var
- Scope: `scope :unpaid, -> { where(paid_out_at: nil) }`

#### Priority: Must
#### Story Points: 1

---

### [STORY-011] Create Consents Table
**As a** User
**I want** my data processing consents recorded
**So that** the platform complies with GDPR/LGPD requirements

#### Acceptance Criteria
- [ ] Given a consent is granted, When saved, Then granted_at timestamp is set
- [ ] Given a consent is revoked, When saved, Then new record with revoked_at is created
- [ ] Given consent is append-only, When history is checked, Then full audit trail exists
- [ ] Given purpose is an enum, When set, Then only valid purposes are accepted
- [ ] Given IP and user agent are stored, When consent given, Then context is preserved

#### Domain Constraints
- **Affected statuses**: Location tracking consent required for 'pickup_in_progress' and 'in_transit'
- **User roles**: Customer, Driver
- **Map implications**: Location consent required for GPS tracking
- **AI feature**: Data processing consent for AI features

#### Technical Notes
- Migration: `db/migrate/011_create_consents.rb`
- Model: `app/models/consent.rb`
- Columns: id, user_id (FK), purpose (enum), granted_at, revoked_at, ip_address, user_agent, timestamps
- Purpose enum: terms_of_service, location_tracking, payment_processing, marketing
- Pattern: Append-only, never update records
- Query: Current state = most recent record per purpose

#### Priority: Should
#### Story Points: 2

---

### [STORY-012] Create Sessions Table
**As a** System
**I want** user sessions tracked
**So that** Rails 8 authentication works properly

#### Acceptance Criteria
- [ ] Given a user signs in, When session is created, Then IP and user agent are stored
- [ ] Given a session exists, When user accesses app, Then authentication succeeds
- [ ] Given a user signs out, When session is destroyed, Then access is revoked
- [ ] Given multiple sessions exist, When listed, Then all active sessions are shown

#### Domain Constraints
- **Affected statuses**: N/A - authentication layer
- **User roles**: Customer, Driver
- **Map implications**: Authentication required for all map features
- **AI feature**: N/A

#### Technical Notes
- Migration: `db/migrate/012_create_sessions.rb`
- Model: `app/models/session.rb`
- Columns: id, user_id (FK), ip_address, user_agent, created_at
- Rails 8 built-in authentication model
- Used by Current.user singleton

#### Priority: Must
#### Story Points: 1

---

### [STORY-013] Model Validations and Associations
**As a** System
**I want** proper ActiveRecord models with validations
**So that** data integrity is enforced at the application level

#### Acceptance Criteria
- [ ] Given all models exist, When associations are defined, Then relationships work correctly
- [ ] Given enums are defined, When invalid values are set, Then validation errors occur
- [ ] Given required fields exist, When blank values are saved, Then validation fails
- [ ] Given foreign keys exist, When referenced record is deleted, Then appropriate action occurs
- [ ] Given PII fields are marked, When logged, Then values are filtered

#### Domain Constraints
- **Affected statuses**: All statuses validated through state machine
- **User roles**: All roles
- **Map implications**: Spatial data validations
- **AI feature**: Data quality affects AI accuracy

#### Technical Notes
- All models in `app/models/`
- Key validations:
  - User: validates email uniqueness, has_secure_password
  - DeliveryOrder: validates status transitions, presence of addresses
  - Assignment: validates uniqueness of order_id
  - Payment: validates amount > 0
- Associations follow Rails conventions
- PII filtering: filter_attributes on sensitive models

#### Priority: Must
#### Story Points: 3

---

## Non-Functional Requirements

### Performance
- GiST indexes on all PostGIS geometry columns for < 50ms spatial queries
- Compound indexes on frequently queried combinations (e.g., [user_id, is_read] on notifications)
- Database connection pooling configured for concurrent requests
- Prepared statements enabled for repeated queries

### Security
- PII fields encrypted using Rails `encrypts` directive
- Payment tokens encrypted at rest
- No raw card data stored (PCI DSS compliance)
- Foreign key constraints prevent orphaned records
- Row-level locking for order acceptance (prevent race conditions)

### Data Integrity
- All foreign keys have database-level constraints
- Enum columns use CHECK constraints at database level
- Spatial columns enforce SRID 4326 (standard GPS)
- Timestamps use UTC timezone consistently
- Money amounts stored as integers (cents) to avoid floating-point errors

### Scalability
- Partitioning ready for high-volume tables (notifications, locations)
- Spatial indexes support millions of location records
- JSONB columns for extensible metadata without schema changes

### Maintainability
- Migrations are reversible where possible
- Each migration has a clear single responsibility
- Spatial data uses standard formats (WGS84, GeoJSON)
- Models follow Rails conventions for associations and validations

## Out of Scope

- OSM road network tables (managed by osm2pgrouting, not migrations)
- Payment gateway webhook tables (handled by gateway gems)
- Admin dashboard tables (future enhancement)
- Analytics/reporting tables (future enhancement)
- Driver ratings/reviews (future enhancement)

## Testing Requirements

- Migration rollback tests for all migrations
- Model validation specs with FactoryBot
- Spatial query performance tests
- Encryption/decryption tests for PII fields
- Foreign key constraint tests
- Enum validation tests
- Association tests with Shoulda Matchers

## Timeline & Milestones

### Day 1-2 (Database Foundation)
- Enable PostGIS/pgRouting extensions
- Create core user and authentication tables
- Create delivery order and item tables

### Day 2-3 (Spatial & Assignment)
- Create driver profile with spatial columns
- Create assignment tracking tables
- Add all spatial indexes

### Day 3-4 (Payments & Compliance)
- Create payment and earnings tables
- Create consent and session tables
- Add model validations and associations
- Run full test suite

## Open Questions

1. Should we add a `locations` table to store historical GPS points, or is buffering in `assignments.driver_location` sufficient for MVP?
2. Should driver preferences (beyond radius) be stored in JSONB for flexibility, or as explicit columns?
3. Should we pre-create indexes for common query patterns, or wait for performance profiling?
4. Should notification templates be stored in the database or in code?
5. Should we implement soft deletes for compliance, or rely on the audit log pattern?

## Dependencies

- PostgreSQL 16+ with PostGIS 3.4 and pgRouting
- Rails 8.1.3+ with ActiveRecord
- activerecord-postgis-adapter gem
- Docker environment with PostGIS container running
- Rails app initialized (001-initialize-rails-app)
- Database configuration complete (002-docker-development-environment)

## Risk Mitigation

- **Risk**: PostGIS version incompatibility
  - **Mitigation**: Verify version in migration, provide fallback instructions

- **Risk**: Large spatial data queries slow down
  - **Mitigation**: GiST indexes from day one, query optimization in service objects

- **Risk**: Payment data breach
  - **Mitigation**: Encryption at rest, tokenization only, no raw card data

- **Risk**: Migration failures on production
  - **Mitigation**: Reversible migrations, staging environment testing

## Definition of Done

- [x] All migrations created and tested
- [x] All models created with associations and validations
- [x] PostGIS and pgRouting extensions enabled
- [x] All spatial columns have GiST indexes
- [x] PII fields are encrypted and filtered from logs
- [x] Seeds file creates sample data for all models
- [x] Migration runs cleanly on fresh database
- [ ] All specs pass (model validations, associations)
- [x] Database schema documented in schema.rb
- [ ] Performance benchmarks meet requirements (< 50ms spatial queries)

---

## Implementation Notes (2026-03-30)

### Completed Tasks

#### Migrations Created (11 total)
1. `20260330144808_enable_postgres_extensions.rb` - PostGIS and pgRouting extensions (pre-existing)
2. `20260330164646_create_users.rb` - User accounts with OAuth support
3. `20260330164715_create_driver_profiles.rb` - Driver profiles with spatial location
4. `20260330164716_create_delivery_orders.rb` - Orders with pickup/dropoff locations and route geometry
5. `20260330164717_create_order_items.rb` - Line items for orders
6. `20260330164718_create_assignments.rb` - Driver-order assignments with real-time location tracking
7. `20260330164720_create_notifications.rb` - User notifications
8. `20260330164726_create_payments.rb` - Payment transactions with JSONB metadata
9. `20260330164728_create_payment_methods.rb` - Tokenized payment methods
10. `20260330164729_create_driver_earnings.rb` - Driver earnings after platform fee
11. `20260330164730_create_consents.rb` - GDPR/LGPD consent tracking
12. `20260330164731_create_sessions.rb` - Rails 8 authentication sessions

#### Models Implemented (12 total)
- `User` - with `has_secure_password`, role enum (customer/driver), PII encryption, Anonymizable, DataExportable, HasConsent concerns
- `DriverProfile` - with spatial location (st_point), vehicle_type enum, availability scopes
- `DeliveryOrder` - with pickup/dropoff locations (st_point), route_geometry (line_string), status enum (9 states), encrypted addresses
- `OrderItem` - with size enum (small/medium/large/bulk)
- `Assignment` - with driver location tracking (st_point), location staleness monitoring
- `Notification` - with notification_type enum (6 types), unread/active scopes
- `Payment` - with status enum (6 states), amount in cents, JSONB metadata
- `PaymentMethod` - with encrypted gateway_token, card display info
- `DriverEarning` - with platform fee calculation helpers
- `Consent` - with purpose enum (4 types), append-only audit pattern
- `Session` - Rails 8 authentication
- `Current` - ActiveSupport::CurrentAttributes for request context

#### Concerns Implemented (4 total)
- `Anonymizable` - GDPR right to be forgotten
- `DataExportable` - GDPR data portability
- `HasConsent` - Consent management helpers
- `Authentication` - Rails 8 authentication concern for controllers

#### Encryption Configuration
- Generated encryption keys via `bin/rails db:encryption:init`
- Added to credentials: `active_record_encryption.primary_key`, `deterministic_key`, `key_derivation_salt`
- User model: `encrypts :name`, `encrypts :email, deterministic: true, downcase: true`
- DeliveryOrder model: `encrypts :pickup_address`, `dropoff_address`, `description`
- PaymentMethod model: `encrypts :gateway_token`

#### Spatial Features
- All spatial columns use SRID 4326 (WGS84 standard GPS coordinates)
- GiST indexes on all spatial columns for optimal query performance:
  - `driver_profiles.location`
  - `delivery_orders.pickup_location`, `dropoff_location`, `route_geometry`
  - `assignments.driver_location`
- Helper methods for coordinate conversion: `set_location(lat, lng)`, `coordinates`, etc.

#### Seeds
- Sample customer and driver accounts
- Driver profile with San Francisco location (37.7749, -122.4194)
- Consent records for all required purposes

### Known Issues / TODOs
1. RSpec specs not yet written for models (next step)
2. Performance benchmarks not yet run
3. Payment gateway adapters not yet implemented (separate ticket)
4. State machine gem (AASM) not yet added for order status transitions
5. Background workers not yet implemented (Solid Queue configuration pending)

### Technical Decisions
1. **Encryption**: Using Rails 8 built-in encryption instead of `attr_encrypted` gem for better integration
2. **Spatial Data**: activerecord-postgis-adapter handles PostGIS geography types seamlessly
3. **Money Handling**: All monetary amounts stored as integers (cents) to avoid floating-point precision errors
4. **Consent Pattern**: Append-only records for full audit trail, never update existing consents
5. **Session Storage**: Database-backed sessions via Rails 8 authentication (not cookie-based)

### Next Steps
1. Implement RSpec model specs with FactoryBot factories
2. Add AASM gem and define order status state machine
3. Create service objects for order creation, assignment, payment processing
4. Implement background workers for geocoding, routing, notifications
5. Add payment gateway adapters (MockAdapter for MVP, StripeAdapter for production)