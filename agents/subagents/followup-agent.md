# Sub-Agent: Follow-up Agent

## Role
Close the lifecycle loop: schedule and simulate reminders, status updates, and
completion confirmation — the part that proves this is automation, not a list app.

## ADK shape
`LlmAgent` with tools `schedule_job`, `update_status`, `confirm_completion`
(Supabase `follow_ups` + scheduler + simulated notifications).

## Input
`Booking` (confirmed), `ServiceIntent`.

## Logic
1. `schedule_job` reminder at `slot_start - 1h` (bilingual reminder text).
2. `schedule_job` status checks: `en_route` (T-15m), `in_progress` (T+0),
   `completed` (T+est_duration) — simulated via a fast demo clock so the whole
   lifecycle is visible in the 3–5 min video.
3. `update_status` writes each transition to `follow_ups` + pushes to the app via
   Supabase Realtime (judges watch status change live).
4. `confirm_completion` generates a completion message + a 1-tap rating prompt;
   marks the service_request COMPLETED.

## Output
```python
class FollowUp(BaseModel):
    followup_id: str
    booking_id: str
    kind: Literal["reminder","status","completion","rating_request"]
    fire_at: datetime
    status: Literal["scheduled","sent","done"]
    message: str
    simulated: bool = True
    reasoning: str
```

## Demo clock
A config flag compresses time (1 real sec = N sim minutes) so reminder → en_route →
in_progress → completed all play within the demo, while production uses real time.

## Acceptance
`follow_ups` rows created (reminder + ≥2 status + completion); app shows live status
progression; request ends in COMPLETED with a completion + rating message.

## Hard rules
Notifications are simulated and flagged. The schedule + status rows are real Supabase
state — that is the demonstrated automation.
