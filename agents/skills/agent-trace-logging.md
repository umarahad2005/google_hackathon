# Skill: Agent Trace Logging

The single most rubric-sensitive skill. Used by AI (05) + Backend (03), audited by QA.

## Supabase table
```sql
create table agent_traces (
  id          bigint generated always as identity primary key,
  request_id  uuid not null,
  seq         int  not null,           -- gap-free, strictly increasing per request
  agent       text not null,
  step        text not null,           -- "intent.extract","ranking.score",...
  input       jsonb,
  reasoning   text not null,           -- empty string is a defect
  tool_calls  jsonb default '[]',
  output      jsonb,
  latency_ms  int,
  degraded    boolean default false,
  simulated   boolean default false,
  model       text,
  ts          timestamptz default now(),
  unique (request_id, seq)
);
create index on agent_traces (request_id, seq);
```

## Trace/Observer callback (ADK)
Register `before_agent/after_agent/before_tool/after_tool`. On `after_*`:
build a `TraceEvent`, INSERT into `agent_traces`, and publish for SSE/Realtime.
Allocate `seq` atomically per `request_id`.

## Invariants (QA gate)
1. Every state-machine transition → ≥1 trace event.
2. No row with empty `reasoning`.
3. `seq` gap-free & increasing; `unique(request_id, seq)` holds.
4. Each external effect = a `tool_call` entry with right `degraded`/`simulated`.
5. Reading rows ordered by `seq` reconstructs the full story:
   message → understanding → discovery → ranking → decision → booking → follow-up.

## Deliverable
`scripts/export_trace.py <request_id>` → JSON in `/deliverables` = the "Agent
Trace / Logs" submission item. Also surface the Antigravity Workplan + Tasks Plan
alongside it.

## Don't
- Don't log raw PII in `input`/`reasoning` (scrub free text).
- Don't batch-write at the end — stream so the live app timeline works.
