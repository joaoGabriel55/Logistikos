# frozen_string_literal: true

namespace :db do
  namespace :postgis do
    desc "Setup PostGIS extensions for all databases"
    task setup: :environment do
      configs = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)

      configs.each do |config|
        puts "Setting up PostGIS for #{config.name} database..."

        begin
          ActiveRecord::Base.establish_connection(config.configuration_hash)
          connection = ActiveRecord::Base.connection

          # Enable core PostGIS extensions (without CASCADE to avoid tiger_geocoder)
          core_extensions = %w[postgis postgis_raster]
          core_extensions.each do |ext|
            connection.execute("CREATE EXTENSION IF NOT EXISTS #{ext}")
            puts "  ✓ Enabled #{ext}"
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

# Enhance db:setup to include PostGIS
Rake::Task["db:setup"].enhance([ "db:postgis:setup" ]) if Rake::Task.task_defined?("db:setup")
