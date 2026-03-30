# Ticket 022: AI — ETA Narratives

## Description
Build the AI-powered ETA narrative feature. Instead of showing raw "12 minutes" on the customer tracking screen, generate contextual human-readable updates like "Your driver is 3 minutes away, currently passing through Boa Viagem. Traffic is light." Uses LLM to generate narratives from delivery context.

## Acceptance Criteria
- [ ] `Ai::EtaNarrator` service generates human-readable ETA messages using LLM
- [ ] Context sent to LLM includes: ETA in seconds, driver location (area/neighborhood), distance remaining, delivery status, time of day
- [ ] Narratives are refreshed on each ETA recalculation (every 30-60 seconds)
- [ ] Generated narratives are cached on the Assignment record or in Redis
- [ ] `OrderTracking.tsx` displays the narrative text prominently above/below the map
- [ ] Fallback: template-based messages when LLM is unavailable:
  - "Your driver is approximately X minutes away"
  - "Your driver has picked up your items and is on the way"
  - "Your delivery is almost here!"
- [ ] Use efficient LLM model (Claude Haiku / GPT-4o-mini) for this high-frequency task
- [ ] Narratives feel natural and contextual — not robotic

## Dependencies
- **019** — ETA recalculation worker provides updated ETA data
- **016** — Delivery must be in active status

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/services/ai/eta_narrator.rb` — LLM-based narrative generation service
- `app/workers/eta_recalculation_worker.rb` — extend to generate narrative after ETA update
- `frontend/pages/Customer/OrderTracking.tsx` — display narrative text

## Technical Notes
- LLM prompt:
  ```
  Generate a brief, friendly delivery status update for a customer.

  Context:
  - Driver ETA: {eta_seconds} seconds ({eta_minutes} minutes)
  - Driver current area: {driver_area}
  - Distance remaining: {distance_km} km
  - Delivery status: {status}
  - Time of day: {time_of_day}

  Rules:
  - Keep it under 2 sentences
  - Be conversational and reassuring
  - Include the area name if available
  - Mention traffic conditions if relevant to the time of day
  ```
- Use Claude Haiku or GPT-4o-mini for cost efficiency (this runs every 30-60s per active delivery)
- Cache narratives in Redis with 30-second TTL: `eta_narrative:assignment:#{id}`
- Rate-limit AI calls: maximum 2 per minute per delivery
- The fallback templates should cover all delivery statuses and ETA ranges
- Narrative should be served alongside location data in the polling response
