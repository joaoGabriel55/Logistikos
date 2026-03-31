import { Head } from '@inertiajs/react'
import MobileLayout from '@/components/layout/MobileLayout'
import OrderForm from '@/components/forms/OrderForm'
import { OrderCreatePageProps } from '@/types/inertia'
import { useOrderForm } from '@/hooks/useOrderForm'

export default function OrderCreate({ has_payment_method = false }: OrderCreatePageProps) {
  const hasPaymentMethod = Boolean(has_payment_method)

  const {
    formData,
    processing,
    errors,
    canSubmit,
    handlers
  } = useOrderForm({ hasPaymentMethod })

  return (
    <>
      <Head title="Create Order" />
      <MobileLayout withTopBar withBottomNav className="bg-surface-container-low">
        <div className="min-h-full">
          {/* Page Header */}
          <div className="px-4 pt-6 pb-4">
            <h1 className="text-display-sm font-display font-bold text-primary">
              New Delivery
            </h1>
            <p className="text-body-md text-on-surface-variant mt-2">
              Fill in the details to create your delivery order
            </p>
          </div>

          {/* Order Form */}
          <div className="px-4">
            <OrderForm
              formData={formData}
              processing={processing}
              errors={errors}
              canSubmit={canSubmit}
              hasPaymentMethod={hasPaymentMethod}
              handlers={handlers}
            />
          </div>
        </div>
      </MobileLayout>
    </>
  )
}
