import { useForm } from '@inertiajs/react'
import { useState } from 'react'
import { DeliveryType, OrderItemInput } from '@/types/models'

interface OrderFormData {
  pickup_address: string
  dropoff_address: string
  delivery_type: DeliveryType
  scheduled_at?: string
  description?: string
  suggested_price_cents?: number
  order_items_attributes: OrderItemInput[]
}

interface UseOrderFormOptions {
  hasPaymentMethod: boolean
}

interface ValidationErrors {
  pickup_address?: string
  dropoff_address?: string
  scheduled_at?: string
  suggested_price_cents?: string
  description?: string
  order_items?: string
}

export function useOrderForm({ hasPaymentMethod }: UseOrderFormOptions) {
  const { data, setData, post, processing, errors: serverErrors } = useForm<OrderFormData>({
    pickup_address: '',
    dropoff_address: '',
    delivery_type: 'immediate',
    scheduled_at: undefined,
    description: '',
    suggested_price_cents: undefined,
    order_items_attributes: [{ name: '', quantity: 1, size: 'medium' }]
  })

  const [clientErrors, setClientErrors] = useState<ValidationErrors>({})

  function validateForm(): boolean {
    const errors: ValidationErrors = {}

    // Pickup address validation
    if (!data.pickup_address || data.pickup_address.trim().length < 5) {
      errors.pickup_address = 'Pickup address must be at least 5 characters'
    }

    // Dropoff address validation
    if (!data.dropoff_address || data.dropoff_address.trim().length < 5) {
      errors.dropoff_address = 'Drop-off address must be at least 5 characters'
    } else if (data.dropoff_address.trim() === data.pickup_address.trim()) {
      errors.dropoff_address = 'Drop-off address must be different from pickup address'
    }

    // Scheduled datetime validation
    if (data.delivery_type === 'scheduled') {
      if (!data.scheduled_at) {
        errors.scheduled_at = 'Scheduled date and time is required'
      } else {
        const scheduledTime = new Date(data.scheduled_at)
        const now = new Date()
        if (scheduledTime <= now) {
          errors.scheduled_at = 'Scheduled time must be in the future'
        }
      }
    }

    // Suggested price validation
    if (data.suggested_price_cents !== undefined && data.suggested_price_cents !== null) {
      if (data.suggested_price_cents < 100) {
        errors.suggested_price_cents = 'Minimum price is $1.00'
      }
    }

    // Description validation
    if (data.description && data.description.length > 500) {
      errors.description = 'Description must be 500 characters or less'
    }

    // Order items validation
    if (data.order_items_attributes.length === 0) {
      errors.order_items = 'At least one item is required'
    } else {
      const hasInvalidItem = data.order_items_attributes.some(
        item => !item.name || item.name.trim().length === 0 || item.quantity < 1
      )
      if (hasInvalidItem) {
        errors.order_items = 'All items must have a name and quantity of at least 1'
      }
    }

    setClientErrors(errors)
    return Object.keys(errors).length === 0
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    if (!hasPaymentMethod) {
      // This should be handled by the UI, but double-check
      return
    }

    if (!validateForm()) {
      return
    }

    // Clear client errors on successful validation
    setClientErrors({})

    // Submit via Inertia
    post('/delivery_orders', {
      preserveScroll: true,
      onSuccess: () => {
        // Navigation will be handled by the controller
      }
    })
  }

  function handleDeliveryTypeChange(type: DeliveryType) {
    setData('delivery_type', type)
    if (type === 'immediate') {
      setData('scheduled_at', undefined)
      // Clear scheduled_at error when switching to immediate
      setClientErrors(prev => ({ ...prev, scheduled_at: undefined }))
    }
  }

  function handleAddItem() {
    if (data.order_items_attributes.length >= 20) {
      setClientErrors(prev => ({ ...prev, order_items: 'Maximum 20 items allowed' }))
      return
    }
    setData('order_items_attributes', [
      ...data.order_items_attributes,
      { name: '', quantity: 1, size: 'medium' }
    ])
  }

  function handleRemoveItem(index: number) {
    if (data.order_items_attributes.length === 1) {
      setClientErrors(prev => ({ ...prev, order_items: 'At least one item is required' }))
      return
    }
    const newItems = data.order_items_attributes.filter((_, i) => i !== index)
    setData('order_items_attributes', newItems)
    // Clear error when removing items
    if (newItems.length > 0) {
      setClientErrors(prev => ({ ...prev, order_items: undefined }))
    }
  }

  function handleItemChange(index: number, field: keyof OrderItemInput, value: string | number) {
    const newItems = [...data.order_items_attributes]
    newItems[index] = { ...newItems[index], [field]: value }
    setData('order_items_attributes', newItems)
    // Clear item error when user starts typing
    if (clientErrors.order_items) {
      setClientErrors(prev => ({ ...prev, order_items: undefined }))
    }
  }

  function handlePriceChange(value: string) {
    if (value === '') {
      setData('suggested_price_cents', undefined)
    } else {
      const dollars = parseFloat(value)
      if (!isNaN(dollars)) {
        setData('suggested_price_cents', Math.round(dollars * 100))
      }
    }
  }

  // Combine client and server errors
  const allErrors = {
    ...clientErrors,
    ...serverErrors
  }

  // Check if form is valid for submission
  const canSubmit: boolean =
    hasPaymentMethod &&
    data.pickup_address.trim().length >= 5 &&
    data.dropoff_address.trim().length >= 5 &&
    data.order_items_attributes.length > 0 &&
    data.order_items_attributes.every(item => item.name.trim().length > 0 && item.quantity > 0) &&
    (data.delivery_type === 'immediate' || (data.delivery_type === 'scheduled' && !!data.scheduled_at))

  return {
    formData: data,
    processing,
    errors: allErrors,
    canSubmit,
    handlers: {
      handleSubmit,
      setPickupAddress: (value: string) => setData('pickup_address', value),
      setDropoffAddress: (value: string) => setData('dropoff_address', value),
      handleDeliveryTypeChange,
      setScheduledAt: (value: string) => setData('scheduled_at', value),
      setDescription: (value: string) => setData('description', value),
      handlePriceChange,
      handleAddItem,
      handleRemoveItem,
      handleItemChange
    }
  }
}
