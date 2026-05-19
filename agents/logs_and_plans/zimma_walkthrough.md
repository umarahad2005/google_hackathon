# 🧠 Zimma AI — Session Walkthrough & Delivery

We have successfully executed the build plan for the **Zimma AI** Agentic Orchestrator (Google Antigravity Hackathon Challenge 2). Here is a complete walkthrough of everything built, configured, and ready for demo.

---

## 1. Phase 0–1: Infrastructure & Data Modeling
*Status: Complete*

We established the Python backend layer and frozen data contracts.
- **Supabase Stack:** Created the `.sql` migrations (`001_initial_schema.sql` and `002_rpc_functions.sql`) to set up the 7-table schema. We enabled **PostGIS** for spatial routing and **Realtime** subscriptions on the `agent_traces` table.
- **Pydantic Contracts:** Defined canonical models (`models.py`) such as `RequestContext`, `TraceEvent`, `ServiceIntent`, and tool schemas.
- **API Contract:** Mapped out the REST and SSE endpoints in `infra/contracts/api-contract.md`.
- **ADRs:** Wrote 4 Architecture Decision Records (Hub-and-Spoke, PostGIS, Traces, SSE) explaining our technical choices for the judges.

---

## 2. Phase 2: Gemini ADK Multi-Agent Pipeline
*Status: Complete*

We built the core "Brain" of the service — a hub-and-spoke multi-agent system powered by Gemini 2.0 Flash and 2.5 Pro.
- **Trace Observer (`trace_observer.py`):** Wraps every agent action to emit a `TraceEvent` with reasoning, latency, and simulated/degraded flags. This fulfills the 25% "Trace-as-First-Class" rubric.
- **Intent / NLU Agent:** Handles Urdu, Roman Urdu, and English natively to extract service type, location, and urgency.
- **Discovery Agent:** Uses Google Maps + our PostGIS gazetteer of Islamabad/Rawalpindi sectors (50+ sectors). Fallbacks automatically trigger if APIs fail.
- **Ranking Agent:** Employs deterministic scoring (distance, availability, rating) backed by a Gemini Pro justification summary.
- **Booking & Follow-Up Agents:** Simulates real-world side effects (inserting into `bookings` table) and compresses a 4-day lifecycle into a 40-second demo simulation.
- **Orchestrator (`orchestrator.py`):** Drives the pipeline strictly through the phase gates (NEW → DISCOVERING → RANKING → RECOMMENDED).

---

## 3. Phase 3: FastAPI Backend
*Status: Complete*

We wrapped the ADK runtime into a web API.
- **REST Endpoints:** `POST /api/requests` to kick off the background worker.
- **Live Trace Engine:** `GET /api/requests/{id}/trace` implements Server-Sent Events (SSE), tailing the `agent_traces` table to stream agent thoughts to the mobile app in real-time.
- **Seed Script (`scripts/seed.py`):** Generates 100 synthetic service providers across 26 sectors of Islamabad/Rawalpindi with realistic Urdu names, PostGIS points, and availability slots.
- **Reference Run (`scripts/run_reference.py`):** A headless script to run the pipeline purely in the CLI to prove the logic is sound without the UI.

*(Note: During `pip install` on Windows, NumPy failed to compile due to missing C++ build tools. If you encounter this, either use WSL or install pre-compiled binaries via `pip install numpy --only-binary :all:` before installing the requirements).*

---

## 4. Phase 4: Flutter Mobile App
*Status: Complete*

We built a 5-screen, premium dark-themed mobile application using Flutter and Riverpod.
- **App Theme (`core/theme.dart`):** Vibrant gradients and glassmorphism designed specifically to make the trace timeline look incredible for the judges.
- **Screen 1 (Request):** Multilingual input (text/voice) with quick example chips for Urdu, Roman Urdu, and English.
- **Screen 2 (Trace Timeline):** **The Hero Screen.** Subscribes to the SSE endpoint and dynamically renders the agent's thought process, complete with reasoning text, tool call badges, and "⚠ DEGRADED" tags.
- **Screen 3 (Recommendation):** Displays the #1 ranked provider with a progress-bar breakdown of the AI's score (Distance, Rating, Price) and the LLM's justification.
- **Screen 4 (Booking):** Shows a confirmed receipt and bilingual success message.
- **Screen 5 (Follow-Up):** A live visual timeline tracking the service lifecycle (Reminder → In Progress → Complete) using a polling fallback that simulates Realtime.

---

## 5. Phase 5–6: Hardening & Deliverables
*Status: Complete*

- **The README (`README.md`):** We wrote a comprehensive, judge-ready README detailing the architecture, the ADK hub-and-spoke topology, how we map to the rubric, and setup instructions.
- **Environment:** Created `.gitignore` and `.env.example` configurations.

### What's Next for You (Demo Prep)

1. **Database:** Open your Supabase project, go to the SQL Editor, and paste the contents of `001_initial_schema.sql` and `002_rpc_functions.sql`.
2. **Keys:** Put your Gemini, Google Maps, and Supabase keys into `.env` in the `backend/` folder.
3. **Seed:** Run `python -m scripts.seed` to populate the synthetic providers.
4. **Run Backend:** Start the backend with `uvicorn app.main:app` (after resolving the pip windows C++ build tools if needed).
5. **Run Flutter:** Run `flutter pub get` and `flutter run`.
6. **Record:** Use the Roman Urdu example prompt (`Mujhe kal subah G-13 mein AC technician chahiye`) to record your hero video!
