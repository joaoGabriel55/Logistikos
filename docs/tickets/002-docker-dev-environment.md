# Ticket 002: Docker Development Environment

## Description
Create Docker Compose configuration for the development environment with PostgreSQL 16 + PostGIS + pgRouting. This provides the database and spatial query infrastructure that all backend features depend on. Include `.env.example` with all required environment variables.

## Acceptance Criteria
- [ ] `docker-compose.yml` defines PostgreSQL 16 + PostGIS + pgRouting service with volume mount and health check
- [ ] `docker-compose up` starts the database service successfully
- [ ] PostgreSQL is accessible on port 5432, PostGIS extension can be enabled (`CREATE EXTENSION postgis`)
- [ ] pgRouting extension can be enabled (`CREATE EXTENSION pgrouting`)
- [ ] `config/database.yml` is configured to use the Docker PostgreSQL with PostGIS adapter
- [ ] `.env.example` documents all required environment variables per PRD section 17
- [ ] Rails can connect to the database (`rails db:create` works)

## Dependencies
- **001** — Project must be scaffolded first

## Estimated Effort
**S** (1-2 hours)

## Files to Create/Modify
- `docker-compose.yml` — PostgreSQL+PostGIS+pgRouting service definition
- `.env.example` — `DATABASE_URL`, `MAPBOX_TOKEN`, `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `SECRET_KEY_BASE`, `ANTHROPIC_API_KEY`, `PAYMENT_GATEWAY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`, `PLATFORM_FEE_PERCENT`, `RAILS_ENV`
- `config/database.yml` — configure `postgis` adapter, reference env vars
- `Gemfile` — confirm `activerecord-postgis-adapter` gem is present

## Technical Notes
- Use the `postgis/postgis:16-3.4` Docker image which includes PostGIS
- pgRouting may need a separate image or a custom Dockerfile extending the PostGIS image — check `pgrouting/pgrouting` images
- Alternative: use `kartoza/postgis` image which bundles PostGIS + pgRouting
- The `activerecord-postgis-adapter` gem replaces the standard `pg` adapter in `database.yml`
- Do NOT include actual secret values in `.env.example` — use placeholder descriptions
- `PAYMENT_GATEWAY` defaults to `mock` — the MockAdapter is the MVP default and requires no external credentials for development
- `STRIPE_PUBLISHABLE_KEY` and `STRIPE_WEBHOOK_SECRET` are only needed when `PAYMENT_GATEWAY=stripe` (not required for MVP/dev)
- `STRIPE_SECRET_KEY` is stored in Rails credentials (`bin/rails credentials:edit`), NOT as an environment variable
- `PLATFORM_FEE_PERCENT` defaults to `15` (driver earnings platform fee percentage)
- **Note:** Redis is NOT needed — Solid Queue (Rails 8 built-in) uses the database for background jobs
