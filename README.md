# 🧠 Zimma AI — Agentic AI Service Orchestrator

> **ذمہ** (Zimma) — *"I take charge of it."*
>
> An AI system that takes responsibility for connecting users in Pakistan's informal economy with service providers — from intent to booking to follow-up — through a transparent, traceable, multi-agent pipeline.

[![Challenge](https://img.shields.io/badge/Challenge-2%20AI%20Service%20Orchestrator-blue)]()
[![Gemini ADK](https://img.shields.io/badge/Gemini%20ADK-Multi--Agent-purple)]()
[![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B)]()
[![FastAPI](https://img.shields.io/badge/FastAPI-Backend-009688)]()
[![Supabase](https://img.shields.io/badge/Supabase-PostGIS-3ECF8E)]()

---

## 🎯 What It Does

Zimma AI is an **agentic service orchestrator** for Pakistan's informal economy. A user speaks or types a request in **Urdu, Roman Urdu, or English** — and the AI autonomously:

1. **Understands** the intent (multilingual NLU)
2. **Discovers** nearby providers (Google Maps + PostGIS)
3. **Ranks** them with transparent, cited reasoning
4. **Books** the best match (real state change in database)
5. **Follows up** with reminders, status updates, and completion confirmation

Every step is **fully traced** — the user watches the AI think in real-time through a live timeline.

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                     │
│  ┌──────────┐ ┌──────────┐ ┌────────┐ ┌──────────────┐ │
│  │ Request   │ │ Trace    │ │ Recom. │ │ Booking +    │ │
│  │ Screen    │ │ Timeline │ │ Screen │ │ Follow-up    │ │
│  └─────┬────┘ └────┬─────┘ └───┬────┘ └──────┬───────┘ │
│        │           │           │              │          │
│        └───────────┴───────────┴──────────────┘          │
│                         │ HTTP + SSE                     │
└─────────────────────────┼───────────────────────────────┘
                          │
┌─────────────────────────┼───────────────────────────────┐
│              FastAPI Backend (Port 8000)                  │
│                         │                                │
│  ┌──────────────────────▼──────────────────────────────┐│
│  │              🧠 ADK Orchestrator Agent               ││
│  │         (Hub-and-Spoke State Machine Driver)         ││
│  │                                                      ││
│  │  ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌─────────┐ ││
│  │  │Intent/  │ │Provider  │ │Ranking &│ │Booking  │ ││
│  │  │NLU Agent│ │Discovery │ │Decision │ │Agent    │ ││
│  │  │(Flash)  │ │Agent     │ │(Pro)    │ │         │ ││
│  │  └────┬────┘ └────┬─────┘ └────┬────┘ └────┬────┘ ││
│  │       │           │            │            │       ││
│  │  ┌────▼───────────▼────────────▼────────────▼────┐ ││
│  │  │           Trace / Observer (Callbacks)         │ ││
│  │  │     Every step → TraceEvent → Supabase         │ ││
│  │  └────────────────────────────────────────────────┘ ││
│  └─────────────────────────────────────────────────────┘│
│                         │                                │
│  ┌──────────────────────▼──────────────────────────────┐│
│  │                   Services Layer                     ││
│  │  ┌────────────┐  ┌──────────────┐                   ││
│  │  │Google Maps  │  │Supabase      │                   ││
│  │  │Places +     │  │PostGIS +     │                   ││
│  │  │Geocoding +  │  │Auth +        │                   ││
│  │  │Distance     │  │Realtime +    │                   ││
│  │  │Matrix       │  │Storage       │                   ││
│  │  └────────────┘  └──────────────┘                   ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### ADK Hub-and-Spoke Topology

- **Root Agent**: Orchestrator owns the `RequestContext` and state machine
- **Sub-Agents**: Intent/NLU, Discovery, Ranking, Booking, Follow-up
- **Routing Rule**: No sub-agent calls another — all routing centralized
- **Trace Observer**: Cross-cutting callbacks on every agent/tool execution

### State Machine

```
NEW → UNDERSTANDING → DISCOVERING → RANKING → RECOMMENDED → BOOKING → CONFIRMED → FOLLOW_UP_SCHEDULED → COMPLETED
         ↓                                        ↓
       CLARIFY                                   FAILED
         ↓
    NO_PROVIDER
```

---

## 📱 Screens

| # | Screen | Purpose |
|---|--------|---------|
| 1 | **Request** | Multilingual text/voice input with example prompts |
| 2 | **Trace Timeline** | Live SSE-streamed AI thinking with reasoning, tools, latency |
| 3 | **Recommendation** | Provider card with score breakdown bars + LLM reasoning |
| 4 | **Booking** | Bilingual confirmation + receipt + AI reasoning |
| 5 | **Follow-up Status** | Live lifecycle: reminder → en_route → completed → rating |

---

## 🛠 Tech Stack

| Layer | Technology | Role |
|-------|-----------|------|
| Mobile | **Flutter** (Dart) | 5-screen app with Riverpod state |
| Backend | **FastAPI** (Python) | REST + SSE, background ADK pipeline |
| AI/LLM | **Gemini ADK** | Multi-agent orchestration |
| Models | `gemini-2.0-flash` / `gemini-2.5-pro` | Flash for routing, Pro for reasoning |
| Geo | **Google Maps Platform** | Places, Geocoding, Distance Matrix |
| Database | **Supabase** (Postgres + PostGIS) | Spatial queries, Realtime, Auth |
| Trace | **Supabase Realtime + SSE** | Dual-channel live trace delivery |

---

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- Flutter SDK 3.11+
- Supabase project (free tier)
- Google Maps API key
- Gemini API key

### 1. Clone & Setup

```bash
git clone <repo-url>
cd google_hackathon
```

### 2. Backend

```bash
cd backend
python -m venv venv
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Environment Variables

```bash
cp .env.example .env
# Edit .env with your real API keys
```

### 4. Database Setup

Run the SQL migrations in your Supabase SQL Editor:
1. `infra/migrations/001_initial_schema.sql`
2. `infra/migrations/002_rpc_functions.sql`

Then seed the database:
```bash
cd backend
python -m scripts.seed
```

### 5. Run Backend

```bash
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 6. Run Flutter App

```bash
flutter pub get
flutter run
```

### 7. Headless Reference Run (Optional)

```bash
cd backend
python -m scripts.run_reference
```

---

## 🔍 Traceability (25% + 20% of Score)

Every agent and tool call emits a `TraceEvent` with:

| Field | Rule |
|-------|------|
| `reasoning` | **Never empty** — explains *why*, not just *what* |
| `seq` | Gap-free, strictly increasing per request |
| `tool_calls` | Every external effect recorded |
| `degraded` | `true` if a fallback was used |
| `simulated` | `true` if external send was simulated |
| `latency_ms` | Wall-clock time of the step |

### Trace Invariants (enforced by QA)

1. Every state-machine transition has ≥1 trace event
2. No trace event has empty `reasoning`
3. `seq` is gap-free per `request_id`
4. Each external effect has a `tool_call` entry
5. Reading by `seq` reconstructs the full decision story

---

## 📁 Project Structure

```
google_hackathon/
├── agents/                  # Build-time org + runtime specs
│   ├── PROJECT_BRIEF.md
│   ├── ORG_CHART.md
│   ├── orchestration/       # Phase gates, state machine
│   ├── subagents/           # Runtime agent specs
│   ├── workflows/           # wf-01..wf-05
│   ├── skills/              # Tech skill guides
│   └── checklists/          # QA gates
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI app
│   │   ├── models.py        # Frozen Pydantic schemas
│   │   ├── settings.py      # pydantic-settings
│   │   ├── agents/          # Gemini ADK sub-agents
│   │   │   ├── orchestrator.py
│   │   │   ├── intent_agent.py
│   │   │   ├── discovery_agent.py
│   │   │   ├── ranking_agent.py
│   │   │   ├── booking_agent.py
│   │   │   ├── followup_agent.py
│   │   │   ├── trace_observer.py
│   │   │   ├── config.py
│   │   │   └── prompts/
│   │   └── services/
│   │       ├── supabase.py  # Data access layer
│   │       └── maps.py      # Google Maps + PostGIS merge
│   ├── scripts/
│   │   ├── seed.py          # 100 synthetic providers
│   │   └── run_reference.py # Headless reference run
│   ├── tests/
│   └── requirements.txt
├── lib/                     # Flutter app
│   ├── main.dart
│   ├── core/
│   │   ├── theme.dart       # Premium dark theme
│   │   └── api_client.dart  # Dio + SSE client
│   ├── features/
│   │   ├── request/         # Screen 1
│   │   ├── trace/           # Screen 2 (hero)
│   │   ├── recommendation/  # Screen 3
│   │   ├── booking/         # Screen 4
│   │   └── followup/        # Screen 5
│   └── l10n/                # en + ur ARB files
├── infra/
│   ├── adrs/                # 4 architecture decision records
│   ├── contracts/           # API contract
│   └── migrations/          # SQL migrations
├── deliverables/
├── .env.example
├── pubspec.yaml
└── README.md
```

---

## 🌐 Multilingual Support

| Language | Example |
|----------|---------|
| Roman Urdu | "Mujhe kal subah G-13 mein AC technician chahiye" |
| Urdu script | "مجھے کل صبح G-13 میں AC ٹیکنیشن چاہیے" |
| English | "I need a plumber in I-8 urgently" |
| Mixed | "AC repair chahiye F-8 mein tomorrow" |

The Intent/NLU Agent handles spelling variants (chahiye/chahie/chaiye), time expressions (kal subah → tomorrow 09:00 PKT), and Islamabad sector resolution (50+ sectors in the gazetteer).

---

## 📐 ADRs

| # | Decision | Status |
|---|----------|--------|
| 001 | ADK Hub-and-Spoke Topology | Accepted |
| 002 | Supabase + PostGIS for Geo, Realtime, Trace | Accepted |
| 003 | Trace Event Schema Design | Accepted |
| 004 | SSE + Supabase Realtime for Live Trace | Accepted |

See `infra/adrs/` for full rationale.

---

## 🏆 Rubric Coverage

| Criteria | Weight | Implementation |
|----------|--------|---------------|
| **Antigravity** | 25% | Full Gemini ADK pipeline, traces streamed via tool |
| **Agentic Reasoning** | 20% | 6 sub-agents with non-empty reasoning, cited numbers |
| **Action Simulation** | 15% | Real Supabase booking row + receipt + follow-ups |
| **Innovation** | 15% | Multilingual NLU, sector gazetteer, demo clock compression |
| **UX** | 15% | 5-screen Flutter app with live trace timeline |
| **Presentation** | 10% | README + architecture map + demo script |

---

## 📄 License

Built for the Google Antigravity Hackathon 2026.
