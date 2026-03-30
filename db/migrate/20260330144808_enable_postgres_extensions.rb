class EnablePostgresExtensions < ActiveRecord::Migration[8.1]
  def up
    # Use raw SQL with IF NOT EXISTS for more resilient extension creation
    # This allows migrations to run even if extensions are partially installed
    execute "CREATE EXTENSION IF NOT EXISTS plpgsql"
    execute "CREATE EXTENSION IF NOT EXISTS hstore"

    # Create PostGIS without CASCADE to avoid tiger_geocoder tables
    # Tiger geocoder creates tables that cause issues with schema loading
    execute "CREATE EXTENSION IF NOT EXISTS postgis"
    execute "CREATE EXTENSION IF NOT EXISTS postgis_raster"

    # Note: pgrouting is not included as it's not available in standard PostGIS images
    # and is not needed for MVP. Add it later if routing functionality is required.
  end

  def down
    # Clean up extensions in reverse order
    execute "DROP EXTENSION IF EXISTS postgis_raster"
    execute "DROP EXTENSION IF EXISTS postgis CASCADE"
    execute "DROP EXTENSION IF EXISTS hstore"
    # Don't drop plpgsql as it's needed by PostgreSQL
  end
end
