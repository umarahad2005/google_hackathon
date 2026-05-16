# Zimma AI — Project Brief (Single Source of Truth)

> Every agent reads this file FIRST. If a decision is not here, escalate to the
> Program Director agent — do not invent product scope.

## 1. What we are building

**Zimma AI** — an Agentic AI System that automates the **end-to-end lifecycle of an
informal-economy service request**: from a natural-language message ("Mujhe kal
subah G-13 mein AC technician chahiye") to a confirmed, simulated booking with
automated follow-up.

`Zimma` (ذمہ) = "responsibility / I take charge of it" — the system takes ownership
of the whole request lifecycle on behalf of the user.

This is **Challenge 2: AI Service Orchestrator for Informal Economy** of the Google
Antigravity Hackathon. The agents/ folder is built so that **Google Antigravity** is
the core orchestration platform that drives both the build and the runtime agentic logic.

## 2. Hard rules (non-negotiable, from the challenge brief)

- This is **NOT a listing/booking app**. Judged on **agentic automation + reasoning**, not UI.
- A **multi-agent system** with `planning → decision → action → follow-up` and **traceable logs**.
- **At least one booking simulated end-to-end** with a visible system-state change.
- Multilingual intent: **Urdu, Roman Urdu, English**.
- **Mobile App is MUST** (Flutter). Web App is **optional**.
- **Google Antigravity must be central** to system logic + orchestration.
- No real personal/sensitive data. Seed datasets must be synthetic.

## 3. Locked tech decisions

| Layer | Decision | Notes |
|---|---|---|
| Mobile | **Flutter** (mobile-first, primary deliverable) | Web build optional, later |
| Backend | **FastAPI** (Python 3.11+) | REST + SSE for live agent trace |
| AI orchestration | **Google Gemini ADK** multi-agent | Root orchestrator + specialist sub-agents |
| LLM | **Gemini 2.x** via Gemini API | `gemini-2.0-flash` for routing, `gemini-2.x-pro` for reasoning |
| Geo | **Google Maps Platform** | Places API (New), Distance Matrix, Geocoding, Maps SDK (Flutter) |
| Data / Auth / Realtime | **Supabase** | Postgres + PostGIS, Auth, Realtime, Storage |
| Notifications | FCM (push) + **simulated** SMS/WhatsApp confirmation | Simulation is acceptable per brief |
| Dev orchestrator | **Google Antigravity** | Drives the build via this agents/ folder |

## 4. The runtime agentic pipeline (the product's brain)

```
User NL message
   │
   ▼
[Orchestrator Agent]  ── plans the run, owns state, writes trace
   │
   ├─▶ [Intent/NLU Agent]        extract {service_type, location, time, urgency, language}
   │
   ├─▶ [Provider Discovery Agent] Places API + Supabase provider table → candidate set
   │
   ├─▶ [Ranking & Decision Agent] score(distance, availability, rating, price) + reasoning
   │
   ├─▶ [Booking Agent]            simulate slot booking → confirmation + receipt → Supabase
   │
   └─▶ [Follow-up Agent]          schedule reminder, status updates, completion confirmation
   │
   ▼
Structured result + full agent trace (shown in app + stored in Supabase)
```

Every agent emits a **trace event** (`agent`, `step`, `input`, `reasoning`, `tool_calls`,
`output`, `latency_ms`) to the `agent_traces` table. The mobile app renders this as a
live "AI is thinking" timeline — this is core to the 25% Antigravity score and 20%
agentic-reasoning score.

## 5. Reference scenario (must work end-to-end for the demo)

Input: `"Mujhe kal subah G-13 mein AC technician chahiye"`

Expected output:
- Service: AC Technician · Location: G-13, Islamabad · Time: tomorrow morning
- Recommended: "Ali AC Services" (2.1 km) — closest available, high rating, with reasoning
- Simulated booking: slot 10:00 AM, confirmation + receipt generated, written to Supabase
- Follow-up: reminder scheduled 1h before; status updates; completion confirmation
- Full agent trace visible in-app

## 6. Domain & seed data

- City: **Islamabad / Rawalpindi** sectors (G-10, G-13, F-8, I-8, etc.).
- Services: AC technician, electrician, plumber, tutor, beautician, carpenter, appliance repair.
- ~80–120 **synthetic** providers seeded in Supabase with: name, category, geo point
  (PostGIS), rating, price band, working hours, availability calendar, languages.
- Real Google Places lookups augment the seeded set (the system must work with both).

## 7. Definition of "done" for the product (demo-ready)

See `checklists/challenge2-compliance-checklist.md`. In short: reference scenario runs
end-to-end on a physical/emulated Android device, agent trace is visible and stored,
a booking row + receipt + follow-up jobs exist in Supabase, README + architecture map +
demo video script are written.
