# Logistikos Component Library

This directory contains the foundational UI components for the Logistikos marketplace, implementing the **Precision Logistikos** design system.

## Design Principles

All components follow these core principles from `DESIGN.md`:

1. **The No-Line Rule**: No borders for sectioning. Use background color shifts and tonal layering instead.
2. **Surface Hierarchy**: Cards sit on sections via tonal contrast (e.g., `surface-container-lowest` on `surface-container-low`).
3. **Touch Targets**: All interactive elements meet 44x44px minimum for mobile usability.
4. **Glassmorphism**: Floating elements use `surface-tint` at 80% opacity with 20px backdrop blur.
5. **Mobile-First**: Primary viewport 375-428px with safe area handling for iOS/Android.

---

## UI Components (`/ui`)

### Button

Three variants following the design system:

```tsx
import { Button } from '@/components/ui'

// Primary - Gradient CTA
<Button variant="primary" onClick={handleSubmit}>
  Accept Order
</Button>

// Action - Solid secondary color for critical actions
<Button variant="action" onClick={handleUrgent}>
  Start Delivery
</Button>

// Tertiary - Text-only with icon
<Button variant="tertiary" onClick={handleCancel}>
  Cancel
</Button>

// With loading state
<Button variant="primary" loading={isSubmitting}>
  Processing...
</Button>
```

**Props:**
- `variant`: `'primary' | 'action' | 'tertiary' | 'secondary'`
- `loading`: boolean
- `fullWidth`: boolean
- `disabled`: boolean
- All standard HTML button attributes

**Design Notes:**
- Primary uses gradient from `#000e24` to `#00234b`
- Action uses solid `#a33800` (secondary color)
- All variants meet 44x44px touch target
- 0.75rem border radius per design system

---

### LoadingSpinner

Centered loading indicator using primary color:

```tsx
import { LoadingSpinner } from '@/components/ui'

<LoadingSpinner size="md" />
```

**Props:**
- `size`: `'sm' | 'md' | 'lg'`
- `className`: string

**Design Notes:**
- Uses primary color (`#000e24`)
- Centered by default
- CSS animation for 60fps performance

---

### EmptyState

Display for empty data states:

```tsx
import { EmptyState } from '@/components/ui'
import { RiInboxLine } from 'react-icons/ri'

<EmptyState
  title="No orders yet"
  description="When you create an order, it will appear here"
  icon={<RiInboxLine className="w-16 h-16" />}
  action={<Button variant="primary">Create Order</Button>}
/>
```

**Props:**
- `title`: string (required)
- `description`: string
- `icon`: ReactNode
- `action`: ReactNode
- `className`: string

**Design Notes:**
- Uses `on-surface-variant` color for secondary text
- Icon at 50% opacity for subtle presence
- Manrope font for title

---

### BottomSheet

Mobile-optimized modal that slides up from bottom:

```tsx
import { BottomSheet } from '@/components/ui'

const [isOpen, setIsOpen] = useState(false)

<BottomSheet
  isOpen={isOpen}
  onClose={() => setIsOpen(false)}
  title="Filter Orders"
>
  <div className="space-y-4">
    {/* Sheet content */}
  </div>
</BottomSheet>
```

**Props:**
- `isOpen`: boolean (required)
- `onClose`: () => void (required)
- `title`: string
- `children`: ReactNode (required)
- `className`: string

**Features:**
- Backdrop blur overlay
- Escape key to close
- Prevents body scroll when open
- Drag handle indicator
- Max height 90vh with scroll
- Surface-container-lowest background

**Design Notes:**
- No border dividers (uses background color shift for title)
- Ambient shadow for depth
- Rounded top corners

---

## Layout Components (`/layout`)

### MobileLayout

Page wrapper with proper surface background and safe area handling:

```tsx
import { MobileLayout } from '@/components/layout'

<MobileLayout withTopBar withBottomNav>
  <div className="p-4">
    {/* Page content */}
  </div>
</MobileLayout>
```

**Props:**
- `children`: ReactNode (required)
- `withTopBar`: boolean - adds top padding for TopBar
- `withBottomNav`: boolean - adds bottom padding for BottomNav
- `className`: string

**Design Notes:**
- Sets `bg-surface` background (`#f8f9fb`)
- Handles iOS/Android safe areas with `env(safe-area-inset-*)`
- Full height viewport
- Flexible main content area

---

### TopBar

Glassmorphism sticky header for page titles:

```tsx
import { TopBar } from '@/components/layout'

// With back button
<TopBar
  title="Order Details"
  showBack
  backHref="/orders"
/>

// With menu button
<TopBar
  title="Dashboard"
  showMenu
  onMenuClick={() => setMenuOpen(true)}
/>

// With custom right action
<TopBar
  title="Active Delivery"
  showBack
  rightAction={
    <button className="text-secondary">Help</button>
  }
/>
```

**Props:**
- `title`: string (required)
- `showBack`: boolean
- `onBack`: () => void
- `backHref`: string - uses Inertia Link if provided
- `showMenu`: boolean
- `onMenuClick`: () => void
- `rightAction`: ReactNode
- `className`: string

**Design Notes:**
- Fixed position with glassmorphism (`surface-tint` 80% opacity + 20px blur)
- Manrope font for title
- 44x44px touch targets for back/menu buttons
- Safe area top padding for notched devices
- Z-index 30 for proper layering

---

### BottomNav

Persistent bottom navigation with 4 tabs:

```tsx
import { BottomNav } from '@/components/layout'

// Place outside page content (typically in layout)
<BottomNav />
```

**Navigation Items:**
1. **Feed** - `/driver/feed` (Grid icon)
2. **Orders** - `/orders` (File list icon)
3. **Map** - `/map` (Map pin icon)
4. **Profile** - `/profile` (User icon)

**Props:**
- `className`: string

**Features:**
- Active state detection via Inertia `usePage().url`
- Pattern matching for route prefixes
- Filled icons for active state
- Secondary color (`#a33800`) for active items
- Inertia Link components for SPA navigation

**Design Notes:**
- Fixed position with glassmorphism
- Ghost border top (15% opacity per design system)
- Safe area bottom padding for home indicator
- 44x44px touch targets
- `label-md` (0.75rem) font size for labels
- Z-index 30 for proper layering

---

## Design System Tokens

### Colors
- Primary: `#000e24` (Deep Navy)
- Secondary: `#a33800` (Burnt Orange - Actions/CTAs only)
- Surface: `#f8f9fb` (Cool-toned background)
- Surface Container Low: `#f3f4f6` (Section background)
- Surface Container Lowest: `#ffffff` (Card background)
- On-Surface: `#191c1e` (Primary text)
- On-Surface Variant: `#43474e` (Secondary text)

### Typography
- Font families: `font-display` (Manrope), `font-body` (Inter)
- Display: `text-display-md` (2.75rem)
- Title: `text-title-md` (1.125rem)
- Label: `text-label-md` (0.75rem)

### Spacing
- `spacing-5`: 1.1rem (vertical card separation)
- `spacing-8`: 1.75rem (section breathing room)

### Effects
- Glassmorphism: `.glass` class
- Ambient Shadow: `.shadow-ambient` or `shadow-ambient`
- Ghost Border: `.border-ghost` class
- Gradient Primary: `.gradient-primary` utility

---

## Usage Examples

### Complete Page Layout

```tsx
import { MobileLayout, TopBar, BottomNav } from '@/components/layout'
import { Button, EmptyState } from '@/components/ui'

export default function OrdersPage({ orders }) {
  return (
    <>
      <TopBar title="My Orders" />

      <MobileLayout withTopBar withBottomNav>
        <div className="bg-surface-container-low p-4 space-y-5">
          {orders.length === 0 ? (
            <EmptyState
              title="No orders yet"
              description="Create your first delivery order to get started"
              action={
                <Button variant="primary" href="/orders/new">
                  Create Order
                </Button>
              }
            />
          ) : (
            orders.map(order => (
              <OrderCard key={order.id} order={order} />
            ))
          )}
        </div>
      </MobileLayout>

      <BottomNav />
    </>
  )
}
```

### Card Component Pattern

```tsx
// Following the No-Line Rule: use background shifts, not borders
function OrderCard({ order }) {
  return (
    <div className="bg-surface-container-lowest rounded-md shadow-ambient p-4">
      {/* Priority indicator - 4px accent bar */}
      {order.priority && (
        <div className="absolute left-0 top-0 bottom-0 w-1 bg-secondary-fixed rounded-l-md" />
      )}

      {/* Intentional asymmetry - main data left, price right */}
      <div className="flex justify-between items-start">
        <div>
          <h3 className="font-display font-semibold text-on-surface">
            #{order.id}
          </h3>
          <p className="text-body-md text-on-surface-variant">
            {order.pickupAddress}
          </p>
        </div>
        <div className="text-title-md font-semibold text-on-surface">
          ${order.price}
        </div>
      </div>
    </div>
  )
}
```

---

## Accessibility

All components meet WCAG AA standards:

- Color contrast ratios meet minimum requirements
- Keyboard navigation supported
- Focus states visible
- Screen reader labels (ARIA) on interactive elements
- Minimum 44x44px touch targets
- Semantic HTML elements

---

## Performance

- Components are tree-shakeable
- CSS transforms for 60fps animations
- Lazy-loaded routes
- Font-display: swap for web fonts
- No inline styles except dynamic values

---

## Testing

Each component should have:
- Unit tests for props and states
- Accessibility audits
- Touch target validation
- Visual regression tests

---

## Migration Notes

When migrating existing pages to this design system:

1. Remove all border utilities (`border-*`)
2. Use surface hierarchy for depth (`bg-surface-container-lowest` on `bg-surface-container-low`)
3. Replace custom buttons with `<Button>` component
4. Wrap pages with `<MobileLayout>` + `<TopBar>` + `<BottomNav>`
5. Use `spacing-5` between cards (1.1rem vertical whitespace)
6. Apply glassmorphism (`.glass`) to floating elements only

---

For complete design specifications, see `/DESIGN.md`.
