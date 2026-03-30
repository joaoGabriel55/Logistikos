# Ticket 014: Order Filtering & Discovery

## Description
Add filtering capabilities to the driver feed. Drivers can filter orders by distance radius (PostGIS-powered), vehicle compatibility, load size, and price range. Filters persist in URL parameters via Inertia visits for shareability and browser back/forward support.

## Acceptance Criteria
- [ ] **Radius filter**: slider (5-50 km) using PostGIS `ST_DWithin` spatial index query
- [ ] **Vehicle compatibility filter**: checkboxes for vehicle types — shows only orders compatible with selected vehicles
- [ ] **Load size filter**: multi-select for Small/Medium/Large/Bulk
- [ ] **Price range filter**: min/max inputs or range slider
- [ ] All filters compose correctly (AND logic)
- [ ] Filters are reflected in URL query parameters via Inertia visits
- [ ] `Filters.tsx` panel/page with filter controls — can be a slide-in panel or dedicated page
- [ ] Filter state persists on page navigation (URL-driven)
- [ ] Clear all filters button resets to defaults
- [ ] Spatial radius filter uses GiST index for performance (< 50ms per PRD)
- [ ] Filter UI follows DESIGN.md: large touch targets, no borders, surface hierarchy

## Dependencies
- **013** — Order feed must exist to apply filters to

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/models/delivery_order.rb` — add parameterized scopes: `within_radius`, `for_vehicle_types`, `for_sizes`, `in_price_range`
- `app/controllers/delivery_orders_controller.rb` — apply filter params to query
- `frontend/pages/Driver/Filters.tsx` — filter controls UI
- `frontend/pages/Driver/OrderFeed.tsx` — integrate filter state, pass as Inertia visit params

## Technical Notes
- Radius scope:
  ```ruby
  scope :within_radius, ->(point, meters) {
    where("ST_DWithin(pickup_location::geography, ?::geography, ?)", point, meters)
  }
  ```
- Vehicle compatibility scope should use the same matrix from ticket 012
- Price range scope: `where(price: min..max)` or `where("COALESCE(price, estimated_price) BETWEEN ? AND ?", min, max)`
- Use Inertia's `router.get` with query params to update the feed:
  ```tsx
  router.get('/driver/feed', { radius: 20, sizes: ['medium', 'large'], price_min: 20 }, { preserveState: true })
  ```
- Consider debouncing slider inputs to avoid excessive requests
- Default radius should match driver's profile `radius_preference`
