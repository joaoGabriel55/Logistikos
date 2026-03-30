class EnablePostgresExtensions < ActiveRecord::Migration[8.1]
  def up
    # Use raw SQL with IF NOT EXISTS for more resilient extension creation
    # This allows migrations to run even if extensions are partially installed
    execute "CREATE EXTENSION IF NOT EXISTS plpgsql"
    execute "CREATE EXTENSION IF NOT EXISTS hstore"
    execute "CREATE EXTENSION IF NOT EXISTS postgis CASCADE"
    execute "CREATE EXTENSION IF NOT EXISTS postgis_raster"

    # pgrouting may not be available in all PostGIS installations
    begin
      execute "CREATE EXTENSION IF NOT EXISTS pgrouting"
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn "Skipping pgrouting extension: #{e.message}"
    end

    # PostGIS topology extension creates its own schema automatically
    # Don't manually create the schema - let the extension handle it
    begin
      execute "CREATE EXTENSION IF NOT EXISTS postgis_topology"
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn "Skipping postgis_topology extension: #{e.message}"
    end

    # pg_cron can only be enabled in one database (configured in postgresql.conf)
    # Skip it in test environment to avoid CI errors
    unless Rails.env.test?
      begin
        execute "CREATE EXTENSION IF NOT EXISTS pg_cron SCHEMA pg_catalog"
      rescue ActiveRecord::StatementInvalid => e
        Rails.logger.warn "Skipping pg_cron extension: #{e.message}"
      end
    end
  end

  def down
    # Topology extension and schema will be dropped together with CASCADE
    execute "DROP EXTENSION IF EXISTS postgis_topology CASCADE"
    execute "DROP EXTENSION IF EXISTS pgrouting"
    execute "DROP EXTENSION IF EXISTS postgis_raster"
    execute "DROP EXTENSION IF EXISTS postgis CASCADE"
    execute "DROP EXTENSION IF EXISTS hstore"
    execute "DROP EXTENSION IF EXISTS pg_cron" unless Rails.env.test?
    # Don't drop plpgsql as it's needed by PostgreSQL
  end
end
