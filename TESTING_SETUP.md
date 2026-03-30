# Testing Setup - Automated PostGIS & RSpec

## ✅ What's Been Automated

The entire test database setup is now **fully automated**. You don't need to manually run PostgreSQL commands anymore!

### Key Features:
1. **PostGIS extensions** are automatically installed when you create a database
2. **Pending migrations** are automatically run before tests
3. **RSpec** is fully configured with FactoryBot, Shoulda Matchers, and DatabaseCleaner
4. **GitHub Actions CI** is updated to use RSpec instead of the old Rails test framework

## Quick Start

### First Time Setup
```bash
# Option 1: Use the automated setup script (recommended)
bin/setup-test-db

# Option 2: Manual steps (if needed)
RAILS_ENV=test bin/rails db:create  # Automatically sets up PostGIS!
RAILS_ENV=test bin/rails db:migrate
```

### Running Tests
```bash
# Run all specs (PostGIS extensions auto-setup on first run)
bundle exec rspec

# Run specific types of specs
bundle exec rspec spec/models
bundle exec rspec spec/requests
bundle exec rspec spec/system

# Run a single file
bundle exec rspec spec/models/user_spec.rb

# Run a single test by line number
bundle exec rspec spec/models/user_spec.rb:42

# Run with detailed output
bundle exec rspec --format documentation
```

## How It Works

### 1. Database Creation Hook
When you run `bin/rails db:create`, the system automatically:
- Creates the database
- Installs PostGIS, PostGIS Raster, and pgRouting extensions
- Verifies the installation

**Implementation:** `lib/tasks/db_postgis.rake` enhances `db:create` task

### 2. Migration Auto-Fix
The migration file (`db/migrate/20260330144808_enable_postgres_extensions.rb`) uses:
- `CREATE EXTENSION IF NOT EXISTS` instead of `enable_extension`
- This is more resilient and won't fail if extensions already exist

### 3. RSpec Auto-Migration
In `spec/rails_helper.rb`, when you run tests:
1. Detects pending migrations
2. Automatically runs them
3. Sets up PostGIS extensions if needed
4. Runs your tests

**No manual intervention required!**

## Rake Tasks

### PostGIS Management
```bash
# Setup PostGIS for all environments
bin/rails db:postgis:setup

# Verify PostGIS installation
bin/rails db:postgis:verify

# Prepare test database (includes PostGIS setup)
bin/rails db:test:prepare
```

### Example Output
```bash
$ bin/rails db:postgis:verify

Verifying PostGIS installation...
PostgreSQL version: PostgreSQL 16.3
PostGIS version: 3.4.2
✓ PostGIS is properly installed!

Installed extensions:
  - hstore (1.8)
  - pg_catalog (1.1)
  - plpgsql (1.0)
  - postgis (3.4.2)
  - postgis_raster (3.4.2)
  - pgrouting (3.6.2)
  - postgis_topology (3.4.2)
```

## What Changed

### 1. Migration File
**Before:**
```ruby
enable_extension "postgis"  # Fails if not manually installed
```

**After:**
```ruby
execute "CREATE EXTENSION IF NOT EXISTS postgis CASCADE"  # Auto-installs!
```

### 2. GitHub Actions CI
**Before:**
```yaml
- name: Run tests
  run: bin/rails db:prepare test
```

**After:**
```yaml
- name: Prepare database
  run: |
    bin/rails db:create
    bin/rails db:postgis:setup
    bin/rails db:migrate

- name: Run RSpec tests
  run: bundle exec rspec --exclude-pattern "spec/system/**/*_spec.rb"
```

### 3. RSpec Helper
Automatically handles:
- PostGIS extension setup
- Pending migration detection and execution
- Database cleaning between tests

## Troubleshooting

### PostGIS Not Installed on System
If you see warnings about PostGIS not being available:

**macOS:**
```bash
brew install postgis
```

**Ubuntu/Debian:**
```bash
sudo apt-get install postgresql-postgis postgresql-postgis-scripts
```

**Windows:**
Download PostGIS from https://postgis.net/windows_downloads/

### PostgreSQL Not Running
```bash
# macOS (Homebrew)
brew services start postgresql@16

# Ubuntu/Debian
sudo systemctl start postgresql

# Check status
pg_isready
```

### Database Already Exists Issues
```bash
# Reset everything
RAILS_ENV=test bin/rails db:drop
RAILS_ENV=test bin/rails db:create  # Auto-setup happens here
RAILS_ENV=test bin/rails db:migrate
```

### Skip Auto-Setup (Advanced)
If you need to skip the automatic PostGIS setup for some reason:
```bash
SKIP_POSTGIS_SETUP=true bundle exec rspec
```

## CI/CD Integration

### GitHub Actions
The CI is configured to use the PostGIS Docker image:
```yaml
services:
  postgres:
    image: postgis/postgis:16-3.4  # Includes PostGIS pre-installed
```

This ensures the same setup in CI as in development.

### Environment Variables
```yaml
DATABASE_URL: postgis://postgres:postgres@localhost:5432/logistikos_test
```

## Testing Best Practices

1. **Use FactoryBot** - Don't create records manually
   ```ruby
   let(:user) { create(:user) }  # Good
   ```

2. **Use `let` for lazy-loading**
   ```ruby
   let(:user) { create(:user) }  # Only created when used
   ```

3. **One assertion per test**
   ```ruby
   it 'creates a user' do
     expect { create(:user) }.to change(User, :count).by(1)
   end
   ```

4. **Use Shoulda Matchers**
   ```ruby
   it { should validate_presence_of(:email) }
   it { should belong_to(:organization) }
   ```

5. **Test behavior, not implementation**
   ```ruby
   # Good
   it 'sends a welcome email' do
     expect { user.save }.to change(ActionMailer::Base.deliveries, :count).by(1)
   end

   # Bad
   it 'calls send_welcome_email' do
     expect(user).to receive(:send_welcome_email)
   end
   ```

## Directory Structure

```
spec/
├── examples/          # Example specs (can be removed)
├── factories/         # FactoryBot factory definitions
├── models/            # Model specs
├── requests/          # Request/API specs (JSON endpoints)
├── system/            # System/feature specs (Capybara browser tests)
├── support/           # Helper files and shared examples
├── rails_helper.rb    # Rails + RSpec configuration
├── spec_helper.rb     # Pure RSpec configuration
└── README.md          # Testing guide and examples
```

## Summary

✅ **No manual commands needed** - Just run `bundle exec rspec`
✅ **PostGIS auto-installs** - Extensions created automatically
✅ **Migrations auto-run** - Detected and executed automatically
✅ **CI configured** - GitHub Actions uses RSpec with PostGIS
✅ **Full test suite** - Models, requests, and system tests ready

**Just start writing tests!** 🚀

---

For more detailed RSpec usage, see `spec/README.md`
