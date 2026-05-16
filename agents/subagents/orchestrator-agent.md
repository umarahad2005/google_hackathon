# Sub-Agent: Orchestrator Agent (ADK root)

## Role
The brain stem. Owns `RequestContext` and the state machine
(`orchestration/workflow-state-machine.md`). Plans the run, routes to one sub-agent
at a time, handles failures, decides when the request is complete.

## ADK shape
ADK `LlmAgent` acting as a router + an explicit state-machine driver in code.
The LLM proposes the next step + reasoning; code enforces valid transitions.

## Input
`raw_message` (+ optional `audio_url`), `request_id`.

## Output
Final structured result + the completed `RequestContext` + ordered trace.

## Logic
1. State NEW → call **Intent/NLU**. If confidence < 0.6 on service/location/time →
   state CLARIFY, return a clarifying question (don't guess).
2. State DISCOVERING → call **Provider Discovery**. 0 results → widen radius once →
   still 0 → state NO_PROVIDER with a graceful message.
3. State RANKING → call **Ranking & Decision**.
4. State RECOMMENDED → in demo auto-confirm top provider (or wait for user confirm).
5. State BOOKING → call **Booking Agent**. Slot conflict → re-rank / next provider.
6. State CONFIRMED → call **Follow-up Agent** → FOLLOW_UP_SCHEDULED → COMPLETED.
7. On any sub-agent error: write `error` trace, run documented fallback, else FAILED.

## Reasoning requirement
Before each routing decision, emit a one-line plan: *"Intent extracted (AC technician,
G-13, tomorrow AM, conf 0.91) → routing to Provider Discovery."* This narration is
what judges read as the agentic storyline.

## Hard rules
- Never let a sub-agent call another sub-agent.
- Never skip a state; every transition emits a trace event.
- Never fabricate data to keep moving — degrade and flag instead.
