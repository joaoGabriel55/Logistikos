import { Head, Link } from '@inertiajs/react'
import MobileLayout from '@/components/layout/MobileLayout'
import Button from '@/components/ui/Button'

interface CustomerDashboardPageProps {
  stats: {
    total_orders: number
    active_orders: number
    completed_orders: number
  }
}

export default function Dashboard({ stats }: CustomerDashboardPageProps) {
  return (
    <>
      <Head title="Dashboard" />
      <MobileLayout withTopBar withBottomNav className="bg-surface-container-low">
        <div className="min-h-full px-4 py-6">
          <div className="mb-6">
            <h1 className="text-display-medium text-on-surface font-manrope">
              Dashboard
            </h1>
            <p className="text-body-medium text-on-surface-variant mt-2">
              Manage your deliveries
            </p>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-3 gap-3 mb-6">
            <div className="bg-surface-container rounded-2xl p-4 text-center">
              <div className="text-headline-large text-primary font-manrope">
                {stats.total_orders}
              </div>
              <div className="text-label-small text-on-surface-variant mt-1">Total</div>
            </div>
            <div className="bg-surface-container rounded-2xl p-4 text-center">
              <div className="text-headline-large text-secondary font-manrope">
                {stats.active_orders}
              </div>
              <div className="text-label-small text-on-surface-variant mt-1">Active</div>
            </div>
            <div className="bg-surface-container rounded-2xl p-4 text-center">
              <div className="text-headline-large text-tertiary font-manrope">
                {stats.completed_orders}
              </div>
              <div className="text-label-small text-on-surface-variant mt-1">Done</div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="bg-surface-container rounded-2xl p-6 mb-6">
            <h2 className="text-title-large text-on-surface font-manrope mb-4">
              Quick Actions
            </h2>
            <div className="space-y-3">
              <Button variant="primary" fullWidth>
                Create New Order
              </Button>
              <Button variant="secondary" fullWidth>
                View All Orders
              </Button>
            </div>
          </div>

          {/* Recent Orders - Empty State */}
          <div className="bg-surface-container rounded-2xl p-6">
            <h2 className="text-title-large text-on-surface font-manrope mb-4">
              Recent Orders
            </h2>
            <div className="flex flex-col items-center justify-center py-8">
              <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="w-8 h-8 text-primary"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
              </div>
              <p className="text-body-medium text-on-surface-variant text-center">
                No orders yet. Create your first delivery order to get started.
              </p>
            </div>
          </div>
        </div>
      </MobileLayout>
    </>
  )
}
