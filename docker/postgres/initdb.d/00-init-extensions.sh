#!/bin/bash
set -e

# This script runs automatically when the container is first initialized
# Scripts in /docker-entrypoint-initdb.d/ are executed in alphabetical order

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Enable required extensions
    CREATE EXTENSION IF NOT EXISTS plpgsql;
    CREATE EXTENSION IF NOT EXISTS hstore;
    CREATE EXTENSION IF NOT EXISTS postgis CASCADE;
    CREATE EXTENSION IF NOT EXISTS postgis_raster;
    CREATE EXTENSION IF NOT EXISTS pgrouting;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;

    -- Verify installation
    SELECT PostGIS_Version();
    SELECT pgr_version();
EOSQL

echo "PostGIS and pgRouting extensions initialized successfully"
