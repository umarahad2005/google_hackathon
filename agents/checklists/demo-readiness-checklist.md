# Demo Readiness Checklist

Run on the exact device + network used for the recording.

## Environment
- [ ] `make demo` resets DB, seeds, starts backend cleanly
- [ ] Maps + Gemini keys valid and within quota; fallback path also verified
- [ ] Demo clock compression on so follow-up lifecycle plays in < 5 min

## Mobile
- [ ] App launches; reference message entered by text AND voice
- [ ] Live agent-trace timeline streams each step with reasoning + latency
- [ ] Recommendation card shows distance, rating, map pins, "why this one"
- [ ] Booking confirmation + receipt: state change is unmistakable
- [ ] Follow-up status visibly progresses to completed
- [ ] Urdu RTL screen looks correct (no clipped text)

## Story (3–5 min)
- [ ] Beat 1 input → Beat 2 understanding → Beat 3 matching → Beat 4 ranked
      recommendation + reasoning → Beat 5 booking + receipt → Beat 6 follow-up
- [ ] Antigravity Workplan/Tasks Plan shown briefly as "how it was built + run"
- [ ] One edge case shown (no provider OR ambiguous intent clarify)

## Backup
- [ ] Recorded fallback clip in case of live network failure
- [ ] Seeded DB snapshot so the demo is deterministic

All checked → cleared for recording.
