# Auth Components

This directory contains reusable components for authentication flows (registration, login, etc.). All components follow the Precision Logistikos design system.

## Components

### ProgressIndicator

Multi-step progress indicator with animated transitions between steps.

**Usage:**
```tsx
import { ProgressIndicator } from '@/components/auth'

<ProgressIndicator
  currentStep={2}
  steps={[
    { number: 1, label: 'Choose Role' },
    { number: 2, label: 'Your Details' }
  ]}
/>
```

**Props:**
- `currentStep: number` - Currently active step number
- `steps: StepConfig[]` - Array of step configurations with number and label

**Features:**
- Animated progress bar between steps
- Active step highlighted with gradient
- Responsive label visibility (hidden on small screens)
- Smooth scale transitions

---

### RoleCard

Interactive card for selecting user role (Customer/Driver) with glassmorphism effects.

**Usage:**
```tsx
import { RoleCard } from '@/components/auth'
import { RiShoppingBag3Line } from 'react-icons/ri'

<RoleCard
  title="I'm a Customer"
  description="Send packages and track deliveries in real-time"
  icon={RiShoppingBag3Line}
  actionText="Get Started"
  colorScheme="primary"
  onClick={() => handleRoleSelect('customer')}
/>
```

**Props:**
- `title: string` - Card title
- `description: string` - Card description text
- `icon: IconType` - React Icon component
- `actionText: string` - Call-to-action text
- `colorScheme: 'primary' | 'secondary'` - Color theme (primary for customer, secondary for driver)
- `onClick: () => void` - Click handler

**Features:**
- Hover gradient overlay
- Icon scale animation on hover
- Touch-optimized with scale feedback
- Border color changes on hover based on color scheme
- Animated arrow on action text

---

### VehicleOption

Selectable vehicle type option with icon, label, description, and checkmark indicator.

**Usage:**
```tsx
import { VehicleOption } from '@/components/auth'
import { RiCarLine } from 'react-icons/ri'

const option = {
  value: 'car',
  label: 'Car',
  icon: RiCarLine,
  description: 'Standard delivery'
}

<VehicleOption
  option={option}
  isSelected={selectedVehicle === 'car'}
  onSelect={(value) => setSelectedVehicle(value)}
/>
```

**Props:**
- `option: VehicleOptionConfig` - Vehicle option configuration
  - `value: string` - Option value
  - `label: string` - Display label
  - `icon: IconType` - React Icon component
  - `description: string` - Short description
- `isSelected: boolean` - Whether this option is currently selected
- `onSelect: (value: string) => void` - Selection handler

**Features:**
- Selected state with secondary color
- Checkmark indicator when selected
- Scale animation on selection
- Icon color changes based on selection
- Touch-optimized

---

### RadiusOption

Selectable radius preference option with distance label and description.

**Usage:**
```tsx
import { RadiusOption } from '@/components/auth'

const option = {
  value: '10',
  label: '10 km',
  description: 'Recommended'
}

<RadiusOption
  option={option}
  isSelected={selectedRadius === '10'}
  onSelect={(value) => setSelectedRadius(value)}
/>
```

**Props:**
- `option: RadiusOptionConfig` - Radius option configuration
  - `value: string` - Option value (distance in km)
  - `label: string` - Display label (e.g., "10 km")
  - `description: string` - Short description (e.g., "Recommended")
- `isSelected: boolean` - Whether this option is currently selected
- `onSelect: (value: string) => void` - Selection handler

**Features:**
- Large, bold distance label with Manrope font
- Selected state with secondary color
- Scale animation on selection
- Center-aligned layout
- Touch-optimized

---

### FormInput

Standardized form input field with icon, label, error handling, and helper text.

**Usage:**
```tsx
import { FormInput } from '@/components/auth'
import { RiMailLine } from 'react-icons/ri'

<FormInput
  id="email"
  label="Email address"
  type="email"
  value={email}
  onChange={(e) => setEmail(e.target.value)}
  icon={RiMailLine}
  error={errors.email}
  autoComplete="email"
  required
/>
```

**Props:**
- `id: string` - Input element ID
- `label: string` - Field label
- `type: 'text' | 'email' | 'password'` - Input type
- `value: string` - Current value
- `onChange: (e: ChangeEvent<HTMLInputElement>) => void` - Change handler
- `icon: IconType` - Left-aligned icon
- `error?: string` - Error message to display
- `autoComplete?: string` - Browser autocomplete hint
- `autoFocus?: boolean` - Auto-focus on mount
- `required?: boolean` - HTML5 required attribute
- `minLength?: number` - Minimum character length
- `helperText?: string` - Helper text (hidden when error is shown)

**Features:**
- Icon positioned on the left inside input
- Error state with red border and error message
- Helper text for guidance
- Accessible with proper labels and ARIA attributes
- Touch-optimized with 56px height
- Consistent padding for icon alignment

---

## Design System Compliance

All components follow the Precision Logistikos design system:

- **Colors**: Primary (`#000e24`) for customer theme, Secondary (`#a33800`) for driver/action states
- **Typography**: Manrope for display/headings, Inter for body/labels
- **Spacing**: Consistent use of design tokens (`spacing-*`)
- **Glassmorphism**: Applied to overlays and floating elements
- **No borders for sectioning**: Uses background color shifts instead
- **Touch Targets**: Minimum 44x44px for all interactive elements
- **Animations**: Smooth transitions with duration-200/300 for immediate feedback

## File Structure

```
components/auth/
├── README.md                 # This file
├── index.ts                  # Barrel exports
├── ProgressIndicator.tsx     # Multi-step progress indicator
├── RoleCard.tsx             # Role selection card
├── VehicleOption.tsx        # Vehicle type selector option
├── RadiusOption.tsx         # Radius preference option
└── FormInput.tsx            # Standardized form input
```

## Type Definitions

See `/frontend/types/registration.ts` for shared type definitions used across auth components.
