# Orchestration — Build Sequence & Phase Gates

The Program Director executes phases in order. **A phase cannot start until the
previous phase's gate checklist passes.** Each gate produces a trace artifact.

## Phase 0 — Foundations (owner: Architect + DevOps)
- Repo layout: `/backend` (FastAPI), `/mobile` (Flutter), `/agents` (this), `/infra`.
- Supabase project + schema migration (providers, bookings, follow_ups, agent_traces, users).
- Secrets/env: Gemini API key, Google Maps key, Supabase URL/keys — via `.env`, never committed.
- ADRs written for: ADK topology, Supabase vs alternatives, trace schema.
- **Gate:** `checklists/definition-of-done.md` (foundations section) + ADRs exist.

## Phase 1 — Contracts (owner: Architect, consulted: Backend/Mobile/AI)
- API contract: `POST /requests` (NL in) → request_id; `GET /requests/{id}` (result);
  `GET /requests/{id}/trace` (SSE stream); booking + follow-up endpoints.
- Data contracts: the canonical `ServiceRequest`, `Provider`, `Booking`, `TraceEvent` schemas.
- ADK agent I/O schemas frozen in `subagents/`.
- **Gate:** every contract uses `templates/api-contract-template.md`; Mobile + Backend + AI sign off.

## Phase 2 — Runtime brain: Gemini ADK multi-agent (owner: AI Engineer)
- Build Orchestrator + 5 sub-agents + Trace/Observer per `subagents/`.
- Tools wired: Places/Distance Matrix (via Maps/Geo agent), Supabase reads/writes.
- Runs headless from a script with the reference scenario; full trace printed.
- **Gate:** `workflows/wf-01..wf-05` each pass their acceptance; trace is complete & ordered.

## Phase 3 — Backend services (owner: Backend)
- FastAPI wraps the ADK pipeline; SSE trace stream; Supabase persistence; seed script.
- **Gate:** contract tests green; reference scenario works via HTTP.

## Phase 4 — Mobile app (owner: Mobile, consulted: UX)
- Flutter: request screen (voice/text, 3 languages), live agent-trace timeline,
  recommendation card with reasoning, booking confirmation + receipt, follow-up view.
- Google Maps SDK shows provider pins + distance.
- **Gate:** `checklists/demo-readiness-checklist.md` mobile section on a real/emulated device.

## Phase 5 — Hardening (owner: QA)
- Edge cases: ambiguous intent, no provider found, mixed-language input, offline.
- **Gate:** `checklists/challenge2-compliance-checklist.md` fully green.

## Phase 6 — Deliverables (owner: Tech Writer)
- README (architecture, APIs, how Antigravity is used, assumptions/limitations),
  architecture map image, 3–5 min demo video script, exported Antigravity trace/logs.
- **Gate:** all four challenge deliverables present and reviewed by Program Director.

## Phase 7 — Web app (OPTIONAL, owner: Mobile)
- Only after Phase 6 green. Flutter web build reusing the same API.

## Parallelization

After Phase 1, Phases 2 & 3 backend can run while UX designs Phase 4 screens.
Mobile (Phase 4) starts against a contract mock, then switches to the real backend.
The Program Director tracks this in the Antigravity Tasks Plan.
