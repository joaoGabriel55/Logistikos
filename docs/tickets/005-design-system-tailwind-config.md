# Ticket 005: Design System Tailwind Configuration

## Description
Configure TailwindCSS to implement the full DESIGN.md specification: color tokens, typography (Manrope + Inter), surface hierarchy, spacing scale, elevation/shadow definitions, glassmorphism utilities, and the "no-border" rule. This ensures all UI components built in subsequent tickets use a consistent, design-system-compliant vocabulary.

## Acceptance Criteria
- [ ] All DESIGN.md color tokens are available as Tailwind classes:
  - Primary: `#000e24`, Secondary: `#a33800`, Background: `#f8f9fb`
  - Surface hierarchy: surface (`#f8f9fb`), surface-container-low (`#f3f4f6`), surface-container-lowest (`#ffffff`), surface-container-high (`#e7e8ea`), surface-container-highest (`#e1e2e4`), surface-bright (`#f8f9fb`), surface-dim (`#d9dadc`), surface-tint (`#455f8a`)
  - On-surface: `#191c1e`, on-surface-variant: `#43474e`
  - Primary-container: `#00234b`, secondary-fixed: `#ffdbce`
  - Tertiary-container: `#001f5a`, on-tertiary-container: `#5384ff`
  - On-primary-fixed-variant: `#2c4771`
  - Outline-variant: `#c4c6d0`
- [ ] **Manrope** font loaded (Google Fonts) for display/headlines
- [ ] **Inter** font loaded (Google Fonts) for body/labels
- [ ] Typography scale defined: `display-md` (2.75rem), `title-md` (1.125rem), `label-md` (0.75rem)
- [ ] Spacing scale includes: `spacing-5` (1.1rem), `spacing-8` (1.75rem)
- [ ] Ambient shadow utility: `Y: 8px, Blur: 24px, Color: #191c1e at 6% opacity`
- [ ] Glassmorphism utility class: `surface-tint` at 80% opacity + 20px backdrop blur
- [ ] Gradient utility for primary CTAs: linear gradient from `#000e24` to `#00234b`
- [ ] Border-radius `md` token: 0.75rem
- [ ] All tokens work correctly when applied to HTML elements

## Dependencies
- **001** — TailwindCSS must be installed

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `tailwind.config.js` — extend theme with all color tokens, typography, spacing, shadows, border-radius
- `frontend/entrypoints/application.css` — `@import` Google Fonts (Manrope, Inter), Tailwind directives, custom utility classes
- `postcss.config.js` — ensure PostCSS processes Tailwind correctly

## Technical Notes
- Import Manrope and Inter via Google Fonts CDN in the CSS or HTML head
- Use Tailwind's `extend` in config to add custom tokens without overriding defaults
- The "no-border" rule is a design guideline — enforce through code review, not tooling
- The glassmorphism utility can be a custom Tailwind plugin or a CSS class:
  ```css
  .glass { background: rgba(69, 95, 138, 0.8); backdrop-filter: blur(20px); }
  ```
- The gradient CTA can be a custom class:
  ```css
  .gradient-primary { background: linear-gradient(to right, #000e24, #00234b); }
  ```
- Ghost border fallback: `outline-variant` at 15% opacity = `rgba(196, 198, 208, 0.15)`
- Reference DESIGN.md sections 2 (Colors), 3 (Typography), 4 (Elevation & Depth)
