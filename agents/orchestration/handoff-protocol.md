# Hand-off Protocol

How control and context pass between agents — build-time and runtime. A hand-off is
explicit, typed, and traced. No agent reaches into another agent's scope.

## Hand-off packet (the only thing that crosses a boundary)

```json
{
  "from_agent": "02-solution-architect",
  "to_agent": "03-backend-engineer",
  "phase": "Phase 3 — Backend services",
  "intent": "Implement POST /requests + SSE trace per contract",
  "inputs": ["contracts/api.md", "subagents/orchestrator-agent.md"],
  "acceptance": ["checklists/definition-of-done.md#backend"],
  "constraints": ["Do not alter ADK agent I/O schemas (frozen Phase 1)"],
  "open_questions": [],
  "trace_ref": "trace://build/phase3/handoff-001"
}
```

## Rules

1. **Single owner at a time.** The packet names exactly one `to_agent`. Parallel
   work means multiple packets from the Program Director, not shared ownership.
2. **Contracts are frozen.** If a receiving agent needs a contract change, it does
   NOT edit it — it returns a `CHANGE_REQUEST` packet to the Architect, who decides.
3. **Acceptance travels with the packet.** The receiver knows up front which
   checklist closes the task. "Done" = that checklist passes, not "code compiles".
4. **Every hand-off is traced.** Build-time: a note in the Antigravity Tasks Plan +
   `trace_ref`. Runtime: a row in Supabase `agent_traces` with `from`/`to`.
5. **Blocked → escalate, don't guess.** Return a `BLOCKER` packet to the Program
   Director with what's missing. The Program Director re-plans.

## Runtime hand-off (Gemini ADK)

The ADK Orchestrator Agent passes a typed `RequestContext` object (the state-machine
state + accumulated extractions) to each sub-agent via ADK's session state. Each
sub-agent returns a typed result and an appended trace event. The Orchestrator never
lets a sub-agent talk to another sub-agent directly — all routing is centralized
(hub-and-spoke), which keeps the decision trace linear and gradable.

## Definition of a clean hand-off

- Receiver can start with zero clarifying questions.
- Inputs referenced are committed/present in the repo.
- Acceptance criteria are testable.
- A trace event records from, to, intent, and timestamp.
