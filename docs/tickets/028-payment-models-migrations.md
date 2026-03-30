# Ticket 028: Payment Models & Migrations

## Description
Create the Payment, PaymentMethod, and DriverEarning models with migrations. These support the full payment lifecycle: storing tokenized payment methods, tracking payment state (authorized/captured/refunded), and recording driver earnings per completed delivery.

## Acceptance Criteria
- [ ] `payments` table: delivery_order_id (FK), customer_id (FK), driver_id (FK nullable), amount_cents (integer), currency (string default 'brl'), status (enum: pending/authorized/captured/refunded/voided/failed), gateway_provider, gateway_payment_id, authorized_at, captured_at, refunded_at, metadata (jsonb), timestamps
- [ ] `payment_methods` table: user_id (FK), gateway_provider, gateway_token (encrypted), card_last_four, card_brand, is_default (boolean), expires_at, timestamps
- [ ] `driver_earnings` table: driver_id (FK), payment_id (FK), delivery_order_id (FK), gross_amount_cents, platform_fee_cents, net_amount_cents, paid_out_at (nullable), timestamps
- [ ] `Payment` model with status enum, AASM state machine (pending→authorized→captured; authorized→voided; captured→refunded; any→failed), associations, validations
- [ ] `PaymentMethod` model with `encrypts :gateway_token`, `self.filter_attributes`, associations
- [ ] `DriverEarning` model with associations and computed net_amount_cents validation
- [ ] Indexes on: payments.delivery_order_id, payments.customer_id, payments.status, payment_methods.user_id, driver_earnings.driver_id
- [ ] `PaymentSerializer` and `PaymentMethodSerializer` for Inertia props
- [ ] `rails db:migrate` runs cleanly

## Dependencies
- **003** — base schema
- **027** — gateway abstraction for provider values

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `db/migrate/XXX_create_payments.rb` — payments table migration
- `db/migrate/XXX_create_payment_methods.rb` — payment_methods table migration
- `db/migrate/XXX_create_driver_earnings.rb` — driver_earnings table migration
- `app/models/payment.rb` — Payment model with AASM state machine
- `app/models/payment_method.rb` — PaymentMethod model with encrypted token
- `app/models/driver_earning.rb` — DriverEarning model
- `app/models/user.rb` — add has_many :payment_methods, :driver_earnings
- `app/models/delivery_order.rb` — add has_one :payment
- `app/serializers/payment_serializer.rb` — serializer for Inertia props
- `app/serializers/payment_method_serializer.rb` — serializer for Inertia props
- `spec/models/payment_spec.rb` — Payment model tests
- `spec/models/payment_method_spec.rb` — PaymentMethod model tests
- `spec/models/driver_earning_spec.rb` — DriverEarning model tests

## Technical Notes
- Payment amounts always in cents (integer)
- Payment AASM state machine similar to DeliveryOrder
- `PaymentMethod.gateway_token` is encrypted via `encrypts :gateway_token`
- DriverEarning is created only on successful capture
- Platform fee: `ENV.fetch('PLATFORM_FEE_PERCENT', '15').to_f`
