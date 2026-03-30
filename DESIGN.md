# Design System Specification: Precision Logistikos

## 1. Overview & Creative North Star: "The Kinetic Architect"
This design system moves away from the static, "boxy" nature of traditional Logistikos software. Our Creative North Star is **The Kinetic Architect**. It treats data not as a static list, but as a living flow of information. By utilizing intentional asymmetry, layered translucency, and an editorial typographic hierarchy, we create an environment that feels authoritative yet remarkably fast to navigate.

The system rejects the "template" look. We do not use borders to separate ideas; we use depth and light. This approach ensures that drivers, operating in high-stress, "on-the-move" environments, can distinguish between a critical alert and a standard data point through subconscious visual cues rather than hunting for text.

---

## 2. Colors & Surface Philosophy
The palette is anchored in stability but punctuated by high-velocity action.

### The Foundation
- **Primary (`#000e24`)**: Deep Navy. Used for headers and primary brand moments to establish trust and authority.
- **Secondary (`#a33800`)**: High-Visibility Burnt Orange. Reserved exclusively for "Action" states, CTAs, and critical status updates (e.g., "Arrived," "Delayed").
- **Background (`#f8f9fb`)**: A cool-toned light gray that reduces eye strain compared to pure white.

### The "No-Line" Rule
**Borders are prohibited for sectioning.** To define boundaries, designers must use background color shifts. For example, a card (`surface-container-lowest`) sits on a section background (`surface-container-low`). This creates a cleaner, more sophisticated interface that feels "built" rather than "drawn."

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers.
- **Base Level:** `surface` (#f8f9fb).
- **In-Page Sections:** `surface-container-low` (#f3f4f6).
- **Interactive Cards:** `surface-container-lowest` (#ffffff).
- **Elevated Overlays:** `surface-bright` (#f8f9fb).

### The "Glass & Gradient" Rule
To elevate the "on-the-move" feel, use **Glassmorphism** for floating action buttons or sticky headers.
- Use `surface-tint` (#455f8a) at 80% opacity with a `20px` backdrop blur.
- **Signature Texture:** Apply a subtle linear gradient from `primary` (#000e24) to `primary-container` (#00234b) on main CTAs to give them a metallic, industrial "soul" that feels premium and tactile.

---

## 3. Typography: Editorial Utility
We pair **Manrope** (Display/Headline) with **Inter** (Body/Labels) to balance character with raw legibility.

- **Manrope (Display & Headlines):** Chosen for its geometric precision. Use `display-md` (2.75rem) for high-impact data points like "Current Earnings" or "Total Miles."
- **Inter (Body & Labels):** The workhorse for dense Logistikos data.
- **Data Weights:** Use `title-md` (Inter, 1.125rem) for price points and shipment IDs to ensure they pop during a quick scan.
- **Labeling:** Use `label-md` (Inter, 0.75rem) in `on-surface-variant` (#43474e) for secondary metadata like "Weight" or "ETA."

The hierarchy conveys the brand by making the *Action* (Manrope) feel bold and the *Information* (Inter) feel organized and surgical.

---

## 4. Elevation & Depth
Depth is achieved through **Tonal Layering** rather than structural lines.

- **The Layering Principle:** Stack `surface-container-lowest` (#ffffff) cards on top of `surface-container-high` (#e7e8ea) backgrounds. This creates a soft "lift" that guides the eye naturally.
- **Ambient Shadows:** For floating elements (like a "Scan QR" button), use extra-diffused shadows.
- *Specs:* `Y: 8px, Blur: 24px, Color: on-surface (#191c1e) at 6% opacity`.
- Never use dark, harsh shadows.
- **The "Ghost Border" Fallback:** If a border is required for accessibility, use `outline-variant` (#c4c6d0) at **15% opacity**. It should be felt, not seen.
- **Glassmorphism:** Use for persistent navigation bars. This allows the map or list content to "bleed" through, making the app feel like a single, integrated tool rather than a series of disconnected screens.

---

## 5. Components

### Buttons
- **Primary:** Gradient fill (`primary` to `primary-container`), roundedness `md` (0.75rem). High-contrast white text.
- **Action (Status):** Solid `secondary` (#a33800). This is the "Attention" color.
- **Tertiary:** No background. Use `on-primary-fixed-variant` (#2c4771) text with an icon.

### Input Fields
- **Container:** Use `surface-container-highest` (#e1e2e4).
- **Active State:** Change background to `surface-container-lowest` (#ffffff) with a `ghost border` using `primary`.
- **Logic:** Inputs should be large (height: 56px) for easy tapping while the vehicle is stationary.

### Cards & Lists (The Logistikos Item)
- **Rule:** Forbid divider lines.
- **Separation:** Use `spacing-5` (1.1rem) of vertical white space to separate shipment cards.
- **Visual Anchor:** Use a `secondary_fixed` (#ffdbce) vertical accent bar (4px wide) on the left side of a card to indicate a "Priority" load.

### Specialized Logistikos Components
- **The "Quick-Scan" Badge:** A small `tertiary_container` (#001f5a) badge with `on-tertiary-container` (#5384ff) text for weight/type (e.g., "HAZMAT," "LTL").
- **Route Timeline:** Use thin line icons connected by a `1px` vertical line using `surface-dim` (#d9dadc), creating a visual thread of the driver's journey.

---

## 6. Do's and Don'ts

### Do:
- **Use "Intentional Asymmetry":** Align main data points to the left, but place "Secondary Action" or "Price" floating to the right within a card to create a clear diagonal scanning path.
- **Prioritize "On-The-Move" Contrast:** Ensure all critical text meets WCAG AA standards against the `surface` colors.
- **Embrace White Space:** Logistikos is messy; the UI shouldn't be. Use the `spacing-8` (1.75rem) token to let the data breathe.

### Don't:
- **Don't use 100% opaque borders:** It clutters the interface and distracts the driver.
- **Don't use vibrant blue for non-actions:** Blue should represent "Stability" (Primary), while Orange/Electric Blue (Secondary/Tertiary) represents "Movement."
- **Don't use small tap targets:** Every interactive element must be at least 44x44dp, regardless of the Spacing Scale, to accommodate fast-paced use.
