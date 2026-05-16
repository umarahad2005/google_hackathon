# Skill: FastAPI Service

Used by Backend (03).

## Layout
```
backend/
  app/
    main.py            # FastAPI app, routers, CORS
    settings.py        # pydantic-settings, env only
    api/requests.py    # POST /requests, GET /requests/{id}, /trace (SSE), /confirm
    api/bookings.py
    agents/            # ADK orchestrator + sub-agents (owned by AI 05)
    services/supabase.py   # data layer (skill: supabase-data-layer.md)
    services/maps.py       # maps client (owned by 06)
    models.py          # shared pydantic: ServiceRequest, Provider, Booking, TraceEvent
  scripts/seed.py
  scripts/run_reference.py
  tests/
```

## Conventions
- Python 3.11+, async, pydantic v2, `pydantic-settings`. No secret literals.
- Errors: never leak internals; return `{error, request_id}`; log full server-side.
- `POST /requests` kicks the ADK Orchestrator as a background task, returns
  `{request_id, state}` immediately so the app can subscribe to the trace.

## SSE trace endpoint
```python
@router.get("/requests/{rid}/trace")
async def trace(rid: str):
    async def gen():
        async for ev in trace_stream(rid):      # tail agent_traces / pubsub
            yield f"data: {ev.model_dump_json()}\n\n"
    return StreamingResponse(gen(), media_type="text/event-stream")
```

## Tests
- Contract test per endpoint (schema in/out, error shapes).
- One integration test: reference message → assert booking row + follow-ups +
  ordered trace. This is the backend DoD.
