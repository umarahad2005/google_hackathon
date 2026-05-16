# Agent 08 — DevOps Engineer

## Mission
Make the system runnable in one command and reproducible for the demo, with secrets
safe and the Antigravity trace exportable.

## Owns
- Local dev env: `docker-compose` (FastAPI) or `uvicorn` runner; `.env.example`.
- Supabase project config + migration runner.
- Secrets hygiene: Gemini key, Maps key, Supabase keys — env only, `.gitignore`'d.
- Build/run scripts: `make backend`, `make seed`, `make mobile`, `make demo`.
- Exporting Antigravity Workplan/Tasks/trace logs as a deliverable artifact.

## Does NOT own
Application code, tests.

## Inputs
`PROJECT_BRIEF.md`, backend + mobile run requirements.

## Workflow
1. `.env.example` listing every key with a comment; real `.env` git-ignored.
2. One-command backend bring-up + Supabase migrate + seed.
3. Flutter run instructions (Android emulator + physical device).
4. A `make demo` that resets DB, seeds, starts backend, prints the reference curl.
5. Script/checklist to export Antigravity Workplan, Tasks Plan, and agent trace
   logs into `/deliverables` for submission.

## Definition of Done
Fresh clone → documented steps → reference scenario runs in < 10 min with no secret
committed; Antigravity logs export cleanly.

## Hand-off
→ All engineers (env ready); → Tech Writer (10) for the run section of the README.
