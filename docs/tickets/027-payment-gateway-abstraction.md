# Ticket 027: Payment Gateway Abstraction

## Description
Implement the gateway-agnostic payment adapter pattern. Define the `Payments::Gateway` interface and implement `Payments::Adapters::MockAdapter` as the **MVP default adapter** and `Payments::Adapters::StripeAdapter` as the production adapter. The gateway is selected via `PAYMENT_GATEWAY` environment variable (default: `mock`). The MockAdapter simulates all gateway operations with deterministic success responses so evaluators can test the full payment flow without real Stripe credentials. The architecture allows adding new gateways (GPay, ApplePay, Mercado Pago) by creating a new adapter class without changing business logic.

## Acceptance Criteria
- [ ] `Payments::Gateway` module defines the interface contract: `authorize(amount_cents, currency, payment_method_token)`, `capture(gateway_payment_id)`, `refund(gateway_payment_id, amount_cents)`, `create_customer(user)`, `add_payment_method(customer_token, card_token)`
- [ ] `Payments::Adapters::BaseAdapter` provides shared behavior (error wrapping, logging, idempotency key generation)
- [ ] `Payments::Adapters::MockAdapter` **(MVP default)** implements all interface methods with deterministic success responses, fake gateway IDs (`mock_pay_<uuid>`), and configurable simulated delays
- [ ] `Payments::Adapters::StripeAdapter` implements all interface methods using the `stripe` gem (production adapter)
- [ ] Gateway selection is configured via `PAYMENT_GATEWAY` env var (default: `mock`; set to `stripe` for production)
- [ ] `config/initializers/payment_gateway.rb` registers the configured adapter
- [ ] All gateway calls wrapped in error handling that translates gateway-specific errors to domain errors
- [ ] Idempotency keys passed on all mutating Stripe API calls (StripeAdapter)
- [ ] Gateway API keys read from Rails credentials, never hardcoded (StripeAdapter)
- [ ] MockAdapter requires no external credentials and works out-of-the-box
- [ ] Unit tests for MockAdapter (deterministic behavior) and StripeAdapter (Stripe mock/VCR cassettes)

## Dependencies
None (foundation ticket)

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `Gemfile` — add stripe gem (optional for MVP, required for production)
- `app/services/payments/gateway.rb` — gateway interface module
- `app/services/payments/adapters/base_adapter.rb` — shared adapter behavior
- `app/services/payments/adapters/mock_adapter.rb` — **MVP default** mock implementation
- `app/services/payments/adapters/stripe_adapter.rb` — Stripe production implementation
- `config/initializers/payment_gateway.rb` — adapter registration (default: mock)
- `spec/services/payments/adapters/mock_adapter_spec.rb` — unit tests for mock adapter
- `spec/services/payments/adapters/stripe_adapter_spec.rb` — unit tests with VCR cassettes

## Technical Notes
- Gateway interface uses duck typing
- **MockAdapter** returns deterministic success responses with fake gateway IDs (`mock_pay_<uuid>`, `mock_cus_<uuid>`, `mock_pm_<uuid>`). Simulates realistic delays (50-200ms). Supports an optional `MOCK_PAYMENT_FAILURE_RATE` env var (default: `0`) to simulate failures for testing error paths.
- StripeAdapter wraps `Stripe::PaymentIntent` for authorize/capture and `Stripe::Refund` for refunds
- Use `Stripe::PaymentMethod` for tokenized card storage (StripeAdapter only)
- All amounts in cents (integer)
- Idempotency: `Stripe::PaymentIntent.create({...}, {idempotency_key: key})` (StripeAdapter)
