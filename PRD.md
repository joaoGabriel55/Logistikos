# 📄 Product Requirements Document (PRD)  
**Logistikos — Supply-Driven Logistikos Marketplace (with Real-Time Map Viewer & AI-Powered Features)**

---

## 🏆 Competition Context: AI Dev Challenge

This project is being developed for the **AI Dev Challenge**, a 2-week internal competition (dev period: **03/30/2026 – 04/10/2026**). The evaluation criteria directly shaped product decisions:

| Criterion | How Logistikos Addresses It |
|---|---|
| **AI Usage** | AI used across the full dev cycle (ideation, architecture, code, tests, docs, design). AI is also a **user-facing feature** (smart pricing, intelligent order matching, delivery Estimated Time of Arrival (ETA) predictions) — earning bonus points. |
| **Creativity & Innovation** | Supply-driven Logistikos marketplace with real-time map tracking and a zero-external-API geodata stack (Supabase PostGIS + pgRouting). Not a to-do list. |
| **Scope & Value Delivered** | Full production-ready flows for 2 user roles (Customer, Driver), real-time map, background task system, notifications — ambitious but focused. |
| **Technical Quality** | Clean MVC architecture (Rails + Inertia.js + React), incremental commits, comprehensive tests, proper error handling, no hardcoded credentials. |
| **Real Potential** | Addresses a real market gap for independent drivers and small Logistikos businesses. Viable as SaaS or internal tool. |
| **User Experience** | Mobile-first, intuitive flows, optimistic UI, < 3 taps to accept an order. |
| **Presentation** | App must function live. Dockerfile provided for reproducible deployment. |

### Deliverables

| Deliverable | Detail |
|---|---|
| **Repository** | GitHub — transferred to the Code org at the end |
| **README** | Product description, usage instructions, documented environment variables |
| **Deployed App** | **Publicly accessible link on Render.com** (https://render.com/) — free tier web service |
| **Dockerfile** | Ready for VPS / Render deployment |

### Key Dates

| Event | Date |
|---|---|
| Development start | 03/30/2026 |
| Submission (repo + README + deploy on Render.com) | 04/10/2026 |
| Top 3 finalists announced | 04/16/2026 |
| Presentations + voting | 04/17/2026 |

---

## Terminology Guide

To avoid ambiguity, this document uses the following domain terms consistently:

| Term | Meaning |
|---|---|
| **Delivery Order** (or **Order**) | A customer-created request for a delivery. This is the core domain entity that drivers browse, accept, and fulfill. |
| **Order Item** | A line item within a Delivery Order (name, quantity, size). |
| **Assignment** | The binding between a Delivery Order and the driver who accepted it. |
| **Background Task** (or **Worker Task**) | An asynchronous unit of work processed off the main request path (e.g., geocoding, notifications, ETA recalculation). These run in a task queue and never block the user. |
| **Worker** | A long-running process that consumes and executes background tasks from a queue. |
| **Payment** | A financial transaction record linking a DeliveryOrder to a charge or payout processed via a payment gateway. |
| **Payment Method** | A tokenized customer payment instrument (card, digital wallet). Raw card data is never stored — only gateway tokens. |
| **Payment Gateway** | An external payment processing service (Stripe, GPay, ApplePay, etc.) accessed via an adapter pattern. **For MVP, a MockAdapter is the default** — it simulates all gateway operations (authorize, capture, refund) with deterministic success responses, so evaluators can test the full payment flow without real credentials. |
| **Driver Earning** | The net amount a driver receives for a completed delivery (captured amount minus platform fee). |
| **PII** | Personally Identifiable Information — any data that can identify a person directly or indirectly, subject to encryption, filtering, and retention policies. |
| **DSAR** | Data Subject Access Request — a user's right to access, export, or delete their personal data (GDPR Art. 15-17, LGPD Art. 18). |
| **Consent** | A user's explicit, recorded permission for specific data processing purposes (e.g., location tracking, payment processing). |

> **Why this matters:** "Job" is ambiguous in a Logistikos product — it could mean the delivery itself _or_ a background processing unit. This document avoids "job" entirely to prevent confusion between domain concepts and infrastructure concepts.

---

## 1. 🎯 Product Overview

### Product Name

**Logistikos**

### Product Type

Mobile-first web application

### Summary

A Logistikos marketplace that enables **independent drivers, small delivery businesses, and fleet operators** to discover and accept delivery orders posted by customers.

**Core features:**
- **Real-time map viewer** allowing both drivers and customers to see the full delivery route and the driver's live position during execution
- **AI-powered smart pricing** — automatic price estimation using ML-based models that consider distance, load, time of day, and historical data
- **AI-powered intelligent matching** — smart driver-order matching that goes beyond radius, considering driver history, preferences, and route optimization

Unlike traditional delivery apps, this platform is **supply-driven**, where drivers choose profitable orders **and** track progress visually on an interactive map.

---

## 2. 💡 Problem Statement

### For Drivers / Small Logistikos Businesses

* Lack of consistent demand
* No centralized place to discover delivery opportunities
* Difficulty identifying profitable orders quickly

### For Customers

* Hard to find available and reliable delivery providers
* No easy way to request complex deliveries (e.g., moving, bulk transport)

---

## 3. 🚀 Product Goals

### Primary Goal

Enable drivers and small Logistikos businesses to discover, evaluate, accept, **and visually track** delivery orders efficiently.

### Secondary Goal

Allow customers to post requests **and monitor progress in real time on a map**.

---

## 4. 🧑‍🤝‍🧑 Target Users

### Primary Users (Core Focus)

* Independent drivers
* Small Logistikos businesses
* Fleet owners

### Secondary Users

* Individuals
* Small businesses needing delivery services

---

## 5. 🧩 Core Value Proposition

### For Drivers (Core)
- Access to an order marketplace
- Freedom to choose orders based on distance, load, and profitability
- **AI-powered order recommendations** — personalized feed ranking based on driver preferences, location history, and earning patterns
- **Real-time map navigation during delivery**
- **Transparent earnings** — see per-delivery earnings breakdown, automatic payout tracking after platform fee deduction

### For Customers
- Access to a distributed delivery network
- **AI-powered smart pricing** — fair, transparent price suggestions based on route complexity, load, and market conditions
- **Live visibility of the driver's position and route on an interactive map**
- **Secure, seamless payments** — pay on delivery completion with stored payment methods; full refund on cancellation before capture

---

## 6. 📦 MVP Scope (2 Weeks — Production Ready)

> **This is NOT a POC.** The app must be complete, stable, and deployable. All flows must work end-to-end. No broken screens, no hardcoded data, no local-only dependencies. The app must be ready for a live demo and public deployment on Render.com.

Now includes a real-time map viewer powered by Mapbox on the frontend, **AI-powered features** for end users, and a **gateway-agnostic payment system** (MockAdapter MVP default, Stripe adapter available) with authorize-on-acceptance, capture-on-completion lifecycle.

> **⚠️ MVP Payment Strategy:** The payment gateway is **mocked by default** (`PAYMENT_GATEWAY=mock`). The `MockAdapter` simulates all payment operations (authorize, capture, refund) with deterministic success responses and realistic delays. This ensures evaluators can test the complete order→payment→earning flow without configuring real Stripe API keys. To use real Stripe, set `PAYMENT_GATEWAY=stripe` and configure credentials.

### AI-Powered User-Facing Features

These features use AI/ML as core functionality visible to the end user (competition bonus):

1. **Smart Price Estimation** — When a customer doesn't provide a suggested price, an AI model estimates a fair price considering distance, load size/type, time of day, and delivery urgency. Uses a trained model (or LLM-based reasoning) rather than a simple formula.

2. **Intelligent Order Ranking** — The driver feed is ranked by an AI model that learns from driver behavior (accepted orders, ignored orders, preferred routes) to surface the most relevant orders first. Goes beyond simple distance sorting.

3. **Natural Language Order Description** — Customers can describe their delivery needs in natural language (e.g., "I need to move a sofa and two boxes from Boa Viagem to Casa Forte, preferably this afternoon"). An LLM parses this into structured order fields (pickup, dropoff, items, schedule, size category).

4. **AI-Powered ETA Narratives** — Instead of showing raw minutes, the customer tracking screen shows contextual updates generated by AI (e.g., "Your driver is 3 minutes away, currently passing through Boa Viagem. Traffic is light.").

**Geodata architecture:**

* **Frontend (Mapbox GL JS)** — Map tile rendering, route polyline display, and live driver markers. This is the only layer that uses Mapbox.
* **Backend (Supabase PostGIS + pgRouting)** — All heavy geodata processing lives inside the managed Supabase PostgreSQL instance. PostGIS handles spatial storage, indexing, distance calculations, radius queries, and geocoding. pgRouting handles route calculation over an imported OpenStreetMap road network. **No external paid geocoding or routing APIs are used on the backend**, eliminating per-request costs and external dependencies.
* The backend stores and serves raw geodata (coordinates, polylines, distances) via Inertia props and REST endpoints. The frontend consumes this data and renders it on Mapbox maps.

---

## 7. 🔑 Functional Requirements

### 7.1 Authentication & Roles

**Authentication is powered by Rails 8 built-in authentication** (`bin/rails generate authentication`), which provides:
* `has_secure_password` for password hashing (bcrypt)
* `Session` model for session management
* `Current.user` singleton for accessing the authenticated user
* Authentication concern for controllers (`before_action :authenticate`)

Users must:

* Sign in via Google OAuth (preferred) or email/password
* Be assigned a role:

  * Customer
  * Driver / Business

---

### 7.2 Delivery Order Creation (Customer)

Customers can create delivery orders with:

**Required Fields:**

* Pickup address
* Drop-off address
* Delivery type:

  * Immediate
  * Scheduled
* Load details:

  * Item list (multiple items)
  * Quantity per item
  * Size category:

    * Small / Medium / Large / Bulk
* Description (optional)

**Optional Fields:**

* Suggested price

**⚡ Background Tasks on Order Creation:**

When a customer submits a delivery order, the API returns immediately with status `201 Created` and the order in a `processing` state. The following tasks run asynchronously via Solid Queue background workers:

* **Geocoding Task** — Convert pickup and drop-off addresses to lat/lng coordinates using PostGIS geocoding functions (inside Supabase).
* **Route Calculation Task** — Compute the shortest-path route between pickup and drop-off using pgRouting (`pgr_dijkstra` or `pgr_astar`) over the imported OSM road network inside Supabase. The resulting route geometry is stored as a GeoJSON polyline (`ST_AsGeoJSON`), along with total distance (`ST_Length`) and estimated duration.
* **Price Estimation Task** — If no suggested price was provided, calculate a recommended price based on the computed distance, load size, and vehicle type.
* **Driver Matching & Notification Fan-Out Task** — Use PostGIS spatial queries (`ST_DWithin`) to identify all eligible drivers (compatible vehicle, available, within radius) and enqueue in-app notifications for each.

Once all background tasks complete, the order transitions to `open` and becomes visible in the driver feed. If geocoding or routing fails, the order enters an `error` state and the customer is notified to correct the address.

---

### 7.3 Order Marketplace (Driver Feed) ⭐ CORE FEATURE

Drivers access a **real-time order feed** containing:

Each order card includes:

* Pickup distance (calculated via `ST_Distance` or `ST_DistanceSphere` from driver's last known position inside Supabase)
* Delivery distance (optional estimate from pgRouting)
* Load summary (item list preview)
* Size classification
* Price
* Scheduled/immediate indicator

**⚡ Background Tasks:**

* **Feed Indexing Task** — Periodically rebuilds or updates a denormalized feed cache (database-backed cache or materialized view) with pre-computed pickup distances relative to each driver's last known location using PostGIS spatial queries inside Supabase, so feed queries remain fast regardless of order volume.
* **Stale Order Cleanup Task** — A recurring task that marks `open` orders older than a configurable threshold (e.g., 2 hours for immediate, 24 hours for scheduled) as `expired` and notifies the customer.

---

### 7.4 Order Filtering & Discovery

Drivers can filter orders by:

* Distance radius (powered by PostGIS `ST_DWithin` spatial index queries inside Supabase)
* Vehicle compatibility
* Load size
* Price range

---

### 7.5 Order Acceptance

* Drivers can accept a delivery order
* Once accepted:

  * Order becomes **assigned**
  * Removed from marketplace
* Only one driver per order

**⚡ Background Tasks on Order Acceptance:**

The acceptance endpoint uses an optimistic lock (row-level `SELECT ... FOR UPDATE` or version column) to prevent race conditions. Once the assignment is committed:

* **Customer Notification Task** — Notify the customer that a driver has accepted, including driver name, vehicle type, and ETA.
* **Feed Invalidation Task** — Remove the order from all driver feed caches and cancel any pending notification deliveries for this order.
* **Route Snapshot Task** — If not already cached, compute and store the full route polyline via pgRouting (inside Supabase) so neither the driver's nor the customer's frontend needs to wait for geodata on first map load.

---

### 7.6 Notifications System (Critical)

Drivers receive notifications when:

* New orders are available matching their preferences

**MVP Implementation:**

* Polling-based updates (every 3–5 seconds)
* In-app notifications (no push required)

**⚡ Background Tasks:**

* **Notification Dispatch Worker** — When a new order is created (or a status changes), a Solid Queue worker evaluates driver preference rules (radius via PostGIS inside Supabase, vehicle type, availability) and creates notification records in batch. This prevents the order creation endpoint from scaling linearly with driver count.
* **Notification Expiry Task** — A scheduled task that marks unread notifications as `expired` once the associated order is no longer `open` (accepted, cancelled, or expired), keeping the notification feed clean.

---

### 7.7 Delivery Execution Flow

Each delivery order follows a status lifecycle:

* `open` — visible in marketplace
* `accepted` — driver assigned
* `pickup_in_progress` — driver en route to pickup
* `in_transit` — goods collected, en route to drop-off
* `completed` — delivery confirmed

Drivers can update status manually.

**⚡ Background Tasks on Status Transitions:**

Each status update triggers async side effects via a status transition worker:

| Transition | Background Tasks Triggered |
|---|---|
| `open` → `accepted` | Customer notification, feed invalidation, route caching, **PaymentAuthorizationWorker** (authorize estimated amount on customer's payment method) |
| `accepted` → `pickup_in_progress` | Customer notification ("Driver is heading to pickup"), start location polling window, **request GPS permission from driver's device; begin continuous GPS tracking via browser Geolocation API** |
| `pickup_in_progress` → `in_transit` | Customer notification ("Driver has picked up your items"), recalculate ETA from current position |
| `in_transit` → `completed` | Customer notification ("Delivery completed"), stop location polling, stop GPS tracking, archive assignment, mark driver as `available` again, **PaymentCaptureWorker** (capture final amount), **create DriverEarning record** |
| Any → `cancelled` | **PaymentRefundWorker** (void authorization or refund if captured), re-open order or mark as cancelled, notify counterpart |

* **Stale Delivery Monitor Task** — A scheduled task that flags active deliveries with no status update for more than a configurable time (e.g., 30 minutes) and alerts an operations dashboard or sends a reminder notification to the driver.

---

### 7.8 Driver Profile Management

Drivers must define:

* Vehicle type:

  * Motorcycle
  * Car
  * Van
  * Truck
* Availability (on/off)
* Preferred working radius

**⚡ Background Tasks:**

* **Availability Toggle Task** — When a driver goes offline, a background task removes them from all active notification queues and stops location polling. When they come back online, the task rehydrates their feed with currently eligible orders.

---

### 7.9 Real-Time Map Viewer ⭐ CORE FEATURE

Users (Drivers and Customers) can open an interactive map viewer that displays:

* Pickup and drop-off addresses as pins
* Calculated delivery route (polyline rendered from backend-cached GeoJSON, computed by pgRouting inside Supabase)
* Driver's current position (live marker that updates via polling)
* Optional ETA and distance remaining

**Availability:**
* Order Details screen (preview before acceptance)
* Active Delivery View (Driver — for navigation)
* Order Status Tracking screen (Customer)

**MVP Implementation:**
* **Mapbox GL JS on the frontend** — renders map tiles, pins, polylines, and live markers. This is the **only Mapbox usage** in the entire stack.
* **Backend serves pre-computed geodata via Inertia props and REST endpoints** — coordinates, cached route polyline (GeoJSON from pgRouting inside Supabase), driver lat/lng + timestamp. All spatial computation happens in Supabase PostGIS/pgRouting, never on the frontend or via external APIs.
* Polling every 5–15 seconds while delivery is active
* Graceful fallback if location data is stale
* **Driver location source (GPS):** During active delivery, location updates originate from the driver's device GPS via `navigator.geolocation.watchPosition()` with `enableHighAccuracy: true`. The frontend `useGpsTracking` hook manages the GPS session and transmits coordinates to the backend at 5–10 second intervals.
* **GPS permission flow:** On delivery start (`accepted` → `pickup_in_progress`), the frontend requests GPS permission. On denial, a persistent warning banner is shown and the driver is prompted to enable location services. A manual position fallback is available as a last resort but clearly marked as degraded.

**⚡ Background Tasks:**

* **Location Ingestion Worker** — Driver location updates (sent from the driver's device GPS every 5–10 seconds via the `useGpsTracking` hook) are batched and flushed to the Assignment table in batches (every 10–15 seconds). This prevents high-frequency `UPDATE` pressure on Supabase.
* **ETA Recalculation Task** — Every 30–60 seconds for active deliveries, a Solid Queue recurring task recalculates the ETA using pgRouting (`pgr_dijkstra` from driver's current position to drop-off inside Supabase) and updates the cached route metadata. The frontend simply reads the updated ETA from the API.
* **Stale Location Detector Task** — A periodic task that checks for active deliveries where `last_location_updated_at` is older than 60 seconds and marks the location data as `stale`, so the frontend can display a warning badge instead of a misleading position.

> **GPS Requirement:** During `pickup_in_progress` and `in_transit` statuses, the driver's location **MUST** come from the device GPS via the browser Geolocation API (`navigator.geolocation.watchPosition` with `enableHighAccuracy: true`). Manual location input is not permitted during active delivery. If GPS permission is denied, the driver is shown a persistent warning banner and prompted to enable location services. As a last resort, a manual position fallback is available but clearly marked as "manual/degraded" for transparency.

---

### 7.10 Payment Processing

Logistikos uses an **Uber-like payment model**: customers pay when a delivery is completed, and drivers receive earnings after a platform fee deduction.

**Payment Lifecycle:**

1. **Customer adds a payment method** — In production, card data is tokenized client-side via Stripe.js Elements (raw card data never touches the server). **In MVP (MockAdapter)**, the payment method form accepts test card details and generates a mock token — no real card processing occurs.
2. **Order acceptance** (`open` → `accepted`) — The estimated amount is **authorized** (held) on the customer's default payment method via the payment gateway. With MockAdapter, authorization always succeeds with a simulated gateway response.
3. **Delivery completion** (`in_transit` → `completed`) — The final amount is **captured** from the authorized hold. A `DriverEarning` record is created with `net_amount = captured_amount - platform_fee`.
4. **Cancellation** — If the authorization has not been captured, it is **voided**. If already captured, a full **refund** is issued.

**Gateway Abstraction (Adapter Pattern):**

The payment system is designed to be **gateway-agnostic**. The architecture allows swapping or adding payment providers without changing business logic:

* `Payments::Gateway` — Defines the interface contract: `authorize`, `capture`, `refund`, `create_customer`, `add_payment_method`
* `Payments::Adapters::BaseAdapter` — Shared adapter behavior (error wrapping, logging, idempotency key generation)
* `Payments::Adapters::MockAdapter` — **MVP default** — simulates all gateway operations with deterministic success responses, realistic delays, and fake gateway IDs. Enables full payment flow testing without external dependencies.
* `Payments::Adapters::StripeAdapter` — Production implementation using the `stripe` gem
* Gateway selection is configured via the `PAYMENT_GATEWAY` environment variable (default: `mock`; set to `stripe` for production)
* Adding a new gateway (e.g., GPay, ApplePay, Mercado Pago) requires only creating a new adapter class — no changes to workers, controllers, or business logic

**⚡ Background Tasks:**

All payment operations run via Solid Queue workers — they never block the user request path:

* **Payment Authorization Worker** (`critical` queue) — On order acceptance, authorizes the estimated amount on the customer's payment method via the gateway. If authorization fails, the order reverts to `open` and the customer is notified to update their payment method.
* **Payment Capture Worker** (`critical` queue) — On delivery completion, captures the final amount from the authorized hold. Creates a `DriverEarning` record with the net amount after platform fee.
* **Payment Refund Worker** (`default` queue) — On cancellation, voids the authorization (if not yet captured) or issues a full refund (if already captured).

**Security:**

* **No raw card data** — Card numbers, CVVs, and full card data are never stored, logged, or transmitted through the server. Stripe.js Elements handles tokenization client-side.
* **PCI DSS compliance** — By using gateway tokenization, Logistikos operates at PCI SAQ-A level (lowest compliance burden).
* **Payment gateway API keys** — Stored in Rails credentials (`bin/rails credentials:edit`), never hardcoded or in environment variables directly.
* **Idempotency** — All mutating gateway API calls include idempotency keys to prevent double-charges on retries.

**Driver Earnings:**

* Platform fee is configurable via `PLATFORM_FEE_PERCENT` environment variable (default: 15%)
* `DriverEarning.net_amount_cents = gross_amount_cents - platform_fee_cents`
* Earnings are visible to drivers per-delivery and as a cumulative summary in their profile
* Payout tracking (`paid_out_at`) is included in the model for future payout automation

---

## 8. 🧠 Business Rules

* Orders are visible only to compatible vehicles
* Order assignment is first-come, first-served
* Drivers must be marked as "available" to receive orders
* Cancellation allowed only before pickup starts
* Radius-based visibility (default: 10–20 km, enforced via PostGIS `ST_DWithin` inside Supabase)
* Map viewer is available to any authenticated user viewing an active or recently accepted order
* Location sharing is opt-in per delivery (driver must be "on duty" and have accepted the order)
* **Customers must have a valid payment method on file before creating an order**
* **Payment is authorized (held) when a driver accepts an order; captured only upon delivery completion**
* **If delivery is cancelled before capture, the authorization is voided; if after capture, a full refund is issued**
* **Driver earnings = captured amount minus platform fee** (configurable, default 15%)
* **GPS must be enabled on the driver's device during active delivery** (`pickup_in_progress`, `in_transit`); manual location input is not permitted during active delivery
* **PII fields are encrypted at rest** and filtered from all logs, error reports, and background job arguments

---

## 9. 📱 User Flows

### 🔹 Customer Flow
1. Login
2. Create delivery order
3. **Order enters `processing` state (background geocoding via Supabase PostGIS + routing via pgRouting + driver matching)**
4. Submit confirmation shown immediately; order transitions to `open` asynchronously
5. Wait for driver acceptance **(receive in-app notification when accepted)**
6. **Track delivery status AND view live map with driver position**

### 🔹 Driver / Business Flow (Primary)
1. Login
2. Configure profile (vehicle, availability)
3. Access order marketplace **(pre-built feed loaded from cache, distances from Supabase PostGIS)**
4. Filter and browse orders
5. View order details **(including map preview with pre-cached route from pgRouting inside Supabase)**
6. Accept order **(optimistic lock, instant feedback)**
7. Execute delivery **(real-time map with navigation, location buffered in background)**
8. Update status until completion **(each transition triggers async notifications)**

---

## 10. 🖥️ Key Screens

> All screens are designed **mobile-first** using responsive React components rendered via Inertia.js. The layout prioritizes touch interactions, vertical stacking, and bottom-anchored action buttons optimized for one-handed use.

### Customer
* Login
* Create Order Form **(with inline processing indicator)**
* **Natural Language Order Creation** — free-text input parsed by AI into structured fields, with confirmation screen
* **Order Status Tracking (with embedded Map Viewer + AI ETA Narratives)**

### Driver (Priority UX)
* Order Feed (main screen) ⭐ **(AI-ranked by relevance)**
* Filters Panel
* Order Details (with map preview + **AI-estimated price breakdown**)
* **Active Delivery View (full-screen map + status buttons)**
* Status Update Screen

---

## 11. ⚙️ Non-Functional Requirements

### Performance
* Order feed loads in < 2 seconds
* **Map viewer loads in < 3 seconds; marker updates feel real-time (5–15s polling)**
* Order creation API responds in < 500ms (heavy work offloaded to background tasks)
* Status update API responds in < 300ms (notifications dispatched async)
* Location update ingestion responds in < 200ms (buffered, not written synchronously)
* Supabase PostGIS spatial queries (radius, distance) respond in < 50ms with proper GiST indexing

### Scalability (MVP Level)
* Designed for low/medium traffic
* Solid Queue workers can be scaled horizontally independent of the Rails server
* Supabase PostGIS spatial indexes handle location queries efficiently without external API rate limits

### Reliability
* Prevent duplicate order acceptance (optimistic locking)
* Ensure data consistency (location updates are non-blocking)
* Background tasks must be **idempotent** — safe to retry on failure without side effects
* Failed tasks are retried with exponential backoff (max 3 attempts) and moved to a dead-letter queue for manual inspection
* **Payment operations are idempotent** — safe to retry without double-charging (idempotency keys on all gateway calls)
* **Payment state is tracked independently** from order state — eventual consistency between order lifecycle and payment lifecycle

### Security
* Authenticated access only
* Location data visible only to participants of the delivery
* Solid Queue workers run within the same trust boundary as the Rails app; no public endpoints exposed
* **PII encrypted at rest** using Rails Active Record Encryption (`encrypts` directive) — email (deterministic/searchable), name, phone, addresses (non-deterministic)
* **PII filtered from logs** via `config.filter_parameters` and per-model `self.filter_attributes`
* **Background workers receive only record IDs** — PII data is never passed as worker arguments
* **Payment data is tokenized** via the gateway — raw card numbers, CVVs, and full card data never enter the system
* **Payment gateway API keys** stored in Rails credentials (`bin/rails credentials:edit`)
* **HTTPS enforced** in production (`config.force_ssl = true` with HSTS)

### Privacy & Data Protection
* **GDPR/LGPD compliance foundations** — built-in support for data subject rights (access, rectification, erasure)
* **Data retention policy**: location history anonymized after 90 days; completed order PII anonymized after configurable retention period (default: 3 years)
* **DSAR foundations**: `Anonymizable` and `DataExportable` concerns on User model — users can request export or deletion of their personal data
* **Consent management**: append-only `Consent` records tracking user permissions for specific purposes (terms_of_service, location_tracking, payment_processing, marketing)
* **Data minimization**: serializers expose only necessary fields in Inertia props; strong parameters in controllers
* **`logstop` gem** for catch-all PII pattern redaction in logs as a safety net

### UX Requirements
* **Mobile-first design** — all screens designed for 375px–428px viewport widths as the primary target, with graceful scaling up to desktop
* **Touch-optimized interactions** — minimum 44px touch targets, swipe gestures for common actions, bottom-sheet modals
* Fast order scanning experience
* **Smooth, responsive map interactions (pinch-zoom, auto-center on driver)**
* Minimal steps for order acceptance (< 3 taps)
* **Optimistic UI updates** — the interface reflects expected state immediately, with background confirmation
* **Bottom navigation bar** — persistent mobile navigation for quick switching between Feed, Orders, Map, and Profile

---

## 12. 🏗️ Technical Stack

### Architecture Pattern: MVC with Inertia.js

The application follows the **Model-View-Controller (MVC)** pattern using **Ruby on Rails** as the backend framework with **Inertia.js (inertia_rails adapter)** bridging Rails controllers to **React** frontend components.

**How it works:**
- **Model** — Rails ActiveRecord models with PostGIS/ActiveRecord spatial extensions (`activerecord-postgis-adapter`). Business logic, validations, and domain rules live in models and service objects (POROs).
- **View** — React components (TypeScript) rendered via Inertia.js. No traditional ERB views. Each Inertia page receives props directly from the controller — no REST API layer, no client-side data fetching for page loads.
- **Controller** — Standard Rails controllers using `render inertia:` to pass data as props to React page components. Controllers orchestrate model interactions and delegate background work to Solid Queue.

**Key architectural benefits:**
- **No API to build or maintain** — Inertia eliminates the need for a separate REST/GraphQL API for page rendering. Controllers pass serialized data directly to React components as props.
- **Rails routing and sessions** — Authentication (Rails 8 built-in auth + OmniAuth), authorization, and session management stay in Rails. No JWT, no token management.
- **Rails form handling** — Validation errors flow automatically from Rails back to React components via Inertia's error handling protocol.
- **Code splitting** — Inertia supports lazy-loaded page components for performance.

**Reference:** [https://inertia-rails.dev/](https://inertia-rails.dev/)

```
┌──────────────────────────────────────────────────────────────┐
│                      CLIENT (Browser)                        │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              React Components (TypeScript)              │  │
│  │         Rendered via @inertiajs/react adapter            │  │
│  │                                                          │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │  │
│  │  │ OrderFeed│  │ OrderForm│  │  MapView │  ...          │  │
│  │  └──────────┘  └──────────┘  └──────────┘              │  │
│  │                                                          │  │
│  │  Mapbox GL JS  │  TailwindCSS  │  TanStack Query (*)    │  │
│  └────────────────────────────────────────────────────────┘  │
│       │  Inertia requests (XHR)          │  REST (polling)   │
└───────┼──────────────────────────────────┼───────────────────┘
        │                                  │
┌───────┼──────────────────────────────────┼───────────────────┐
│       ▼          RAILS SERVER (MVC)      ▼                   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐    │
│  │              CONTROLLERS (C)                          │    │
│  │  render inertia: { props }   │   respond_to :json     │    │
│  │  (page navigation)           │   (polling endpoints)  │    │
│  └──────────────────────┬───────────────────────────────┘    │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐    │
│  │              MODELS (M) — ActiveRecord + PostGIS      │    │
│  │  DeliveryOrder  │  User  │  DriverProfile  │  etc.    │    │
│  │  Validations, scopes, spatial queries, state machine  │    │
│  └──────────────────────┬───────────────────────────────┘    │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐    │
│  │              SERVICE OBJECTS (Business Logic)          │    │
│  │  OrderCreator │ PriceEstimator │ DriverMatcher │        │    │
│  │  Payments::Gateway │ Payments::Processor │ etc.         │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐    │
│  │              SIDEKIQ WORKERS (Background Tasks)       │    │
│  │  GeocodeWorker │ RouteWorker │ NotifyWorker │ etc.    │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐         ┌────▼─────┐
   │ Supabase │         │  Solid  │         │ LLM API │         │ Stripe   │
   │PostGIS + │         │  Queue  │         │ Claude/ │         │ (Payment │
   │ pgRouting│         │ Workers │         │  GPT    │         │ Gateway) │
   └──────────┘         └─────────┘         └─────────┘         └──────────┘
```

> (*) TanStack Query is used **only** for polling endpoints (location updates, notifications) — not for page data, which flows through Inertia props.

### Frontend (View Layer)
* **React 18+ with TypeScript** — Page components rendered via `@inertiajs/react`
* **Inertia.js client adapter** — Handles page visits, form submissions, partial reloads
* **TailwindCSS** — Utility-first CSS, mobile-first responsive design
* **Mapbox GL JS** — Map tile rendering, route polyline display, live markers. **Only Mapbox usage in the stack.**
* **TanStack Query** — Used exclusively for polling endpoints (driver location, notifications)
* **Vite** — Frontend bundler (configured via `vite_rails` gem)
* **`@stripe/stripe-js` + `@stripe/react-stripe-js`** — Stripe.js Elements for secure card tokenization (card data never touches our server)

### Backend (Model + Controller Layers)
* **Ruby on Rails 8.1.3+** — MVC framework
* **Inertia Rails (`inertia_rails` gem)** — Server-side Inertia adapter; replaces traditional ERB views with React component rendering
* **Rails 8 built-in authentication** (`bin/rails generate authentication`) — Session-based auth with `has_secure_password`, `Current.user`, and authentication concerns. OmniAuth for Google OAuth integration. No Devise, no JWT.
* **Solid Queue** — Database-backed background task processing (geocoding, routing, notifications, ETA recalculation, payment processing)
* **AASM or state_machines** — Order and Payment status lifecycle management
* **Jbuilder or Alba** — Props serialization for Inertia responses
* **`stripe` gem** — Payment gateway production adapter (server-side API calls for authorize, capture, refund). **Not required for MVP** — MockAdapter is the default.
* **Active Record Encryption** — Built-in Rails 8 encryption for PII fields at rest (`encrypts` directive)
* **`logstop` gem** — Catch-all PII pattern redaction in application logs

### Database & Geodata Engine
* **Supabase PostgreSQL** (with PostGIS 3+ and pgRouting extensions enabled) — Spatial data storage, GiST indexing, distance calculations (`ST_Distance`, `ST_DistanceSphere`), radius queries (`ST_DWithin`), geometry processing (`ST_AsGeoJSON`, `ST_MakeLine`), and geocoding (Tiger Geocoder or imported address data) all happen inside the managed Supabase instance. pgRouting handles shortest-path route calculation (`pgr_dijkstra`, `pgr_astar`) over an imported OpenStreetMap road network. **No external paid geocoding or routing APIs are used.**
* **`activerecord-postgis-adapter`** — Rails adapter for PostGIS spatial columns
* **OSM road network data** — Imported via `osm2pgrouting` directly into Supabase (run once locally or in CI against the Supabase connection string). Covers the operational region. Refreshed periodically (monthly or as needed).

> **Cost advantage:** All geocoding, distance, routing, and spatial queries run inside Supabase PostgreSQL — zero external API calls, zero per-request costs, no rate limits. Mapbox is used only for frontend map tiles (free tier covers MVP volume).

### Caching / Buffering
* **Solid Cache** (Rails 8 built-in) — database-backed caching for feed data and notification state
* **Optional:** Redis for high-frequency location buffering (if needed; can start with database writes)

### AI / LLM Layer
* **Anthropic Claude API** (or OpenAI API) — powers natural language order parsing, smart pricing reasoning, and ETA narrative generation
* **Model selection:** Claude Haiku / GPT-4o-mini for high-frequency low-latency tasks (ETA narratives); Claude Sonnet / GPT-4o for complex reasoning (NL order parsing, price estimation)
* All AI calls are **asynchronous** (Solid Queue workers) — never block the user request path
* **Fallback strategy:** if LLM is unavailable, fall back to rule-based logic (formula pricing, keyword extraction for orders)

### Real-Time Strategy (MVP)
* Polling (3–5s for feed, 5–15s for map location updates)
* Polling endpoints are standard Rails JSON controllers consumed via TanStack Query on the frontend

### Deployment
* **Final deployment target: Render.com** (https://render.com/) — Public web service (free tier). The app **must** be deployed to Render.com for the competition submission.
* **Docker** — single container with Rails app + Solid Queue workers. **No Postgres container** — database is external Supabase PostgreSQL.
* **Dockerfile** — multi-stage build, production-optimized
* `.env.example` with all required environment variables documented

---

## 13. 🗃️ Data Model (ERD Foundation)

> All models follow Rails ActiveRecord conventions. Spatial columns use PostGIS types via `activerecord-postgis-adapter`.

### User

* id
* name _(encrypted via `encrypts :name`)_
* **email** _(encrypted via `encrypts :email, deterministic: true, downcase: true` — searchable)_
* password_digest _(`has_secure_password` — Rails 8 built-in auth)_
* role (customer | driver)
* provider (OAuth provider)
* uid (OAuth UID)
* `has_many :sessions`, `has_many :payment_methods`, `has_many :driver_earnings`, `has_many :consents`
* `self.filter_attributes = %i[name email password_digest]`

---

### DriverProfile

* user_id (FK → User, `belongs_to :user`)
* vehicle_type
* is_available
* radius_preference
* **location** _(PostGIS `GEOMETRY(Point, 4326)` — updated in background from location buffer)_
* **last_location_updated_at**

---

### DeliveryOrder

* id
* created_by (FK → User, `belongs_to :creator, class_name: 'User'`)
* status _(values: `processing`, `open`, `accepted`, `pickup_in_progress`, `in_transit`, `completed`, `cancelled`, `expired`, `error`)_
* pickup_address
* dropoff_address
* **pickup_location** _(PostGIS `GEOMETRY(Point, 4326)` — populated by geocoding background task)_
* **dropoff_location** _(PostGIS `GEOMETRY(Point, 4326)`)_
* **route_geometry** _(PostGIS `GEOMETRY(LineString, 4326)` — computed by pgRouting inside Supabase, served as GeoJSON to frontend)_
* **estimated_distance_meters** _(computed via `ST_Length(route_geometry::geography)`)_
* **estimated_duration_seconds** _(computed from pgRouting cost + average speed model)_
* scheduled_at
* price
* **estimated_price** _(auto-calculated if customer didn't suggest one)_

---

### OrderItem

* id
* order_id _(FK → DeliveryOrder, `belongs_to :delivery_order`)_
* name
* quantity
* size

---

### Assignment

* id
* order_id _(FK → DeliveryOrder, `belongs_to :delivery_order`)_
* driver_id (FK → User, `belongs_to :driver, class_name: 'User'`)
* accepted_at
* **driver_location** _(PostGIS `GEOMETRY(Point, 4326)`)_
* **last_location_updated_at**
* **cached_eta_seconds** _(updated by ETA recalculation task via pgRouting)_
* **location_stale** _(boolean, set by stale location detector task)_

---

### Notification

* id
* user_id (FK → User, `belongs_to :user`)
* order_id _(FK → DeliveryOrder, `belongs_to :delivery_order`)_
* type _(new_order, order_accepted, status_update, delivery_complete, etc.)_
* message
* is_read
* is_expired
* created_at

---

### Payment

* id
* delivery_order_id (FK → DeliveryOrder, `belongs_to :delivery_order`)
* customer_id (FK → User, `belongs_to :customer, class_name: 'User'`)
* driver_id (FK → User, `belongs_to :driver, class_name: 'User'`, nullable until assignment)
* amount_cents _(integer — all amounts in cents to avoid floating-point issues)_
* currency _(string, default: `'brl'`)_
* status _(values: `pending`, `authorized`, `captured`, `refunded`, `voided`, `failed`)_
* gateway_provider _(string, e.g., `'stripe'`)_
* gateway_payment_id _(string — external reference from gateway)_
* authorized_at
* captured_at
* refunded_at
* metadata _(jsonb — gateway response data, idempotency keys)_

---

### PaymentMethod

* id
* user_id (FK → User, `belongs_to :user`)
* gateway_provider _(string)_
* **gateway_token** _(string — tokenized reference, **encrypted at rest** via `encrypts :gateway_token`)_
* card_last_four _(string)_
* card_brand _(string, e.g., `'visa'`, `'mastercard'`)_
* is_default _(boolean)_
* expires_at

---

### DriverEarning

* id
* driver_id (FK → User, `belongs_to :driver, class_name: 'User'`)
* payment_id (FK → Payment, `belongs_to :payment`)
* delivery_order_id (FK → DeliveryOrder)
* gross_amount_cents _(integer — captured payment amount)_
* platform_fee_cents _(integer — calculated from `PLATFORM_FEE_PERCENT`)_
* net_amount_cents _(integer — gross minus platform fee)_
* paid_out_at _(nullable — for future payout automation)_

---

### Consent

* id
* user_id (FK → User, `belongs_to :user`)
* purpose _(enum: `terms_of_service`, `location_tracking`, `payment_processing`, `marketing`)_
* granted_at
* revoked_at _(nullable — null means active consent)_
* ip_address
* user_agent

> **Append-only pattern:** Consent records are never updated. A new record is created for each grant or revocation. The current consent state is derived by finding the most recent record per purpose.

---

### Session _(Rails 8 built-in auth)_

* id
* user_id (FK → User, `belongs_to :user`)
* ip_address
* user_agent
* created_at

---

### OSM Road Network _(managed by osm2pgrouting inside Supabase)_

* **ways** — Road segments with geometry, source/target vertex IDs, cost, reverse_cost
* **ways_vertices_pgr** — Road network vertices (intersections) with point geometry
* _GiST spatial indexes on all geometry columns for fast nearest-edge lookups_

---

## 14. 📁 Project Structure (Rails + Inertia.js + React)

```
Logistikos/
├── app/
│   ├── controllers/                    # (C) Rails controllers
│   │   ├── application_controller.rb
│   │   ├── auth/
│   │   │   └── omniauth_callbacks_controller.rb  # Google OAuth callback
│   │   ├── delivery_orders_controller.rb
│   │   ├── driver_profiles_controller.rb
│   │   ├── assignments_controller.rb
│   │   ├── notifications_controller.rb
│   │   ├── payment_methods_controller.rb  # Payment method CRUD
│   │   ├── sessions_controller.rb         # Rails 8 auth sessions
│   │   ├── registrations_controller.rb    # Rails 8 auth registration
│   │   └── api/                        # JSON-only endpoints (polling)
│   │       ├── locations_controller.rb
│   │       ├── notifications_controller.rb
│   │       └── webhooks/
│   │           └── payments_controller.rb  # Payment gateway webhooks
│   ├── models/                         # (M) ActiveRecord models
│   │   ├── user.rb
│   │   ├── session.rb                     # Rails 8 auth session model
│   │   ├── current.rb                     # Current.user singleton
│   │   ├── driver_profile.rb
│   │   ├── delivery_order.rb
│   │   ├── order_item.rb
│   │   ├── assignment.rb
│   │   ├── notification.rb
│   │   ├── payment.rb                     # Payment lifecycle (AASM)
│   │   ├── payment_method.rb              # Tokenized payment instruments
│   │   ├── driver_earning.rb              # Net earnings per delivery
│   │   ├── consent.rb                     # Append-only consent records
│   │   └── concerns/
│   │       ├── authentication.rb          # Rails 8 auth concern
│   │       ├── anonymizable.rb            # DSAR anonymization
│   │       ├── data_exportable.rb         # DSAR data export
│   │       └── has_consent.rb             # Consent checking
│   ├── services/                       # Service objects (business logic)
│   │   ├── orders/
│   │   │   ├── creator.rb
│   │   │   ├── acceptor.rb
│   │   │   └── status_transitioner.rb
│   │   ├── pricing/
│   │   │   ├── estimator.rb
│   │   │   └── ai_pricing_service.rb
│   │   ├── matching/
│   │   │   └── driver_matcher.rb
│   │   ├── geo/
│   │   │   ├── geocoder.rb
│   │   │   └── route_calculator.rb
│   │   ├── ai/
│   │   │   ├── nl_order_parser.rb
│   │   │   ├── eta_narrator.rb
│   │   │   └── order_ranker.rb
│   │   └── payments/                   # Payment gateway abstraction
│   │       ├── gateway.rb              # Interface/contract
│   │       ├── adapters/mock_adapter.rb # MVP default — no external deps
│   │       ├── processor.rb            # Orchestrates authorize/capture/refund
│   │       └── adapters/
│   │           ├── base_adapter.rb
│   │           └── stripe_adapter.rb
│   ├── jobs/                           # Solid Queue workers (ActiveJob)
│   │   ├── geocode_worker.rb
│   │   ├── route_calculation_worker.rb
│   │   ├── price_estimation_worker.rb
│   │   ├── driver_match_worker.rb
│   │   ├── notification_dispatch_worker.rb
│   │   ├── eta_recalculation_worker.rb
│   │   ├── location_flush_worker.rb
│   │   ├── stale_order_cleanup_worker.rb
│   │   ├── stale_delivery_monitor_worker.rb
│   │   ├── notification_expiry_worker.rb
│   │   ├── payment_authorization_worker.rb
│   │   ├── payment_capture_worker.rb
│   │   ├── payment_refund_worker.rb
│   │   └── data_retention_worker.rb
│   └── serializers/                    # Props serialization
│       ├── delivery_order_serializer.rb
│       ├── driver_profile_serializer.rb
│       ├── notification_serializer.rb
│       ├── payment_serializer.rb
│       └── payment_method_serializer.rb
├── frontend/                           # (V) React components via Inertia
│   ├── pages/                          # Inertia page components
│   │   ├── Auth/
│   │   │   └── Login.tsx
│   │   ├── Customer/
│   │   │   ├── OrderCreate.tsx
│   │   │   ├── OrderNaturalLanguage.tsx
│   │   │   ├── OrderTracking.tsx
│   │   │   ├── OrderList.tsx
│   │   │   ├── PaymentMethods.tsx         # Payment method management
│   │   │   └── PaymentConfirmation.tsx    # Post-acceptance payment info
│   │   ├── Driver/
│   │   │   ├── OrderFeed.tsx
│   │   │   ├── OrderDetail.tsx
│   │   │   ├── ActiveDelivery.tsx
│   │   │   ├── Profile.tsx
│   │   │   └── Filters.tsx
│   │   └── Shared/
│   │       ├── Dashboard.tsx
│   │       └── NotFound.tsx
│   ├── components/                     # Reusable React components
│   │   ├── layout/
│   │   │   ├── MobileLayout.tsx
│   │   │   ├── BottomNav.tsx
│   │   │   └── TopBar.tsx
│   │   ├── map/
│   │   │   ├── MapViewer.tsx
│   │   │   ├── RoutePolyline.tsx
│   │   │   ├── DriverMarker.tsx
│   │   │   └── LocationPins.tsx
│   │   ├── orders/
│   │   │   ├── OrderCard.tsx
│   │   │   ├── OrderStatusBadge.tsx
│   │   │   └── PriceBreakdown.tsx
│   │   ├── payments/
│   │   │   ├── PaymentMethodCard.tsx
│   │   │   ├── PaymentMethodForm.tsx      # Stripe.js Elements integration
│   │   │   ├── PaymentStatusBadge.tsx
│   │   │   └── ReceiptCard.tsx
│   │   ├── forms/
│   │   │   ├── OrderForm.tsx
│   │   │   ├── AddressInput.tsx
│   │   │   └── ItemListInput.tsx
│   │   └── ui/
│   │       ├── Button.tsx
│   │       ├── BottomSheet.tsx
│   │       ├── LoadingSpinner.tsx
│   │       └── EmptyState.tsx
│   ├── hooks/                          # Custom React hooks
│   │   ├── usePolling.ts
│   │   ├── useDriverLocation.ts
│   │   ├── useGpsTracking.ts             # GPS session management for drivers
│   │   └── useNotifications.ts
│   ├── layouts/                        # Inertia layouts
│   │   └── AppLayout.tsx
│   ├── types/                          # TypeScript type definitions
│   │   ├── models.ts
│   │   └── inertia.d.ts
│   └── entrypoints/
│       └── application.tsx             # Inertia app entry point
├── config/
│   ├── routes.rb                       # Rails routes (Inertia pages + API)
│   ├── initializers/
│   │   ├── inertia_rails.rb            # Inertia configuration
│   │   ├── payment_gateway.rb           # Payment gateway adapter config
│   │   ├── active_record_encryption.rb  # Encryption key configuration
│   │   └── filter_parameter_logging.rb  # PII filter parameters
│   ├── queue.yml                       # Solid Queue configuration
│   └── recurring.yml                   # Solid Queue recurring tasks
├── db/
│   ├── migrate/                        # Rails migrations (PostGIS enabled)
│   └── seeds.rb                        # Demo data for live presentation
├── spec/                               # RSpec tests
│   ├── models/
│   ├── controllers/
│   ├── services/
│   ├── workers/
│   └── system/                         # Capybara system tests
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## 15. 📆 Execution Plan (2 Weeks — 03/30 to 04/10/2026)

### Week 1 (03/30 – 04/03)
* Rails project setup with `inertia_rails` gem + React + Vite + TailwindCSS
* **Supabase project creation + PostGIS + pgRouting extensions enabled + regional OSM data import via `osm2pgrouting` directly into Supabase**
* Authentication (Rails 8 built-in auth + OmniAuth Google) with Inertia page rendering
* User model + DriverProfile model with PostGIS spatial columns
* Delivery order model + creation flow + **background geocoding (Supabase PostGIS) & routing (pgRouting) pipeline via Solid Queue**
* **AI: Smart Price Estimation service**
* **AI: Natural Language Order Description (LLM integration via Solid Queue worker)**
* Order listing (driver feed) + **feed cache layer with Supabase PostGIS spatial queries**
* Mobile-first layout components (MobileLayout, BottomNav, TopBar)
* Basic Inertia pages (Customer: OrderCreate, Driver: OrderFeed)
* **Solid Queue setup with queue configuration (critical, default, maintenance)**
* **Basic map integration (Mapbox GL JS — static pins + route preview from cached polyline)**
* **RSpec unit tests for core business rules (pricing, order lifecycle, assignment logic)**

### Week 2 (04/04 – 04/10)
* Order acceptance logic + **optimistic locking + async notification dispatch via Solid Queue**
* Status lifecycle + **status transition service with side effects**
* Filtering system **(Supabase PostGIS-powered radius & distance filters)**
* **AI: Intelligent Order Ranking for driver feed**
* **AI: ETA Narratives for customer tracking**
* **Location ingestion worker + ETA recalculation task (pgRouting via Solid Queue)**
* **Real-time location updates + live map viewer**
* **Stale order/delivery/location monitor tasks (Solid Queue recurring tasks)**
* Notification polling (JSON API endpoint + TanStack Query) + **notification expiry task**
* **Integration tests for critical flows (order creation → assignment → completion)**
* **Payment system** — gateway abstraction (adapter pattern), **MockAdapter (MVP default)** + Stripe adapter, Payment/PaymentMethod/DriverEarning models, authorize/capture/refund workers, payment method UI (mock-friendly form with optional Stripe.js Elements)
* **GPS tracking integration** — `useGpsTracking` hook wrapping `navigator.geolocation.watchPosition`, GPS permission flow, update ActiveDelivery page
* **Privacy-by-design** — PII encryption on User/DeliveryOrder/PaymentMethod models (`encrypts` directive), `config.filter_parameters`, `self.filter_attributes`, background job arg protection, data retention worker, DSAR foundation concerns (`Anonymizable`, `DataExportable`), consent management
* Mobile UI polish + error handling audit + touch interaction refinement
* **Dockerfile + docker-compose for production deployment on Render.com**
* **Deploy to Render.com** — public link (final required target)
* **README: product description, setup instructions, env vars documentation**

### Commit Strategy
* Small, frequent commits with descriptive messages
* Feature branches merged via PR
* No mega-commits — incremental development visible in git history

---

## 16. 🧪 Testing Strategy

Testing is a key evaluation criterion. The project must have meaningful tests covering core business logic.

### Unit Tests (Required — Minimum)
* **Order lifecycle state machine** — valid/invalid transitions, edge cases
* **Price estimation logic** — distance-based, load-based, AI model output validation
* **Assignment/acceptance logic** — optimistic locking, race condition handling
* **Spatial query helpers** — radius filtering, distance calculations (Supabase PostGIS)
* **AI feature parsers** — natural language order parsing, ranking algorithm
* **Model validations** — all ActiveRecord models
* **Payment lifecycle state machine** — valid/invalid transitions (pending → authorized → captured, voided, refunded, failed)
* **Payment gateway adapter** — MockAdapter (deterministic responses), StripeAdapter with mocked API responses, idempotency key generation
* **Driver earning calculation** — net amount = gross - platform fee, edge cases
* **Privacy concerns** — Anonymizable (PII replaced with `[ANONYMIZED]`), DataExportable (complete user data export), HasConsent (consent checking logic)

### Integration Tests
* **Order creation → geocoding → routing → open** (full async pipeline with Solid Queue `perform_inline`)
* **Order acceptance → payment authorization → notification → feed invalidation** (assignment + payment flow)
* **Delivery completion → payment capture → driver earning creation** (payment capture flow)
* **Order cancellation → payment void/refund** (cancellation flow)
* **Driver location update → ETA recalculation** (real-time pipeline)
* **Authentication flow** (Rails 8 auth + Google OAuth via OmniAuth test mode)
* **Inertia page rendering** — verify correct components receive correct props
* **PII encryption** — verify encrypted fields are ciphertext in database, readable via model

### E2E Smoke Tests (Nice-to-have)
* Customer adds payment method → Creates order → Driver sees it → Driver accepts (payment authorized) → Customer tracks on map → Delivery completes (payment captured, driver earning created)

### Test Tools
* **RSpec** — unit + integration tests (Rails standard)
* **FactoryBot** — test fixtures and factories
* **Shoulda Matchers** — model validation tests
* **Capybara + Selenium** — system/E2E tests
* **Solid Queue Testing** — inline mode for integration tests
* **Database Cleaner** — test database management
* Test database with Supabase connection (or local replica for CI)

---

## 17. 🐳 Deployment & Infrastructure

### Production Deployment Requirements

The app **must** be deployed to **Render.com** (https://render.com/) for the final submission.

**Dockerfile / docker-compose:**
* Multi-stage build (Rails app with precompiled frontend assets)
* **No Postgres container** — external Supabase PostgreSQL (with PostGIS + pgRouting)
* Solid Queue workers run in same container as Rails app (via `bin/jobs`)
* Environment variables documented in `.env.example`

**Environment Variables (documented in README):**
* `DATABASE_URL` — Supabase PostgreSQL connection string
* `MAPBOX_TOKEN` — Mapbox GL JS public token (frontend only)
* `GOOGLE_OAUTH_CLIENT_ID` / `GOOGLE_OAUTH_CLIENT_SECRET`
* `SECRET_KEY_BASE` — Rails secret key
* `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` — for AI-powered features (LLM calls)
* `PAYMENT_GATEWAY` — payment gateway provider (default: `mock`; set to `stripe` for production)
* `STRIPE_PUBLISHABLE_KEY` — Stripe publishable key (frontend tokenization) — **not required when using MockAdapter**
* `STRIPE_WEBHOOK_SECRET` — Stripe webhook signing secret — **not required when using MockAdapter**
* `PLATFORM_FEE_PERCENT` — platform fee percentage for driver earnings (default: `15`)
* `RAILS_ENV` — production/development

> **Note:** `STRIPE_SECRET_KEY` is stored in Rails credentials (`bin/rails credentials:edit`), NOT as an environment variable, for security. **Not required when using MockAdapter (MVP default).**

**Public Deploy:**
* **Required:** Render.com free tier (web service) with external Supabase database
* Alternative (for local testing only): Railway, Fly.io, or any VPS with Docker

---

## 18. 🤖 AI Usage Documentation

> Required by competition rules: the participant must demonstrate **how** AI was used throughout development.

### AI in Development Process

| Stage | AI Usage |
|---|---|
| **Ideation** | Problem exploration, market analysis, feature brainstorming sessions with Claude |
| **Architecture** | MVC structure decisions, Inertia.js integration patterns, database schema design, Supabase PostGIS/pgRouting architecture decisions, Solid Queue design |
| **Code generation** | Feature implementation via Claude Code (primary tool), including complex PostGIS queries, React components, Rails controllers, Inertia page setup, background workers |
| **Testing** | Test case generation, edge case discovery, RSpec test fixture creation |
| **Documentation** | PRD writing, README generation, API documentation |
| **Design** | UI/UX decisions, mobile-first component structure, touch-optimized layout guidance |
| **Debugging** | Error diagnosis, performance optimization, race condition analysis |

### AI as User-Facing Feature (Bonus)

| Feature | AI Technology | User Benefit |
|---|---|---|
| Smart Price Estimation | LLM reasoning or ML model | Fair, transparent pricing without guesswork |
| Natural Language Orders | LLM (Claude/GPT) | Create orders by describing needs in plain language |
| Intelligent Order Ranking | ML-based scoring | Drivers see most relevant orders first |
| ETA Narratives | LLM generation | Human-readable, contextual delivery updates |

### Development Tool

All code development performed using **Claude Code** as required by competition rules.

---

## 19. 📏 Success Metrics

### Driver Success
* Time to accept an order < 1 minute
* Clear visibility of order value
* **Seamless navigation via live map**

### Customer Success
* Order creation time < 2 minutes
* Order gets accepted
* **Real-time visibility of driver progress on map**

### Technical Health (Background Tasks)
* **Order creation → `open` latency < 5 seconds** (Supabase PostGIS geocoding + pgRouting route calculation + driver matching)
* **Notification delivery latency < 2 seconds** from trigger event
* **Background task failure rate < 1%** (with retries)
* **Dead-letter queue depth = 0** under normal operation
* **Location ingestion p99 < 200ms**
* **Supabase PostGIS spatial query p99 < 50ms**

---

## 20. ⚠️ Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Low initial supply/demand | Focus on demo quality |
| Poor order pricing clarity | Show structured order details |
| Complex UX | Keep interface minimal, mobile-first |
| **Mapbox frontend tile costs** | Free tier covers MVP volume; Mapbox is only used for tile rendering, not backend computation |
| **OSM data freshness / quality** | Import regional OSM extract into Supabase; refresh monthly; validate road coverage before launch |
| **pgRouting performance on large graphs** | Limit OSM import to operational region; use `pgr_astar` for faster heuristic routing; add GiST indexes on all geometry columns inside Supabase |
| **PostGIS geocoding accuracy** | Use Tiger Geocoder or import authoritative address data for target region; fall back to address text display if geocoding fails |
| **Background task failure / data inconsistency** | Idempotent tasks, exponential retry, dead-letter queue, health monitoring dashboard |
| **Location update storms under load** | Batch flush to database, rate-limit client-side reporting, use database buffering |
| **Race conditions on order acceptance** | Optimistic locking with row-level locks; return clear "already taken" error to losing drivers |
| **LLM API latency for AI features** | AI features run asynchronously (Solid Queue workers); cache results; graceful fallback to rule-based logic if LLM is unavailable |
| **LLM cost for AI features** | Use efficient models (Claude Haiku / GPT-4o-mini) for high-volume tasks (ETA narratives); cache repeated patterns; rate-limit AI calls per user |
| **AI hallucination in NL order parsing** | Validate parsed fields against schema; show confirmation screen before submitting; reject unparseable inputs gracefully |
| **Inertia.js learning curve** | Follow official `inertia-rails.dev` documentation; use starter kit as reference; leverage Claude Code for implementation patterns |
| **2-week timeline too tight** | Prioritize core flows first (order creation → acceptance → tracking), then layer AI features; cut AI features before cutting stability |
| **Live demo failure** | Prepare seed data script (`rails db:seed`); test on production Render.com URL before demo day; have fallback flow ready |
| **Payment gateway downtime** | MVP uses MockAdapter (no external dependency). Production: retry with exponential backoff; queue payments for later processing; show user-friendly error ("Payment pending, will retry automatically") |
| **PCI compliance exposure** | Never handle raw card data; use Stripe.js Elements for tokenization on frontend; no card data in logs, database, or error reports |
| **Payment double-capture** | Idempotency keys on all mutating gateway API calls; check payment status before capture (idempotent workers) |
| **GPS permission denied by driver** | Persistent warning banner; allow degraded mode with manual location updates; mark location source as "manual" for transparency |
| **PII data breach** | Encryption at rest (Rails Active Record Encryption), filtered logs (`config.filter_parameters` + `logstop`), minimal data retention, HTTPS enforcement |
| **GDPR/LGPD non-compliance** | Built-in anonymization (`Anonymizable` concern), data export (`DataExportable`), consent tracking (append-only records), configurable retention periods |

---

## 21. 🔥 Strategic Positioning

This product is closer to load boards + modern freight marketplaces, now enhanced with **real-time map-based tracking** for transparency and trust, and **AI-powered intelligence** that makes Logistikos accessible to non-technical users and more efficient for drivers.

---

## 22. 🧠 MVP Differentiator

> A lightweight Logistikos marketplace where drivers and small businesses choose the orders they want — **and everyone tracks progress live on an interactive map** — powered by a zero-external-API geodata stack (Supabase PostGIS + pgRouting) and **AI-powered features** (smart pricing, natural language orders, intelligent matching) that make Logistikos accessible and efficient. Built with a clean Rails MVC architecture using Inertia.js + React for a seamless mobile-first experience. **Final deployment on Render.com.**

---

## 23. 🔄 Background Tasks Summary

A consolidated reference of all background tasks in the system, their triggers, and expected SLAs.

| Task Name | Trigger | Description | SLA |
|---|---|---|---|
| **Geocode Addresses** | Order created | Convert addresses to coordinates via Supabase PostGIS geocoder | < 3s |
| **Calculate Route** | Geocoding complete | Compute route polyline + distance via pgRouting (`pgr_dijkstra`) inside Supabase | < 3s |
| **Estimate Price** | Route calculated (no suggested price) | Auto-calculate recommended price from distance + load | < 1s |
| **Driver Match & Notify** | Order becomes `open` | Spatial query (`ST_DWithin` inside Supabase) to find eligible drivers, fan-out notifications | < 2s |
| **Feed Cache Update** | Order created/accepted/expired | Update denormalized feed index with Supabase PostGIS distances | < 1s |
| **Stale Order Cleanup** | Cron (every 5 min) | Expire old `open` orders, notify customers | — |
| **Customer Notification** | Order accepted / status changed | Notify customer of progress updates | < 2s |
| **Feed Invalidation** | Order accepted/cancelled | Remove order from all driver feed caches | < 1s |
| **Route Snapshot** | Order accepted | Cache full route polyline via pgRouting inside Supabase for frontend map rendering | < 3s |
| **Notification Expiry** | Cron (every 1 min) | Mark notifications for closed orders as expired | — |
| **Location Ingestion** | Driver location update (5–10s) | Batch flush to Supabase (PostGIS point) | < 200ms |
| **ETA Recalculation** | Cron per active delivery (30–60s) | Recalculate ETA via pgRouting inside Supabase from driver's current position | < 5s |
| **Stale Location Detector** | Cron (every 30s) | Flag deliveries with stale location data | — |
| **Stale Delivery Monitor** | Cron (every 5 min) | Flag deliveries with no status update for 30+ min | — |
| **Availability Rehydrate** | Driver toggles availability | Rebuild driver feed (Supabase PostGIS queries) or clear notification queues | < 2s |
| **Payment Authorization** | Order accepted | Authorize estimated amount on customer's payment method via gateway | < 5s |
| **Payment Capture** | Delivery completed | Capture final amount from authorized payment; create DriverEarning record | < 5s |
| **Payment Refund** | Delivery cancelled | Void authorization or issue refund via gateway | < 5s |
| **Data Retention Cleanup** | Cron (weekly) | Anonymize PII on inactive users past retention period; clean old location data | — |

### Queue Architecture (MVP — Solid Queue)

Three queues to separate concerns and allow independent scaling:

* **`critical`** — Order acceptance, geocoding (Supabase PostGIS), route calculation (pgRouting), feed invalidation, **payment authorization, payment capture** (low latency, high priority)
* **`default`** — Notifications, ETA recalculation (pgRouting), price estimation, availability rehydration, **payment refund**
* **`maintenance`** — Stale order cleanup, stale delivery monitor, notification expiry, location detector, **data retention cleanup** (can tolerate delay)

### Retry Policy

* Max 3 attempts with exponential backoff (1s → 5s → 25s)
* Failed after 3 attempts → moved to dead-letter queue
* Dead-letter queue monitored via health check endpoint and (future) alerting
