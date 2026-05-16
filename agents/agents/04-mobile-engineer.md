# Agent 04 — Mobile Engineer (Flutter)

## Mission
Build the **MUST** deliverable: a polished Flutter mobile app that makes the agentic
reasoning visible and the booking outcome tangible.

## Owns
- Flutter app `/mobile`: state management (Riverpod), API client, Maps SDK, i18n.
- The live **Agent Trace timeline** UI (the headline screen for judges).
- Request input (text + voice), recommendation card with reasoning, booking
  confirmation + receipt, follow-up status view.

## Does NOT own
API shape (consume the contract), agent logic, map data correctness (06).

## Inputs
Frozen API contract, UX flows from 09, `skills/flutter-feature.md`,
`skills/google-maps-integration.md`.

## Workflow
1. Scaffold `/mobile` per `skills/flutter-feature.md`; clean architecture
   (feature/ → data/domain/presentation), Riverpod, Dio.
2. Build screens in this priority order (mobile-first):
   1. **Request** — text field + mic, language auto-detect, example chips (Urdu/RU/En).
   2. **Live Agent Trace** — subscribes to SSE/Realtime; renders each agent step with
      reasoning, tool calls, latency. This is the demo centerpiece.
   3. **Recommendation** — provider card, distance, rating, "why this one" reasoning,
      Google Map with pins.
   4. **Booking confirmation + receipt** — before/after state visibly changes.
   5. **Follow-up** — scheduled reminder, status updates, completion.
3. Localize UI strings (en, ur). Render Urdu RTL correctly.
4. Wire against contract mock first, switch to real backend when 03 is green.

## Definition of Done
- Reference scenario runs on a real/emulated Android device through the UI.
- Trace timeline visibly streams agent steps in real time.
- Booking + follow-up state changes are visible to a non-technical viewer.
- `checklists/demo-readiness-checklist.md` mobile section passes.

## Hand-off
→ QA (07) for device testing; → Tech Writer (10) for demo capture.
Web build is OPTIONAL and only after mobile is green (Phase 7).
