# Ticket 029: Payment Processing Flow

## Description
Implement the full payment lifecycle using Sidekiq workers: authorize on order acceptance, capture on delivery completion, refund/void on cancellation. Integrate with the Orders::StatusTransitioner service to trigger payment workers on status transitions. **MVP uses MockAdapter by default** — all gateway calls succeed deterministically, enabling evaluators to test the full flow without real Stripe credentials.

## Acceptance Criteria
- [ ] `Payments::Processor` service orchestrates payment lifecycle (authorize, capture, refund)
- [ ] `PaymentAuthorizationWorker` (critical queue): creates Payment record, calls gateway.authorize, updates Payment status to `authorized`
- [ ] `PaymentCaptureWorker` (critical queue): calls gateway.capture, updates Payment to `captured`, creates DriverEarning record
- [ ] `PaymentRefundWorker` (default queue): calls gateway.refund (or void if not captured), updates Payment to `refunded`/`voided`
- [ ] `Orders::StatusTransitioner` updated to enqueue payment workers on relevant transitions:
  - `open` → `accepted`: enqueue `PaymentAuthorizationWorker`
  - `in_transit` → `completed`: enqueue `PaymentCaptureWorker`
  - Any → `cancelled`: enqueue `PaymentRefundWorker`
- [ ] All payment workers are idempotent (check payment status before acting)
- [ ] All payment workers pass only IDs in perform args (no PII)
- [ ] Failed payment authorization prevents order acceptance (rolls back to `open`)
- [ ] DriverEarning computes: net = gross - (gross * platform_fee_percentage)
- [ ] Platform fee percentage configurable via env var (default: 15%)
- [ ] Integration tests for full flow: create → accept (authorize) → complete (capture)
- [ ] Integration test: accept → cancel (void)

## Dependencies
- **027** — gateway abstraction
- **028** — payment models
- **016** — StatusTransitioner service

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `app/services/payments/processor.rb` — payment lifecycle orchestration
- `app/workers/payment_authorization_worker.rb` — authorization Sidekiq worker
- `app/workers/payment_capture_worker.rb` — capture Sidekiq worker
- `app/workers/payment_refund_worker.rb` — refund/void Sidekiq worker
- `app/services/orders/status_transitioner.rb` — add payment worker triggers
- `config/sidekiq.yml` — verify critical queue is configured
- `spec/services/payments/processor_spec.rb` — processor service tests
- `spec/workers/payment_authorization_worker_spec.rb` — worker tests
- `spec/workers/payment_capture_worker_spec.rb` — worker tests
- `spec/workers/payment_refund_worker_spec.rb` — worker tests

## Technical Notes
- Authorization failure should NOT crash the acceptance flow. Instead, set payment status to `failed` and revert order to `open` with notification to customer
- Platform fee: `ENV.fetch('PLATFORM_FEE_PERCENT', '15').to_f`
- DriverEarning created ONLY on successful capture
- Workers must check current payment status before acting (idempotency guard)
- Example idempotency pattern: return early if payment.status already matches the target state before calling the gateway
- **MVP note:** With MockAdapter (default), all gateway operations succeed deterministically. Use `MOCK_PAYMENT_FAILURE_RATE` env var to simulate failures for testing error paths.
