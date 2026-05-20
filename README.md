# 🧠 Zimma AI — Agentic Service Orchestrator

> **ذمہ** (Zimma) — *"I take charge of it."*
>
> An AI system that takes responsibility for connecting users in Pakistan's
> informal economy with service providers — from a spoken/typed request, to a
> ranked recommendation, to a booking, to follow-up — through a transparent,
> fully-traced multi-agent pipeline.

[![Flutter](https://img.shields.io/badge/Client-Flutter-02569B)]()
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688)]()
[![Gemini](https://img.shields.io/badge/LLM-Gemini%202.5%20(Vertex)-purple)]()
[![Supabase](https://img.shields.io/badge/Data-Supabase%20%2B%20PostGIS-3ECF8E)]()
[![Maps](https://img.shields.io/badge/Geo-Google%20Maps%20Platform-EA4335)]()

---

## 1. Repository Layout (read this first)

The project is **two repositories**:

| Repo | Path | What it is |
|------|------|-----------|
| **Client** (this repo) | `D:\google_hack` | Flutter app (mobile + web). No backend code lives here. |
| **Backend** | `D:\google_hackathon_backend` | FastAPI service: the agent pipeline, Maps/Supabase integration, SSE trace. |

The `agents/` folder **in this repo is documentation only** — the original
build-time agent specs, workflows, skills, and plans. The runtime agents live
in the backend repo under `app/agents/`.

> Deep design, the full agent pipeline, the state machine, and the
> mock-vs-real matrix are in **[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)**.
> This README is the overview + how to run it.

---

## 2. What It Does

A user speaks or types a request in **Urdu, Roman Urdu, English, or mixed**
(e.g. *"Mujhe Mansoorah home Lahore mein electrician chahiye abhi"*). The AI
then autonomously:

1. **Understands** the intent — multilingual NLU (service type, location, time, urgency).
2. **Discovers** nearby providers — Google Places + a seeded Supabase/PostGIS pool.
3. **Ranks** them with deterministic scoring and LLM-written, number-cited reasoning.
4. **Calls & books** the best match — a real state change persisted to the database.
5. **Follows up** — reminder, en-route, in-progress, completed, rating request.

Every step streams to the app **live** as a trace timeline — the user watches
the AI think, including which external tools it called and why.

---

## 3. Architecture at a Glance

```
┌──────────────────────── Flutter App (mobile + web) ─────────────────────────┐
│  Onboarding → Auth → Shell( Dashboard · New · History · Profile )            │
│  Request → Trace (live SSE) → Recommendation → Booking → Follow-up           │
│  State: Riverpod   ·   Transport: Dio (+ Supabase JWT)   ·   Auth: Supabase  │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                     │  HTTPS  +  SSE (text/event-stream)
                                     │  Authorization: Bearer <supabase jwt>
┌────────────────────────────────────▼─────────────────────────────────────────┐
│                      FastAPI Backend  (port 8000)                             │
│                                                                               │
│   Orchestrator  (hub-and-spoke state-machine driver)                          │
│        │                                                                      │
│        ├─ Intent/NLU Agent      (Gemini 2.5 Flash)                            │
│        ├─ Provider Discovery    (Google Places + Supabase PostGIS merge)      │
│        ├─ Ranking & Decision    (deterministic score + Gemini 2.5 Pro why)    │
│        ├─ Vendor Agent          (simulated outbound call, deterministic)      │
│        ├─ Booking Agent         (REAL Supabase row + simulated SMS/WhatsApp)  │
│        └─ Follow-up Agent       (simulated notifications, compressed clock)   │
│                                                                               │
│   Trace Observer → every agent/tool call → `agent_traces` (gap-free seq)      │
│                                                                               │
│   Services:  Google Maps (Geocoding · Places · Distance Matrix)               │
│              Supabase (Postgres + PostGIS + Realtime + Auth)                   │
└───────────────────────────────────────────────────────────────────────────────┘
```

**Topology:** hub-and-spoke. The Orchestrator owns the request context and the
state machine; no sub-agent calls another — all routing is centralized. A
cross-cutting Trace Observer wraps every agent and tool call.

**State machine:**

```
NEW → UNDERSTANDING → DISCOVERING → RANKING → RECOMMENDED
    → BOOKING → CONFIRMED → FOLLOW_UP_SCHEDULED → COMPLETED
        ↘ CLARIFY      ↘ NO_PROVIDER        ↘ FAILED
```

---

## 4. Mock vs. Real — be honest about it

| Capability | Status | How it's decided |
|---|---|---|
| **Gemini LLM** (intent, ranking reasoning) | **REAL** | Vertex AI, project `zimmaai` / `us-central1`, service-account auth. Falls back through a model chain on rate-limit. |
| **Google Maps Geocoding / Places / Distance Matrix** | **REAL** | Used when `GOOGLE_MAPS_API_KEY` is set and valid. |
| **Offline sector gazetteer** | **FALLBACK (degraded)** | Hard-coded Islamabad/Rawalpindi sector coords used only if Maps is absent/fails. The step is flagged `degraded:true`. |
| **Supabase Postgres + PostGIS** | **REAL** | Service requests, bookings, follow-ups, traces, providers, availability are all persisted. The booking is a genuine DB state change. |
| **Supabase Auth (JWT)** | **REAL** | Client signs in (email/pass or Google); backend verifies the bearer token. |
| **Vendor outbound phone call** | **SIMULATED** | Always simulated, but deterministic (no RNG) and traced as a real two-sided decision. Flagged `simulated:true`. |
| **SMS / WhatsApp confirmation** | **SIMULATED** | Bilingual message is drafted and persisted; send is flagged `simulated:true`. |
| **Follow-up notifications** | **SIMULATED** | Reminder/status/rating events are real DB+trace state changes; the *send* is simulated. Timeline compressed by a demo-clock multiplier. |

The trace makes this transparent: every event carries `degraded` and
`simulated` flags and a non-empty `reasoning`. See the full table and the
decision logic in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## 5. The Flutter Client (this repo)

### 5.1 Stack

| Concern | Choice |
|---|---|
| State management | `flutter_riverpod` |
| HTTP transport | `dio` (typed `ZimmaApi`, bearer-injected) |
| Auth | `supabase_flutter` (email/password + Google OAuth) |
| Voice input | `speech_to_text` |
| Localization | `flutter_localizations` + `intl` (en, ur) |
| Motion / UI | `flutter_animate`, `google_fonts`, custom 3D/glass theme |

### 5.2 Layout

```
lib/
├── main.dart                  # Supabase.initialize → AuthGate
├── core/
│   ├── network/
│   │   ├── dio_client.dart     # base URL + Supabase JWT interceptor
│   │   └── api_exception.dart  # single typed error
│   ├── supabase_config.dart    # URL / anon key (dart-define overridable)
│   ├── theme.dart              # the "Salmon & Sage" dark design system
│   └── ui/                     # reusable primitives (DepthCard, GlassPanel…)
├── data/
│   ├── models/                 # immutable models + JSON (ServiceRequest, …)
│   ├── zimma_api.dart          # typed transport over the FastAPI backend
│   └── zimma_repository.dart   # repository the providers consume
├── providers/                  # Riverpod
│   ├── auth_controller.dart
│   ├── request_controller.dart
│   ├── trace_controller.dart   # SSE + polling fallback (session-persistent)
│   ├── followup_controller.dart
│   ├── data_providers.dart
│   └── core_providers.dart
├── features/
│   ├── onboarding/  splash/  auth/
│   ├── shell/                  # 4-tab shell: Dashboard · New · History · Profile
│   ├── request/                # multilingual text/voice input
│   ├── trace/                  # HERO screen — live agent timeline
│   ├── recommendation/         # provider card + score breakdown + reasoning
│   ├── booking/                # confirmation + receipt card
│   ├── followup/               # live lifecycle status
│   ├── history/  settings/  dashboard/
└── l10n/                       # en + ur
```

### 5.3 Backend endpoints the client uses

| Method | Path | Used by |
|---|---|---|
| `POST` | `/api/requests` | Request screen — create request |
| `GET` | `/api/requests/{id}/trace` | Trace screen — SSE stream of agent steps |
| `GET` | `/api/requests/{id}` | Trace/polling fallback — final result |
| `POST` | `/api/requests/{id}/confirm` | Recommendation — accept / pick alternative |
| `GET` | `/api/bookings/{id}/receipt` | Booking screen — receipt |
| `GET` | `/api/requests` | History tab |
| `GET` / `PATCH` | `/api/profile` | Settings/Profile |
| `GET` | `/health` | connectivity check |

### 5.4 Live trace delivery (resilient by design)

`trace_controller.dart` opens the SSE stream **and** runs a polling fallback
in parallel, so a dropped stream never strands the screen. The provider is a
**session-persistent** `NotifierProvider.family` (deliberately *not*
autoDispose): leaving the status screen and coming back — or reopening from
History — **resumes the existing timeline instead of restarting the pipeline**.

---

## 6. Running It

### 6.1 Prerequisites
- Flutter SDK (stable), Dart 3+
- A running backend (the sibling repo, or the hosted default)
- Supabase project (for auth) and its URL + anon key
- For the backend: Python 3.11+, Google Maps key, Gemini/Vertex credentials, Supabase service key

### 6.2 Client — local

```bash
flutter pub get

# Point at a local backend (Android emulator uses 10.0.2.2 for host loopback):
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Or just run against the hosted default backend:
flutter run
```

Supabase URL/anon key have working defaults baked into `supabase_config.dart`;
override with `--dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…`
if you use your own project.

### 6.3 Client — web on Vercel

`vercel.json` is committed. It:
- builds Flutter web (clones stable Flutter at build time, `flutter build web --release`),
- serves `build/web`,
- rewrites all routes to `/index.html` (SPA — refreshes & OAuth return don't 404).

**Required Supabase dashboard config** for OAuth to work off-localhost
(Authentication → URL Configuration):

1. **Site URL** → your production URL (e.g. `https://your-app.vercel.app`).
2. **Redirect URLs** → add every origin you serve from:
   - `https://your-app.vercel.app/**`
   - `http://localhost:<dev-port>/**`
   - preview pattern, e.g. `https://*-yourproject.vercel.app/**`
3. Google Cloud OAuth client → ensure
   `https://<your-project>.supabase.co/auth/v1/callback` is an authorized redirect URI.

On web the client now sends `redirectTo: Uri.base.origin`, so OAuth returns to
the origin it was actually served from (this fixed the old "callback bounces to
:3000" bug — Supabase was falling back to its dashboard Site URL).

### 6.4 Backend (sibling repo, summary)

```bash
cd ../google_hackathon_backend
pip install -r requirements.txt
cp .env.example .env          # fill Maps / Vertex / Supabase keys
fastapi run main.py           # serves on :8000  (fastapi dev for reload)
```

DB migrations and the provider seed script live in the backend repo. See its
own README and [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the agent
internals, prompts, and config keys.

---

## 7. Multilingual & Location Handling

| Input style | Example |
|---|---|
| Roman Urdu | "Mujhe kal subah G-13 mein AC technician chahiye" |
| Urdu script | "مجھے کل صبح G-13 میں AC ٹیکنیشن چاہیے" |
| English | "I need a plumber in I-8 urgently" |
| Mixed + other city | "Mansoorah home Lahore mein electrician chahiye abhi" |

The Intent/NLU agent normalizes Roman-Urdu spelling variants and time phrases,
and **preserves the city the user actually named**. Geocoding is **city-aware**:
it no longer force-appends "Islamabad" to every query, biases results to
Pakistan (`region=pk`), and skips the Islamabad-only gazetteer for other
cities — so "Mansoorah home Lahore" resolves in Lahore, not Blue Area
Islamabad. (See the recent-fixes note in `docs/ARCHITECTURE.md`.)

---

## 8. Documentation Index

| Doc | Contents |
|---|---|
| **[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)** | Full design: agent-by-agent breakdown, orchestrator state machine, trace contract, LLM/Vertex config, integration details, complete mock-vs-real matrix, recent fixes. |
| `agents/` (this repo) | Original build-time specs, workflows, skills, plans (historical/reference). |
| Backend repo `app/agents/prompts/` | The live system prompts (e.g. `intent.txt`). |

---

Built for the Google Antigravity Hackathon 2026.
