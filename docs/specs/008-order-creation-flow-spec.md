# Product Specification: Order Creation Flow

## Feature Overview

The Order Creation Flow enables customers to create delivery orders through a mobile-optimized interface. The system implements a two-phase creation pattern: immediate creation with `processing` status, followed by asynchronous enrichment (geocoding, routing, pricing). This ensures fast, responsive user experience while handling computationally intensive operations in the background.

### Business Value
- **For Customers**: Quick and intuitive order creation with immediate confirmation
- **For the Platform**: Scalable order processing that doesn't block user interactions
- **For Drivers**: Well-structured orders with complete item details for informed decision-making

### Key Principles
- **Mobile-first design**: 56px touch targets, bottom-sheet patterns, minimal scrolling
- **Fail-fast validation**: Client-side validation prevents invalid submissions
- **Progressive enhancement**: Basic address input now, autocomplete later
- **Payment safety**: Orders require valid payment method on file (enforced via ticket 030)

---

## User Stories

### [STORY-008-1] Basic Order Creation
**As a** Customer  
**I want** to create a delivery order with pickup and drop-off locations  
**So that** I can request delivery service for my items

#### Acceptance Criteria
- [ ] Given I am logged in as a customer with a valid payment method, When I navigate to create order page, Then I see the order creation form
- [ ] Given I am on the order creation form, When I enter pickup address, drop-off address, and at least one item, Then the submit button becomes enabled
- [ ] Given I have filled all required fields, When I submit the form, Then I receive immediate confirmation with a processing indicator
- [ ] Given I submit a valid order, When the creation succeeds, Then the order is created with `processing` status
- [ ] Given I am logged in without a payment method, When I try to create an order, Then I see a prompt to add a payment method first

#### Domain Constraints
- **Affected statuses**: Creates order in `processing` status
- **User roles**: Customer only
- **Map implications**: No immediate map display (addresses not geocoded yet)
- **AI feature**: None in this story (pricing happens async in ticket 010)

#### Technical Notes
- Service objects: `Orders::Creator`
- Sidekiq workers: None (async processing in ticket 010)
- PostGIS queries: None (geocoding happens async)
- Inertia page: `Customer/OrderCreate.tsx`
- AI/LLM integration: None in this phase

#### Priority: **Must**
#### Story Points: **5**

---

### [STORY-008-2] Dynamic Item Management
**As a** Customer  
**I want** to add multiple items with quantities and sizes to my order  
**So that** drivers understand what they'll be transporting

#### Acceptance Criteria
- [ ] Given I am creating an order, When I click "Add Item", Then a new item row appears with name, quantity, and size fields
- [ ] Given I have added an item, When I click the remove (×) button, Then the item is removed from the list
- [ ] Given I am entering item details, When I select a size, Then I can choose from Small/Medium/Large/Bulk options
- [ ] Given I have multiple items, When I submit the order, Then all items are saved as OrderItem records
- [ ] Given an item has no name or quantity, When I try to submit, Then I see validation errors for that item

#### Domain Constraints
- **Affected statuses**: Part of order creation (processing)
- **User roles**: Customer
- **Map implications**: None
- **AI feature**: None (future: AI could suggest item categorization)

#### Technical Notes
- Service objects: `Orders::Creator` creates OrderItem records
- Sidekiq workers: None
- PostGIS queries: None
- Inertia component: `ItemListInput.tsx`
- AI/LLM integration: None

#### Priority: **Must**
#### Story Points: **3**

---

### [STORY-008-3] Delivery Type Selection
**As a** Customer  
**I want** to choose between immediate or scheduled delivery  
**So that** I can plan deliveries according to my needs

#### Acceptance Criteria
- [ ] Given I am creating an order, When I view the form, Then I see a toggle for Immediate/Scheduled delivery
- [ ] Given I select "Immediate", When I submit, Then the order is created with `delivery_type: immediate` and no scheduled_at
- [ ] Given I select "Scheduled", When the form updates, Then I see a datetime picker for scheduling
- [ ] Given I select "Scheduled" and pick a past datetime, When I submit, Then I see a validation error
- [ ] Given I select "Scheduled" and pick a future datetime, When I submit, Then the order is created with the scheduled_at timestamp

#### Domain Constraints
- **Affected statuses**: processing (all scheduled orders start here)
- **User roles**: Customer
- **Map implications**: None
- **AI feature**: Future enhancement - AI could suggest optimal delivery windows

#### Technical Notes
- Service objects: `Orders::Creator` validates scheduled_at
- Sidekiq workers: Future - `ScheduledOrderActivator` (ticket 011)
- PostGIS queries: None
- Inertia component: Native datetime-local input or custom picker
- AI/LLM integration: None in MVP

#### Priority: **Must**
#### Story Points: **3**

---

### [STORY-008-4] Optional Order Details
**As a** Customer  
**I want** to add a description and suggested price to my order  
**So that** I can provide additional context and pricing expectations

#### Acceptance Criteria
- [ ] Given I am creating an order, When I view the form, Then I see optional fields for description and suggested price
- [ ] Given I enter a description, When I submit, Then the description is encrypted and saved with the order
- [ ] Given I enter a suggested price, When I submit, Then the price is saved as `suggested_price_cents`
- [ ] Given I enter a negative price, When I submit, Then I see a validation error
- [ ] Given I leave optional fields empty, When I submit, Then the order is created successfully without those values

#### Domain Constraints
- **Affected statuses**: processing
- **User roles**: Customer
- **Map implications**: None
- **AI feature**: Suggested price will be compared with AI pricing in ticket 010

#### Technical Notes
- Service objects: `Orders::Creator` handles optional fields
- Sidekiq workers: None
- PostGIS queries: None
- Inertia component: Part of `OrderForm.tsx`
- AI/LLM integration: None directly (AI pricing comparison happens async)

#### Priority: **Should**
#### Story Points: **2**

---

### [STORY-008-5] Form Validation and Error Handling
**As a** Customer  
**I want** clear validation feedback when creating orders  
**So that** I can fix errors before submission

#### Acceptance Criteria
- [ ] Given I submit without required fields, When validation fails, Then I see inline errors next to each field
- [ ] Given I fix a validation error, When I modify the field, Then the error message disappears
- [ ] Given the server returns validation errors, When displayed, Then they appear next to the relevant fields
- [ ] Given I have validation errors, When I view the form, Then the submit button shows a different state
- [ ] Given network failure during submission, When the request fails, Then I see a user-friendly error message

#### Domain Constraints
- **Affected statuses**: None (validation prevents creation)
- **User roles**: Customer
- **Map implications**: None
- **AI feature**: None

#### Technical Notes
- Service objects: `Orders::Creator` returns validation errors
- Sidekiq workers: None
- PostGIS queries: None
- Inertia component: Uses `useForm` hook with error handling
- AI/LLM integration: None

#### Priority: **Must**
#### Story Points: **3**

---

## Technical Requirements

### API Contracts

#### GET /delivery_orders/new
**Purpose**: Render order creation form  
**Authentication**: Required (Customer role)  
**Inertia Props**:
```ruby
{
  has_payment_method: boolean,  # Whether customer has valid payment method
  user: {
    id: integer,
    name: string,
    email: string
  }
}
```

#### POST /delivery_orders
**Purpose**: Create new delivery order  
**Authentication**: Required (Customer role)  
**Request Body**:
```json
{
  "delivery_order": {
    "pickup_address": "string",
    "dropoff_address": "string", 
    "delivery_type": "immediate|scheduled",
    "scheduled_at": "ISO 8601 datetime (optional)",
    "description": "string (optional)",
    "suggested_price_cents": "integer (optional)",
    "order_items_attributes": [
      {
        "name": "string",
        "quantity": "integer",
        "size": "small|medium|large|bulk"
      }
    ]
  }
}
```

**Success Response (201)**:
```json
{
  "id": 123,
  "status": "processing",
  "tracking_code": "DEL-ABC123",
  "created_at": "2026-03-31T10:00:00Z"
}
```

**Error Response (422)**:
```json
{
  "errors": {
    "pickup_address": ["can't be blank"],
    "order_items": ["must have at least one item"]
  }
}
```

### Data Model Requirements

#### DeliveryOrder Attributes Used
- `created_by_id` (foreign key to User)
- `status` (set to 'processing')
- `delivery_type` (immediate/scheduled)
- `pickup_address` (encrypted)
- `dropoff_address` (encrypted)
- `scheduled_at` (nullable datetime)
- `description` (encrypted, optional)
- `suggested_price_cents` (optional integer)
- `tracking_code` (auto-generated)

#### OrderItem Attributes
- `delivery_order_id` (foreign key)
- `name` (required string)
- `quantity` (required positive integer)
- `size` (enum: small/medium/large/bulk)

### Validation Rules

#### Server-side (Orders::Creator)
- `pickup_address`: required, min 5 characters
- `dropoff_address`: required, min 5 characters, different from pickup
- `delivery_type`: required, must be valid enum value
- `scheduled_at`: required if delivery_type is 'scheduled', must be future datetime
- `suggested_price_cents`: optional, must be positive if present
- `description`: optional, max 500 characters
- `order_items`: must have at least one, max 20 items
- Each order item:
  - `name`: required, 1-100 characters
  - `quantity`: required, integer between 1-999
  - `size`: required, valid enum value
- Payment method check: User must have at least one valid (non-expired, default) payment method

#### Client-side (matching server rules)
- Real-time validation as user types
- Disable submit until all required fields valid
- Show character count for description field

---

## UI/UX Requirements

### Design System Alignment (per DESIGN.md)

#### Layout Structure
- **Container**: `MobileLayout` wrapper with bottom navigation
- **Page Background**: `surface` (#f8f9fb)
- **Form Sections**: `surface-container-low` (#f3f4f6) with tonal layering
- **Input Cards**: `surface-container-lowest` (#ffffff) 

#### Typography
- **Page Title**: Manrope, `display-sm` (2.25rem), color: `primary` (#000e24)
- **Section Headers**: Inter, `title-lg` (1.375rem), color: `on-surface` (#191c1e)
- **Input Labels**: Inter, `label-lg` (0.875rem), color: `on-surface-variant` (#43474e)
- **Input Text**: Inter, `body-lg` (1rem), color: `on-surface` (#191c1e)
- **Helper Text**: Inter, `label-md` (0.75rem), color: `on-surface-variant` (#43474e)

#### Components

##### Input Fields
- **Height**: 56px (per DESIGN.md requirement)
- **Background**: `surface-container-highest` (#e1e2e4) default
- **Active State**: Background changes to `surface-container-lowest` (#ffffff)
- **Border**: NO borders - use "ghost border" (15% opacity) only on focus
- **Border Radius**: `md` (0.75rem)
- **Padding**: 16px horizontal
- **Error State**: Background tint with `error` color at 5% opacity

##### Submit Button
- **Style**: Primary with gradient (`primary` #000e24 to `primary-container` #00234b)
- **Height**: 56px
- **Border Radius**: `md` (0.75rem)
- **Text**: White, Inter Semi-Bold, 1rem
- **Disabled State**: 50% opacity
- **Loading State**: Show spinner, disable interactions

##### Toggle Switch (Immediate/Scheduled)
- **Background**: `surface-container` (#e7e8ea)
- **Active Segment**: `primary` (#000e24) with white text
- **Height**: 48px
- **Border Radius**: `sm` (0.5rem)
- **Animation**: 200ms ease-out slide

##### Item List Component
- **Item Card**: `surface-container-lowest` (#ffffff) with 8px padding
- **Spacing Between Items**: `spacing-3` (0.75rem)
- **Add Button**: Tertiary style, `secondary` (#a33800) text with + icon
- **Remove Button**: 24x24 touch target, `on-surface-variant` (#43474e) × icon

#### Mobile Optimizations
- **Sticky Header**: Page title with glassmorphism (80% opacity, 20px blur)
- **Bottom Sheet**: For datetime picker (slides up from bottom)
- **Keyboard Avoidance**: Form scrolls to keep active input visible
- **Tap Targets**: Minimum 44x44dp for all interactive elements

### Form Flow

1. **Initial State**
   - Show payment method warning if none on file
   - All fields empty, submit disabled
   - "Immediate" delivery selected by default

2. **Progressive Disclosure**
   - Datetime picker only shown when "Scheduled" selected
   - Error messages appear inline as user types
   - Submit enables when all required fields valid

3. **Submission Flow**
   - Show loading spinner on button
   - Disable all inputs during submission
   - On success: Show confirmation with order tracking code
   - On error: Show errors inline, maintain form state

4. **Confirmation State**
   - Success message with tracking code
   - "Processing" status indicator
   - "View Order" CTA button
   - "Create Another" secondary button

---

## Service Object Design

### Orders::Creator

```ruby
module Orders
  class Creator
    attr_reader :user, :params, :order

    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      return error_result("Payment method required") unless valid_payment_method?
      
      ActiveRecord::Base.transaction do
        create_order
        create_order_items
        generate_tracking_code
      end

      success_result
    rescue ActiveRecord::RecordInvalid => e
      error_result(e.record.errors)
    end

    private

    def valid_payment_method?
      user.payment_methods.default.active.exists?
    end

    def create_order
      @order = user.delivery_orders.create!(
        status: :processing,
        pickup_address: params[:pickup_address],
        dropoff_address: params[:dropoff_address],
        delivery_type: params[:delivery_type],
        scheduled_at: params[:scheduled_at],
        description: params[:description],
        suggested_price_cents: params[:suggested_price_cents]
      )
    end

    def create_order_items
      items_params = params[:order_items_attributes] || []
      items_params.each do |item_params|
        @order.order_items.create!(
          name: item_params[:name],
          quantity: item_params[:quantity],
          size: item_params[:size]
        )
      end
    end

    def generate_tracking_code
      @order.update!(tracking_code: "DEL-#{SecureRandom.alphanumeric(6).upcase}")
    end

    def success_result
      Result.new(success: true, order: @order)
    end

    def error_result(errors)
      Result.new(success: false, errors: errors)
    end

    class Result
      attr_reader :order, :errors

      def initialize(success:, order: nil, errors: nil)
        @success = success
        @order = order
        @errors = errors
      end

      def success?
        @success
      end
    end
  end
end
```

---

## Edge Cases to Handle

1. **Payment Method Edge Cases**
   - No payment method on file → Show add payment method prompt
   - Expired payment method → Treat as no payment method
   - Multiple payment methods → Use default one for validation

2. **Address Input Edge Cases**
   - Same pickup and dropoff → Show validation error
   - Very long addresses → Truncate display, store full value
   - Special characters → Sanitize but preserve for geocoding

3. **Scheduling Edge Cases**
   - Scheduled time in past → Validation error
   - Scheduled time within next hour → Show warning but allow
   - Timezone handling → Store in UTC, display in user's timezone

4. **Item List Edge Cases**
   - Zero items → Validation error
   - More than 20 items → Validation error
   - Duplicate item names → Allow (could be intentional)
   - Very long item names → Truncate in UI, store up to 100 chars

5. **Network Edge Cases**
   - Submission timeout → Show error, preserve form state
   - Duplicate submission → Prevent with request ID
   - Offline mode → Show offline indicator, disable submit

6. **Browser Edge Cases**
   - Back button after submission → Handle with Inertia router
   - Form autofill → Support for address fields
   - Session timeout → Redirect to login, preserve form data if possible

---

## Migration Considerations

Since this is an MVP feature, consider these future enhancements:

1. **Address Autocomplete** (Future)
   - Integrate with geocoding service
   - Show suggestions as user types
   - Store structured address components

2. **Smart Pricing** (Ticket 010)
   - AI-powered price estimation
   - Show estimated price before submission
   - Compare with user's suggested price

3. **Order Templates** (Future)
   - Save frequent orders as templates
   - Quick reorder functionality
   - Bulk order creation

4. **Multi-stop Deliveries** (Future)
   - Multiple pickup/dropoff locations
   - Route optimization
   - Complex pricing models

5. **Business Features** (Future)
   - Bulk CSV upload
   - API integration
   - Recurring scheduled orders

---

## Success Metrics

- **Completion Rate**: % of users who start and complete order creation
- **Time to Complete**: Average time from form load to submission
- **Validation Error Rate**: % of submissions with validation errors
- **Item Count Distribution**: Average items per order
- **Delivery Type Split**: % immediate vs scheduled

---

## Open Questions

1. **Address Format**: Should we enforce specific address formats or allow free text for MVP?
   - Decision: Free text for MVP, structured in future

2. **Price Validation**: Should we set min/max bounds for suggested price?
   - Decision: Minimum $1, no maximum for MVP

3. **Item Images**: Should customers be able to attach photos of items?
   - Decision: Not in MVP, consider for future

4. **Order Drafts**: Should incomplete orders be saved as drafts?
   - Decision: Not in MVP, form state only preserved during session

5. **Notifications**: Should customer receive email/SMS on order creation?
   - Decision: Yes, handled by NotificationDispatchWorker in ticket 012

---

## Implementation Notes (2026-03-31)

### Backend Components Implemented

#### 1. Database Migration
- **File**: `db/migrate/20260331112541_modify_delivery_orders_for_order_creation.rb`
- Made `pickup_location` and `dropoff_location` nullable (geocoding happens async)
- Added `tracking_code` column with unique index
- Added `suggested_price_cents` column

#### 2. Models Updated
- **DeliveryOrder** (`app/models/delivery_order.rb`):
  - Added `accepts_nested_attributes_for :order_items`
  - Enhanced validations: address length, description max length, suggested price positive
  - Custom validations: future `scheduled_at`, different addresses, item count limits (1-20)
  - Encryption: `pickup_address`, `dropoff_address`, `description` (Rails 8 `encrypts`)
  
- **OrderItem** (`app/models/order_item.rb`):
  - Added length validations: name (1-100 chars), quantity (1-999)
  - Enum validation for size (small/medium/large/bulk)

#### 3. Service Object
- **File**: `app/services/orders/creator.rb`
- Plain Ruby object (PORO) pattern with Result object
- Payment method guard (checks for default, active payment method)
- Customer role guard
- Builds order with items in memory, validates, then saves atomically
- Generates unique tracking code (DEL-XXXXXX format)
- Transaction safety: rolls back on any validation failure
- Handles ArgumentError for invalid enum values

#### 4. Controller
- **File**: `app/controllers/delivery_orders_controller.rb`
- `new` action: Renders Inertia page with payment method check
- `create` action: Calls service, returns 201 with serialized order or 422 with errors
- Authentication required (`before_action :authenticate`)
- Customer role required (`before_action :require_customer`)
- Strong params with nested attributes for order items

#### 5. Serializer
- **File**: `app/serializers/delivery_order_serializer.rb`
- Serializes order with all fields including encrypted PII
- Nested order items serialization
- Location data as GeoJSON (when available)
- ISO8601 timestamps
- Creator user data

#### 6. Routes
- `GET /delivery_orders/new` → `DeliveryOrdersController#new`
- `POST /delivery_orders` → `DeliveryOrdersController#create`

### Test Coverage

#### Factories Created
- `delivery_orders.rb` - with traits: `:scheduled`, `:with_items`, `:with_location`, `:with_description`, `:with_suggested_price`
- `order_items.rb` - with size traits
- `payment_methods.rb` - with traits: `:default`, `:expired`, `:active`
- `assignments.rb` - for relationship testing

#### Test Files (125 examples, 0 failures)
- `spec/models/delivery_order_spec.rb` (37 examples)
  - Associations, enums, validations, encryption, scopes
- `spec/models/order_item_spec.rb` (17 examples)
  - Associations, enums, validations
- `spec/services/orders/creator_spec.rb` (26 examples)
  - Happy path, payment method validation, invalid params, transaction rollback
- `spec/controllers/delivery_orders_controller_spec.rb` (24 examples)
  - Authentication, authorization, create/new actions, error handling
- `spec/serializers/delivery_order_serializer_spec.rb` (21 examples)
  - All fields serialization, nested items, location data

### Key Design Decisions

1. **Nullable Locations**: Locations are nullable to support immediate order creation without blocking on geocoding
2. **In-Memory Item Building**: Items built in memory before save to ensure atomic transaction
3. **Payment Method Guard**: Service enforces payment method requirement (prep for ticket 030)
4. **Enum Error Handling**: Service catches ArgumentError from invalid enum values
5. **Tracking Code Generation**: Retry logic with max 10 attempts to handle collisions
6. **PII Encryption**: All address fields and description encrypted at rest
7. **Validation Rules**:
   - Pickup/dropoff addresses: min 5 chars, must be different
   - Items: 1-20 per order, name 1-100 chars, quantity 1-999
   - Description: max 500 chars
   - Suggested price: positive integer (cents)
   - Scheduled delivery: must have future `scheduled_at`

### Frontend Integration Points

The controller returns JSON for the create action with this structure:

```json
{
  "id": 123,
  "tracking_code": "DEL-ABC123",
  "status": "processing",
  "delivery_type": "immediate",
  "pickup_address": "...",
  "dropoff_address": "...",
  "order_items": [
    {"id": 1, "name": "Box", "quantity": 1, "size": "medium"}
  ],
  "created_at": "2026-03-31T10:00:00Z",
  ...
}
```

Error responses (422) return:
```json
{
  "errors": {
    "pickup_address": ["can't be blank"],
    "order_items": ["must have at least one item"]
  }
}
```

### Next Steps (Ticket 010)

- Enqueue background workers for:
  - Geocoding (GeocodeWorker)
  - Route calculation (RouteCalculationWorker)
  - Price estimation (PriceEstimationWorker)
  - Driver matching (DriverMatchWorker)
- Transition order from `processing` → `open` status when ready