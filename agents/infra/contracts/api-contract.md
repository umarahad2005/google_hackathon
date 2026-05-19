# Zimma AI — API Contract (Frozen Phase 1)

> Template: `agents/templates/api-contract-template.md`
> Owner: Solution Architect (02)
> Consumers: Backend (03), Mobile (04), AI (05)

---

## Base URL
```
http://localhost:8000/api
```

---

## POST /requests
Create a new service request from a natural-language message.

**Request:**
```json
{
  "message": "Mujhe kal subah G-13 mein AC technician chahiye",
  "audio_url": null,
  "user_id": "demo-user"
}
```

**Response (202 Accepted):**
```json
{
  "request_id": "uuid",
  "state": "NEW"
}
```

**Behavior:** Kicks the ADK Orchestrator as a background task. Returns immediately
so the client can subscribe to the trace stream.

---

## GET /requests/{id}
Get the current state and accumulated result of a service request.

**Response (200):**
```json
{
  "request_id": "uuid",
  "state": "CONFIRMED",
  "intent": { ...ServiceIntent },
  "recommended": { ...RankedProvider },
  "alternatives": [ ...RankedProvider ],
  "booking": { ...Booking },
  "followups": [ ...FollowUp ],
  "trace_count": 12
}
```

---

## GET /requests/{id}/trace
SSE stream of agent trace events. Opens a persistent connection; each event is
a `TraceEvent` JSON object.

**Response (200, text/event-stream):**
```
data: {"request_id":"uuid","seq":1,"agent":"intent_nlu","step":"intent.extract","reasoning":"...","latency_ms":342,...}

data: {"request_id":"uuid","seq":2,"agent":"provider_discovery","step":"discovery.search",...}
```

**Behavior:** Streams existing events immediately, then tails for new ones until
the request reaches a terminal state (COMPLETED, FAILED, NO_PROVIDER).

---

## POST /requests/{id}/confirm
Confirm the recommended provider (accept rank 1, or specify alternative).

**Request:**
```json
{
  "provider_id": "uuid",
  "action": "accept"
}
```

**Response (200):**
```json
{
  "request_id": "uuid",
  "state": "BOOKING"
}
```

---

## GET /bookings/{id}
Get booking details including receipt URL.

**Response (200):**
```json
{
  "booking_id": "uuid",
  "provider_id": "uuid",
  "slot_start": "2026-05-17T10:00:00+05:00",
  "slot_end": "2026-05-17T11:00:00+05:00",
  "status": "confirmed",
  "price_estimate": "PKR 2,000–3,000",
  "receipt_url": "https://...",
  "confirmation_message": "آپ کی بکنگ کنفرم ہو گئی ہے۔ ...",
  "reasoning": "..."
}
```

---

## Error Shape (all endpoints)
```json
{
  "error": "Human-readable message",
  "request_id": "uuid or null"
}
```
Never leak internals. Log full details server-side.
