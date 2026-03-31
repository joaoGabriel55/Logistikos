import MobileLayout from "@/components/layout/MobileLayout";
import { Head, Link } from "@inertiajs/react";

interface PaymentMethod {
  id: number;
  card_brand: string;
  last_four: string;
  expires_at: string | null;
  is_default: boolean;
  is_expired: boolean;
  gateway_provider: string;
  created_at: string;
}

interface Props {
  payment_methods: PaymentMethod[];
}

export default function Index({ payment_methods }: Props) {
  return (
    <>
      <Head title="Payment Methods" />
      <MobileLayout withTopBar className="bg-surface-container-low">
        <div className="px-4 py-6">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-[var(--color-on-surface)] mb-2">
              Payment Methods
            </h1>
            <p className="text-sm text-[var(--color-on-surface-variant)]">
              Manage your payment methods for deliveries
            </p>
          </div>

          {payment_methods.length === 0 ? (
            <div className="bg-[var(--color-surface-container)] rounded-2xl p-6 text-center">
              <p className="text-[var(--color-on-surface-variant)] mb-4">
                No payment methods on file
              </p>
              <Link
                href="/payment_methods/new"
                className="inline-block px-6 py-3 bg-gradient-to-r from-[#000e24] to-[#1a2d4d] text-white rounded-xl font-semibold"
              >
                Add Payment Method
              </Link>
            </div>
          ) : (
            <div className="space-y-3">
              {payment_methods.map((pm) => (
                <div
                  key={pm.id}
                  className="bg-[var(--color-surface-container)] rounded-2xl p-4"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="font-semibold text-[var(--color-on-surface)]">
                        {pm.card_brand} •••• {pm.last_four}
                      </div>
                      <div className="text-sm text-[var(--color-on-surface-variant)]">
                        {pm.expires_at ? (
                          <>
                            Expires{" "}
                            {new Date(pm.expires_at).toLocaleDateString(
                              "en-US",
                              {
                                month: "short",
                                year: "numeric",
                              },
                            )}
                            {pm.is_expired && (
                              <span className="ml-2 text-[var(--color-error)]">
                                Expired
                              </span>
                            )}
                          </>
                        ) : (
                          "No expiration"
                        )}
                      </div>
                      {pm.is_default && (
                        <span className="inline-block mt-1 text-xs bg-[var(--color-primary-container)] text-[var(--color-on-primary-container)] px-2 py-1 rounded">
                          Default
                        </span>
                      )}
                    </div>
                    <form
                      method="post"
                      action={`/payment_methods/${pm.id}`}
                      onSubmit={(e) => {
                        if (!confirm("Remove this payment method?")) {
                          e.preventDefault();
                        }
                      }}
                    >
                      <input type="hidden" name="_method" value="delete" />
                      <button
                        type="submit"
                        className="text-[var(--color-error)] text-sm font-medium"
                      >
                        Remove
                      </button>
                    </form>
                  </div>
                </div>
              ))}

              <Link
                href="/payment_methods/new"
                className="block text-center py-3 bg-[var(--color-surface-container)] rounded-xl text-[var(--color-primary)] font-semibold"
              >
                + Add Payment Method
              </Link>
            </div>
          )}

          <div className="mt-8 p-4 bg-[var(--color-surface-container)] rounded-2xl">
            <p className="text-sm text-[var(--color-on-surface-variant)]">
              <strong className="text-[var(--color-on-surface)]">Note:</strong>{" "}
              Full payment method management (adding cards, editing) will be
              available in Ticket 030. This is a placeholder for MVP.
            </p>
          </div>
        </div>
      </MobileLayout>
    </>
  );
}
