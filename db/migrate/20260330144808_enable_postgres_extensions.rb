class EnablePostgresExtensions < ActiveRecord::Migration[8.1]
  def up
    # Use raw SQL with IF NOT EXISTS for more resilient extension creation
    # This allows migrations to run even if extensions are partially installed
    execute "CREATE EXTENSION IF NOT EXISTS plpgsql"
    execute "CREATE EXTENSION IF NOT EXISTS hstore"
    execute "CREATE EXTENSION IF NOT EXISTS postgis CASCADE"
    execute "CREATE EXTENSION IF NOT EXISTS postgis_raster"
    execute "CREATE EXTENSION IF NOT EXISTS pgrouting"

    # PostGIS topology extension creates its own schema
    execute "CREATE SCHEMA IF NOT EXISTS topology"
    execute "CREATE EXTENSION IF NOT EXISTS postgis_topology SCHEMA topology"

    # pg_cron can only be enabled in one database (configured in postgresql.conf)
    # Skip it in test environment to avoid CI errors
    unless Rails.env.test?
      execute "CREATE EXTENSION IF NOT EXISTS pg_cron SCHEMA pg_catalog"
    end
  end

  def down
    execute "DROP EXTENSION IF EXISTS postgis_topology CASCADE"
    execute "DROP SCHEMA IF EXISTS topology CASCADE"
    execute "DROP EXTENSION IF EXISTS pgrouting"
    execute "DROP EXTENSION IF EXISTS postgis_raster"
    execute "DROP EXTENSION IF EXISTS postgis CASCADE"
    execute "DROP EXTENSION IF EXISTS hstore"
    execute "DROP EXTENSION IF EXISTS pg_cron" unless Rails.env.test?
    # Don't drop plpgsql as it's needed by PostgreSQL
  end
end
