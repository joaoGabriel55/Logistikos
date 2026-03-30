You are a DevOps engineer setting up or verifying the **Logistikos** development environment. This command handles the full project setup including the spatial data pipeline.

## Setup Pipeline

Execute each step sequentially. Report status after each step.

### Step 1: Database & Extensions
1. Verify PostgreSQL is running
2. Verify PostGIS extension is enabled: `SELECT PostGIS_Version();`
3. Verify pgRouting extension is enabled: `SELECT pgr_version();`
4. If missing, enable them:
   ```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
   CREATE EXTENSION IF NOT EXISTS pgrouting;
   ```

### Step 2: Rails Database Setup
1. Run `bundle install` to ensure all gems are installed
2. Run `bundle exec rails db:create` (if database doesn't exist)
3. Run `bundle exec rails db:migrate`
4. Verify `activerecord-postgis-adapter` is working by checking spatial columns exist

### Step 3: OSM Road Network Import
1. Check if the `ways` and `ways_vertices_pgr` tables exist (pgRouting road network)
2. If missing, import OSM data for the operational region:
   ```bash
   osm2pgrouting --f <region>.osm --conf mapconfig.xml --dbname logistikos_development --clean
   ```
3. Verify road network: `SELECT count(*) FROM ways;` (should have records)
4. Verify vertices: `SELECT count(*) FROM ways_vertices_pgr;`

### Step 4: Spatial Indexes
Ensure GiST indexes exist on all geometry columns:
- `driver_profiles.location`
- `delivery_orders.pickup_location`
- `delivery_orders.dropoff_location`
- `delivery_orders.route_geometry`
- `assignments.driver_location`
- `ways.the_geom` (OSM road network)

### Step 5: Redis & Sidekiq
1. Verify Redis is running: `redis-cli ping` (should return PONG)
2. Verify Sidekiq configuration exists in `config/sidekiq.yml`
3. Verify 3 queues are configured: `critical`, `default`, `maintenance`

### Step 6: Frontend Build
1. Run `npm install` (or `yarn install`) for frontend dependencies
2. Verify Vite config exists (`vite.config.ts`)
3. Run a test build: `npx vite build` (or the configured build command)

### Step 7: Smoke Tests
1. Run `bundle exec rspec` to verify test suite passes
2. Run a smoke spatial query:
   ```sql
   SELECT ST_AsText(ST_MakePoint(-34.87, -8.05));
   ```
3. Run a smoke pgRouting query (if OSM data is imported):
   ```sql
   SELECT * FROM pgr_dijkstra('SELECT gid AS id, source, target, cost FROM ways', 1, 2);
   ```

### Step 8: Seed Data (Optional)
If setting up for demo/development:
1. Run `bundle exec rails db:seed` for demo data

## Environment Variables
Verify these are set (check `.env` or `.env.example`):
- `DATABASE_URL` — PostgreSQL connection
- `REDIS_URL` — Redis connection
- `MAPBOX_TOKEN` — Mapbox GL JS public token
- `GOOGLE_OAUTH_CLIENT_ID` / `GOOGLE_OAUTH_CLIENT_SECRET`
- `SECRET_KEY_BASE` — Rails secret
- `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` — for AI features
- `PAYMENT_GATEWAY` — payment gateway provider (default: `mock`; set to `stripe` for production)
- `STRIPE_PUBLISHABLE_KEY` — Stripe publishable key (frontend tokenization) — **not required when using MockAdapter**
- `STRIPE_WEBHOOK_SECRET` — Stripe webhook signing secret — **not required when using MockAdapter**
- `PLATFORM_FEE_PERCENT` — platform fee for driver earnings (default: `15`)
- `RAILS_ENV` — development/production

> **Note:** `STRIPE_SECRET_KEY` should be in Rails credentials (`bin/rails credentials:edit`), not as an env var. **Not required when using MockAdapter (MVP default).**

Report a summary of all steps with pass/fail status.
