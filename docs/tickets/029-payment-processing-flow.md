# Ticket 029: Payment Processing Flow

## Description
Implement the full payment lifecycle using Solid Queue jobs: authorize on order acceptance, capture on delivery completion, refund/void on cancellation. Integrate with the Orders::StatusTransitioner service to trigger payment jobs on status transitions. **MVP uses MockAdapter by default** — all gateway calls succeed deterministically, enabling evaluators to test the full flow without real Stripe credentials.

## Acceptance Criteria
- [ ] `Payments::Processor` service orchestrates payment lifecycle (authorize, capture, refund)
- [ ] `PaymentAuthorizationJob` (critical queue): creates Payment record, calls gateway.authorize, updates Payment status to `authorized`
- [ ] `PaymentCaptureJob` (critical queue): calls gateway.capture, updates Payment to `captured`, creates DriverEarning record
- [ ] `PaymentRefundJob` (default queue): calls gateway.refund (or void if not captured), updates Payment to `refunded`/`voided`
- [ ] `Orders::StatusTransitioner` updated to enqueue payment jobs on relevant transitions:
  - `open` → `accepted`: enqueue `PaymentAuthorizationJob`
  - `in_transit` → `completed`: enqueue `PaymentCaptureJob`
  - Any → `cancelled`: enqueue `PaymentRefundJob`
- [ ] All payment jobs are idempotent (check payment status before acting)
- [ ] All payment jobs pass only IDs in perform args (no PII)
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
- `app/jobs/payment_authorization_job.rb` — authorization Solid Queue job
- `app/jobs/payment_capture_job.rb` — capture Solid Queue job
- `app/jobs/payment_refund_job.rb` — refund/void Solid Queue job
- `app/services/orders/status_transitioner.rb` — add payment job triggers
- `config/solid_queue.yml` — verify critical queue is configured
- `spec/services/payments/processor_spec.rb` — processor service tests
- `spec/jobs/payment_authorization_job_spec.rb` — job tests
- `spec/jobs/payment_capture_job_spec.rb` — job tests
- `spec/jobs/payment_refund_job_spec.rb` — job tests

## Technical Notes
- Authorization failure should NOT crash the acceptance flow. Instead, set payment status to `failed` and revert order to `open` with notification to customer
- Platform fee: `ENV.fetch('PLATFORM_FEE_PERCENT', '15').to_f`
- DriverEarning created ONLY on successful capture
- Jobs must check current payment status before acting (idempotency guard)
- Example idempotency pattern: return early if payment.status already matches the target state before calling the gateway
- **MVP note:** With MockAdapter (default), all gateway operations succeed deterministically. Use `MOCK_PAYMENT_FAILURE_RATE` env var to simulate failures for testing error paths.
