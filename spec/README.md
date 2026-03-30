# RSpec Testing Guide

> 📖 **For automated PostGIS setup and quick start, see [TESTING_SETUP.md](../TESTING_SETUP.md)**

## Setup Complete! ✓

RSpec has been successfully installed and configured with the following gems:
- **rspec-rails** (~> 7.1) - Core RSpec testing framework
- **factory_bot_rails** (~> 6.4) - Test data factories
- **faker** (~> 3.5) - Generate fake data
- **shoulda-matchers** (~> 6.4) - Additional RSpec matchers
- **database_cleaner-active_record** (~> 2.2) - Clean database between tests

### 🚀 Quick Start
```bash
# First time setup (automated)
bin/setup-test-db

# Run tests (PostGIS auto-setup on first run)
bundle exec rspec
```

## Running Tests

```bash
# Run all specs
bundle exec rspec

# Run specific directory
bundle exec rspec spec/models
bundle exec rspec spec/requests
bundle exec rspec spec/system

# Run single file
bundle exec rspec spec/models/user_spec.rb

# Run single spec by line number
bundle exec rspec spec/models/user_spec.rb:42

# Run with detailed output
bundle exec rspec --format documentation

# Run with fail fast (stop on first failure)
bundle exec rspec --fail-fast
```

## Database Setup

### ✅ Fully Automated!

PostGIS and database migrations are now **completely automated**. Just run:

```bash
# One-time setup
bin/setup-test-db

# Or let RSpec handle it automatically
bundle exec rspec  # Auto-creates extensions and runs migrations!
```

**No manual PostgreSQL commands needed!** The system automatically:
- Creates the test database
- Installs PostGIS extensions
- Runs pending migrations
- Sets up everything you need

See [TESTING_SETUP.md](../TESTING_SETUP.md) for details on how this works.

## Directory Structure

```
spec/
├── examples/          # Example specs demonstrating setup
├── factories/         # FactoryBot factory definitions
├── models/            # Model specs
├── requests/          # Request/API specs
├── system/            # System/feature specs (Capybara)
├── support/           # Helper files and shared examples
├── rails_helper.rb    # Rails-specific RSpec configuration
└── spec_helper.rb     # Core RSpec configuration
```

## Writing Specs

### Model Spec Example

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { should have_many(:orders) }
  end

  describe '#full_name' do
    it 'returns the concatenated first and last name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

### Factory Example

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :driver do
      role { 'driver' }
    end

    trait :customer do
      role { 'customer' }
    end
  end
end
```

### Request Spec Example

```ruby
# spec/requests/api/orders_spec.rb
require 'rails_helper'

RSpec.describe 'Orders API', type: :request do
  describe 'POST /api/orders' do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        pickup_address: '123 Main St',
        delivery_address: '456 Oak Ave'
      }
    end

    it 'creates a new order' do
      post '/api/orders', params: { order: valid_params }, headers: auth_headers(user)

      expect(response).to have_http_status(:created)
      expect(json_response['pickup_address']).to eq('123 Main St')
    end
  end
end
```

## Available Matchers

### Shoulda Matchers

```ruby
# Validations
should validate_presence_of(:name)
should validate_uniqueness_of(:email)
should validate_length_of(:password).is_at_least(8)

# Associations
should belong_to(:user)
should have_many(:orders)
should have_one(:profile)

# Database
should have_db_column(:email).of_type(:string)
should have_db_index(:email)
```

### RSpec Rails Matchers

```ruby
# HTTP status
expect(response).to have_http_status(:success)
expect(response).to have_http_status(:created)
expect(response).to have_http_status(:unprocessable_entity)

# Redirects
expect(response).to redirect_to(root_path)

# Rendering
expect(response).to render_template(:index)
```

## Best Practices

1. **Use FactoryBot for test data** - Don't create records manually
2. **Use `let` and `let!`** - Define reusable test data
3. **One assertion per test** - Keep specs focused
4. **Use descriptive names** - Test names should explain what they test
5. **Test behavior, not implementation** - Focus on what, not how
6. **Use contexts** - Group related specs with `context` blocks
7. **Keep specs DRY** - Use shared examples and helper methods
8. **Test edge cases** - Don't just test the happy path

## Configuration

The RSpec configuration includes:
- ✓ FactoryBot syntax methods included globally
- ✓ DatabaseCleaner configured for transaction strategy
- ✓ Shoulda Matchers integrated
- ✓ Spec type inference from file location
- ✓ Rails backtrace filtering
- ✓ Documentation format output
- ✓ Color output

## Troubleshooting

### DatabaseCleaner Issues
If you encounter issues with database state between tests, check that DatabaseCleaner is properly configured in `spec/rails_helper.rb`.

### Factory Errors
If factories fail to build, ensure:
1. The model exists
2. Required validations are satisfied
3. Associated records are created

### Slow Test Suite
- Use `let` instead of `let!` when possible
- Consider using `build` instead of `create` when persistence isn't needed
- Profile slow tests: `bundle exec rspec --profile`

## Additional Resources

- [RSpec Rails Documentation](https://rspec.info/features/7-1/rspec-rails/)
- [FactoryBot Getting Started](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)
- [Better Specs](https://www.betterspecs.org/)
