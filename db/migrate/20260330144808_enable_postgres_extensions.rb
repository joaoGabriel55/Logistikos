class EnablePostgresExtensions < ActiveRecord::Migration[8.1]
  def up
    # Core extensions needed for all environments
    enable_extension "plpgsql"
    enable_extension "hstore"
    enable_extension "postgis"
    enable_extension "postgis_raster"
    enable_extension "pgrouting"

    # Create topology schema for PostGIS
    execute "CREATE SCHEMA IF NOT EXISTS topology"
    enable_extension "postgis_topology", schema: "topology"

    # pg_cron can only be enabled in one database (configured in postgresql.conf)
    # Skip it in test environment to avoid CI errors
    unless Rails.env.test?
      enable_extension "pg_cron", schema: "pg_catalog"
    end
  end

  def down
    disable_extension "postgis_topology"
    execute "DROP SCHEMA IF EXISTS topology CASCADE"
    disable_extension "pgrouting"
    disable_extension "postgis_raster"
    disable_extension "postgis"
    disable_extension "hstore"
    disable_extension "pg_cron" unless Rails.env.test?
    disable_extension "plpgsql"
  end
end
