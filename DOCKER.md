# Docker Setup for Logistikos

This document describes the Docker-based development and testing environment for Logistikos.

## Overview

We use the **official postgis/postgis** Docker image as our base, with a custom build that adds pgRouting support for route optimization features.

- **Official Image**: [postgis/postgis](https://hub.docker.com/r/postgis/postgis) from the [docker-postgis project](https://github.com/postgis/docker-postgis)
- **Base**: PostgreSQL 16 + PostGIS 3.4
- **Custom Addition**: pgRouting for route calculations

## Quick Start

### Development Environment

```bash
# Start PostgreSQL with PostGIS + pgRouting
docker compose up -d

# Wait for PostgreSQL to be ready
docker compose ps

# Setup database
bin/rails db:create db:migrate

# Stop services
docker compose down

# Stop and remove volumes (clean slate)
docker compose down -v
```

### Testing Environment (CI-like)

```bash
# Use CI configuration (no pgRouting, uses tmpfs)
docker compose -f docker-compose.ci.yml up -d

# Run tests
RAILS_ENV=test bin/rails db:create db:migrate
bundle exec rspec

# Cleanup
docker compose -f docker-compose.ci.yml down
```

## Configuration Files

### docker-compose.yml (Development)

- **Purpose**: Local development environment
- **Image**: Custom-built from `docker/postgres/Dockerfile`
- **Includes**: PostGIS + pgRouting
- **Storage**: Named volume `postgres_data` (persistent)
- **Port**: 5432
- **Auto-initialization**: Extensions created on first startup via `/docker-entrypoint-initdb.d/`

### docker-compose.ci.yml (CI/Testing)

- **Purpose**: CI-like testing environment
- **Image**: Official `postgis/postgis:16-3.4` (no build needed)
- **Includes**: PostGIS only (pgRouting optional)
- **Storage**: tmpfs (fast, ephemeral)
- **Port**: 5432

## Custom PostgreSQL Image

### docker/postgres/Dockerfile

Builds on the official PostGIS image to add pgRouting:

```dockerfile
FROM postgis/postgis:16-3.4
# Installs: postgresql-16-pgrouting, postgresql-16-pgrouting-scripts
```

### docker/postgres/initdb.d/00-init-extensions.sh

Initialization script that runs once when the container is first created. Creates all required extensions:

- `plpgsql` (procedural language)
- `hstore` (key-value store)
- `postgis` (spatial functions)
- `postgis_raster` (raster support)
- `pgrouting` (routing algorithms)
- `postgis_topology` (topology support)

## Environment Variables

Set these in your `.env` file (see `.env.example`):

```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=logistikos_development
DATABASE_URL=postgis://postgres:postgres@localhost:5432/logistikos_development
```

## Rebuilding the Custom Image

If you modify the Dockerfile or change versions:

```bash
# Rebuild the custom PostgreSQL image
docker compose build postgres

# Or force rebuild without cache
docker compose build --no-cache postgres

# Start with rebuilt image
docker compose up -d
```

## Troubleshooting

### Extensions Not Available

If you see errors about missing extensions:

```bash
# Check what's installed
docker compose exec postgres psql -U postgres -d logistikos_development -c "SELECT extname, extversion FROM pg_extension;"

# Check PostGIS version
docker compose exec postgres psql -U postgres -d logistikos_development -c "SELECT PostGIS_Version();"

# Check pgRouting version (only in development setup)
docker compose exec postgres psql -U postgres -d logistikos_development -c "SELECT pgr_version();"
```

### Reset Database

```bash
# Stop containers
docker compose down

# Remove volumes (deletes all data!)
docker volume rm logistikos_postgres_data

# Start fresh
docker compose up -d
bin/rails db:create db:migrate db:seed
```

### Permission Issues

If you encounter permission errors with volumes:

```bash
# Check volume ownership
docker compose exec postgres ls -la /var/lib/postgresql/data

# If needed, recreate volume with proper permissions
docker compose down -v
docker volume create logistikos_postgres_data
docker compose up -d
```

### CI Differences

GitHub Actions CI uses the official `postgis/postgis:16-3.4` image directly without pgRouting. Our migrations handle this gracefully:

- **Development**: All extensions including pgRouting
- **CI**: Core PostGIS extensions only
- **Migration Strategy**: Optional extensions fail gracefully with warnings

## Production Deployment

For production, use managed PostgreSQL with PostGIS:

- **AWS RDS**: PostgreSQL with PostGIS extension
- **Google Cloud SQL**: PostgreSQL with PostGIS support
- **Heroku Postgres**: Add PostGIS buildpack
- **DigitalOcean**: Managed PostgreSQL with PostGIS

Install extensions via migration on first deployment:

```bash
# Rails migrations handle extension setup automatically
bin/rails db:migrate
```

## Official Documentation

- [postgis/docker-postgis GitHub](https://github.com/postgis/docker-postgis)
- [PostGIS Documentation](https://postgis.net/documentation/)
- [pgRouting Documentation](https://docs.pgrouting.org/)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)

## Alternative: Use Official Image Without Building

If you don't need pgRouting in development, edit `docker-compose.yml`:

```yaml
services:
  postgres:
    # Comment out the build section
    image: postgis/postgis:16-3.4  # Use official image directly
    # ... rest of configuration
```

Then migrations will skip pgRouting with a warning (same as CI).
