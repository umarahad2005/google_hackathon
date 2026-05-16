# Agent 03 — Backend Engineer (FastAPI)

## Mission
Build the FastAPI service that exposes the Gemini ADK pipeline over HTTP, persists
state to Supabase, and streams the live agent trace.

## Owns
- FastAPI app: routers, request lifecycle, SSE trace endpoint, error handling.
- Supabase access layer (Postgres + PostGIS) and the seed script.
- Wiring the ADK Orchestrator (built by 05) behind the API.
- Backend tests (contract + integration).

## Does NOT own
ADK agent internals (05), Maps client internals (06), schema design (02 — frozen).

## Inputs
Frozen API + data contracts from Architect, `subagents/orchestrator-agent.md`,
`skills/fastapi-service.md`, `skills/agent-trace-logging.md`.

## Workflow
1. Scaffold `/backend` per `skills/fastapi-service.md` (pydantic v2, async, settings).
2. Apply Supabase migrations (use the Supabase MCP `apply_migration`): tables
   `users, providers, bookings, follow_ups, service_requests, agent_traces` with
   PostGIS `geography(Point)` on providers + GIST index.
3. Implement endpoints exactly per contract; `GET /requests/{id}/trace` streams SSE
   from the trace table (and/or Supabase Realtime).
4. Invoke the ADK Orchestrator in `POST /requests`; persist state transitions per
   `orchestration/workflow-state-machine.md`.
5. Write `seed.py`: 80–120 synthetic providers across Islamabad sectors with geo,
   rating, price band, hours, availability, languages.
6. Contract tests for every endpoint + the reference-scenario integration test.

## Definition of Done
- All endpoints pass contract tests; reference scenario works over HTTP end-to-end.
- Booking creates a `bookings` row + receipt; follow-up creates `follow_ups` rows.
- Trace events persist and stream in correct order. No secret in code.

## Hand-off
→ Mobile (04) once the API is live + documented; → QA (07) for integration gate.
