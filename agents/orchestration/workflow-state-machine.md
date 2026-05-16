# Runtime State Machine — One Service Request

This is the lifecycle of a single user request inside Zimma AI. The Orchestrator
Agent owns this state and writes a trace event on every transition.

```
NEW
 │  user message received (POST /requests)
 ▼
UNDERSTANDING ──(intent ambiguous)──▶ CLARIFY ──(user replies)──┐
 │  Intent/NLU extracted ok                                     │
 ▼ ◀────────────────────────────────────────────────────────────┘
DISCOVERING
 │  Provider Discovery returns ≥1 candidate
 │  └─(0 candidates)──▶ NO_PROVIDER (graceful message + widen radius retry once)
 ▼
RANKING
 │  Ranking & Decision produces ordered list + reasoning
 ▼
RECOMMENDED  ──(user rejects / picks other)──▶ RANKING (re-rank with constraint)
 │  user (or auto-confirm in demo) accepts top provider
 ▼
BOOKING
 │  Booking Agent simulates slot booking
 │  └─(slot conflict)──▶ RANKING (next provider) or RECOMMENDED (new slot)
 ▼
CONFIRMED       booking row + receipt written to Supabase; confirmation message generated
 │
 ▼
FOLLOW_UP_SCHEDULED   reminder (T-1h), status checks, completion confirmation queued
 │
 ▼
COMPLETED       follow-up completion confirmed; request closed
```

## Transition contract

| From → To | Trigger | Guard | Trace event |
|---|---|---|---|
| NEW → UNDERSTANDING | request created | valid text/audio | `intent.start` |
| UNDERSTANDING → CLARIFY | low confidence on service/location/time | conf < 0.6 | `intent.clarify` |
| UNDERSTANDING → DISCOVERING | all required slots filled | conf ≥ 0.6 | `discovery.start` |
| DISCOVERING → NO_PROVIDER | empty candidate set after retry | radius maxed | `discovery.empty` |
| DISCOVERING → RANKING | candidates ≥ 1 | — | `ranking.start` |
| RANKING → RECOMMENDED | scored & ordered | top score valid | `decision.recommend` |
| RECOMMENDED → BOOKING | accept | provider available | `booking.start` |
| BOOKING → CONFIRMED | slot simulated | no conflict | `booking.confirmed` |
| CONFIRMED → FOLLOW_UP_SCHEDULED | persisted | row exists | `followup.scheduled` |
| FOLLOW_UP_SCHEDULED → COMPLETED | completion confirmed | — | `request.completed` |

## State persistence

State + every trace event lives in Supabase. The Flutter app subscribes via Supabase
Realtime to render the live timeline. The state column is the demo's "before vs
after" evidence: judges see it move NEW → COMPLETED with system-state changes.

## Error & timeout policy

- Any agent failure → Orchestrator catches, writes `error` trace, attempts the
  documented fallback (retry once / widen radius / next provider). After fallback
  exhaustion → state `FAILED` with a human-readable reason. Never crash silently.
