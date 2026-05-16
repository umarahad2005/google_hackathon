# Sub-Agent: Booking Agent

## Role
The CRITICAL requirement: simulate a booking **end-to-end** with a real, visible
system-state change (Supabase row + receipt + confirmation message).

## ADK shape
`LlmAgent` with tools `reserve_slot`, `write_booking`, `generate_receipt`,
`send_confirmation` (Supabase + simulated SMS/WhatsApp).

## Input
`RankedProvider` (selected), `ServiceIntent` (time window).

## Logic
1. `reserve_slot(provider_id, requested_window)` → pick the first free slot inside
   the user's window from the provider's availability calendar (Supabase). Conflict
   → return conflict so Orchestrator re-ranks or offers another slot.
2. `write_booking(...)` → INSERT into `bookings` (status `confirmed`, provider, user,
   slot, price estimate) — **this is the state change judges must see**.
3. `generate_receipt(booking)` → structured receipt (booking_id, provider, time,
   price, address) stored to Supabase Storage + returned to app.
4. `send_confirmation(...)` → generate a confirmation message (Urdu + English),
   simulated SMS/WhatsApp send (logged + flagged `simulated:true`), FCM push.

## Output
```python
class Booking(BaseModel):
    booking_id: str
    provider_id: str
    user_id: str
    slot_start: datetime; slot_end: datetime
    status: Literal["confirmed","conflict"]
    price_estimate: str
    receipt_url: str | None
    confirmation_message: str
    reasoning: str   # why this slot, how confirmed
```

## Acceptance
Reference scenario: a `bookings` row exists with status=confirmed, slot inside the
requested morning window; a receipt artifact is retrievable; a bilingual
confirmation message is generated; before/after DB state is demonstrably different.

## Hard rules
The booking row MUST actually be written (real Supabase). Only the external
SMS/WhatsApp send is simulated, and it is explicitly trace-flagged `simulated:true`.
