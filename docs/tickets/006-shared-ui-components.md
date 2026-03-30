# Ticket 006: Shared UI Components

## Description
Build the foundational reusable component library following DESIGN.md specifications. This includes base UI components (Button, BottomSheet, LoadingSpinner, EmptyState) and layout components (MobileLayout, BottomNav, TopBar). All components enforce the design system: no borders, surface hierarchy, 44px minimum touch targets, mobile-first.

## Acceptance Criteria
- [ ] **Button** component with 3 variants per DESIGN.md section 5:
  - Primary: gradient fill (`#000e24` to `#00234b`), rounded `md` (0.75rem), white text
  - Action/Secondary: solid `#a33800` background
  - Tertiary: no background, `#2c4771` text with icon
  - All variants: minimum 44x44px touch target
- [ ] **BottomSheet** component: slide-up modal for mobile, uses surface-container-lowest background
- [ ] **LoadingSpinner** component: uses primary color, centered
- [ ] **EmptyState** component: illustration placeholder + message, uses on-surface-variant text
- [ ] **MobileLayout** component: wraps pages with proper surface background, safe area padding, responsive 375-428px primary viewport
- [ ] **BottomNav** component: persistent bottom navigation with 4 tabs (Feed, Orders, Map, Profile), glassmorphism background, active state uses secondary color
- [ ] **TopBar** component: glassmorphism sticky header per DESIGN.md section 4, app title in Manrope
- [ ] All components are TypeScript with proper props interfaces
- [ ] No borders used for sectioning (DESIGN.md "No-Line" rule)
- [ ] Ambient shadows used per DESIGN.md specs on elevated elements

## Dependencies
- **005** — Design system tokens must be configured in Tailwind

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `frontend/components/ui/Button.tsx` — 3 variants, touch-optimized
- `frontend/components/ui/BottomSheet.tsx` — slide-up modal
- `frontend/components/ui/LoadingSpinner.tsx` — loading indicator
- `frontend/components/ui/EmptyState.tsx` — empty state display
- `frontend/components/layout/MobileLayout.tsx` — page wrapper
- `frontend/components/layout/BottomNav.tsx` — persistent bottom navigation (Feed/Orders/Map/Profile)
- `frontend/components/layout/TopBar.tsx` — glassmorphism sticky header

## Technical Notes
- BottomNav should use Inertia `Link` components for navigation (not `<a>` tags)
- Glassmorphism for TopBar and BottomNav: `background: rgba(69, 95, 138, 0.8); backdrop-filter: blur(20px);`
- Use `surface-container-low` (#f3f4f6) as the in-page section background to create card lift effect
- BottomSheet can use CSS transitions for slide-up animation — keep it simple for MVP
- All interactive elements must be at least 44x44dp per DESIGN.md section 6
- MobileLayout should handle bottom safe area (for devices with home indicators)
- Reference DESIGN.md sections 4 (Elevation), 5 (Components), 6 (Do's and Don'ts)
