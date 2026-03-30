# Ticket 031: Privacy-by-Design Foundations

## Description
Implement privacy-by-design practices across the application following the privacy-by-design-rails skill patterns. Covers PII encryption at rest, log filtering, Sidekiq argument protection, data retention automation, DSAR foundations (anonymization and data export), consent management, and session security hardening.

## Acceptance Criteria

### PII Encryption (Active Record Encryption)
- [ ] Generate encryption keys: `bin/rails db:encryption:init`
- [ ] Store keys in Rails credentials (`bin/rails credentials:edit`)
- [ ] User model: `encrypts :email, deterministic: true, downcase: true` (searchable), `encrypts :name` (non-deterministic)
- [ ] DeliveryOrder model: `encrypts :pickup_address`, `encrypts :dropoff_address`
- [ ] PaymentMethod model: `encrypts :gateway_token`
- [ ] `config.active_record.encryption.support_unencrypted_data = true` for migration period

### Log & Output Protection
- [ ] `config/initializers/filter_parameter_logging.rb` updated with all PII fields: `:passw`, `:email`, `:secret`, `:token`, `:_key`, `:crypt`, `:salt`, `:name`, `:phone`, `:pickup_address`, `:dropoff_address`, `:gateway_token`, `:card_last_four`, `:ip_address`
- [ ] `self.filter_attributes` declared on User, DeliveryOrder, PaymentMethod, Payment models
- [ ] Sidekiq workers verified to accept only record IDs (audit all perform signatures)
- [ ] Add `logstop` gem for catch-all PII pattern redaction in logs

### Data Retention
- [ ] `DataRetentionWorker` (Sidekiq, maintenance queue): anonymizes PII on users inactive > retention period
- [ ] Location data cleanup: anonymize/delete Assignment location history older than 90 days
- [ ] Configurable retention period via env var `DATA_RETENTION_YEARS` (default: 3)
- [ ] Scheduled via `config/sidekiq.yml` (recurring, weekly)

### DSAR Foundations
- [ ] `Anonymizable` concern on User model: replaces PII fields with `[ANONYMIZED]`
- [ ] `DataExportable` concern on User model: exports user data as JSON (name, email, orders, payment history minus sensitive gateway data)
- [ ] Both concerns included in User model

### Consent Management (Foundation)
- [ ] `consents` table: user_id (FK), purpose (enum: terms_of_service/location_tracking/payment_processing/marketing), granted_at, revoked_at, ip_address, user_agent, timestamps
- [ ] `Consent` model with append-only pattern (new record for each grant/revoke, never update existing)
- [ ] `HasConsent` concern for checking active consent on User model
- [ ] Consent record created on registration (terms_of_service) and on first payment method add (payment_processing)

### Session Security
- [ ] `config.force_ssl = true` in production
- [ ] Secure cookie settings verified
- [ ] HSTS header configured

## Dependencies
- **003** — base schema/User model exists
- **028** — PaymentMethod encryption

## Estimated Effort
**XL** (4-6 hours)

## Files to Create/Modify
- `config/initializers/filter_parameter_logging.rb` — expanded PII field list
- `config/initializers/active_record_encryption.rb` — encryption configuration
- `config/environments/production.rb` — force_ssl and HSTS
- `app/models/user.rb` — encrypts, filter_attributes, Anonymizable/DataExportable/HasConsent concerns
- `app/models/delivery_order.rb` — encrypts :pickup_address, :dropoff_address, filter_attributes
- `app/models/payment_method.rb` — encrypts :gateway_token, filter_attributes
- `app/models/payment.rb` — filter_attributes
- `app/models/concerns/anonymizable.rb` — PII replacement concern
- `app/models/concerns/data_exportable.rb` — JSON data export concern
- `app/models/concerns/has_consent.rb` — active consent checking concern
- `app/models/consent.rb` — append-only consent model
- `db/migrate/XXX_create_consents.rb` — consents table migration
- `app/workers/data_retention_worker.rb` — scheduled PII anonymization worker
- `config/sidekiq.yml` — add recurring weekly schedule for DataRetentionWorker
- `Gemfile` — add logstop gem
- `spec/models/concerns/anonymizable_spec.rb` — Anonymizable concern tests
- `spec/models/concerns/data_exportable_spec.rb` — DataExportable concern tests
- `spec/workers/data_retention_worker_spec.rb` — worker tests

## Technical Notes
- Follow patterns from the privacy-by-design-rails skill at `.agents/skills/privacy-by-design-rails/`
- Use Sidekiq (not Solid Queue) for data retention since the project uses Sidekiq throughout
- `Anonymizable` replaces PII with `[ANONYMIZED]`, preserving the record for referential integrity
- `DataExportable` generates a JSON export including: user profile, orders (without other users' data), payment history (without gateway tokens), consents
- Consent is append-only: current state = most recent record per purpose
