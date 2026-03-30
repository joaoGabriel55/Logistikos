# Dockerfile for PostgreSQL with PostGIS and pgRouting
# Based on the official postgis/postgis image
# https://github.com/postgis/docker-postgis

ARG POSTGRES_VERSION=16
ARG POSTGIS_VERSION=3.4

FROM postgis/postgis:${POSTGRES_VERSION}-${POSTGIS_VERSION}

# Re-declare ARG after FROM to make it available in this build stage
ARG POSTGRES_VERSION=16

# Install pgrouting
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       postgresql-${POSTGRES_VERSION}-pgrouting \
       postgresql-${POSTGRES_VERSION}-pgrouting-scripts \
    && rm -rf /var/lib/apt/lists/*

# The official postgis/postgis image already includes:
# - PostgreSQL ${POSTGRES_VERSION}
# - PostGIS ${POSTGIS_VERSION}
# - postgis_raster
# - postgis_topology
# We're just adding pgrouting on top

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD pg_isready -U ${POSTGRES_USER:-postgres} || exit 1
