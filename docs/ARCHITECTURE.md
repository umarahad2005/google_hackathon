# Zimma AI — Architecture & Implementation

Deep design document. Companion to the top-level [`README.md`](../README.md).
This explains *how* the system is built: the agent pipeline, the orchestration
state machine, the trace contract, every external integration, what is real vs.
simulated and why, the Flutter client implementation, and the recent fixes.

> **Two repos.** Client = this repo (`D:\google_hack`, Flutter). Backend =
> `D:\google_hackathon_backend` (FastAPI). File paths below are relative to the
> repo named in the heading.

---

## 1. Design Goals

1. **Autonomy with accountability.** The system *acts* (it books), but every
   decision and every external effect is recorded and explainable.
2. **Traceability is a first-class feature, not logging.** The trace is the
   product surface — the user watches the AI reason in real time.
3. **Degrade honestly.** If a real API is unavailable, fall back, but *say so*
   in the trace (`degraded` / `simulated`), never fabricate.
4. **Multilingual, location-correct.** Pakistan informal-economy users speak
   Urdu/Roman-Urdu/English and live in many cities — the pipeline must not
   silently assume Islamabad.

---

## 2. Topology — Hub-and-Spoke

```
                       ┌────────────────────┐
                       │    Orchestrator    │  owns RequestContext
                       │  (state machine)   │  + the state machine
                       └─────────┬──────────┘
        ┌───────────┬────────────┼────────────┬───────────┬───────────┐
        ▼           ▼            ▼            ▼           ▼           ▼
   Intent/NLU   Discovery     Ranking      Vendor      Booking    Follow-up
     Agent       Agent         Agent       Agent        Agent       Agent
        └───────────┴────────────┴────────────┴───────────┴───────────┘
                                  │
                       ┌──────────▼───────────┐
                       │   Trace Observer     │  wraps every agent + tool call
                       │  emit → agent_traces │  gap-free seq, Realtime + SSE
                       └──────────────────────┘
```

**Rule:** sub-agents never call each other. The Orchestrator is the only router.
This keeps the decision path linear and the trace a faithful, replayable story.

Backend files: `app/agents/orchestrator.py`, `intent_agent.py`,
`discovery_agent.py`, `ranking_agent.py`, `vendor_agent.py`,
`booking_agent.py`, `followup_agent.py`, `trace_observer.py`, `config.py`,
`gemini.py`; prompts in `app/agents/prompts/`.

---

## 3. The Orchestration State Machine

```
NEW
 └─ UNDERSTANDING        intent_agent → ServiceIntent
     ├─ CLARIFY          (a required slot is missing/low-confidence)
     └─ DISCOVERING      discovery_agent → candidate providers
         ├─ NO_PROVIDER  (nothing within radius, even after retry)
         └─ RANKING      ranking_agent → ordered list + reasoning
             └─ RECOMMENDED   (waits for user confirm)
                 └─ BOOKING        vendor_agent (call) → booking_agent (reserve)
                     ├─ FAILED     (vendor declined / no slot after attempts)
                     └─ CONFIRMED  real Supabase booking row written
                         └─ FOLLOW_UP_SCHEDULED  followup_agent arms timeline
                             └─ COMPLETED
```

The Orchestrator persists the state on each transition and emits **≥1 trace
event per transition**. The client's state, derived from `request.state`,
decides which screen to show — which is why reopening a request from History
lands the user where they left off (the server is the source of truth).

---

## 4. Agents — Development & Implementation

Each agent is a small, single-responsibility unit. Where an agent uses the LLM
it does so through `app/agents/gemini.py`, which handles Vertex auth and the
model fallback chain.

### 4.1 Intent / NLU Agent — `intent_agent.py`
- **Job:** raw multilingual message → structured `ServiceIntent`
  (`service_type`, `location_text`, `time_*`, `urgency`, `confidence`,
  `missing[]`, `language`, `reasoning`).
- **Model:** Gemini 2.5 **Flash** (fast, cheap, routing-class).
- **Prompt:** `app/agents/prompts/intent.txt` — service taxonomy, time
  normalization (Asia/Karachi), Roman-Urdu spelling normalization, a
  **Location Extraction (CRITICAL)** section, few-shot examples (incl. a
  non-Islamabad Lahore example), and hard rules ("never invent a slot",
  "keep the user's city verbatim").
- **Output discipline:** if any required slot is low-confidence it goes in
  `missing[]` → Orchestrator branches to `CLARIFY` rather than guessing.

### 4.2 Provider Discovery Agent — `discovery_agent.py`
- **Job:** `ServiceIntent` → list of `ProviderCandidate`.
- **Mechanics:** radius by urgency (now→3km, today→6km, scheduled→10km);
  retries once at **2× radius** if the first pass is empty; sets `degraded`
  when it had to fall back.
- **Data source:** `app/services/maps.py::find_candidates()` merges:
  - **Google Places (New)** nearby results (real), and
  - **Supabase/PostGIS** seeded providers within radius (real),
  deduplicated (drops near-identical points within ~200 m).

### 4.3 Ranking & Decision Agent — `ranking_agent.py`
- **Scoring is deterministic** (auditable, reproducible):
  `distance 40% · availability 25% · rating 25% · price 10%`.
- **Reasoning is LLM-written** (Gemini 2.5 **Pro**): 2–3 sentences that
  **cite the actual numbers** and explicitly say why #1 beat #2 — no generic
  praise (enforced by the prompt).
- Distances are upgraded from haversine to **real driving distance** via
  Google Distance Matrix when available; otherwise haversine is kept
  (never fabricated).

### 4.4 Vendor Agent — `vendor_agent.py`
- **Simulated** outbound call, but **deterministic** (no RNG): decision ∈
  {`accepted`, `declined`}; e.g. a provider with rating < 3.0 is a red flag.
- The decision is a *real* two-sided state change in the request, fully traced
  with `simulated:true`.

### 4.5 Booking Agent — `booking_agent.py`
- **Real:** writes the booking row to Supabase (genuine persisted state change)
  and produces a receipt.
- **Simulated:** the bilingual (Urdu/English) SMS/WhatsApp confirmation —
  drafted and stored, send flagged `simulated:true`.

### 4.6 Follow-up Agent — `followup_agent.py`
- Arms a lifecycle: reminder (T-1h) → `en_route` → `in_progress` →
  `completed` → rating request.
- Each transition is a real DB + trace state change; the *notification send*
  is simulated.
- Uses a **demo-clock multiplier** (`DEMO_CLOCK_MULTIPLIER`) so a multi-hour
  job plays out in demo-time seconds.

### 4.7 Trace Observer — `trace_observer.py`
- `TraceContext` async context-manager wraps every agent/tool call.
- `emit_trace()` allocates an atomic monotonic `seq` (DB RPC), inserts into
  the `agent_traces` table; Supabase Realtime + the SSE endpoint stream it out.

---

## 5. The Trace Contract

Every emitted event carries:

| Field | Invariant |
|---|---|
| `reasoning` | **Never empty** — explains *why*, not just *what*. |
| `seq` | Strictly increasing, **gap-free per `request_id`**. |
| `tool_calls` | One entry per external effect (Maps, DB, simulated send…). |
| `degraded` | `true` whenever a fallback path was taken. |
| `simulated` | `true` whenever an external send was simulated. |
| `latency_ms` | Wall-clock duration of the step. |

**Enforced invariants:** (1) every state transition has ≥1 event; (2) no empty
reasoning; (3) gap-free `seq`; (4) every external effect has a `tool_call`;
(5) replaying events in `seq` order reconstructs the full decision story.

**Delivery is dual-channel and resilient.** The backend exposes
`GET /api/requests/{id}/trace` as Server-Sent Events; Supabase Realtime backs
it. The client subscribes to SSE **and** polls `GET /api/requests/{id}` in
parallel, so a dropped stream never strands the UI.

---

## 6. LLM Configuration (Vertex AI)

- **Models:** `gemini-2.5-flash` (intent/routing), `gemini-2.5-pro`
  (ranking reasoning). *Only `gemini-2.5-*` models are available on the
  configured Vertex project/region.*
- **Auth:** Vertex AI, project `zimmaai`, location `us-central1`,
  **service-account** credentials (Vertex Express API key path is disabled by
  org policy). Configured in `app/settings.py` / `app/agents/gemini.py`.
- **Resilience:** comma-separated fallback chains — on rate-limit/quota the
  client automatically advances to the next model
  (flash → flash-lite → pro, and a pro chain).
- **Config key names** (values via `.env`, never committed):
  `GEMINI_USE_VERTEX`, `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`,
  `GOOGLE_SERVICE_ACCOUNT_JSON` / `GOOGLE_APPLICATION_CREDENTIALS`,
  `GEMINI_FLASH_MODEL`, `GEMINI_PRO_MODEL`, `GEMINI_FLASH_FALLBACKS`,
  `GEMINI_PRO_FALLBACKS`, plus `GOOGLE_MAPS_API_KEY`, `SUPABASE_URL`,
  `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY`, `DEMO_CLOCK_MULTIPLIER`,
  `BACKEND_HOST`, `BACKEND_PORT`.

---

## 7. External Integrations

### 7.1 Google Maps Platform — `app/services/maps.py`
- **Geocoding** (location text → lat/lng), **Places (New)** (nearby providers),
  **Distance Matrix** (driving distance/ETA).
- **Gazetteer fallback:** a hard-coded table of Islamabad/Rawalpindi sector
  coordinates, used **only** when Maps is absent/fails. Steps that use it are
  flagged `degraded`.
- **City-aware resolution (post-fix, see §9):** the geocoder detects a
  Pakistani city in the text; if present it geocodes the text as-is with
  `region="pk"` + `components={"country":"PK"}` instead of force-appending
  `", Islamabad, Pakistan"`. The Islamabad-only gazetteer is **skipped** for
  other cities (a wrong-city result is worse than an honest `degraded` fail).

### 7.2 Supabase — `app/services/supabase.py`
- **Postgres + PostGIS.** Tables: service requests, bookings, follow-ups,
  `agent_traces`, providers, availability. PostGIS powers the
  "providers within radius" spatial query.
- **Realtime** backs the live trace channel.
- **Service-role key** is server-side only; the client never sees it.

### 7.3 Supabase Auth (client ↔ backend)
- The Flutter client signs in via Supabase (email/password or Google OAuth)
  and attaches the JWT as `Authorization: Bearer …` on every request
  (`lib/core/network/dio_client.dart`). The backend verifies it; identity
  comes from the token, not the request body.

---

## 8. Flutter Client Implementation Notes

- **State:** Riverpod. Key controllers in `lib/providers/`:
  - `request_controller.dart` — submits a request, hands off `requestId`.
  - `trace_controller.dart` — owns the live-trace lifecycle: SSE stream +
    parallel polling fallback + final-result load. **Session-persistent**
    (`NotifierProvider.family`, *not* autoDispose) so navigating back from the
    status screen or reopening from History **resumes** instead of restarting
    the pipeline. A `_started`/`isComplete` guard prevents re-streaming a
    finished request.
  - `followup_controller.dart` — polls the follow-up lifecycle.
- **Transport:** `lib/data/zimma_api.dart` is the single typed surface over the
  FastAPI backend; every method returns a model and throws one `ApiException`.
- **Navigation:** the request funnel (Trace → Recommendation → Booking →
  Follow-up) pushes as full routes over a 4-tab shell
  (Dashboard · New · History · Profile) and returns to it.
- **Web/Vercel:** `vercel.json` builds Flutter web and SPA-rewrites to
  `index.html`. On web, Google OAuth uses `redirectTo: Uri.base.origin` so it
  returns to the actual serving origin (see §9).

---

## 9. Recent Fixes (changelog)

These were applied across both repos; deploy the backend for the geocoding /
prompt changes to take effect on the hosted app.

1. **City-aware geocoding** — `backend/app/services/maps.py`
   `resolve_location()`. Stopped force-appending `", Islamabad, Pakistan"` to
   every query; added a `PK_CITIES` detector + `DEFAULT_CITY_CONTEXT`; geocode
   now uses `region="pk"` + country component; the Islamabad/Rawalpindi
   gazetteer is skipped when the user named another city. Fixes
   *"Mansoorah home Lahore" → Blue Area, Islamabad*.

2. **Stronger intent prompt** — `backend/app/agents/prompts/intent.txt`. Added
   a *Location Extraction (CRITICAL)* section, a Lahore few-shot example, and a
   rule that `location_text` must keep the user's city verbatim and never
   default to Islamabad.

3. **Session-persistent pipeline state** — `lib/providers/trace_controller.dart`.
   Changed from `NotifierProvider.autoDispose.family` to
   `NotifierProvider.family` with a start guard. Leaving the service-status
   screen and returning (or reopening from History) now resumes the existing
   timeline instead of replaying the whole agent pipeline.

4. **Web OAuth callback** — `lib/features/auth/auth_screen.dart`. On web,
   `redirectTo` is now `Uri.base.origin` instead of `null` (which made
   Supabase fall back to its dashboard Site URL, default `localhost:3000`,
   breaking the callback off-localhost). Added `vercel.json` (Flutter web
   build + SPA rewrites). Requires the Supabase Redirect-URL allowlist entries
   listed in the README §6.3.

---

## 10. Glossary

| Term | Meaning |
|---|---|
| **Degraded** | A real API was unavailable and a fallback (e.g. gazetteer) was used. Surfaced in the trace. |
| **Simulated** | An external *send* (call/SMS/notification) was not actually dispatched, but the resulting state change and trace are real. |
| **Gazetteer** | Hard-coded Islamabad/Rawalpindi sector → lat/lng table; offline geocoding fallback. |
| **Demo clock** | Multiplier compressing the follow-up lifecycle so hours of service play out in demo seconds. |
| **Trace** | The ordered, gap-free, reasoning-bearing event stream that is the product's hero surface. |
