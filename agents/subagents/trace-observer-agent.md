# Sub-Agent: Trace / Observer (cross-cutting)

## Role
Not in the request flow — a callback layer that wraps every agent and every tool
call to produce the **gradable agentic trace**. This is the single most rubric-
sensitive component (Antigravity 25% + agentic reasoning 20% both read this).

## ADK shape
ADK `before_agent` / `after_agent` / `before_tool` / `after_tool` callbacks (or
equivalent middleware). Zero business logic — pure observation + persistence.

## What it captures (every step)
- `agent`, `step`, monotonically increasing `seq`, `request_id`
- `input` (the typed payload in), `output` (typed payload out)
- `reasoning` (lifted from the agent's required `reasoning` field)
- `tool_calls`: name, args, result summary, `degraded`/`simulated` flags
- `latency_ms`, `ts`, model used

## Where it goes
- INSERT into Supabase `agent_traces` (the durable record / deliverable export).
- Stream to the Flutter app via `GET /requests/{id}/trace` (SSE) and/or Supabase
  Realtime → the live "AI is thinking" timeline.

## Invariants (QA enforces)
1. Every state-machine transition has ≥1 trace event.
2. No decision event has an empty `reasoning`.
3. `seq` is gap-free and strictly increasing per `request_id`.
4. Each external effect (Maps call, booking write, notification) appears as a
   `tool_call` with correct `degraded`/`simulated` flags.
5. The trace alone, read top-to-bottom, tells the full story:
   message → understanding → discovery → ranking → decision → booking → follow-up.

## Acceptance
Replaying the stored trace for the reference request reconstructs the entire
decision path with no missing step — this export is a submission deliverable.
