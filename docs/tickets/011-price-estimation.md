# Ticket 011: Price Estimation (Rule-Based + AI Smart Pricing)

## Description
Build the price estimation system with both a rule-based fallback and an AI-powered smart pricing service. When a customer doesn't provide a suggested price, the system automatically estimates a fair price considering distance, load size, vehicle type, time of day, and urgency. This runs as a Sidekiq worker chained after route calculation.

## Acceptance Criteria
- [ ] `Pricing::Estimator` service computes price using rule-based formula: `base_rate + (distance_km * per_km_rate) * load_multiplier * vehicle_multiplier`
- [ ] Load multipliers: small (1.0), medium (1.3), large (1.7), bulk (2.5)
- [ ] Vehicle multipliers: motorcycle (0.8), car (1.0), van (1.4), truck (2.0)
- [ ] `Pricing::AiPricingService` calls Claude/GPT API with order context (distance, load, time, urgency) for smart price reasoning
- [ ] AI service returns a price with reasoning explanation
- [ ] `PriceEstimationWorker` (Sidekiq, `default` queue):
  - Runs only if customer did NOT provide a suggested price
  - Attempts AI pricing first, falls back to rule-based on failure
  - Stores `estimated_price` on DeliveryOrder
  - After pricing: enqueues driver matching (ticket 012) and transitions order toward `open`
- [ ] Fallback: if LLM API is unavailable, rule-based pricing works without errors
- [ ] Worker is idempotent

## Dependencies
- **010** — Route must be calculated (need distance for pricing)

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/services/pricing/estimator.rb` — rule-based price calculation
- `app/services/pricing/ai_pricing_service.rb` — LLM-based smart pricing
- `app/workers/price_estimation_worker.rb` — async pricing worker
- `app/workers/route_calculation_worker.rb` — modify to chain `PriceEstimationWorker`

## Technical Notes
- AI pricing prompt should include: distance (km), load description (items + sizes), delivery type (immediate/scheduled), time of day, and region context
- Use Claude Haiku or GPT-4o-mini for cost efficiency on this high-frequency task
- Cache AI pricing results for similar distance/load combinations to reduce API calls
- The rule-based estimator should produce reasonable prices for the demo — tune rates based on typical local delivery costs
- Environment variable: `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`
- Consider using the `anthropic` or `ruby-openai` gem for LLM API calls
- Price should be stored as decimal/integer (cents) to avoid floating-point issues
