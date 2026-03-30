# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Logistikos is a supply-driven logistics marketplace built for the AI Dev Challenge (dev period: 03/30/2026 – 04/10/2026). It connects customers who need deliveries with independent drivers. Two user roles: Customer and Driver.

## Tech Stack

- **Backend:** Ruby 3.4.3, Rails 8.1.3+ with Inertia.js (renders React components, not ERB)
- **Frontend:** React 18+ / TypeScript via `@inertiajs/react`, Vite (`vite_rails`), TailwindCSS, Mapbox GL JS
- **Database:** SQLite3 in development/test (planned PostgreSQL 16+ with PostGIS + pgRouting for spatial features)
- **Background Jobs:** Solid Queue (Rails 8 default); agent definitions reference Sidekiq — follow whichever is actually configured
- **Auth:** Rails 8 built-in authentication (`has_secure_password`, `Current.user`, `Session` model) — no JWT, no Devise
- **Payments:** Gateway-agnostic adapter pattern; `Payments::Adapters::MockAdapter` is the MVP default
- **Asset Pipeline:** Propshaft + importmap-rails (Hotwire/Stimulus also present)

## Common Commands

```bash
# Setup
bin/setup                        # Initial project setup
bin/rails db:prepare             # Create/migrate database

# Development
bin/dev                          # Start dev server (Puma + jobs)
bin/rails server                 # Start Rails server only
bin/jobs                         # Start background job runner

# Testing
bin/rails test                   # Run all unit/integration tests
bin/rails test test/models/user_test.rb           # Run a single test file
bin/rails test test/models/user_test.rb:42        # Run a single test by line
bin/rails test:system            # Run system tests (Capybara + Selenium)
bin/rails db:test:prepare        # Prepare test database

# Linting & Security
bin/rubocop                      # Lint (rubocop-rails-omakase style)
bin/rubocop -a                   # Auto-fix lint issues
bin/brakeman --no-pager          # Security static analysis
bin/bundler-audit                # Scan gems for vulnerabilities
bin/importmap audit              # Scan JS dependencies

# Docker (production)
docker build -t logistikos .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<key> --name logistikos logistikos
```

## Architecture

### Backend Conventions
- **Controllers** use `render inertia:` for page responses and `respond_to :json` for polling endpoints
- **Service objects** live in `app/services/` with namespaces like `Orders::Creator`, `Pricing::Estimator`, `Geo::RouteCalculator`, `Ai::NlOrderParser`
- **State machines** (AASM or state_machines) manage the order lifecycle
- **Workers** must be idempotent, accept only record IDs (not full objects), max 3 retries with exponential backoff

### Frontend Conventions
- **Page components** in `frontend/pages/` receive props from Rails controllers via Inertia
- **Reusable components** in `frontend/components/` follow the "Precision Logistikos" design system (see `DESIGN.md`)
- **TanStack Query** is used exclusively for polling (driver location every 5-15s, notifications every 3-5s) — never for page data
- **Mobile-first**: primary viewport 375-428px, bottom navigation, 44x44dp minimum tap targets

### Design System ("Precision Logistikos")
Key rules from `DESIGN.md`:
- **No borders for sectioning** — use background color shifts and tonal layering instead
- **Fonts:** Manrope (display/headlines) + Inter (body/labels)
- **Colors:** Primary `#000e24` (deep navy), Secondary `#a33800` (burnt orange for actions/CTAs), Background `#f8f9fb`
- **Glassmorphism** for floating elements and sticky headers

### Privacy & Data Protection
- Encrypt PII fields with Rails `encrypts` directive
- Declare `self.filter_attributes` on models with PII
- Workers accept only record IDs, never PII directly
- `logstop` gem redacts PII patterns in logs

## Domain Terminology

Use these terms consistently — never use "job" for deliveries (ambiguous with background jobs):
- **Delivery Order / Order** — customer-created delivery request
- **Order Item** — line item within an Order
- **Assignment** — binding between an Order and the accepting driver
- **Background Task / Worker Task** — async work processed off the main request path

## CI Pipeline

GitHub Actions runs on PRs and pushes to `main`: Brakeman, bundler-audit, importmap audit, RuboCop, unit tests, system tests.
