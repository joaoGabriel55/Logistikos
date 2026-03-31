# Driver Profile Components

This directory contains the modular components for the Driver Profile page, following the principles of component composition and separation of concerns.

## Architecture

The Driver Profile page has been refactored into:

1. **Custom Hook** (`useDriverProfile`) - Handles all business logic
2. **UI Components** - Pure presentational components

## Hook: `useDriverProfile`

Located in `/frontend/hooks/useDriverProfile.ts`

### Purpose
Centralizes all business logic for the driver profile page:
- Form state management (Inertia's useForm)
- Location fetching via Geolocation API
- Form submission
- Error handling
- State transformations

### Usage
```tsx
import { useDriverProfile } from '@/hooks/useDriverProfile'

const {
  formData,        // Current form values
  processing,      // Form submission state
  errors,          // Validation errors from backend
  locationState,   // { gettingLocation, locationError }
  handlers         // All event handlers
} = useDriverProfile({ profile })
```

### Returned Handlers
- `handleSubmit` - Form submission handler
- `handleAvailabilityToggle` - Toggle availability with auto-submit
- `handleVehicleSelect` - Select vehicle type
- `handleRadiusChange` - Update working radius
- `handleGetLocation` - Fetch current GPS location

## Components

### AvailabilityToggle

Glassmorphism sticky header with availability toggle switch.

**Props:**
```tsx
interface AvailabilityToggleProps {
  isAvailable: boolean
  onToggle: () => void
}
```

**Features:**
- Sticky positioning with glassmorphism effect
- Visual feedback with check icon when available
- Smooth transitions
- Accessible switch role

---

### VehicleTypeSelector

2x2 grid of vehicle type cards (motorcycle, car, van, truck).

**Props:**
```tsx
interface VehicleTypeSelectorProps {
  selectedVehicleType: string
  onSelect: (vehicleType: VehicleType) => void
  error?: string
}
```

**Features:**
- 4 vehicle options with icons and descriptions
- Visual selection state with ring and check indicator
- Responsive grid layout
- Touch-optimized tap targets

---

### RadiusSlider

Working radius slider with visual feedback.

**Props:**
```tsx
interface RadiusSliderProps {
  value: number
  onChange: (value: number) => void
  error?: string
}
```

**Features:**
- Range: 5-50km in 5km increments
- Large display of current value
- Dynamic slider background (filled portion changes color)
- Range labels at min/max

---

### LocationSection

GPS location display and update button.

**Props:**
```tsx
interface LocationSectionProps {
  latitude: number | null
  longitude: number | null
  locationUpdatedAt?: string
  locationAccuracy?: number
  gettingLocation: boolean
  locationError: string | null
  onGetLocation: () => void
  error?: string
}
```

**Features:**
- Shows coordinates, last updated time, and accuracy
- Empty state when no location set
- Loading state while fetching
- Error display for permission/timeout issues
- High-accuracy GPS positioning

---

## Design System Compliance

All components follow the Precision Logistikos design system:

- **No borders** - Uses background color shifts for section boundaries
- **Touch targets** - Minimum 44x44px for all interactive elements
- **Typography** - Manrope for display, Inter for body text
- **Colors** - Primary (#000e24), Secondary (#a33800), surface variants
- **Glassmorphism** - Sticky header uses glass effect with backdrop blur

## File Structure

```
frontend/
  hooks/
    useDriverProfile.ts           # Business logic hook
  components/
    driver/
      profile/
        AvailabilityToggle.tsx    # Sticky header with toggle
        VehicleTypeSelector.tsx   # Vehicle type grid
        RadiusSlider.tsx          # Working radius slider
        LocationSection.tsx       # GPS location management
        index.ts                  # Barrel export
        README.md                 # This file
```

## Benefits of This Architecture

1. **Separation of Concerns**
   - Business logic is isolated in the hook
   - UI components are purely presentational
   - Easy to test each piece independently

2. **Reusability**
   - Components can be used elsewhere if needed
   - Hook can be tested without UI
   - Each component has a single responsibility

3. **Maintainability**
   - Clear boundaries between concerns
   - Smaller, focused files
   - Easy to locate and update specific functionality

4. **Type Safety**
   - All components are fully typed
   - Props interfaces clearly define contracts
   - TypeScript catches errors at compile time

5. **Performance**
   - Components only re-render when their props change
   - Business logic doesn't trigger unnecessary UI updates
   - Optimal React reconciliation

## Usage Example

```tsx
import { useDriverProfile } from '@/hooks/useDriverProfile'
import {
  AvailabilityToggle,
  VehicleTypeSelector,
  RadiusSlider,
  LocationSection
} from '@/components/driver/profile'

export default function Profile({ profile }: DriverProfilePageProps) {
  const { formData, processing, errors, locationState, handlers } =
    useDriverProfile({ profile })

  return (
    <form onSubmit={handlers.handleSubmit}>
      <AvailabilityToggle
        isAvailable={formData.is_available}
        onToggle={handlers.handleAvailabilityToggle}
      />

      <VehicleTypeSelector
        selectedVehicleType={formData.vehicle_type}
        onSelect={handlers.handleVehicleSelect}
        error={errors.vehicle_type}
      />

      {/* ... other components */}
    </form>
  )
}
```
