# Infrastructure Specification: Docker Development Environment

**Ticket ID**: 002
**Type**: Infrastructure/DevOps
**Priority**: Must Have
**Estimated Effort**: S (1-2 hours)

## Overview

Configure Docker Compose for local development with PostgreSQL 16 + PostGIS + pgRouting extensions. This provides the spatial database infrastructure required by all geo-enabled features in Logistikos (geocoding, routing, radius matching, distance calculations).

## Requirements Summary

### Database Infrastructure
- PostgreSQL 16 with PostGIS 3.4+ and pgRouting extensions
- Accessible on standard PostgreSQL port (5432)
- Persistent data via Docker volumes
- Health checks for container readiness

### Rails Integration
- Configure `activerecord-postgis-adapter` in `database.yml`
- Environment-based database connection
- Support for spatial column types and queries

### Environment Configuration
- Document all required environment variables in `.env.example`
- Use placeholder values, not actual secrets
- Support both development and production configurations

## Acceptance Criteria

- [ ] `docker-compose.yml` defines PostgreSQL 16 + PostGIS + pgRouting service with volume mount and health check
- [ ] `docker-compose up` starts the database service successfully
- [ ] PostgreSQL is accessible on port 5432, PostGIS extension can be enabled (`CREATE EXTENSION postgis`)
- [ ] pgRouting extension can be enabled (`CREATE EXTENSION pgrouting`)
- [ ] `config/database.yml` is configured to use the Docker PostgreSQL with PostGIS adapter
- [ ] `.env.example` documents all required environment variables per PRD section 17
- [ ] Rails can connect to the database (`rails db:create` works)

## Technical Constraints

### Docker Image Selection
- **Recommended**: `kartoza/postgis` image (bundles PostgreSQL + PostGIS + pgRouting)
- **Alternative**: `postgis/postgis:16-3.4` base + manual pgRouting installation
- Must support both PostGIS and pgRouting extensions without additional setup

### Rails Configuration
- Must use `postgis` adapter (not standard `postgresql`) in `database.yml`
- Requires `activerecord-postgis-adapter` gem in Gemfile
- Database URL pattern: `postgis://user:password@host:port/database`

### Background Jobs
- **No Redis required** — Solid Queue uses the database for job storage
- Single PostgreSQL instance serves both application data and job queue

## Deliverables

### 1. `docker-compose.yml`
```yaml
services:
  postgres:
    image: kartoza/postgis:16-3.4
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER
      - POSTGRES_PASSWORD
      - POSTGRES_DB
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER"]
      interval: 5s
      timeout: 5s
      retries: 5
```

### 2. `.env.example`
Must document all variables from PRD section 17:

**Database**
- `DATABASE_URL` — PostgreSQL connection string
- `POSTGRES_USER` — Database username
- `POSTGRES_PASSWORD` — Database password
- `POSTGRES_DB` — Database name

**External Services**
- `MAPBOX_TOKEN` — Mapbox GL JS API token for map rendering
- `ANTHROPIC_API_KEY` — Claude API key for AI features
- `GOOGLE_OAUTH_CLIENT_ID` — Google OAuth client ID
- `GOOGLE_OAUTH_CLIENT_SECRET` — Google OAuth client secret

**Payments**
- `PAYMENT_GATEWAY` — Payment adapter selection (default: `mock`)
- `STRIPE_PUBLISHABLE_KEY` — Stripe public key (only when PAYMENT_GATEWAY=stripe)
- `STRIPE_WEBHOOK_SECRET` — Stripe webhook endpoint secret (only when PAYMENT_GATEWAY=stripe)
- `PLATFORM_FEE_PERCENT` — Platform fee percentage (default: 15)

**Rails**
- `SECRET_KEY_BASE` — Rails encryption key
- `RAILS_ENV` — Environment (development/test/production)

### 3. `config/database.yml`
```yaml
default: &default
  adapter: postgis
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  url: <%= ENV.fetch("DATABASE_URL", "postgis://postgres:password@localhost:5432/logistikos_development") %>

test:
  <<: *default
  url: <%= ENV.fetch("DATABASE_URL", "postgis://postgres:password@localhost:5432/logistikos_test") %>

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

### 4. Gemfile Verification
Confirm presence of:
- `gem 'pg', '~> 1.5'`
- `gem 'activerecord-postgis-adapter', '~> 10.0'`

## Dependencies

- **Ticket 001**: Rails project must be scaffolded first
- Gems: `pg` and `activerecord-postgis-adapter` must be installed

## Verification Steps

1. Run `docker-compose up -d` to start PostgreSQL container
2. Verify container health: `docker-compose ps` shows "healthy" status
3. Test Rails connection: `bin/rails db:create` succeeds
4. Enable extensions: `bin/rails db:migrate` can create spatial columns
5. Verify PostGIS: `bin/rails c` then `ActiveRecord::Base.connection.execute("SELECT PostGIS_version();")`
6. Verify pgRouting: `ActiveRecord::Base.connection.execute("SELECT pgr_version();")`

## Notes

- **No Redis/Sidekiq** — Solid Queue (Rails 8 default) uses PostgreSQL for job storage
- **Mock Payment Gateway** — Default `PAYMENT_GATEWAY=mock` requires no external credentials
- **Stripe credentials** — `STRIPE_SECRET_KEY` stored in Rails credentials, not environment variables
- **Production deployment** — This Docker setup is for development; production uses external Supabase PostgreSQL