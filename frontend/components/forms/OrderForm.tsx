import clsx from 'clsx'
import { RiCalendarLine, RiFileTextLine, RiMoneyDollarCircleLine } from 'react-icons/ri'
import AddressInput from './AddressInput'
import ItemListInput from './ItemListInput'
import { DeliveryType, OrderItemInput } from '@/types/models'

interface OrderFormProps {
  formData: {
    pickup_address: string
    dropoff_address: string
    delivery_type: DeliveryType
    scheduled_at?: string
    description?: string
    suggested_price_cents?: number
    order_items_attributes: OrderItemInput[]
  }
  processing: boolean
  errors: Record<string, string>
  canSubmit: boolean
  hasPaymentMethod: boolean
  handlers: {
    handleSubmit: (e: React.FormEvent) => void
    setPickupAddress: (value: string) => void
    setDropoffAddress: (value: string) => void
    handleDeliveryTypeChange: (type: DeliveryType) => void
    setScheduledAt: (value: string) => void
    setDescription: (value: string) => void
    handlePriceChange: (value: string) => void
    handleAddItem: () => void
    handleRemoveItem: (index: number) => void
    handleItemChange: (index: number, field: keyof OrderItemInput, value: string | number) => void
  }
}

export default function OrderForm({
  formData,
  processing,
  errors,
  canSubmit,
  hasPaymentMethod,
  handlers
}: OrderFormProps) {
  const suggestedPriceDollars = formData.suggested_price_cents
    ? (formData.suggested_price_cents / 100).toFixed(2)
    : ''

  return (
    <form onSubmit={handlers.handleSubmit} className="space-y-6 pb-24">
      {/* Payment Method Warning */}
      {!hasPaymentMethod && (
        <div className="bg-secondary/10 border-l-4 border-secondary rounded-md p-4">
          <p className="text-body-md text-on-surface font-medium">
            Payment method required
          </p>
          <p className="text-body-sm text-on-surface-variant mt-1">
            You need to add a payment method before creating an order.
          </p>
          <a
            href="/payment_methods"
            className="inline-block mt-3 text-label-lg font-medium text-secondary hover:underline"
          >
            Add Payment Method
          </a>
        </div>
      )}

      {/* Addresses Section */}
      <section className="space-y-4">
        <h2 className="text-title-lg font-semibold text-on-surface">
          Delivery Details
        </h2>
        <AddressInput
          id="pickup_address"
          label="Pickup Address"
          value={formData.pickup_address}
          onChange={handlers.setPickupAddress}
          error={errors.pickup_address}
          placeholder="Enter pickup location"
        />
        <AddressInput
          id="dropoff_address"
          label="Drop-off Address"
          value={formData.dropoff_address}
          onChange={handlers.setDropoffAddress}
          error={errors.dropoff_address}
          placeholder="Enter drop-off location"
        />
      </section>

      {/* Delivery Type Section */}
      <section className="space-y-4">
        <h2 className="text-title-lg font-semibold text-on-surface">
          Delivery Time
        </h2>

        {/* Toggle Switch */}
        <div className="inline-flex bg-surface-container rounded-lg p-1">
          <button
            type="button"
            onClick={() => handlers.handleDeliveryTypeChange('immediate')}
            className={clsx(
              'px-6 py-2 rounded-md text-label-lg font-medium transition-all duration-200',
              formData.delivery_type === 'immediate'
                ? 'bg-primary text-white'
                : 'text-on-surface-variant hover:text-on-surface'
            )}
          >
            Immediate
          </button>
          <button
            type="button"
            onClick={() => handlers.handleDeliveryTypeChange('scheduled')}
            className={clsx(
              'px-6 py-2 rounded-md text-label-lg font-medium transition-all duration-200',
              formData.delivery_type === 'scheduled'
                ? 'bg-primary text-white'
                : 'text-on-surface-variant hover:text-on-surface'
            )}
          >
            Scheduled
          </button>
        </div>

        {/* Scheduled DateTime Picker */}
        {formData.delivery_type === 'scheduled' && (
          <div className="space-y-2">
            <label htmlFor="scheduled_at" className="block text-label-lg font-medium text-on-surface-variant">
              Schedule Date & Time
              <span className="text-secondary ml-1">*</span>
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <RiCalendarLine className="h-5 w-5 text-on-surface-variant" />
              </div>
              <input
                id="scheduled_at"
                type="datetime-local"
                value={formData.scheduled_at || ''}
                onChange={(e) => handlers.setScheduledAt(e.target.value)}
                className={clsx(
                  'input w-full pl-12 text-body-lg',
                  errors.scheduled_at && 'bg-secondary/5 ring-2 ring-secondary/20'
                )}
                required
              />
            </div>
            {errors.scheduled_at && (
              <p className="text-label-md text-secondary" role="alert">
                {errors.scheduled_at}
              </p>
            )}
          </div>
        )}
      </section>

      {/* Items Section */}
      <section className="space-y-4">
        <h2 className="text-title-lg font-semibold text-on-surface">
          Items to Deliver
        </h2>
        <ItemListInput
          items={formData.order_items_attributes}
          onAddItem={handlers.handleAddItem}
          onRemoveItem={handlers.handleRemoveItem}
          onItemChange={handlers.handleItemChange}
          error={errors.order_items}
        />
      </section>

      {/* Optional Details Section */}
      <section className="space-y-4">
        <h2 className="text-title-lg font-semibold text-on-surface">
          Additional Details (Optional)
        </h2>

        {/* Description */}
        <div className="space-y-2">
          <label htmlFor="description" className="block text-label-lg font-medium text-on-surface-variant">
            Description
          </label>
          <div className="relative">
            <div className="absolute top-4 left-0 pl-4 flex items-start pointer-events-none">
              <RiFileTextLine className="h-5 w-5 text-on-surface-variant" />
            </div>
            <textarea
              id="description"
              value={formData.description || ''}
              onChange={(e) => handlers.setDescription(e.target.value)}
              className={clsx(
                'input w-full pl-12 pt-3 pb-3 min-h-[96px] resize-none text-body-lg',
                errors.description && 'bg-secondary/5 ring-2 ring-secondary/20'
              )}
              placeholder="Add any special instructions or notes"
              maxLength={500}
              rows={3}
            />
          </div>
          <div className="flex justify-between items-center">
            <div>
              {errors.description && (
                <p className="text-label-md text-secondary" role="alert">
                  {errors.description}
                </p>
              )}
            </div>
            <span className="text-label-md text-on-surface-variant">
              {formData.description?.length || 0} / 500
            </span>
          </div>
        </div>

        {/* Suggested Price */}
        <div className="space-y-2">
          <label htmlFor="suggested_price" className="block text-label-lg font-medium text-on-surface-variant">
            Suggested Price (USD)
          </label>
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
              <RiMoneyDollarCircleLine className="h-5 w-5 text-on-surface-variant" />
            </div>
            <input
              id="suggested_price"
              type="number"
              value={suggestedPriceDollars}
              onChange={(e) => handlers.handlePriceChange(e.target.value)}
              className={clsx(
                'input w-full pl-12 text-body-lg',
                errors.suggested_price_cents && 'bg-secondary/5 ring-2 ring-secondary/20'
              )}
              placeholder="0.00"
              min="1.00"
              step="0.01"
            />
          </div>
          {errors.suggested_price_cents && (
            <p className="text-label-md text-secondary" role="alert">
              {errors.suggested_price_cents}
            </p>
          )}
          <p className="text-label-md text-on-surface-variant">
            Drivers will see this as a reference price. Final pricing may vary.
          </p>
        </div>
      </section>

      {/* Submit Button - Bottom safe area */}
      <div className="pb-20 px-4">
        <button
          type="submit"
          disabled={!canSubmit || processing}
          className="w-full h-14 rounded-2xl bg-gradient-to-r from-[#000e24] to-[#1a2d4d] text-white text-base font-semibold disabled:opacity-50 disabled:cursor-not-allowed transition-opacity"
        >
          {processing ? 'Creating Order...' : 'Create Order'}
        </button>
      </div>
    </form>
  )
}
