# ================================================================
# Zimma AI — Demo Script (T-6.3)
# For judges, team, and the hackathon video recording.
# ================================================================

## Overview

**Zimma AI** is an agentic AI service orchestrator for Pakistan's
informal economy. This script guides the demo presenter through
a live, narrated walkthrough that showcases all rubric dimensions.

---

## Setup Checklist (Before Going Live)

- [ ] `backend/.env` has real keys (Gemini, Maps, Supabase)
- [ ] Supabase migrations applied (001 + 002)
- [ ] Database seeded (`python -m scripts.seed`)
- [ ] FastAPI running: `python -m uvicorn app.main:app --port 8000`
- [ ] Flutter app running: `flutter run`
- [ ] Screen recording software ready
- [ ] Phone/emulator clearly visible

---

## Scene 1 — The Problem (30 seconds)

**SAY:**
> "Millions of people in Pakistan need everyday services — plumbers,
> electricians, AC technicians — but there's no reliable way to find them.
> People rely on WhatsApp forwards and word of mouth.
> Zimma AI solves this."

**SHOW:** The Request Screen on the Flutter app.

---

## Scene 2 — The Hero Request (45 seconds)

**SAY:**
> "Our user, Muhammad, needs an AC technician tomorrow morning in G-13
> Islamabad. He types in Roman Urdu — the way millions of Pakistanis text."

**TYPE** (or use the quick-chip):
```
Mujhe kal subah G-13 mein AC technician chahiye
```

**PRESS:** Send / Submit.

**SAY:**
> "The moment he hits send, our multi-agent pipeline activates."

---

## Scene 3 — The Live Trace (60 seconds) 🌟 HERO MOMENT

**SHOW:** The Trace Timeline screen auto-opens and populates in real-time.

**NARRATE each agent card as it appears:**

| Agent card appears | Say this |
|---|---|
| **Orchestrator** — "Starting pipeline" | "The root orchestrator receives the request and begins routing." |
| **Intent/NLU** — "Extracted ac_technician" | "Our Gemini-powered NLU agent understands Roman Urdu natively. It extracts the service type, location, and time — with 92% confidence." |
| **Discovery** — "Found 5 providers in G-13" | "The discovery agent queries Google Places AND our Supabase PostGIS database — within 3km of G-13." |
| **Ranking** — "Ali AC Services #1 (0.847)" | "The ranking agent scores candidates: 40% distance, 25% availability, 25% rating, 10% price. Ali AC Services wins." |
| **Booking** — "Confirmed for tomorrow 09:00" | "Booking is written to the database. A simulated WhatsApp confirmation is sent." |

**POINT OUT the trace features:**
- Each card shows the agent's **reasoning** in plain language
- Tool calls are shown as `[find_candidates]`, `[write_booking]`
- Any degraded fallback shows a `⚠ DEGRADED` badge
- The timeline is live-streamed via SSE — not polling

---

## Scene 4 — Recommendation Screen (30 seconds)

**SHOW:** The Recommendation screen.

**SAY:**
> "The AI presents the top-ranked provider with a full score breakdown.
> Not just a name — but *why* this provider was chosen."

**POINT OUT:**
- Score bars: Distance ██████████ 1.2km
- Rating: ████████░░ 4.5/5.0
- Gemini Pro justification text (quoted reasoning)
- "Book Now" button

---

## Scene 5 — Booking Confirmation (20 seconds)

**PRESS:** "Book Now"

**SHOW:** The Booking screen with receipt.

**SAY:**
> "The booking is confirmed. A receipt is generated.
> The user gets a bilingual confirmation — English and Urdu."

---

## Scene 6 — Follow-Up Lifecycle (30 seconds)

**NAVIGATE TO:** Follow-Up screen.

**SAY:**
> "Zimma AI doesn't stop at booking. It orchestrates the full lifecycle.
> A reminder 30 minutes before. Status updates. Completion confirmation."

**SHOW:** The animated timeline progressing (demo clock is compressed
so 4 days of lifecycle plays in ~40 seconds).

---

## Scene 7 — Architecture (30 seconds)

**SHOW:** The README architecture diagram or draw on screen.

**SAY:**
> "Under the hood: a hub-and-spoke multi-agent system built with
> Google's Agent Development Kit. Gemini 2.0 Flash for fast routing,
> Gemini 2.5 Pro for deep reasoning. All traces are stored in Supabase
> and streamed live to the mobile app."

---

## Scene 8 — Rubric Callout (20 seconds)

**SAY:**
> "Every judge criterion is met:
> - **Agentic reasoning**: 5 specialized agents, each with a distinct role
> - **Real APIs**: Google Places, Gemini, Supabase PostGIS
> - **Trace-as-First-Class**: Every agent thought is visible, stored, and streamable
> - **Multilingual**: Urdu script, Roman Urdu, and English — all work natively
> - **Real-world impact**: Designed for Pakistan's 50M+ informal economy workers"

---

## Fallback Plan (If Something Breaks)

| Problem | Recovery |
|---------|----------|
| Gemini rate limit | Wait 60 seconds, retry. Free tier resets per minute. |
| Supabase down | App shows degraded mode — seed data still works for UI demo |
| Flutter build error | Use `flutter run -d web-server` and show in browser |
| SSE stream freezes | Refresh trace screen — it re-subscribes automatically |

---

## Key Numbers to Remember

| Metric | Value |
|--------|-------|
| Providers seeded | 100 |
| Sectors covered | 26 (Islamabad + Rawalpindi) |
| Availability slots | 4,900 |
| Agent pipeline steps | 8 trace events minimum |
| Gemini confidence (ref) | ≥ 0.85 |
| Ranking #1 score (ref) | ≥ 0.80 |

---

## Reference Commands

```powershell
# Start backend
cd d:\google_hackathon\backend
C:\Users\HP\AppData\Local\Programs\Python\Python313\python.exe -m uvicorn app.main:app --reload --port 8000

# Run headless E2E test (prints full trace)
C:\Users\HP\AppData\Local\Programs\Python\Python313\python.exe -m scripts.run_reference

# Start Flutter app
cd d:\google_hackathon
flutter run

# Run test suite
cd d:\google_hackathon\backend
C:\Users\HP\AppData\Local\Programs\Python\Python313\python.exe -m pytest tests/ -v
```
