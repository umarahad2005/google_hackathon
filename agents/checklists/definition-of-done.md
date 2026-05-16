# Definition of Done (per layer)

A task is done only when its section here is fully checked AND a trace artifact exists.

## Foundations
- [ ] Repo: `/backend /mobile /agents /infra /deliverables`
- [ ] Supabase project created; migration applied (`users, providers, bookings,
      follow_ups, service_requests, agent_traces`); PostGIS enabled
- [ ] `.env.example` complete; real `.env` git-ignored; no secret in code
- [ ] ADRs written (ADK topology, Supabase, trace schema, SSE/Realtime)

## Contracts
- [ ] API contract uses `templates/api-contract-template.md`, all endpoints
- [ ] Data + ADK I/O schemas frozen; signed off by Backend, AI, Mobile

## Backend
- [ ] All endpoints implemented per contract; contract tests green
- [ ] ADK pipeline invoked via `POST /requests`; SSE trace streams ordered
- [ ] Supabase persistence for state, booking, follow-ups, traces
- [ ] Seed script: 80–120 synthetic providers across sectors
- [ ] Reference scenario passes over HTTP

## AI / ADK
- [ ] Orchestrator + 5 sub-agents + Trace/Observer implemented per `subagents/`
- [ ] Headless reference run: correct extraction, ≥3 ranked w/ reasoning,
      booking, follow-ups, complete linear trace
- [ ] `wf-01..wf-05` acceptance all pass

## Mobile (MUST)
- [ ] 5 screens; live trace timeline streams in real time
- [ ] Maps SDK shows provider pins + distance
- [ ] Urdu RTL renders correctly; en/ur localized
- [ ] Reference scenario works through the UI on a device

## QA
- [ ] Multilingual + edge suite green
- [ ] `challenge2-compliance-checklist.md` fully green

## Docs
- [ ] README, architecture map, demo script, exported logs in `/deliverables`

> "Code compiles" is NOT done. Done = checklist green + trace exists + owner signed.
