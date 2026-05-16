# Skill: Building a Gemini ADK Agent

How any runtime sub-agent is built. Used by AI Engineer (05).

## Stack
- `google-adk` (Agent Development Kit, Python) + `google-genai` (Gemini).
- Models: routing/extraction → `gemini-2.0-flash`; reasoning → `gemini-2.x-pro`.
  Centralize model IDs in `backend/app/agents/config.py`.

## Pattern: one sub-agent
```python
from google.adk.agents import LlmAgent
from pydantic import BaseModel

class Out(BaseModel):
    ...
    reasoning: str          # MANDATORY, non-empty

intent_agent = LlmAgent(
    name="intent_nlu",
    model=MODELS.flash,
    instruction=open("prompts/intent.txt").read(),  # tight, role-scoped
    output_schema=Out,            # forces validated structured output
    tools=[],                     # only tools this agent needs
)
```

## Pattern: orchestrator (hub-and-spoke)
- Root agent owns `RequestContext` in ADK session state.
- It calls sub-agents in code, driven by the state machine — NOT free-form
  agent-to-agent chatter. The LLM proposes the next step + a one-line plan;
  code validates the transition (`orchestration/workflow-state-machine.md`).
- Never register sub-agents as each other's tools.

## Rules
1. Every agent output schema has a required `reasoning: str`. Empty → defect.
2. Wrap all agents/tools with the Trace/Observer callbacks (see
   `skills/agent-trace-logging.md`) — no exceptions.
3. Tools are plain typed Python functions; validate args before side effects.
4. Prompts: short, single-responsibility, with 1–2 few-shot multilingual examples
   for the NLU agent (see `skills/roman-urdu-nlu.md`).
5. Make a headless `scripts/run_reference.py` that runs the reference scenario and
   prints the full ordered trace — this is the AI Engineer's DoD proof.

## Anti-patterns
- One mega-agent doing everything (kills the multi-agent score).
- Reasoning generated after the decision as decoration — reason THEN decide.
- Silent fallback with fabricated data — degrade + flag instead.
