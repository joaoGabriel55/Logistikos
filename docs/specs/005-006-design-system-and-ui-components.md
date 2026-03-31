# Product Specification: Design System Implementation & Shared UI Components

**Document Version:** 1.0
**Date:** 2026-03-30
**Status:** Ready for Development
**Priority:** P0 - Foundation

---

## 1. Feature Overview

This specification defines the implementation of the **Precision Logistikos** design system and the foundational UI component library for the Logistikos marketplace. These components form the visual and interaction foundation for all user-facing features, ensuring consistency, accessibility, and mobile-first optimization across the platform.

The design system embraces the **"Kinetic Architect"** philosophy - treating data as a living flow rather than static lists, using depth and light instead of borders, and creating an environment that feels both authoritative and fast to navigate. This is critical for drivers operating in high-stress, on-the-move environments who need to distinguish between critical alerts and standard data through subconscious visual cues.

### Business Value
- **Reduced cognitive load** for drivers making split-second decisions
- **Increased order acceptance rates** through optimized mobile UX (< 3 taps)
- **Higher user trust** through consistent, professional visual design
- **Faster feature development** with reusable component library

### Competition Alignment
- **Technical Quality:** Clean, maintainable component architecture
- **User Experience:** Mobile-first, intuitive flows with optimistic UI
- **Real Potential:** Professional design that appeals to independent drivers and businesses

---

## 2. User Stories & Acceptance Criteria

### STORY-005: Design System Configuration

**As a** System
**I want** a fully configured Tailwind design system
**So that** all UI components use consistent visual tokens per the Precision Logistikos specification

#### Acceptance Criteria
- [ ] Given the application loads, When any page renders, Then Manrope font is used for headlines and Inter font is used for body text
- [ ] Given a developer uses color classes, When they reference `bg-primary`, Then it renders as `#000e24` (deep navy)
- [ ] Given a developer uses color classes, When they reference `bg-secondary`, Then it renders as `#a33800` (burnt orange)
- [ ] Given a developer creates a surface hierarchy, When they use `bg-surface-container-low`, Then it renders as `#f3f4f6`
- [ ] Given a developer needs glassmorphism, When they apply the `glass` utility, Then it shows 80% opacity surface-tint with 20px backdrop blur
- [ ] Given a developer creates a CTA button, When they apply `gradient-primary`, Then it shows a linear gradient from `#000e24` to `#00234b`
- [ ] Given accessibility requirements, When a ghost border is needed, Then `outline-variant` at 15% opacity is available
- [ ] Given mobile-first design, When spacing is applied, Then `spacing-5` equals 1.1rem and `spacing-8` equals 1.75rem
- [ ] Given elevated elements need depth, When `shadow-ambient` is applied, Then it shows Y:8px, Blur:24px at 6% opacity

#### Domain Constraints
- **Affected statuses**: N/A (system-wide)
- **User roles**: All users (Customer, Driver)
- **Map implications**: Glassmorphism effects will be used for map overlays
- **AI feature**: N/A

#### Technical Notes
- Extend Tailwind theme in `tailwind.config.js` with custom color tokens
- Import Google Fonts (Manrope, Inter) via CSS
- Create custom utility classes for glassmorphism and gradients
- Use PostCSS for processing
- Implement "no-border" rule through code review guidelines

#### Priority: Must
#### Story Points: 3

---

### STORY-006A: Core UI Components

**As a** Customer or Driver
**I want** consistent, touch-optimized UI components
**So that** I can interact efficiently with the platform on mobile devices

#### Acceptance Criteria
- [ ] Given a user taps a primary button, When the button renders, Then it shows a gradient from `#000e24` to `#00234b` with white text and 0.75rem border radius
- [ ] Given a user taps an action button, When the button renders, Then it shows solid `#a33800` background (secondary color)
- [ ] Given a user taps a tertiary button, When the button renders, Then it shows no background with `#2c4771` text and an icon
- [ ] Given any button is rendered, When measured, Then the touch target is at least 44x44 pixels
- [ ] Given a loading state occurs, When the spinner appears, Then it uses the primary color and is centered
- [ ] Given no data is available, When the empty state renders, Then it shows an illustration with on-surface-variant text color
- [ ] Given a modal action is needed, When the bottom sheet opens, Then it slides up from bottom with surface-container-lowest background

#### Domain Constraints
- **Affected statuses**: All order statuses (visual feedback)
- **User roles**: Customer, Driver
- **Map implications**: Loading states during map interactions
- **AI feature**: Loading states during AI processing

#### Technical Notes
- Components in `frontend/components/ui/`
- TypeScript with proper props interfaces
- Use Tailwind classes from STORY-005
- CSS transitions for animations
- No external UI libraries

#### Priority: Must
#### Story Points: 5

---

### STORY-006B: Layout Components

**As a** Customer or Driver
**I want** consistent navigation and layout structure
**So that** I can easily navigate between different sections of the app

#### Acceptance Criteria
- [ ] Given a page loads, When the MobileLayout wrapper renders, Then it provides proper surface background and safe area padding
- [ ] Given the viewport width, When between 375-428px, Then the layout is optimized for mobile-first experience
- [ ] Given the bottom navigation, When rendered, Then it shows 4 tabs: Feed, Orders, Map, Profile
- [ ] Given the bottom navigation, When a tab is active, Then it uses the secondary color (`#a33800`) for highlighting
- [ ] Given the bottom navigation background, When rendered, Then it uses glassmorphism effect (80% opacity, 20px blur)
- [ ] Given the top bar, When scrolling, Then it remains sticky with glassmorphism background
- [ ] Given the top bar title, When rendered, Then it uses Manrope font family
- [ ] Given device has home indicator, When bottom navigation renders, Then it accounts for safe area padding

#### Domain Constraints
- **Affected statuses**: N/A (persistent across all states)
- **User roles**: Customer, Driver
- **Map implications**: Bottom nav and top bar overlay map view
- **AI feature**: N/A

#### Technical Notes
- Use Inertia `Link` components for navigation
- Components in `frontend/components/layout/`
- Handle iOS/Android safe areas
- Persistent navigation state management
- CSS sticky positioning for top bar

#### Priority: Must
#### Story Points: 5

---

### STORY-006C: Design System Compliance

**As a** Developer
**I want** enforced design system rules
**So that** the UI remains consistent with the Precision Logistikos specification

#### Acceptance Criteria
- [ ] Given any UI component, When reviewed, Then no borders are used for sectioning (only background color shifts)
- [ ] Given cards need separation, When rendered, Then they use tonal layering (surface-container-lowest on surface-container-low)
- [ ] Given visual hierarchy is needed, When elements stack, Then they follow the surface hierarchy system
- [ ] Given shadows are applied, When on elevated elements, Then they use ambient shadow specs (Y:8px, Blur:24px, 6% opacity)
- [ ] Given data density, When cards are spaced, Then they use `spacing-5` (1.1rem) vertical separation
- [ ] Given priority indication, When needed, Then a 4px wide secondary-fixed accent bar appears on the left
- [ ] Given accessibility fallback, When a border is absolutely required, Then ghost border (15% opacity) is used

#### Domain Constraints
- **Affected statuses**: All visual states
- **User roles**: All users
- **Map implications**: Map overlays follow glassmorphism rules
- **AI feature**: AI suggestions use proper elevation hierarchy

#### Technical Notes
- Enforce through PR review checklist
- Document patterns in component library
- Create Storybook stories showing correct usage
- ESLint rules for deprecated patterns

#### Priority: Must
#### Story Points: 2

---

## 3. Technical Requirements

### 3.1 Development Environment
- **Frontend Framework:** React 18+ with TypeScript
- **CSS Framework:** TailwindCSS 3.x with PostCSS
- **Build Tool:** Vite via vite_rails
- **Component Structure:** Functional components with hooks
- **State Management:** React Context for theme/layout state

### 3.2 Font Loading Strategy
```css
/* frontend/entrypoints/application.css */
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700&family=Inter:wght@400;500;600&display=swap');
```

### 3.3 Tailwind Configuration Structure
```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#000e24',
        secondary: '#a33800',
        surface: {
          DEFAULT: '#f8f9fb',
          'container-low': '#f3f4f6',
          'container-lowest': '#ffffff',
          'container-high': '#e7e8ea',
          'container-highest': '#e1e2e4',
          'bright': '#f8f9fb',
          'dim': '#d9dadc',
          'tint': '#455f8a'
        },
        // ... additional color tokens
      },
      fontFamily: {
        'display': ['Manrope', 'sans-serif'],
        'body': ['Inter', 'sans-serif']
      },
      fontSize: {
        'display-md': '2.75rem',
        'title-md': '1.125rem',
        'label-md': '0.75rem'
      },
      spacing: {
        '5': '1.1rem',
        '8': '1.75rem'
      },
      borderRadius: {
        'md': '0.75rem'
      }
    }
  }
}
```

### 3.4 Component Architecture
```typescript
// Example Button component structure
interface ButtonProps {
  variant: 'primary' | 'action' | 'tertiary';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}
```

### 3.5 Accessibility Requirements
- **WCAG AA Compliance:** All text must meet contrast ratios
- **Touch Targets:** Minimum 44x44dp for all interactive elements
- **Focus States:** Visible focus indicators for keyboard navigation
- **Screen Reader Support:** Proper ARIA labels and semantic HTML

### 3.6 Performance Requirements
- **Bundle Size:** Components should be tree-shakeable
- **CSS Loading:** Critical CSS inlined, non-critical deferred
- **Font Loading:** Use font-display: swap for web fonts
- **Animation:** Use CSS transforms for 60fps animations

---

## 4. Design System Compliance Notes

### 4.1 The "No-Line" Rule
**Enforcement:** No component may use borders for visual separation. Instead:
- Use background color shifts (e.g., card on section background)
- Apply tonal layering through the surface hierarchy
- Utilize spacing tokens for visual breathing room

### 4.2 The "Kinetic Architect" Philosophy
**Implementation:**
- Data flows through intentional asymmetry (left-aligned primary, right-floating secondary)
- Visual hierarchy through typography scale (Manrope for impact, Inter for density)
- Depth through shadows and glassmorphism, not structural lines

### 4.3 Mobile-First Constraints
**Requirements:**
- Primary viewport: 375-428px width
- Bottom-up interaction patterns (thumb-reachable zones)
- Persistent bottom navigation for core actions
- Swipe gestures for bottom sheets

### 4.4 Color Usage Guidelines
| Color | Use Case | Never Use For |
|-------|----------|---------------|
| Primary (#000e24) | Headers, brand moments, primary buttons | Body text, backgrounds |
| Secondary (#a33800) | CTAs, active states, critical alerts | Passive elements, decorative |
| Surface hierarchy | Background layering, cards | Text, icons |
| On-surface variants | Text, icons | Backgrounds, buttons |

### 4.5 Glassmorphism Application
**When to use:**
- Sticky headers (TopBar)
- Persistent navigation (BottomNav)
- Floating action buttons
- Map overlays

**Implementation:**
```css
.glass {
  background: rgba(69, 95, 138, 0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}
```

---

## 5. Testing Requirements

### 5.1 Component Testing
- Unit tests for all component props and states
- Visual regression tests for design token application
- Accessibility audits (axe-core integration)
- Touch target size validation

### 5.2 Cross-Browser Testing
- Safari iOS (primary)
- Chrome Android (primary)
- Chrome Desktop (secondary)
- Firefox Desktop (secondary)

### 5.3 Device Testing
- iPhone 12/13/14 (375px viewport)
- iPhone Pro Max series (428px viewport)
- Android flagship devices
- Tablet responsive (stretch goal)

---

## 6. Documentation Requirements

### 6.1 Component Documentation
Each component must include:
- Props interface with descriptions
- Usage examples
- Do's and don'ts per design system
- Accessibility notes
- Performance considerations

### 6.2 Storybook Stories
Create stories showing:
- All component variants
- Loading and error states
- Mobile viewport preview
- Interaction states (hover, focus, active)
- Composition examples

---

## 7. Migration & Rollout Plan

### Phase 1: Foundation (STORY-005)
1. Configure Tailwind with all design tokens
2. Set up font loading
3. Create utility classes (glass, gradients)
4. Verify token application

### Phase 2: Core Components (STORY-006A)
1. Build Button component with 3 variants
2. Implement LoadingSpinner
3. Create EmptyState
4. Develop BottomSheet

### Phase 3: Layout System (STORY-006B)
1. Build MobileLayout wrapper
2. Implement BottomNav with Inertia routing
3. Create TopBar with glassmorphism
4. Test safe area handling

### Phase 4: Validation
1. Design system audit
2. Accessibility testing
3. Performance profiling
4. Cross-device QA

---

## 8. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Component reusability | > 80% of UI uses shared components | Code analysis |
| Touch target compliance | 100% meet 44x44dp minimum | Automated testing |
| Lighthouse score | > 90 Performance, > 95 Accessibility | CI/CD pipeline |
| Design consistency | 0 border violations | PR review checklist |
| Bundle size | < 50KB for component library | Webpack analysis |

---

## 9. Open Questions

1. **Dark mode support:** Should we implement dark mode variants for the competition demo?
   - **Recommendation:** No, focus on polishing light mode for MVP

2. **Animation library:** Should we use Framer Motion for complex animations?
   - **Recommendation:** CSS transitions only for MVP, keep dependencies minimal

3. **Icon system:** Which icon library should we adopt?
   - **Recommendation:** Heroicons or Lucide React (both are tree-shakeable)

4. **Component testing:** Should we set up Storybook for the 2-week timeline?
   - **Recommendation:** No Storybook for MVP, focus on functional components

5. **Responsive breakpoints:** Should we support desktop views?
   - **Recommendation:** Mobile-first only for competition, desktop can be post-MVP

---

## 10. Dependencies & Risks

### Dependencies
- TailwindCSS must be installed and configured (from ticket 001)
- React/TypeScript setup must be complete (from ticket 001)
- Inertia.js must be configured for routing (from ticket 001)

### Risks
| Risk | Mitigation |
|------|------------|
| Font loading performance | Use font-display: swap, preconnect to Google Fonts |
| Glassmorphism browser support | Provide solid color fallback for unsupported browsers |
| Touch target conflicts with design | Enforce 44px minimum even if it affects visual density |
| Color contrast failures | Test all combinations with WCAG tools before implementation |

---

## Appendix: Design Token Reference

### Complete Color Palette
```javascript
{
  primary: '#000e24',
  'primary-container': '#00234b',
  secondary: '#a33800',
  'secondary-fixed': '#ffdbce',
  'tertiary-container': '#001f5a',
  'on-tertiary-container': '#5384ff',
  'on-primary-fixed-variant': '#2c4771',
  surface: '#f8f9fb',
  'surface-container-low': '#f3f4f6',
  'surface-container-lowest': '#ffffff',
  'surface-container-high': '#e7e8ea',
  'surface-container-highest': '#e1e2e4',
  'surface-bright': '#f8f9fb',
  'surface-dim': '#d9dadc',
  'surface-tint': '#455f8a',
  'on-surface': '#191c1e',
  'on-surface-variant': '#43474e',
  'outline-variant': '#c4c6d0'
}
```

### Typography Scale
```javascript
{
  'display-lg': '3.5rem',    // Future use
  'display-md': '2.75rem',   // Main data points
  'display-sm': '2.25rem',   // Future use
  'headline-lg': '2rem',     // Future use
  'headline-md': '1.75rem',  // Future use
  'headline-sm': '1.5rem',   // Future use
  'title-lg': '1.375rem',    // Future use
  'title-md': '1.125rem',    // Price points, IDs
  'title-sm': '0.875rem',    // Future use
  'body-lg': '1rem',         // Future use
  'body-md': '0.875rem',     // Default body
  'body-sm': '0.75rem',      // Future use
  'label-lg': '0.875rem',    // Future use
  'label-md': '0.75rem',     // Metadata
  'label-sm': '0.6875rem'    // Future use
}
```

### Shadow Definitions
```javascript
{
  'shadow-ambient': '0 8px 24px rgba(25, 28, 30, 0.06)',
  'shadow-none': 'none'
}
```

---

*End of Specification*