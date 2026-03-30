# Ticket 007: Driver Profile Management

## Description
Build the driver profile CRUD flow — controller, serializer, and Inertia page. Drivers must configure their vehicle type, availability status, preferred working radius, and location. The profile uses PostGIS for spatial location storage and provides scopes for querying available drivers.

## Acceptance Criteria
- [ ] `DriverProfilesController` with `show`, `edit`, `update` actions rendering Inertia pages
- [ ] Driver can select vehicle type (motorcycle, car, van, truck) from a picker
- [ ] Driver can toggle availability on/off
- [ ] Driver can set preferred working radius via slider (5-50 km range)
- [ ] Driver location is stored as PostGIS Point (SRID 4326) — either from browser geolocation or manual input
- [ ] `DriverProfileSerializer` serializes profile data as Inertia props
- [ ] `Profile.tsx` page follows DESIGN.md: no borders, surface hierarchy, large touch targets (56px inputs)
- [ ] `DriverProfile.available` scope returns profiles where `is_available: true`
- [ ] `DriverProfile.within_radius(point, distance)` scope uses `ST_DWithin` for spatial queries
- [ ] Model validations: vehicle_type required, radius_preference > 0
- [ ] Background task stub: `AvailabilityToggleTask` — when driver goes offline, queue feed cleanup; when online, rehydrate feed

## Dependencies
- **004** — Authentication must work (driver must be logged in)
- **006** — UI components (MobileLayout, Button, TopBar, BottomNav)

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/controllers/driver_profiles_controller.rb` — show/edit/update actions
- `app/serializers/driver_profile_serializer.rb` — props serialization
- `app/models/driver_profile.rb` — validations, enums, spatial scopes
- `frontend/pages/Driver/Profile.tsx` — profile management page
- `config/routes.rb` — add driver profile routes

## Technical Notes
- Use browser Geolocation API on the frontend to get driver's current position
- Store location using `RGeo::Geographic.spherical_factory(srid: 4326).point(lng, lat)`
- The `within_radius` scope: `where("ST_DWithin(location::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)", lng, lat, radius_meters)`
- Vehicle type enum maps to delivery order compatibility — this is used in ticket 012 for matching
- Availability toggle should be a prominent switch/toggle at the top of the profile page
- Consider using Inertia form helpers for the edit form submission
