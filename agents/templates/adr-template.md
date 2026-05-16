# ADR Template (Architecture Decision Record)

```
# ADR-<n>: <decision title>
Date: <YYYY-MM-DD>   Status: proposed | accepted | superseded
Owner: Solution Architect (02)

## Context
<the forces: requirement, constraint, rubric pressure>

## Decision
<the choice, stated plainly>

## Alternatives considered
- <option> — rejected because <reason>

## Consequences
+ <benefit>
- <cost / risk + mitigation>

## Rubric impact
<which evaluation criteria this strengthens and how>
```

## ADRs required for Zimma AI (write these in Phase 1)
- ADR-1: Gemini ADK hub-and-spoke multi-agent topology (vs single tool-calling LLM)
- ADR-2: Supabase (Postgres+PostGIS+Auth+Realtime) as data/realtime layer
- ADR-3: Trace event schema + Trace/Observer callback approach
- ADR-4: SSE vs Supabase Realtime for the live trace timeline
- ADR-5: Demo clock compression for follow-up lifecycle
