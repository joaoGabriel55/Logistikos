# Order Form Components

This directory contains form components for the order creation flow (Ticket 008).

## Component Architecture

Following the Component Architecture Standard, the order creation feature is split into:

1. **Custom Hook** (`useOrderForm.ts`): Handles all business logic
   - Form state management via Inertia's `useForm`
   - Client-side validation
   - Form submission
   - Item management (add/remove/update)
   
2. **Presentational Components**: Small, focused UI components
   - `AddressInput.tsx`: Address input field with icon and validation
   - `ItemListInput.tsx`: Dynamic item list with add/remove functionality
   - `OrderForm.tsx`: Main form composition that uses the above components
   
3. **Page Component** (`OrderCreate.tsx`): Compositional page that uses the hook and form

## Components

### AddressInput

Reusable address input field following the design system.

**Features:**
- Map pin icon
- 56px height (design system requirement)
- Error state with background tint
- Required indicator
- Accessible label and error message

**Usage:**
```tsx
<AddressInput
  id="pickup_address"
  label="Pickup Address"
  value={formData.pickup_address}
  onChange={handlers.setPickupAddress}
  error={errors.pickup_address}
  placeholder="Enter pickup location"
/>
```

### ItemListInput

Dynamic list of items with add/remove functionality.

**Features:**
- Add items (up to 20)
- Remove items (minimum 1)
- Each item has: name, quantity, size (small/medium/large/bulk)
- Card-based layout with tonal layering
- Touch-optimized buttons (44x44px minimum)
- No borders between items (design system requirement)

**Usage:**
```tsx
<ItemListInput
  items={formData.order_items_attributes}
  onAddItem={handlers.handleAddItem}
  onRemoveItem={handlers.handleRemoveItem}
  onItemChange={handlers.handleItemChange}
  error={errors.order_items}
/>
```

### OrderForm

Main form component that composes all form sections.

**Features:**
- Payment method warning (if not set)
- Delivery details (pickup/dropoff addresses)
- Delivery type toggle (immediate/scheduled)
- Datetime picker (shown only for scheduled deliveries)
- Dynamic item list
- Optional description textarea (500 char limit with counter)
- Optional suggested price input (USD, converted to cents)
- Fixed submit button at bottom
- Primary gradient button styling
- Loading state during submission

**Usage:**
```tsx
<OrderForm
  formData={formData}
  processing={processing}
  errors={errors}
  canSubmit={canSubmit}
  hasPaymentMethod={has_payment_method}
  handlers={handlers}
/>
```

## Design System Compliance

All components follow the Precision Logistikos design system:

- **No borders** for sectioning (use background color shifts)
- **56px input height** for touch optimization
- **44x44px minimum tap targets** for all interactive elements
- **Surface hierarchy**: Cards on section backgrounds via tonal contrast
- **Typography**: Inter for body/labels, proper sizing tokens
- **Colors**: Primary (#000e24), Secondary (#a33800), Surface tokens
- **Error states**: Background tint with secondary color, not borders
- **Spacing**: Proper vertical whitespace (spacing-3, spacing-5)

## Validation

Validation is handled in two layers:

1. **Client-side** (in `useOrderForm` hook):
   - Real-time validation as user types
   - Prevents submission of invalid forms
   - Clear error messages

2. **Server-side** (Rails backend):
   - Final validation in `Orders::Creator` service
   - Errors flow back via Inertia and displayed inline

### Validation Rules

- **Pickup address**: Required, min 5 characters
- **Dropoff address**: Required, min 5 characters, different from pickup
- **Delivery type**: Required (immediate/scheduled)
- **Scheduled datetime**: Required if scheduled, must be future
- **Items**: At least 1, max 20
- **Item name**: Required, 1-100 characters
- **Item quantity**: Required, 1-999
- **Item size**: Required (small/medium/large/bulk)
- **Description**: Optional, max 500 characters
- **Suggested price**: Optional, minimum $1.00

## Accessibility

- Semantic HTML elements
- Proper label associations
- ARIA attributes for error messages (`role="alert"`)
- Keyboard navigation support
- Focus states on all inputs
- Touch-optimized tap targets

## Future Enhancements

- Address autocomplete (currently plain text input)
- Item photos upload
- Order templates
- Multi-stop deliveries
