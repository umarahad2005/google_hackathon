# Workflow: Booking Simulation (runtime — CRITICAL)

Owner: `subagents/booking-agent.md`. Trigger: RECOMMENDED → BOOKING.

## Steps
1. `reserve_slot(provider_id, requested_window)` → first free slot in window from
   the provider's Supabase availability calendar.
2. Slot conflict → return conflict → Orchestrator: offer next slot or next provider
   (re-enter RANKING). Trace the conflict + resolution.
3. `write_booking` → INSERT `bookings` row, status `confirmed` (the state change).
4. `generate_receipt` → receipt artifact → Supabase Storage; return URL.
5. `send_confirmation` → bilingual (Urdu + English) message; simulated SMS/WhatsApp
   (trace `simulated:true`); FCM push to app.
6. Emit trace `booking.confirmed` with reasoning (slot choice, confirmation path).
7. State → CONFIRMED.

## Acceptance (judged 15%)
- `bookings` row exists, status=confirmed, slot inside requested window.
- Receipt retrievable; bilingual confirmation generated.
- Before/after Supabase state demonstrably different (show the row appearing).
- Conflict path tested at least once and traced.

## Hard rule
The booking row is REAL Supabase state. Only the external send is simulated and
explicitly flagged.
