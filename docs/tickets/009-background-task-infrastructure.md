# Ticket 009: Background Task Infrastructure (Sidekiq + Redis)

## Description
Configure Sidekiq with Redis for background task processing. Define the three-queue architecture (critical, default, maintenance) per PRD section 23. Set up retry policies, dead-letter queue handling, and the Sidekiq web UI for monitoring.

## Acceptance Criteria
- [ ] `sidekiq` gem is installed and configured
- [ ] `config/sidekiq.yml` defines three queues: `critical`, `default`, `maintenance`
- [ ] `config/initializers/sidekiq.rb` configures Redis connection
- [ ] Sidekiq web UI is mounted at `/sidekiq` (admin-only access)
- [ ] Retry policy: max 3 attempts with exponential backoff (1s, 5s, 25s)
- [ ] Failed tasks after 3 retries move to dead-letter queue
- [ ] A test worker can be enqueued and processed successfully
- [ ] Sidekiq process starts without errors alongside Rails server
- [ ] Queue priorities are set: critical > default > maintenance

## Dependencies
- **002** — Redis must be running via Docker

## Estimated Effort
**S** (1-2 hours)

## Files to Create/Modify
- `Gemfile` — add `sidekiq` gem
- `config/sidekiq.yml` — queue definitions and concurrency settings
- `config/initializers/sidekiq.rb` — Redis connection, retry configuration
- `config/routes.rb` — mount Sidekiq web UI
- `Procfile.dev` — add Sidekiq worker process for development

## Technical Notes
- Queue configuration in `sidekiq.yml`:
  ```yaml
  :queues:
    - [critical, 6]
    - [default, 3]
    - [maintenance, 1]
  :retry: 3
  ```
- Queue assignment per PRD section 23:
  - **critical**: order acceptance, geocoding, route calculation, feed invalidation
  - **default**: notifications, ETA recalculation, price estimation, availability rehydration
  - **maintenance**: stale order cleanup, stale delivery monitor, notification expiry, location detector
- Sidekiq web UI should be protected — only accessible by admins or in development
- All workers created in subsequent tickets should include `sidekiq_options queue: :queue_name`
- Consider adding `sidekiq-scheduler` gem for cron-like recurring tasks (stale cleanup, etc.)
- Workers must be idempotent — safe to retry without side effects
