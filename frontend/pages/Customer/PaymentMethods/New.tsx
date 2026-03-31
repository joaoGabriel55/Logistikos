import React from "react";
import MobileLayout from "@/components/layout/MobileLayout";
import { Head, Link } from "@inertiajs/react";

export default function New() {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    alert(
      "Payment method creation will be implemented in Ticket 030.\n\n" +
        "For MVP testing, you can create payment methods directly in the database or via Rails console.",
    );
  };

  return (
    <>
      <Head title="Add Payment Method" />
      <MobileLayout withTopBar>
        <div className="px-4 py-6">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-[var(--color-on-surface)] mb-2">
              Add Payment Method
            </h1>
            <p className="text-sm text-[var(--color-on-surface-variant)]">
              Add a card to pay for deliveries
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="bg-[var(--color-surface-container)] rounded-2xl p-6">
              <div className="text-center py-8">
                <div className="text-4xl mb-4">💳</div>
                <p className="text-[var(--color-on-surface)] font-semibold mb-2">
                  Payment Form Coming Soon
                </p>
                <p className="text-sm text-[var(--color-on-surface-variant)]">
                  This feature will be implemented in Ticket 030
                </p>
              </div>
            </div>

            <div className="p-4 bg-[var(--color-secondary-container)] rounded-2xl">
              <p className="text-sm text-[var(--color-on-secondary-container)]">
                <strong>For MVP Testing:</strong> Create payment methods via
                Rails console:
              </p>
              <pre className="mt-2 text-xs bg-[var(--color-surface)] p-2 rounded overflow-x-auto">
                {`PaymentMethod.create!(
  user: User.find_by(email: 'you@example.com'),
  gateway_provider: 'mock',
  gateway_token: 'tok_test_123',
  card_brand: 'Visa',
  card_last_four: '4242',
  expires_at: 2.years.from_now,
  is_default: true
)`}
              </pre>
            </div>

            <div className="flex gap-3">
              <Link
                href="/payment_methods"
                className="flex-1 h-14 flex items-center justify-center rounded-2xl bg-[var(--color-surface-container)] text-[var(--color-on-surface)] font-semibold"
              >
                Back
              </Link>
              <button
                type="submit"
                className="flex-1 h-14 rounded-2xl bg-gradient-to-r from-[#000e24] to-[#1a2d4d] text-white font-semibold"
              >
                Add Card
              </button>
            </div>
          </form>
        </div>
      </MobileLayout>
    </>
  );
}
