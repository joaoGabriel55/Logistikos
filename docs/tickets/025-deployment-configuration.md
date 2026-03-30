# Ticket 025: Deployment Configuration

## Description
Create production-ready Docker configuration and deploy the application to **Render.com** (required by competition rules). This includes a multi-stage Dockerfile, production docker-compose with all services, complete `.env.example` documentation, `render.yaml` blueprint, and deployment to a public Render.com URL. Write the comprehensive README including AI usage documentation.

## Acceptance Criteria
- [ ] **Dockerfile** (multi-stage build):
  - Stage 1: Node — build frontend assets (Vite build)
  - Stage 2: Ruby — Rails app with precompiled assets
  - Production-optimized (minimal image size, no dev dependencies)
- [ ] **docker-compose.yml** (production):
  - `web` — Rails app service
  - `worker` — Sidekiq worker process
  - `redis` — Redis with persistent volume
  - **No Postgres container** — database is external Supabase PostgreSQL (with PostGIS + pgRouting), connected via `DATABASE_URL`
  - Health checks on all services
  - Environment variable configuration via `.env`
- [ ] `.env.example` documents ALL environment variables:
  - `DATABASE_URL` — Supabase PostgreSQL connection string
  - `REDIS_URL` — Redis connection string
  - `SECRET_KEY_BASE` — Rails secret key
  - `MAPBOX_TOKEN` — Mapbox GL JS public token (frontend only, via VITE)
  - `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`
  - `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` — for AI-powered features
  - `PAYMENT_GATEWAY` — payment gateway provider (default: `mock`; set to `stripe` for production)
  - `STRIPE_PUBLISHABLE_KEY` — Stripe publishable key (frontend tokenization) — **not required when using MockAdapter**
  - `STRIPE_WEBHOOK_SECRET` — Stripe webhook signing secret — **not required when using MockAdapter**
  - `PLATFORM_FEE_PERCENT` — platform fee for driver earnings (default: `15`)
  - `RAILS_ENV` — production/development
  - Note: `STRIPE_SECRET_KEY` stored in Rails credentials (`bin/rails credentials:edit`), NOT as env var. **Not required for MockAdapter (MVP default).**
- [ ] `docker-compose up` starts complete stack and app is accessible
- [ ] **README.md** includes:
  - Product description and screenshots
  - Architecture overview (MVC + Inertia.js + React diagram)
  - Setup instructions (Docker and local development)
  - Environment variable documentation (all vars from `.env.example`)
  - How to run tests (`bundle exec rspec`)
  - How to seed demo data (`rails db:seed`)
  - **AI Usage Documentation** (competition requirement — PRD Section 18):
    - **AI in Development Process** table: Ideation, Architecture, Code generation, Testing, Documentation, Design, Debugging — with specific examples
    - **AI as User-Facing Feature** table: Smart Price Estimation, Natural Language Orders, Intelligent Order Ranking, ETA Narratives — with AI technology and user benefit
    - Note that all development performed using Claude Code
- [ ] **`render.yaml`** blueprint defining Render.com services (web, worker, Redis)
- [ ] App deployed to **Render.com** with public URL (required by competition)
- [ ] Deployed app is functional — all core flows work on the Render.com public URL

## Dependencies
- All prior tickets (app must be feature-complete)

## Estimated Effort
**L** (3-4 hours)

## Files to Create/Modify
- `Dockerfile` — multi-stage production build
- `docker-compose.yml` — production service definitions (web, worker, redis — no db container)
- `render.yaml` — Render.com blueprint (web service, worker service, Redis instance)
- `.env.example` — complete environment variable documentation (including payment vars)
- `README.md` — comprehensive project documentation with AI usage section
- `.dockerignore` — exclude unnecessary files from Docker context
- `config/puma.rb` — production Puma configuration
- `bin/docker-entrypoint` — entrypoint script (db:prepare, asset precompile, etc.)

## Technical Notes
- Multi-stage Dockerfile pattern:
  ```dockerfile
  # Stage 1: Build frontend
  FROM node:20-alpine AS frontend
  COPY package.json yarn.lock ./
  RUN yarn install --frozen-lockfile
  COPY frontend/ ./frontend/
  RUN yarn build

  # Stage 2: Rails app
  FROM ruby:3.3-slim
  # Install dependencies, copy gems, copy app, copy built assets from stage 1
  ```
- **Render.com is the required deployment target** (competition rules — PRD Section 17)
- Render deployment: use `render.yaml` blueprint for service definitions (web + worker from same Docker image, different start commands)
- Render.com free tier: web service (750 hours/month) + Redis instance. **No Render PostgreSQL** — use external Supabase PostgreSQL (with PostGIS + pgRouting)
- Production `docker-compose.yml` must NOT include a PostgreSQL container — database is external Supabase, connected via `DATABASE_URL`
- OSM data import: consider bundling a small regional extract in the Docker image or documenting the import step
- `bin/docker-entrypoint` should handle:
  1. Wait for database to be ready
  2. `rails db:prepare` (create + migrate)
  3. Start the server
- For Render: separate services for web and worker (both from same Docker image, different start commands)
- `PAYMENT_GATEWAY` defaults to `mock` on Render — evaluators can test the full payment flow without Stripe credentials
- MVP payment strategy: MockAdapter simulates authorize/capture/refund with deterministic success (PRD Section 6)
