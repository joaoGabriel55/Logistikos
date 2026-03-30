# Ticket 030: Payment UI Components

## Description
Build the customer-facing payment UI: payment method management (add/remove/set default), payment confirmation on order acceptance, receipt display on completion, and driver earnings display. **For MVP (MockAdapter default):** the payment method form is a simple mock form that generates fake tokens — no Stripe.js dependency required. When `PAYMENT_GATEWAY=stripe`, integrate Stripe.js Elements for secure card tokenization (card data never touches our server). This ensures evaluators can test the full payment UI without real Stripe credentials.

## Acceptance Criteria
- [ ] `PaymentMethods.tsx` Inertia page: list saved payment methods, add new, set default, remove
- [ ] `PaymentMethodForm.tsx` component: when `PAYMENT_GATEWAY=mock`, renders a simple mock card form (pre-filled test data, generates fake token); when `PAYMENT_GATEWAY=stripe`, uses Stripe.js Elements for secure card input (card data never touches our server)
- [ ] `PaymentMethodCard.tsx` component: displays card brand icon, last 4 digits, expiry, default badge
- [ ] Order creation flow (`OrderCreate.tsx`) validates customer has at least one payment method before submission
- [ ] `PaymentConfirmation.tsx` Inertia page: shown after order acceptance, displays authorized amount and payment method used
- [ ] `ReceiptCard.tsx` component: shown on completed delivery, displays final amount, payment method, timestamp
- [ ] `PaymentStatusBadge.tsx`: visual indicator for payment status (pending/authorized/captured/refunded)
- [ ] Driver `ActiveDelivery.tsx` shows estimated earnings for the current delivery
- [ ] Driver `Profile.tsx` shows cumulative earnings summary
- [ ] All payment UI follows the Precision Logistikos design system from `DESIGN.md` (no borders, correct surfaces, 44x44px touch targets)
- [ ] TypeScript types for Payment, PaymentMethod, DriverEarning added to `frontend/types/models.ts`
- [ ] `payment_methods_controller.rb` with CRUD + Inertia rendering
- [ ] Routes added to `config/routes.rb`

## Dependencies
- **028** — payment models and serializers
- **029** — payment processing flow
- **005** — design system setup
- **008** — order creation flow for payment method validation

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `frontend/pages/Customer/PaymentMethods.tsx` — Inertia page for managing saved payment methods
- `frontend/pages/Customer/PaymentConfirmation.tsx` — Inertia page shown after order acceptance
- `frontend/components/payments/PaymentMethodCard.tsx` — card brand icon, last 4 digits, expiry, default badge
- `frontend/components/payments/PaymentMethodForm.tsx` — Stripe.js Elements card input form
- `frontend/components/payments/PaymentStatusBadge.tsx` — visual payment status indicator
- `frontend/components/payments/ReceiptCard.tsx` — completed delivery receipt display
- `frontend/types/models.ts` — add Payment, PaymentMethod, DriverEarning types
- `frontend/pages/Driver/ActiveDelivery.tsx` — add estimated earnings for current delivery
- `frontend/pages/Driver/Profile.tsx` — add cumulative earnings summary
- `frontend/pages/Customer/OrderCreate.tsx` — add payment method validation before submission
- `app/controllers/payment_methods_controller.rb` — CRUD actions with Inertia rendering
- `config/routes.rb` — add payment methods routes

## Technical Notes
- **MVP (MockAdapter):** `PaymentMethodForm` renders a simple HTML form with pre-filled test card data (4242 4242 4242 4242, any future expiry, any CVC). On submit, generates a `mock_pm_<uuid>` token and sends it to the backend. No `@stripe/stripe-js` dependency needed.
- **Production (StripeAdapter):** Use `@stripe/stripe-js` and `@stripe/react-stripe-js` for frontend tokenization. Card data NEVER passes through our server — Stripe.js handles it client-side. Stripe publishable key passed via Inertia shared data or meta tag.
- The gateway mode is passed to the frontend via Inertia shared data (`payment_gateway` prop) so the form can switch between mock and Stripe modes
- Payment method list uses Inertia props
- Payment amounts displayed with `Intl.NumberFormat` for locale-aware formatting
