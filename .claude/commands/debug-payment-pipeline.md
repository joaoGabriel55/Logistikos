You are a backend debugging specialist for **Logistikos**. The payment pipeline spans multiple Sidekiq workers and a gateway adapter (MockAdapter by default for MVP, StripeAdapter for production). Use this command to diagnose payment issues.

> **MVP Note:** The default gateway is `MockAdapter` (`PAYMENT_GATEWAY=mock`). Mock operations always succeed with deterministic responses unless `MOCK_PAYMENT_FAILURE_RATE` is set. If debugging payment failures in MVP, check this env var first.

## Input
$ARGUMENTS — a payment ID, order ID, or symptom description

## Payment Pipeline (Expected Flow)

```
Order accepted (open -> accepted)
  -> PaymentAuthorizationWorker (critical queue)
    -> Payments::Gateway.authorize(amount, payment_method_token)
      -> Payment status: pending -> authorized
        -> On completion (in_transit -> completed):
          -> PaymentCaptureWorker (critical queue)
            -> Payments::Gateway.capture(gateway_payment_id)
              -> Payment status: authorized -> captured
                -> DriverEarning record created (net = gross - platform_fee)

Cancellation:
  -> PaymentRefundWorker (default queue)
    -> If authorized (not captured): Payments::Gateway.void -> Payment status: voided
    -> If captured: Payments::Gateway.refund -> Payment status: refunded
```

## Debugging Steps

### Step 1: Check Payment Record
```ruby
payment = Payment.find_by(delivery_order_id: <order_id>)
puts payment&.attributes&.slice('id', 'status', 'amount_cents', 'currency', 'gateway_provider', 'gateway_payment_id', 'authorized_at', 'captured_at', 'refunded_at')
```
If no payment record exists, the `PaymentAuthorizationWorker` never ran or failed before creating the record.

### Step 2: Check Customer Payment Method
```ruby
user = DeliveryOrder.find(<order_id>).creator
puts user.payment_methods.map { |pm| { id: pm.id, brand: pm.card_brand, last4: pm.card_last_four, default: pm.is_default, expired: pm.expires_at&.past? } }
```
Verify at least one non-expired default payment method exists.

### Step 3: Check Sidekiq Worker Status
Check for payment workers in dead-letter and retry queues:
```ruby
# Check retry queue
Sidekiq::RetrySet.new.select { |job| job.klass.include?('Payment') }

# Check dead-letter queue
Sidekiq::DeadSet.new.select { |job| job.klass.include?('Payment') }
```

### Step 4: Check Gateway Response
Check which gateway adapter is active:
```ruby
puts ENV.fetch('PAYMENT_GATEWAY', 'mock')
# If 'mock': MockAdapter — operations are deterministic, check MOCK_PAYMENT_FAILURE_RATE
# If 'stripe': StripeAdapter — look for Stripe API errors
```
Look for gateway errors in Rails logs (PII is filtered — look for gateway_payment_id, not customer data):
```bash
grep -i 'payment\|stripe\|mock\|gateway' log/production.log | tail -50
```

### Step 5: Check Driver Earnings
```ruby
DriverEarning.where(delivery_order_id: <order_id>).first&.attributes&.slice('gross_amount_cents', 'platform_fee_cents', 'net_amount_cents', 'paid_out_at')
```
Earnings only exist after successful capture.

### Step 6: Verify Order Status Consistency
```ruby
order = DeliveryOrder.find(<order_id>)
payment = order.payment
puts "Order status: #{order.status}, Payment status: #{payment&.status}"
```
Expected consistency: `accepted` -> `authorized`, `completed` -> `captured`, `cancelled` -> `voided`/`refunded`

## Common Issues & Fixes

| Symptom | Likely Cause | Fix |
|---|---|---|
| No payment record | AuthorizationWorker never ran | Check StatusTransitioner enqueues PaymentAuthorizationWorker on acceptance |
| Payment stuck in `pending` | Gateway timeout/error during authorization | **MVP (mock):** Check `MOCK_PAYMENT_FAILURE_RATE` env var. **Production (stripe):** Check Sidekiq retries; verify Stripe API key in credentials; check gateway logs |
| Payment `authorized` but never captured | CaptureWorker not triggered on completion | Check StatusTransitioner triggers PaymentCaptureWorker on `in_transit` -> `completed` |
| Payment `failed` | Customer payment method declined | Notify customer; revert order to `open`; check if payment method is expired |
| No DriverEarning after capture | CaptureWorker post-capture logic failed | Check worker code after `gateway.capture` for earning creation |
| Double charge | Missing idempotency key | Verify all gateway calls pass idempotency keys; check worker idempotency guards |
| Order `accepted` but payment `failed` | Authorization failure not caught | StatusTransitioner should revert order to `open` on auth failure |
| Refund not issued | RefundWorker not enqueued on cancellation | Check StatusTransitioner triggers PaymentRefundWorker on any -> `cancelled` |

## Notes
- Payment workers pass only record IDs — never PII in Sidekiq arguments
- All payment operations are idempotent — workers check current status before acting
- Gateway API keys are in Rails credentials, not environment variables (StripeAdapter only; MockAdapter needs no keys)
- Payment amounts are in cents (integer) — never floating point
