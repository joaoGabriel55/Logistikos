# Multi-Step Registration Flow

**Date:** 2026-03-30
**Feature:** Enhanced registration UX with step-by-step role-specific forms

## Overview

Improved the registration flow to be a beautiful, intuitive multi-step process that adapts based on user role selection. Uses the Precision Logistikos design system with glassmorphism, smooth transitions, and mobile-first design.

## User Experience Flow

### Step 1: Role Selection
- **Visual Design:** Large, touch-friendly cards with distinctive icons and gradients
- **Customer Card:** Shopping bag icon with primary color gradient (deep navy)
- **Driver Card:** Truck icon with secondary color gradient (burnt orange)
- **Features:**
  - Hover effects with scale and shadow animations
  - Gradient overlays on hover
  - Clear call-to-action text ("Get Started" / "Start Earning")
  - Google OAuth option above role selection

### Step 2: Registration Form (Role-Specific)

#### Customer Form (Simple)
- Full name
- Email address
- Password
- Password confirmation

#### Driver Form (Extended)
Includes all customer fields plus:

**Vehicle Type Selection:**
- Motorcycle (Fast & nimble)
- Car (Standard delivery)
- Van (Medium cargo)
- Truck (Large cargo)

Visual design: Grid of cards with icons, selected state with checkmark and accent color

**Delivery Radius:**
- 5 km (City center)
- 10 km (Recommended) - default
- 25 km (Metropolitan)
- 50 km (Wide range)

Visual design: Grid of cards with large numbers, selected state highlighted

## Design System Implementation

### Colors & Styling
- **Primary Gradient:** `#000e24` → `#00234b` (deep navy, used for customer cards)
- **Secondary Gradient:** `#a33800` → lighter variation (burnt orange, used for driver cards)
- **Background:** `#f8f9fb` (cool-toned light gray)
- **Glassmorphism:** Applied to main card with backdrop blur

### Typography
- **Manrope:** Display font for headings ("Join Logistikos")
- **Inter:** Body font for form labels and descriptions

### Touch Targets
- All interactive elements meet 44x44dp minimum
- Large form inputs (56px height)
- Generous padding on buttons and cards

### Animations
- Fade-in animation on step transitions
- Progress indicator with animated fill
- Hover effects: scale, shadow, gradient overlays
- Active state feedback on all interactive elements

## Technical Implementation

### Frontend (`frontend/pages/Auth/Register.tsx`)

**State Management:**
```typescript
const [step, setStep] = useState<1 | 2>(1)
const { data, setData, post, processing, errors } = useForm({
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
  role: '' as UserRole | '',
  vehicle_type: 'car' as VehicleType,
  radius_preference_km: '10'
})
```

**Key Features:**
- Step-by-step progression with back navigation
- Progress indicator showing current step
- Conditional form fields based on role
- Inline validation with error display
- Smooth animations between steps

### Backend (`app/controllers/registrations_controller.rb`)

**Driver Profile Creation:**
```ruby
if user.driver?
  user.create_driver_profile!(
    vehicle_type: params[:vehicle_type] || :car,
    is_available: false,
    radius_preference_km: params[:radius_preference_km] || 10.0
  )
end
```

**Validation:**
- Role must be "customer" or "driver"
- Driver profile uses submitted values or sensible defaults
- Transaction ensures atomic user + profile creation

## Testing

### Specs Updated
- ✅ Customer registration with simple form
- ✅ Driver registration with default profile values
- ✅ Driver registration with custom vehicle type and radius
- ✅ Role validation
- ✅ Error handling

**Test Results:** 16 examples, 0 failures

## Accessibility

- Semantic HTML with proper labels
- ARIA labels on error messages
- Focus management on form fields
- Keyboard navigation support
- High contrast ratios (WCAG AA compliant)
- Touch-friendly targets (44x44dp minimum)

## Mobile Experience

- Mobile-first design approach
- Responsive grid layouts (1 column on mobile, 2-4 on desktop)
- Large, touch-friendly controls
- Optimized for 375-428px viewports
- Glassmorphism effects optimized for mobile performance

## Future Enhancements

- [ ] Add form field validation feedback in real-time
- [ ] Include profile picture upload for drivers
- [ ] Add vehicle license plate field
- [ ] Email verification step
- [ ] SMS verification for drivers
- [ ] Progressive profiling (complete profile after registration)
