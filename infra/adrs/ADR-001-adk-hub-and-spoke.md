# ADR-001: ADK Hub-and-Spoke Topology

## Status
Accepted

## Context
Zimma AI requires a multi-agent system where the decision trace is linear and
gradable (Antigravity 25% + agentic reasoning 20%). Two topologies were considered:
1. **Hub-and-spoke** — root Orchestrator routes to one sub-agent at a time.
2. **Mesh** — agents can call each other directly.

## Decision
**Hub-and-spoke** via a root ADK `LlmAgent` acting as a router + state-machine
driver. No sub-agent calls another sub-agent directly; all routing is centralized.

## Rationale
- **Linear trace**: judges follow one storyline top-to-bottom. Mesh produces
  branching traces that are harder to read and grade.
- **Debuggability**: the Orchestrator is the single point of control/failure.
- **State ownership**: `RequestContext` lives in one place (ADK session state),
  mutated only by the Orchestrator after each sub-agent returns.
- **Rubric fit**: the challenge explicitly scores agentic workflow and
  traceability — a linear hub-and-spoke maximizes both.

## Consequences
- Sub-agents cannot compose with each other (by design — they are specialists).
- All latency is additive (no parallel sub-agent calls), acceptable for a demo.
- Adding a new sub-agent requires only registering it with the Orchestrator.
