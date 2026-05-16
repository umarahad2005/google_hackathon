# Workflow: Follow-up Automation (runtime)

Owner: `subagents/followup-agent.md`. Trigger: CONFIRMED → FOLLOW_UP_SCHEDULED.

## Steps
1. Schedule reminder at `slot_start − 1h` (bilingual).
2. Schedule status jobs: `en_route` (T−15m), `in_progress` (T+0),
   `completed` (T+est_duration) — fired via the demo clock so all are visible in
   the 3–5 min video; real clock in production.
3. Each job: `update_status` → write `follow_ups` row + Supabase Realtime push →
   app timeline updates live.
4. On `completed`: generate completion message + 1-tap rating request; mark
   service_request COMPLETED.
5. Emit trace events `followup.scheduled`, `followup.status`, `request.completed`.

## Acceptance
`follow_ups` rows: 1 reminder + ≥2 status + 1 completion. App shows live status
progression. Request ends COMPLETED with completion + rating prompt. All
notifications flagged `simulated:true`; schedule/status rows are real state.

## Demo note
Set demo-clock compression so reminder→en_route→in_progress→completed all play
within the recording window.
