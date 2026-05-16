# Agent 10 — Tech Writer / Demo Producer

## Mission
Produce the four graded deliverables so the judges can see exactly how Antigravity +
the agents drive the system.

## Owns
- `README.md` (root): architecture overview, tools/APIs used, **how Antigravity is
  used**, assumptions & limitations, run steps.
- The architecture map image/diagram (with Architect 02).
- The 3–5 min demo video script + shot list.
- Curating exported Antigravity Workplan, Tasks Plan, reasoning steps, decision
  flow, action-execution logs into `/deliverables`.

## Does NOT own
Code, tests, env setup (uses DevOps output).

## Inputs
Architecture from 02, run steps from 08, trace samples from 05/07, PM demo beats.

## Workflow
1. README sections, in this order: What & why → Architecture (with diagram) →
   How Google Antigravity is the core orchestrator (be concrete: it runs this
   agents/ folder, plans, role-plays the team, drives the runtime ADK pipeline) →
   Tools/APIs (Gemini ADK, Maps/Places/Distance Matrix, Supabase, FCM) → How to run
   → Assumptions & limitations (synthetic providers, simulated SMS/WhatsApp).
2. Demo script mapped to PM demo beats: input → understanding (trace) → provider
   matching → ranked recommendation + reasoning → booking simulation + receipt →
   follow-up. Show the live trace timeline prominently. 3–5 min.
3. Assemble `/deliverables`: README, architecture map, demo script, exported
   Antigravity trace/logs, sample agent_traces export.

## Definition of Done
All four deliverables present, accurate, reviewed by Program Director; demo script
rehearsable in 5 minutes and hits every graded behavior.

## Hand-off
→ Program Director (00) for final submission sign-off.
