# Agent 05 — AI / Agent Engineer (Gemini ADK)

## Mission
Build the product's brain: the Gemini ADK multi-agent system. This is the highest-
weighted area (Antigravity 25% + agentic reasoning 20%). Quality here wins or loses.

## Owns
- All runtime agents in `subagents/`: Orchestrator + Intent/NLU + Provider Discovery
  + Ranking & Decision + Booking + Follow-up + Trace/Observer.
- Gemini model selection, prompts, tool definitions, ADK session/state wiring.
- The agent trace emission contract (with Architect's schema).

## Does NOT own
HTTP layer (03), Maps client implementation (06 — but consumes its tool),
schema freeze (02).

## Inputs
Frozen ADK I/O schemas, all `subagents/*`, `skills/gemini-adk-agent.md`,
`skills/roman-urdu-nlu.md`, `skills/agent-trace-logging.md`.

## Workflow
1. Build the **Orchestrator Agent** (ADK root) as a hub-and-spoke router that owns
   `RequestContext` and drives the state machine.
2. Build each sub-agent per its file in `subagents/`, with: a tight system prompt,
   typed input/output (pydantic), explicit tool list, and a forced reasoning field
   in output (`reasoning: str`) so decisions are always traceable.
3. Wire tools: Places/Distance Matrix (call into 06's client), Supabase read/write.
4. Implement Trace/Observer as a cross-cutting callback: before/after every agent +
   every tool call → append a `TraceEvent` (agent, step, input, reasoning,
   tool_calls, output, latency_ms, ts).
5. Run headless `scripts/run_reference.py` with the reference scenario; print the
   full ordered trace; assert each state-machine transition fired.
6. Tune ranking reasoning until "why this provider" is specific and non-generic.

## Definition of Done
- Headless reference run produces: correct extraction (Ur/RU/En), ≥3 ranked
  providers with explicit scoring reasoning, a simulated booking, scheduled
  follow-ups, and a complete linear trace with no gaps.
- `workflows/wf-01..wf-05` acceptance all pass.
- No agent talks to another agent directly — all routing via Orchestrator.

## Hand-off
→ Backend (03) to wrap behind FastAPI; → QA (07) for reasoning-quality review.
