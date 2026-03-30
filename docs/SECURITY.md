# Security Guidelines for Logistikos

This document outlines critical security practices that must be followed when developing Logistikos features.

## SQL Injection Protection for Spatial Data

### DO NOT Use String Interpolation for Coordinates

**NEVER** do this:
```ruby
# UNSAFE - SQL injection vulnerability
self.location = "POINT(#{lng} #{lat})"
```

**ALWAYS** do this:
```ruby
# SAFE - uses RGeo factory with validated inputs
lat_f = Float(lat)
lng_f = Float(lng)
raise ArgumentError, "Invalid coordinates" unless lat_f.finite? && lng_f.finite?
raise ArgumentError, "Latitude must be between -90 and 90" unless lat_f.between?(-90, 90)
raise ArgumentError, "Longitude must be between -180 and 180" unless lng_f.between?(-180, 180)

factory = RGeo::Geographic.spherical_factory(srid: 4326)
self.location = factory.point(lng_f, lat_f)
```

### Spatial Data Validation Rules

All coordinate inputs must be validated:
1. Convert to Float using `Float()` (raises ArgumentError for invalid input)
2. Check `finite?` to reject NaN and Infinity
3. Validate latitude is between -90 and 90
4. Validate longitude is between -180 and 180
5. Use RGeo factory methods to create spatial objects

### Examples in Codebase

See these models for reference implementations:
- `app/models/delivery_order.rb` - `set_pickup_location`, `set_dropoff_location`, `set_route_geometry`
- `app/models/driver_profile.rb` - `set_location`
- `app/models/assignment.rb` - `update_driver_location`

## PII Protection

### Three Layers of PII Protection

1. **Encryption at Rest** - Use Rails 8 `encrypts` directive:
```ruby
encrypts :name
encrypts :email, deterministic: true  # for searchable fields
encrypts :pickup_address
```

2. **Log Filtering** - Declare filter_attributes on models:
```ruby
self.filter_attributes = %i[name email pickup_address dropoff_address description]
```

3. **Logstop** - Catch-all pattern filtering (configured in `config/initializers/logstop.rb`)

### Adding New PII Fields

When adding a new field that contains PII:

1. Add `encrypts :field_name` to the model
2. Add `:field_name` to `self.filter_attributes` in the model
3. Add `:field_name` to `config/initializers/filter_parameter_logging.rb`

### Current PII Fields

Encrypted fields:
- User: `name`, `email`
- DeliveryOrder: `pickup_address`, `dropoff_address`, `description`
- PaymentMethod: `gateway_token`

Filtered from logs:
- `:name`, `:email`, `:password`, `:token`, `:secret`
- `:pickup_address`, `:dropoff_address`, `:description`
- `:gateway_token`, `:card_number`, `:card_last4`
- `:cvv`, `:cvc`, `:ssn`, `:otp`

## Payment Security

### Never Store Raw Card Data

**NEVER** do this:
```ruby
# UNSAFE - storing raw card data
PaymentMethod.create!(card_number: "4242424242424242", cvv: "123")
```

**ALWAYS** do this:
```ruby
# SAFE - use gateway tokenization (Stripe.js Elements)
PaymentMethod.create!(gateway_token: stripe_token, gateway_type: "card")
```

### Use Idempotency Keys

All payment operations must include an idempotency key:

```ruby
payment = Payment.create!(
  delivery_order: order,
  customer: user,
  amount_cents: 1000,
  currency: "USD",
  status: :pending,
  gateway_provider: "mock",
  idempotency_key: SecureRandom.uuid  # Unique key for this operation
)
```

The database enforces uniqueness to prevent double charges.

### Amounts in Cents

Always store monetary amounts as integers (cents) to avoid floating-point errors:

```ruby
# CORRECT
amount_cents: 1000  # $10.00

# WRONG
amount_dollars: 10.00  # floating-point errors
```

## Data Anonymization

### Use Secure Random for Anonymization

**NEVER** do this:
```ruby
# UNSAFE - predictable, allows enumeration
self.email = "anonymized_#{id}@example.com"
```

**ALWAYS** do this:
```ruby
# SAFE - unpredictable
random_id = SecureRandom.hex(8)
self.email = "user_#{random_id}@anonymized.local"
```

See `app/models/concerns/anonymizable.rb` for the reference implementation.

## Sidekiq Workers

### Only Pass IDs, Never Full Objects

**NEVER** do this:
```ruby
# UNSAFE - serializes full object including PII
MyWorker.perform_async(user)
```

**ALWAYS** do this:
```ruby
# SAFE - only passes ID
MyWorker.perform_async(user.id)

# In the worker:
class MyWorker
  def perform(user_id)
    user = User.find(user_id)
    # ... do work
  end
end
```

## Rails 8 Authentication

### Use Current Attributes

Access the current user via `Current.user`, not global variables:

```ruby
# CORRECT
class OrdersController < ApplicationController
  before_action :authenticate

  def create
    @order = DeliveryOrder.new(order_params)
    @order.creator = Current.user  # Use Current.user
    @order.save!
  end
end
```

### Authentication Concern

Use the `Authentication` concern's `authenticate` method:

```ruby
class ApplicationController < ActionController::Base
  include Authentication

  before_action :authenticate  # Requires login
end
```

## Security Checklist for New Features

Before submitting a PR, verify:

- [ ] No string interpolation in SQL/PostGIS queries
- [ ] All coordinate inputs validated (range checks)
- [ ] RGeo factory methods used for spatial data
- [ ] PII fields encrypted with `encrypts`
- [ ] PII fields added to `filter_attributes`
- [ ] No raw card data stored
- [ ] Payment operations use idempotency keys
- [ ] Monetary amounts in cents (integers)
- [ ] Workers only accept IDs, not full objects
- [ ] Anonymization uses SecureRandom
- [ ] Tests cover security validations

## Reporting Security Issues

If you discover a security vulnerability, DO NOT create a public GitHub issue.

Instead:
1. Email security@logistikos.example.com (placeholder)
2. Include a detailed description and reproduction steps
3. Wait for acknowledgment before public disclosure

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [PostGIS Security](https://postgis.net/docs/using_postgis_dbmanagement.html#security)
- [PCI DSS Compliance](https://www.pcisecuritystandards.org/)

## Review History

- 2026-03-30: Initial security guidelines created based on code review fixes
