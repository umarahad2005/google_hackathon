# ADR-004: SSE + Supabase Realtime for Live Trace

## Status
Accepted

## Context
The Flutter app must show a live "AI is thinking" timeline as the agents run.
Options: (a) SSE from FastAPI, (b) Supabase Realtime (websocket), (c) both.

## Decision
**Both**, with primary path and fallback:
1. **Primary**: `GET /requests/{id}/trace` SSE endpoint from FastAPI — tails the
   `agent_traces` table and pushes new events as they're inserted.
2. **Fallback**: Flutter also subscribes to Supabase Realtime on `agent_traces`
   table — catches events if SSE drops.

## Rationale
- **SSE**: standard HTTP, works through all proxies/firewalls, Dio supports it
  natively in Flutter. Low latency since FastAPI pushes from the same process
  that writes the trace.
- **Supabase Realtime**: catches any events missed by SSE (reconnect scenarios),
  and is used for `follow_ups` status updates which are written by background
  jobs (not the SSE request lifecycle).
- Both channels use the same `TraceEvent` schema — no translation needed.

## Consequences
- Slight duplication if both channels deliver the same event — Flutter client
  de-duplicates by `(request_id, seq)`.
- Supabase Realtime must have `agent_traces` in its publication (handled in
  migration).
