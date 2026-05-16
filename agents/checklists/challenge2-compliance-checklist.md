# Challenge-2 Compliance Checklist (FINAL GATE)

QA agent runs this line by line before submission. Map each to the rubric.

## Intent understanding (req 1)
- [ ] Urdu input extracts service+location+time correctly (3 phrasings)
- [ ] Roman Urdu input correct (3 phrasings incl. reference message)
- [ ] English input correct (3 phrasings)
- [ ] Mixed-language input handled
- [ ] Missing slot → exactly one targeted clarifying question (no guessing)

## Provider discovery (req 2)
- [ ] Real Google Places API results returned for a category near a sector
- [ ] Supabase seeded providers (PostGIS) returned and merged + de-duped
- [ ] Works in degraded mode (no Maps key) → DB candidates + trace flag

## Matching & ranking (req 3, 4 — 20%)
- [ ] ≥3 providers ranked with transparent `score_breakdown`
- [ ] Recommendation `reasoning` cites distance + time-match + rating + beats #2
- [ ] No generic/unsubstantiated justification

## Action simulation (req 5 — CRITICAL, 15%)
- [ ] `bookings` row written, status=confirmed, slot inside requested window
- [ ] Receipt artifact generated + retrievable
- [ ] Bilingual confirmation message generated
- [ ] Before/after system-state change is visibly demonstrated
- [ ] Slot-conflict path tested + traced

## Follow-up automation (req 6)
- [ ] reminder + ≥2 status + completion `follow_ups` rows created
- [ ] Live status progression visible in app
- [ ] Request reaches COMPLETED with rating request

## Agentic workflow (req 7 — 25% + 20%)
- [ ] Multiple ADK agents, hub-and-spoke, no agent↔agent direct calls
- [ ] Every state-machine transition has a trace event
- [ ] No decision event with empty `reasoning`
- [ ] `seq` gap-free; trace alone reconstructs the full story
- [ ] Antigravity Workplan + Tasks Plan exported and readable

## Deliverables
- [ ] Flutter mobile app runs reference scenario end-to-end on a device
- [ ] Demo video script 3–5 min hitting every beat
- [ ] README: architecture, APIs, **how Antigravity is used**, assumptions
- [ ] Exported Antigravity trace/logs in `/deliverables`

## Guidelines compliance
- [ ] Not a plain listing/booking app — agentic automation is the core
- [ ] No real personal/sensitive data; providers synthetic
- [ ] Simulated notifications explicitly flagged `simulated:true`

**Verdict:** PASS only if every box is checked. Any unchecked → BLOCKER to owner.
