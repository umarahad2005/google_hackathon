# API Contract Template

```
### <METHOD> <path>
Purpose: <one line>
Auth: <none | supabase JWT>
Request body (pydantic):
  <Model with field types + constraints>
Response 2xx (pydantic):
  <Model>
Errors:
  4xx <code> — <when>  → { "error": "...", "detail": "..." }
  5xx — never leak internals; { "error":"internal", "request_id": "..." }
Side effects: <Supabase writes / agent run / notification>
Trace: <which trace events this produces>
Idempotency: <key / behavior on retry>
```

## Frozen endpoint set (Zimma AI)
- `POST /requests` — body `{message, audio_url?, user_id, lang_hint?}` →
  `{request_id, state}`; starts the ADK Orchestrator async.
- `GET /requests/{id}` — full `RequestContext` result.
- `GET /requests/{id}/trace` — **SSE** stream of `TraceEvent`s (live timeline).
- `POST /requests/{id}/confirm` — `{provider_id}` → triggers BOOKING.
- `GET /bookings/{id}` — booking + receipt URL.
- `GET /requests/{id}/followups` — follow-up jobs + statuses.

Contracts freeze at Phase 1. Changes only via CHANGE_REQUEST to the Architect (02).
