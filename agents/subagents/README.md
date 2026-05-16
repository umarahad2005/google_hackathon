# Runtime Sub-Agents — Zimma AI Brain (Gemini ADK)

These are NOT build-time roles. These are the **product's runtime agents**, built
with **Google ADK** (Agent Development Kit) and Gemini, owned by build agent
`agents/05-ai-agent-engineer.md`. Antigravity orchestrates them; ADK is the runtime.

## Topology — hub-and-spoke (centralized, traceable)

```
                 ┌───────────────────────────┐
                 │   Orchestrator Agent      │  (ADK root, owns RequestContext)
                 └─────────────┬─────────────┘
       ┌───────────┬───────────┼───────────┬───────────────┐
       ▼           ▼           ▼           ▼               ▼
   Intent/NLU  Provider    Ranking &   Booking       Follow-up
               Discovery   Decision     Agent          Agent
       └───────────┴───────────┴───────────┴───────────────┘
                 ▲ every step wrapped by ▼
                 ┌───────────────────────────┐
                 │  Trace/Observer (callback)│  → Supabase agent_traces
                 └───────────────────────────┘
```

Why hub-and-spoke: no sub-agent calls another sub-agent. The Orchestrator routes
everything, so the decision trace is **linear and gradable** (judges follow one
storyline). This directly serves Antigravity 25% + agentic reasoning 20%.

## Shared contract (frozen at Phase 1 — do not change downstream)

`RequestContext` — passed through ADK session state:
```python
class RequestContext(BaseModel):
    request_id: str
    raw_message: str
    audio_url: str | None = None
    language: Literal["ur","roman_ur","en","mixed"] | None = None
    intent: ServiceIntent | None = None          # filled by Intent/NLU
    candidates: list[ProviderCandidate] = []      # filled by Discovery
    ranked: list[RankedProvider] = []             # filled by Ranking
    selected: RankedProvider | None = None
    booking: Booking | None = None                # filled by Booking
    followups: list[FollowUp] = []                # filled by Follow-up
    state: str                                    # state-machine state
```

Every sub-agent output MUST include a non-empty `reasoning: str`. An agent that
produces a decision without reasoning is a defect (QA blocks it).

## Trace event (emitted by Trace/Observer around every agent + tool call)
```python
class TraceEvent(BaseModel):
    request_id: str
    seq: int
    agent: str
    step: str            # e.g. "intent.extract", "ranking.score"
    input: dict
    reasoning: str
    tool_calls: list[dict]
    output: dict
    latency_ms: int
    degraded: bool = False
    ts: datetime
```

Models: routing/extraction → `gemini-2.0-flash`; ranking reasoning & follow-up
drafting → `gemini-2.x-pro` (configurable in one place).
