# PostGIS Setup - Implementation Summary

## Problem Statement

CI was failing with PostGIS extension setup errors:
- `PG::DuplicateSchema: ERROR: schema "topology" already exists`
- `PG::FeatureNotSupported: ERROR: extension "pgrouting" is not available`
- Inconsistent Docker images between development (Kartoza) and CI (official PostGIS)

## Solution Implemented

Migrated to the **official docker-postgis project** with graceful handling of optional extensions.

## What Changed

### 1. Docker Setup (`docker/`)
- **Dockerfile**: Based on `postgis/postgis:16-3.4` with pgRouting added
- **init script**: Auto-creates extensions on first container startup
- Uses official PostGIS Docker images for reliability

### 2. Docker Compose Files
- **docker-compose.yml** (Development): Custom image with pgRouting
- **docker-compose.ci.yml** (Testing): Official image, tmpfs storage, no pgRouting

### 3. Migration Improvements
- Removed manual topology schema creation (let extension handle it)
- Added error handling for optional extensions (pgrouting, postgis_topology, pg_cron)
- Extensions fail gracefully with warnings instead of breaking migrations

### 4. Rake Task Updates
- Separated core extensions (postgis, postgis_raster) from optional (pgrouting)
- Better error messages for missing extensions
- Won't break CI when optional extensions are unavailable

### 5. CI Workflow Cleanup
- Removed redundant `db:postgis:setup` calls
- Simplified to `bin/rails db:create db:migrate`
- No more duplicate extension creation attempts

### 6. Schema File Management
- Cleaned `db/schema.rb` to only include core extensions
- Added comments explaining optional extensions
- Prevents loading failures in environments without pgRouting

### 7. Documentation
- **DOCKER.md**: Comprehensive Docker setup guide
- **CLAUDE.md**: Updated tech stack and commands
- Troubleshooting guides and examples

## Testing Results

### Development Environment ✅
```bash
$ docker compose up -d
$ bin/rails db:migrate

Extensions installed:
- postgis 3.4.3
- postgis_raster 3.4.3
- pgrouting 3.8.0
- postgis_topology 3.4.3
- hstore 1.8
```

### CI/Test Environment ✅
```bash
$ docker compose -f docker-compose.ci.yml up -d
$ RAILS_ENV=test bin/rails db:create db:migrate

Extensions installed:
- postgis 3.4.3
- postgis_raster 3.4.3
(pgrouting gracefully skipped with warning)
```

## Key Benefits

1. **Official Image**: Uses `postgis/postgis` from docker-postgis project
2. **Reliable**: Same base image in dev and CI
3. **Flexible**: pgRouting in dev, optional in CI/prod
4. **Idempotent**: Extensions created once, safely
5. **Fast CI**: tmpfs storage, no redundant setup
6. **Production Ready**: Works with managed PostgreSQL services

## Migration Strategy

### Development (Full Features)
```ruby
# All extensions enabled including pgRouting
execute "CREATE EXTENSION IF NOT EXISTS pgrouting"
execute "CREATE EXTENSION IF NOT EXISTS postgis_topology"
```

### CI/Production (Core Only)
```ruby
# Optional extensions wrapped in begin/rescue
begin
  execute "CREATE EXTENSION IF NOT EXISTS pgrouting"
rescue ActiveRecord::StatementInvalid => e
  Rails.logger.warn "Skipping pgrouting extension: #{e.message}"
end
```

## Architecture Decision

**Why not SQL structure dumps?**
- Ruby schema.rb works fine for our needs
- pg_dump version mismatches between local (v14) and Docker (v16)
- Manual schema.rb management is simpler for now
- Will migrate to SQL dumps when we add spatial columns

**Why separate compose files?**
- Development needs full feature set (pgRouting for route optimization)
- CI needs fast, minimal setup (tmpfs, no build time)
- Matches actual GitHub Actions environment exactly

## Production Deployment

For production, use managed PostgreSQL with PostGIS:
- AWS RDS: PostgreSQL with PostGIS extension
- Google Cloud SQL: PostgreSQL with PostGIS support
- Heroku Postgres: PostGIS enabled
- DigitalOcean: Managed PostgreSQL + PostGIS

Migrations automatically handle missing optional extensions.

## Files Changed

```
M  .github/workflows/ci.yml          # Simplified database setup
M  CLAUDE.md                         # Updated tech stack docs
M  config/application.rb             # Schema dump config
M  db/migrate/*_enable_*.rb          # Graceful extension handling
M  db/schema.rb                      # Core extensions only
M  docker-compose.yml                # Official PostGIS + pgRouting
M  lib/tasks/db_postgis.rake         # Better error handling
A  DOCKER.md                         # Comprehensive Docker guide
A  docker-compose.ci.yml             # CI test environment
A  docker/postgres/Dockerfile        # Custom PostGIS + pgRouting
A  docker/postgres/initdb.d/*.sh     # Auto-initialization script
```

## References

- [postgis/docker-postgis](https://github.com/postgis/docker-postgis)
- [PostGIS Documentation](https://postgis.net/documentation/)
- [pgRouting Documentation](https://docs.pgrouting.org/)

---

**Date**: 2026-03-30
**Status**: ✅ Complete and tested
