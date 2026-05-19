# ADR-003: Trace Event Schema Design

## Status
Accepted

## Context
The agent trace is a graded feature (Antigravity 25% + agentic reasoning 20%).
We need a schema that: (a) captures every decision with reasoning, (b) is gap-free
and orderable, (c) streams to the app in real time, (d) exports as a deliverable.

## Decision
A single `agent_traces` table with composite `(request_id, seq)` unique constraint.
Schema: `{request_id, seq, agent, step, input, reasoning, tool_calls, output,
latency_ms, degraded, simulated, model, ts}`.

## Rationale
- **`seq` gap-free per request**: judges can verify no step was skipped.
- **`reasoning` NOT NULL**: empty is a defect caught by QA (invariant 2).
- **`degraded` / `simulated` flags**: explicit honesty about fallbacks and
  simulated external sends.
- **Single table**: simple to query, stream, and export.
- **JSONB for `input`/`output`/`tool_calls`**: flexible across agent types
  without schema migration per agent change.

## Consequences
- All agents must populate `reasoning` — enforced by pydantic `min_length=1`.
- `seq` allocation must be atomic per `request_id` (handled in Trace/Observer).
- Export script reads `agent_traces` ordered by `(request_id, seq)`.
