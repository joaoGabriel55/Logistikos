# Ticket 020: AI — Natural Language Order Creation

## Description
Build the natural language order creation feature where customers describe their delivery needs in free text (e.g., "I need to move a sofa and two boxes from Boa Viagem to Casa Forte, preferably this afternoon"). An LLM parses this into structured order fields with a confirmation screen before submission.

## Acceptance Criteria
- [ ] `Ai::NlOrderParser` service sends free-text to Claude/GPT API and parses response into structured fields:
  - Pickup address
  - Dropoff address
  - Items (name, quantity, size category)
  - Delivery type (immediate/scheduled) with timing
  - Description
- [ ] LLM prompt includes clear schema definition and examples for consistent output
- [ ] Parsed output is validated against the order schema — reject unparseable inputs gracefully
- [ ] `OrderNaturalLanguage.tsx` page with:
  - Free-text textarea input
  - "Parse with AI" button
  - Loading state while LLM processes
  - Confirmation screen showing parsed fields in editable form
  - Customer can edit any parsed field before final submission
  - "Submit Order" button that creates the order (reuses `Orders::Creator` from ticket 008)
- [ ] Async processing via Solid Queue job (LLM call doesn't block the UI)
- [ ] Fallback: if LLM is unavailable, show error message and link to standard form (ticket 008)
- [ ] AI hallucination guard: validate all parsed fields, reject if critical fields are missing

## Dependencies
- **008** — Order creation service (reused for final submission)
- **009** — Solid Queue for async LLM processing

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/services/ai/nl_order_parser.rb` — LLM-based text parsing service
- `frontend/pages/Customer/OrderNaturalLanguage.tsx` — NL order page with textarea + confirmation
- `config/routes.rb` — route for NL order page and parsing endpoint

## Technical Notes
- LLM prompt structure:
  ```
  Parse the following delivery request into structured fields.
  Return JSON with: pickup_address, dropoff_address, items (array of {name, quantity, size}),
  delivery_type ("immediate" or "scheduled"), scheduled_time (if applicable), description.

  Size must be one of: small, medium, large, bulk.
  If a field cannot be determined, set it to null.

  Request: "{user_text}"
  ```
- Use Claude Sonnet or GPT-4o for this task (complex reasoning needed)
- The parsing can be synchronous for MVP (wait for LLM response) or async with polling
- For async: create a temporary "parse request" record, poll for completion
- Validation: pickup_address and dropoff_address must be non-null; at least one item required
- The confirmation screen should reuse the same form components from `OrderCreate.tsx` (AddressInput, ItemListInput)
- Environment variable: `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`
