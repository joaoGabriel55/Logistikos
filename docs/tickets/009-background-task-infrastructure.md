# Ticket 009: Background Task Infrastructure (Solid Queue)

## Description
Configure Solid Queue (Rails 8 built-in) for background task processing. Define the three-queue architecture (critical, default, maintenance) per PRD section 23. Set up retry policies, dead-letter queue handling, and Mission Control Jobs for monitoring.

## Acceptance Criteria
- [ ] `solid_queue` gem is confirmed in Gemfile (already present in Rails 8)
- [ ] `config/queue.yml` defines three queues with priorities: `critical`, `default`, `maintenance`
- [ ] `config/recurring.yml` is created for cron-like recurring tasks
- [ ] Solid Queue database tables are present (via `db/queue_schema.rb`)
- [ ] Mission Control Jobs UI is optionally mounted (for monitoring)
- [ ] Retry policy: max 3 attempts with exponential backoff configured in ApplicationJob
- [ ] Failed tasks after 3 retries move to `solid_queue_failed_executions` table
- [ ] A test job can be enqueued and processed successfully
- [ ] `bin/jobs` process starts without errors alongside Rails server
- [ ] Queue priorities are set: critical (highest) > default > maintenance (lowest)

## Dependencies
- None — Solid Queue uses the existing database (SQLite in dev, PostgreSQL in production)

## Estimated Effort
**S** (1-2 hours)

## Files to Create/Modify
- `config/queue.yml` — update queue definitions with priorities
- `config/recurring.yml` — create for recurring/cron tasks
- `app/jobs/application_job.rb` — configure retry policy
- `config/routes.rb` — optionally mount Mission Control Jobs
- `Procfile.dev` — confirm `bin/jobs` is present (already configured in Rails 8)

## Technical Notes

### Queue Configuration (`config/queue.yml`)
Configure workers with queue-specific priorities. Higher priority values are processed first:

```yaml
production:
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: critical
      threads: 5
      processes: 2
      polling_interval: 0.1
      priority: 10
    - queues: default
      threads: 3
      processes: 1
      polling_interval: 0.5
      priority: 5
    - queues: maintenance
      threads: 2
      processes: 1
      polling_interval: 1
      priority: 1
```

### Queue Assignment (per PRD section 23)
- **critical** (priority: 10): order acceptance, geocoding, route calculation, feed invalidation, payment authorization, payment capture
- **default** (priority: 5): notifications, ETA recalculation, price estimation, availability rehydration, payment refund
- **maintenance** (priority: 1): stale order cleanup, stale delivery monitor, notification expiry, location detector, data retention cleanup

### Recurring Tasks (`config/recurring.yml`)
For cron-like tasks (stale cleanup, ETA recalculation, etc.):

```yaml
stale_order_cleanup:
  class: StaleOrderCleanupJob
  queue: maintenance
  schedule: "*/5 * * * *"  # Every 5 minutes

eta_recalculation:
  class: EtaRecalculationJob
  queue: default
  schedule: "* * * * *"  # Every minute (processes active deliveries)
```

### Retry Policy (`app/jobs/application_job.rb`)
Configure exponential backoff in ApplicationJob:

```ruby
class ApplicationJob < ActiveJob::Base
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  # Discard on unrecoverable errors
  discard_on ActiveJob::DeserializationError
end
```

### Important Notes
- All jobs created in subsequent tickets should use `queue_as :queue_name`
- Jobs must be **idempotent** — safe to retry without side effects
- Failed jobs after 3 retries go to `solid_queue_failed_executions` table
- Mission Control Jobs provides a web UI for monitoring (optional: mount at `/jobs`)
- Jobs run in the same database transaction context as the Rails app
