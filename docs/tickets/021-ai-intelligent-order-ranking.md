# Ticket 021: AI — Intelligent Order Ranking

## Description
Build the AI-powered order ranking system for the driver feed. Instead of simple distance sorting, the feed is ranked by an ML/LLM-based model that considers driver history (accepted/ignored orders), preferred routes, earning patterns, and current context to surface the most relevant orders first.

## Acceptance Criteria
- [ ] `Ai::OrderRanker` service scores and ranks orders for a specific driver
- [ ] Ranking factors include:
  - Distance from driver (proximity)
  - Driver's historical acceptance patterns (preferred load sizes, price ranges, areas)
  - Route alignment with driver's preferred working areas
  - Order value (price per km)
  - Time sensitivity (immediate orders ranked higher when urgent)
- [ ] Ranking integrates with the feed controller — replaces simple distance sort
- [ ] Fallback: if AI ranking is unavailable, fall back to distance-based sorting
- [ ] Feed still loads in < 2 seconds with ranking applied
- [ ] Ranking is transparent — feed shows "Recommended for you" label on AI-ranked results

## Dependencies
- **013** — Order feed must exist to apply ranking to

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/services/ai/order_ranker.rb` — ranking/scoring service
- `app/controllers/delivery_orders_controller.rb` — integrate ranking into feed query
- `frontend/pages/Driver/OrderFeed.tsx` — show "Recommended" label on ranked results

## Technical Notes
- **Approach A (Scoring Algorithm):** Compute a weighted score:
  ```ruby
  score = (proximity_weight * proximity_score) +
          (history_weight * history_score) +
          (value_weight * value_score) +
          (urgency_weight * urgency_score)
  ```
  - Proximity: inverse of distance (closer = higher)
  - History: count of past acceptances for similar load size/area
  - Value: price / distance_km
  - Urgency: immediate orders get a boost
- **Approach B (LLM-based):** Send batch of orders + driver profile to Claude for ranking reasoning (slower, more intelligent)
- For MVP, Approach A is recommended for speed; Approach B can be used for a subset
- Track driver behavior: create a simple `driver_interactions` table or use existing assignment history
- The ranker should accept an array of orders and return them sorted by score
- Consider caching ranked results per driver for the feed cache TTL (30 seconds)
