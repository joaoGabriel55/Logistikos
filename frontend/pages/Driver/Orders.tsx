import { Head, Link } from '@inertiajs/react'
import MobileLayout from '@/components/layout/MobileLayout'
import Button from '@/components/ui/Button'

interface DriverOrdersPageProps {
  orders: any[]
}

export default function Orders({ orders }: DriverOrdersPageProps) {
  return (
    <>
      <Head title="Available Orders" />
      <MobileLayout withTopBar withBottomNav className="bg-surface-container-low">
        <div className="min-h-full px-4 py-6">
          <div className="mb-6">
            <h1 className="text-display-medium text-on-surface font-manrope">
              Available Orders
            </h1>
            <p className="text-body-medium text-on-surface-variant mt-2">
              Accept delivery orders in your area
            </p>
          </div>

          {orders.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 px-4">
              <div className="w-24 h-24 bg-primary/10 rounded-full flex items-center justify-center mb-6">
                <svg
                  className="w-12 h-12 text-primary"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                  />
                </svg>
              </div>
              <h2 className="text-title-large text-on-surface font-manrope mb-2">
                No Orders Available
              </h2>
              <p className="text-body-medium text-on-surface-variant text-center mb-6">
                There are no delivery orders in your area right now. Check back later or adjust
                your availability settings.
              </p>
              <Link href="/driver_profile">
                <Button variant="primary">Update Profile</Button>
              </Link>
            </div>
          ) : (
            <div className="space-y-4">
              {orders.map((order, index) => (
                <div
                  key={index}
                  className="bg-surface-container rounded-2xl p-4 shadow-ambient"
                >
                  <p className="text-body-medium text-on-surface-variant">
                    Order #{order.id}
                  </p>
                </div>
              ))}
            </div>
          )}
        </div>
      </MobileLayout>
    </>
  )
}
