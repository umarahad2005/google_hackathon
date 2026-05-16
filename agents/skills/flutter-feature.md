# Skill: Flutter Feature

Used by Mobile (04). Mobile app is the MUST deliverable.

## Stack
- Flutter (stable), Riverpod (state), Dio (HTTP), `google_maps_flutter`,
  `flutter_localizations` + ARB (en, ur), `speech_to_text` (voice input).

## Layout (clean architecture, feature-first)
```
mobile/lib/
  core/        # api client, theme, l10n, env
  features/
    request/   { data/ domain/ presentation/ }
    trace/     # live agent timeline (the hero screen)
    recommendation/
    booking/
    followup/
```

## The hero: live agent-trace timeline
- Open SSE (`/requests/{id}/trace`) or Supabase Realtime on submit.
- Each `TraceEvent` → an animated card: agent icon, step, one-line `reasoning`,
  tool chips, latency, degraded/simulated badges.
- This screen is what wins Antigravity 25% + agentic 20% — make "thinking" visible.

## Screen priority (build in this order)
1. Request (text + mic, language chips, examples incl. the reference message)
2. Live trace timeline
3. Recommendation card (distance, rating, "why this one", map with pins)
4. Booking confirmation + receipt sheet (clear before→after state shift)
5. Follow-up status (live progression to completed + rating)

## Rules
- Localize all strings (ARB); Urdu renders RTL — test for clipping.
- Wire against a contract mock first; flip to real backend when 03 is green.
- No business logic in widgets; keep it in Riverpod notifiers/repositories.
- DoD: reference scenario runs through the UI on a real/emulated Android device.
