# frozen_string_literal: true

namespace :db do
  namespace :postgis do
    desc "Setup PostGIS extensions for all databases"
    task setup: :environment do
      # Patch create_schema to be idempotent so schema.rb can be loaded against a database
      # that already has the topology schema (e.g. inherited from template1 in the
      # postgis/postgis Docker image). Must be applied here (after :environment) because
      # the PostgreSQL adapter is lazy-loaded and not available at rake file parse time.
      # Rake's invoke caching means this task body only runs once per process.
      ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements.prepend(
        Module.new do
          def create_schema(schema_name, **)
            execute("CREATE SCHEMA IF NOT EXISTS #{schema_name}")
          end
        end
      )

      configs = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)

      configs.each do |config|
        puts "Setting up PostGIS for #{config.name} database..."

        begin
          ActiveRecord::Base.establish_connection(config.configuration_hash)
          connection = ActiveRecord::Base.connection

          # Enable core PostGIS extensions (without CASCADE to avoid tiger_geocoder)
          # Use explicit pg_extension check rather than IF NOT EXISTS to avoid
          # DuplicateSchema errors when the Docker postgis image pre-installs extensions
          core_extensions = %w[postgis postgis_raster]
          core_extensions.each do |ext|
            already_installed = connection.select_value(
              "SELECT 1 FROM pg_extension WHERE extname = '#{ext}'"
            )
            if already_installed
              puts "  ✓ #{ext} (already installed)"
            else
              connection.execute("CREATE EXTENSION #{ext}")
              puts "  ✓ Enabled #{ext}"
            end
          end

          puts "PostGIS setup complete for #{config.name}!"
        rescue => e
          puts "  ⚠️  Error setting up PostGIS for #{config.name}: #{e.message}"
          puts "  This is usually fine if PostGIS is not available on your system."
        ensure
          ActiveRecord::Base.establish_connection(Rails.env.to_sym)
        end
      end
    end

    desc "Verify PostGIS installation"
    task verify: :environment do
      connection = ActiveRecord::Base.connection

      puts "\nVerifying PostGIS installation..."

      # Check PostgreSQL version
      pg_version = connection.select_value("SELECT version()")
      puts "PostgreSQL version: #{pg_version.split(',').first}"

      # Check PostGIS version
      begin
        postgis_version = connection.select_value("SELECT PostGIS_Version()")
        puts "PostGIS version: #{postgis_version}"
        puts "✓ PostGIS is properly installed!"
      rescue => e
        puts "✗ PostGIS is not available: #{e.message}"
        puts "\nTo install PostGIS:"
        puts "  macOS: brew install postgis"
        puts "  Ubuntu/Debian: sudo apt-get install postgresql-postgis"
        puts "  Other: Check PostGIS documentation for your platform"
      end

      # List installed extensions
      puts "\nInstalled extensions:"
      extensions = connection.execute("SELECT extname, extversion FROM pg_extension ORDER BY extname")
      extensions.each do |ext|
        puts "  - #{ext['extname']} (#{ext['extversion']})"
      end
    end
  end

  # Override db:test:prepare to include PostGIS setup
  namespace :test do
    task prepare: :environment do
      # Ensure test database exists
      ActiveRecord::Tasks::DatabaseTasks.create_current("test")

      # Setup PostGIS extensions before loading schema
      Rake::Task["db:postgis:setup"].invoke

      # Load schema
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current("test")

      puts "\n✓ Test database prepared with PostGIS extensions!"
    end
  end
end

# Enhance db:create to automatically setup PostGIS
Rake::Task["db:create"].enhance do
  Rake::Task["db:postgis:setup"].invoke if defined?(ActiveRecord)
end

# Ensure PostGIS is installed before db:migrate and db:schema:load run.
Rake::Task["db:migrate"].enhance([ "db:postgis:setup" ]) if Rake::Task.task_defined?("db:migrate")
Rake::Task["db:schema:load"].enhance([ "db:postgis:setup" ]) if Rake::Task.task_defined?("db:schema:load")

# Enhance db:setup to include PostGIS
Rake::Task["db:setup"].enhance([ "db:postgis:setup" ]) if Rake::Task.task_defined?("db:setup")
