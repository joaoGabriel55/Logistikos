# Driver Profile Management Specification

## Feature Overview

The Driver Profile Management feature enables drivers on the Logistikos platform to configure and maintain their professional profile, including vehicle capabilities, working preferences, and availability status. This feature is critical for the marketplace's intelligent matching system, allowing the platform to efficiently connect drivers with compatible delivery orders based on their vehicle type, location, and working radius preferences.

The profile system leverages PostGIS spatial capabilities to store and query driver locations, enabling real-time proximity-based order matching. Drivers can toggle their availability status to control when they receive order notifications, and set their preferred working radius to define their operational area.

## User Stories

### [DRIVER-PROFILE-001] View Driver Profile
**As a** Driver
**I want** to view my current profile information
**So that** I can verify my settings and operational preferences are correct

#### Acceptance Criteria
- [ ] Given I am an authenticated driver, When I navigate to my profile page, Then I see my current vehicle type, availability status, working radius, and location
- [ ] Given I am on my profile page, When the page loads, Then all information is displayed using the Precision Logistikos design system with no borders and proper surface hierarchy
- [ ] Given I am viewing my profile, When I check my location, Then I see it displayed as an address or coordinates with accuracy indicator
- [ ] Given I am viewing my profile, When I check my working radius, Then I see it displayed in kilometers with a visual representation

#### Domain Constraints
- **Affected statuses**: N/A (profile management doesn't affect order statuses)
- **User roles**: Driver only
- **Map implications**: Location display may show a mini-map preview of working area
- **AI feature**: None directly, but profile data feeds into intelligent matching

#### Technical Notes
- Service objects involved: `Drivers::ProfileManager`
- Sidekiq workers triggered: None for viewing
- PostGIS queries needed: `ST_AsText` for displaying location coordinates
- Inertia page component affected: `Driver/Profile.tsx`
- Props serialization via `DriverProfileSerializer`

#### Priority: Must
#### Story Points: 2

---

### [DRIVER-PROFILE-002] Update Vehicle Type
**As a** Driver
**I want** to update my vehicle type
**So that** I only receive delivery orders compatible with my vehicle capabilities

#### Acceptance Criteria
- [ ] Given I am on my profile edit page, When I see the vehicle type selector, Then I can choose from: motorcycle, car, van, or truck
- [ ] Given I select a new vehicle type, When I save the profile, Then the system updates my vehicle type and shows a success message
- [ ] Given I have changed my vehicle type, When new orders are matched, Then I only see orders compatible with my new vehicle type
- [ ] Given I am selecting a vehicle type, When I interact with the picker, Then touch targets are at least 56px in height for mobile usability

#### Domain Constraints
- **Affected statuses**: Affects future order matching but not existing assignments
- **User roles**: Driver only
- **Map implications**: None
- **AI feature**: Affects intelligent matching algorithm

#### Technical Notes
- Service objects involved: `Drivers::ProfileManager`, `Orders::CompatibilityChecker`
- Sidekiq workers triggered: `FeedRehydrationWorker` to update cached feed data
- PostGIS queries needed: None
- Inertia page component affected: `Driver/Profile.tsx`
- Vehicle type stored as enum in `driver_profiles` table

#### Priority: Must
#### Story Points: 2

---

### [DRIVER-PROFILE-003] Toggle Availability Status
**As a** Driver
**I want** to toggle my availability on and off
**So that** I can control when I receive new delivery order notifications

#### Acceptance Criteria
- [ ] Given I am on my profile page, When I see the availability toggle, Then it is prominently displayed at the top of the page
- [ ] Given I am currently available, When I toggle to unavailable, Then the system immediately stops sending me new order notifications
- [ ] Given I am currently unavailable, When I toggle to available, Then the system immediately starts including me in order matching
- [ ] Given I toggle my availability, When the change is saved, Then I receive immediate visual feedback confirming the status change
- [ ] Given I have active assignments, When I toggle to unavailable, Then I can still complete my existing assignments

#### Domain Constraints
- **Affected statuses**: Does not affect existing assignments (accepted, in_transit orders continue)
- **User roles**: Driver only
- **Map implications**: Unavailable drivers may be shown differently on admin/customer maps
- **AI feature**: Availability is a hard filter in intelligent matching

#### Technical Notes
- Service objects involved: `Drivers::AvailabilityManager`
- Sidekiq workers triggered: `AvailabilityToggleWorker` — when offline: cleanup feed cache; when online: rehydrate feed
- PostGIS queries needed: None directly, but affects `DriverProfile.available` scope usage
- Inertia page component affected: `Driver/Profile.tsx`
- Availability stored as boolean `is_available` field

#### Priority: Must
#### Story Points: 3

---

### [DRIVER-PROFILE-004] Set Working Radius Preference
**As a** Driver
**I want** to set my preferred working radius
**So that** I only receive notifications for delivery orders within my operational area

#### Acceptance Criteria
- [ ] Given I am on my profile edit page, When I see the radius preference control, Then I can use a slider to set a value between 5km and 50km
- [ ] Given I adjust the radius slider, When I move it, Then I see real-time feedback showing the selected distance in kilometers
- [ ] Given I set a radius of X kilometers, When new orders are created, Then I only receive notifications for orders with pickup points within X km of my location
- [ ] Given I am setting my radius, When I interact with the slider, Then it has a minimum touch target of 44x44dp for mobile usability
- [ ] Given I save a new radius preference, When the system processes orders, Then it uses `ST_DWithin` to filter orders within my specified radius

#### Domain Constraints
- **Affected statuses**: Affects which open orders appear in driver's feed
- **User roles**: Driver only
- **Map implications**: Could show radius circle overlay on map views
- **AI feature**: Radius is a primary filter in intelligent matching before AI scoring

#### Technical Notes
- Service objects involved: `Geo::RadiusCalculator`, `Orders::ProximityMatcher`
- Sidekiq workers triggered: `FeedRehydrationWorker` to rebuild feed with new radius
- PostGIS queries needed: `ST_DWithin(location::geography, point::geography, radius_meters)`
- Inertia page component affected: `Driver/Profile.tsx`
- Stored as integer `radius_preference_km` in database

#### Priority: Must
#### Story Points: 3

---

### [DRIVER-PROFILE-005] Update Current Location
**As a** Driver
**I want** to update my current location
**So that** the system can accurately calculate distances to pickup points

#### Acceptance Criteria
- [ ] Given I am on my profile page, When I click "Update Location", Then the browser requests my current geolocation permission
- [ ] Given I grant location permission, When the location is retrieved, Then it is automatically saved to my profile as a PostGIS Point
- [ ] Given I deny location permission, When prompted, Then I can manually enter an address or coordinates
- [ ] Given I update my location, When saved, Then the new location is stored as POINT geometry with SRID 4326
- [ ] Given my location changes, When new orders are evaluated, Then pickup distances are calculated from my new location
- [ ] Given I am viewing my location, When displayed, Then I see either the reverse-geocoded address or lat/lng coordinates with timestamp of last update

#### Domain Constraints
- **Affected statuses**: Affects distance calculations for open orders
- **User roles**: Driver only
- **Map implications**: Driver's position updates on map views
- **AI feature**: Location is core input for intelligent proximity matching

#### Technical Notes
- Service objects involved: `Geo::LocationManager`, `Geo::ReverseGeocoder`
- Sidekiq workers triggered: `LocationUpdateWorker` to recalculate distances in feed cache
- PostGIS queries needed: `ST_SetSRID(ST_MakePoint(lng, lat), 4326)` for storage
- Inertia page component affected: `Driver/Profile.tsx`
- Frontend uses browser Geolocation API
- Backend uses RGeo for Point creation: `RGeo::Geographic.spherical_factory(srid: 4326).point(lng, lat)`

#### Priority: Must
#### Story Points: 3

---

### [DRIVER-PROFILE-006] Validate Profile Completeness
**As a** Driver
**I want** the system to validate my profile information
**So that** I can only participate in the marketplace with complete and valid data

#### Acceptance Criteria
- [ ] Given I am saving my profile, When vehicle_type is not selected, Then I see an error message "Vehicle type is required"
- [ ] Given I am saving my profile, When radius_preference is 0 or negative, Then I see an error message "Working radius must be greater than 0"
- [ ] Given I am saving my profile, When radius_preference exceeds 50km, Then I see an error message "Working radius cannot exceed 50km"
- [ ] Given I am saving my profile, When location is not set, Then I see a warning but can still save (location optional initially)
- [ ] Given validation errors exist, When displayed, Then they follow Precision Logistikos design with `error` color (#b3261e) and proper contrast

#### Domain Constraints
- **Affected statuses**: Invalid profiles prevent participation in order marketplace
- **User roles**: Driver only
- **Map implications**: Drivers without location cannot appear on maps
- **AI feature**: Incomplete profiles are excluded from intelligent matching

#### Technical Notes
- Service objects involved: `Drivers::ProfileValidator`
- Sidekiq workers triggered: None
- PostGIS queries needed: None for validation
- Inertia page component affected: `Driver/Profile.tsx`
- Model validations in `DriverProfile`: `validates :vehicle_type, presence: true` and `validates :radius_preference_km, numericality: { greater_than: 0, less_than_or_equal_to: 50 }`

#### Priority: Must
#### Story Points: 2

---

### [DRIVER-PROFILE-007] Profile Data in Order Feed Context
**As a** Driver
**I want** my profile settings to automatically filter the order feed
**So that** I only see relevant delivery orders without manual filtering

#### Acceptance Criteria
- [ ] Given I have set a 10km working radius, When I view the order feed, Then I only see orders with pickup points within 10km of my location
- [ ] Given I have a motorcycle vehicle type, When I view the order feed, Then I don't see orders requiring van or truck capacity
- [ ] Given I am marked as unavailable, When I navigate to the order feed, Then I see a notice that I must be available to view orders
- [ ] Given my profile is incomplete (missing vehicle type or radius), When I try to access the order feed, Then I am redirected to complete my profile first

#### Domain Constraints
- **Affected statuses**: Only affects visibility of open orders
- **User roles**: Driver only
- **Map implications**: Map markers only show compatible orders
- **AI feature**: Profile settings are pre-filters before AI scoring

#### Technical Notes
- Service objects involved: `Orders::FeedBuilder`, `Orders::CompatibilityChecker`
- Sidekiq workers triggered: Feed rebuilt when profile changes via `FeedRehydrationWorker`
- PostGIS queries needed: `DriverProfile.within_radius(pickup_point, radius).available`
- Inertia page component affected: Integration with `Driver/OrderFeed.tsx`
- Scopes chain: `DeliveryOrder.open.compatible_with_vehicle(vehicle_type).within_radius_of(driver_location, driver_radius)`

#### Priority: Should
#### Story Points: 3

## UI/UX Requirements

Following the Precision Logistikos design system (DESIGN.md):

### Visual Design
- **No borders** for sectioning — use background color shifts and tonal layering
- **Surface hierarchy**: Profile cards use `surface-container-lowest` (#ffffff) on `surface-container-low` (#f3f4f6) background
- **Glassmorphism** for the availability toggle header: `surface-tint` (#455f8a) at 80% opacity with 20px backdrop blur
- **Typography**: Manrope for profile headings, Inter for form labels and values

### Component Specifications
- **Availability Toggle**: Prominent switch at page top, minimum 56px height, using `secondary` (#a33800) for "available" state
- **Vehicle Type Picker**: Large touch targets (56px height), icons for each vehicle type, `surface-container-highest` (#e1e2e4) background
- **Radius Slider**: Minimum 44x44dp touch target, real-time kilometer display, gradient track from `primary` to `primary-container`
- **Location Display**: Show accuracy indicator, "Update Location" button with `primary` gradient fill
- **Save Button**: Full-width on mobile, gradient fill from `primary` (#000e24) to `primary-container` (#00234b)

### Mobile Optimizations
- Bottom-aligned save button for thumb reachability
- Collapsible sections to reduce scroll on small screens
- Location update triggered by prominent floating action button
- Swipe gestures for radius adjustment as alternative to slider

## Technical Architecture

### Model Structure
```ruby
class DriverProfile < ApplicationRecord
  belongs_to :user

  # Enums
  enum vehicle_type: {
    motorcycle: 0,
    car: 1,
    van: 2,
    truck: 3
  }

  # Validations
  validates :vehicle_type, presence: true
  validates :radius_preference_km,
    numericality: { greater_than: 0, less_than_or_equal_to: 50 }

  # Scopes
  scope :available, -> { where(is_available: true) }
  scope :within_radius, ->(point, distance_meters) {
    where("ST_DWithin(location::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
      point.x, point.y, distance_meters)
  }
end
```

### Background Tasks
- **AvailabilityToggleWorker**: Processes availability changes asynchronously
  - When going offline: Removes driver from active feed caches
  - When coming online: Rebuilds feed with driver's preferences
  - Max retries: 3 with exponential backoff

### PostGIS Integration
- Location stored as GEOGRAPHY type for accurate distance calculations
- Spatial index on location column for performant radius queries
- SRID 4326 (WGS84) for GPS coordinate compatibility

## Dependencies

### Required Before Implementation
- **Ticket 004 (Authentication)**: Driver must be authenticated to access profile
- **Ticket 006 (UI Components)**: Requires MobileLayout, Button, TopBar, BottomNav components

### Impacts Future Features
- **Ticket 012 (Order Matching)**: Vehicle type compatibility checking
- **Ticket 013 (Order Feed)**: Radius and availability filtering
- **Ticket 015 (Real-time Tracking)**: Driver location updates

## Success Metrics
- Profile completion rate > 90% for active drivers
- Average time to complete profile < 3 minutes
- Location accuracy within 100 meters for 95% of updates
- Availability toggle response time < 500ms

## Security & Privacy Considerations
- Location data is PII and must be encrypted at rest using Rails `encrypts :location`
- Location history should be retained for maximum 30 days per GDPR requirements
- Implement rate limiting on location updates to prevent abuse (max 1 update per minute)
- Audit log all profile changes for compliance tracking

## Open Questions
1. Should we allow drivers to set multiple vehicle types if they have access to different vehicles?
2. Should working radius be time-based (different radius for peak vs off-peak hours)?
3. How should we handle location updates while driver is on an active delivery?
4. Should profile completeness affect driver ratings or marketplace visibility priority?