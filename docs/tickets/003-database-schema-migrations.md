# Ticket 003: Database Schema & Migrations

## Description
Create all ActiveRecord migrations and models per PRD section 13 (Data Model). This includes enabling PostGIS/pgRouting extensions and creating tables for Users, DriverProfile, DeliveryOrder, OrderItem, Assignment, and Notification — all with appropriate PostGIS spatial columns and GiST indexes.

## Acceptance Criteria
- [ ] Migration enables PostGIS extension (`CREATE EXTENSION IF NOT EXISTS postgis`)
- [ ] Migration enables pgRouting extension (`CREATE EXTENSION IF NOT EXISTS pgrouting`)
- [ ] `users` table: id, name, email, password_digest, role (enum: customer/driver), provider, uid, timestamps
- [ ] `driver_profiles` table: user_id (FK), vehicle_type, is_available, radius_preference, location (PostGIS Point 4326), last_location_updated_at
- [ ] `delivery_orders` table: id, created_by (FK), status (enum with all 9 states), pickup_address, dropoff_address, pickup_location (PostGIS Point), dropoff_location (PostGIS Point), route_geometry (PostGIS LineString), estimated_distance_meters, estimated_duration_seconds, scheduled_at, price, estimated_price, description, delivery_type, timestamps
- [ ] `order_items` table: id, order_id (FK), name, quantity, size (enum), timestamps
- [ ] `assignments` table: id, order_id (FK), driver_id (FK), accepted_at, driver_location (PostGIS Point), last_location_updated_at, cached_eta_seconds, location_stale (boolean), timestamps
- [ ] `notifications` table: id, user_id (FK), order_id (FK), notification_type, message, is_read, is_expired, timestamps
- [ ] GiST spatial indexes on ALL geometry columns (driver_profiles.location, delivery_orders.pickup_location, delivery_orders.dropoff_location, delivery_orders.route_geometry, assignments.driver_location)
- [ ] All ActiveRecord models created with associations, enums, and basic validations
- [ ] `rails db:migrate` runs cleanly on a fresh database

## Dependencies
- **001** — Rails app must exist
- **002** — PostgreSQL + PostGIS must be running

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `db/migrate/001_enable_postgis.rb` — enable PostGIS and pgRouting extensions
- `db/migrate/002_create_users.rb`
- `db/migrate/003_create_driver_profiles.rb`
- `db/migrate/004_create_delivery_orders.rb`
- `db/migrate/005_create_order_items.rb`
- `db/migrate/006_create_assignments.rb`
- `db/migrate/007_create_notifications.rb`
- `app/models/user.rb` — `has_secure_password`, role enum, associations (`has_one :driver_profile`, `has_many :delivery_orders`)
- `app/models/driver_profile.rb` — belongs_to user, vehicle_type enum, scopes for available drivers
- `app/models/delivery_order.rb` — status enum (processing/open/accepted/pickup_in_progress/in_transit/completed/cancelled/expired/error), associations
- `app/models/order_item.rb` — size enum (small/medium/large/bulk), belongs_to delivery_order
- `app/models/assignment.rb` — belongs_to delivery_order and driver
- `app/models/notification.rb` — notification_type enum, belongs_to user and delivery_order

## Technical Notes
- Use `activerecord-postgis-adapter` column types: `st_point` for Point columns, `line_string` for LineString
- All spatial columns should use SRID 4326 (WGS84 — standard GPS coordinates)
- Status enum on DeliveryOrder: `processing`, `open`, `accepted`, `pickup_in_progress`, `in_transit`, `completed`, `cancelled`, `expired`, `error`
- Vehicle type enum: `motorcycle`, `car`, `van`, `truck`
- Size enum on OrderItem: `small`, `medium`, `large`, `bulk`
- Delivery type enum: `immediate`, `scheduled`
- Add `null: false` constraints on required fields
- Add foreign key constraints on all FK columns
- `password_digest` column on `users` is required by Rails 8 `has_secure_password` (ticket 004 configures the auth generator, but the column must exist in the schema)
- The OSM road network tables (ways, ways_vertices_pgr) are managed by `osm2pgrouting` — do NOT create migrations for these
