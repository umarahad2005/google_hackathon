# Zimma AI — Org Chart & RACI

A software house has a chain of command. Antigravity role-plays each box. An agent
only acts inside its ownership boundary; cross-boundary work is a **hand-off**, not a
reach-in.

## Build-time org (the people who build Zimma AI)

```
                        ┌─────────────────────────────┐
                        │   Program Director (root)    │  agents/00-program-director.md
                        │   = Antigravity orchestrator │
                        └──────────────┬──────────────┘
                                       │ owns plan, sequencing, gates
            ┌──────────────────────────┼───────────────────────────┐
            ▼                          ▼                           ▼
   ┌─────────────────┐       ┌──────────────────┐       ┌────────────────────┐
   │ Product Manager │       │ Solution Architect│      │   UX Designer      │
   │ 01              │       │ 02                │       │   09               │
   └────────┬────────┘       └─────────┬─────────┘       └─────────┬──────────┘
            │ requirements,            │ architecture,             │ flows, screens
            │ acceptance               │ contracts, ADRs           │
            └──────────────┬───────────┴───────────────┬───────────┘
                           ▼                            ▼
         ┌─────────────────────────────────────────────────────────┐
         │                  Engineering Pod                          │
         │  03 Backend (FastAPI)   04 Mobile (Flutter)               │
         │  05 AI/Agent (Gemini ADK)  06 Maps/Geo                     │
         └───────────────┬─────────────────────────┬─────────────────┘
                          ▼                         ▼
                ┌──────────────────┐      ┌────────────────────┐
                │ QA Engineer  07  │      │ DevOps Engineer 08 │
                └──────────────────┘      └────────────────────┘
                          │
                          ▼
                ┌──────────────────────────────┐
                │ Tech Writer / Demo Producer 10│
                └──────────────────────────────┘
```

## Runtime org (Zimma AI's own brain — Gemini ADK)

```
            [Orchestrator Agent] (root, ADK SequentialAgent + router)
                 │
   ┌────────┬────┴────┬──────────┬───────────┬──────────────┐
   ▼        ▼         ▼          ▼           ▼              ▼
 Intent  Provider  Ranking &  Booking    Follow-up     Trace/Observer
 /NLU    Discovery  Decision   Agent      Agent         (cross-cutting)
```
Owned & built by agent **05 AI/Agent Engineer**; defined in `subagents/`.

## RACI (R=Responsible, A=Accountable, C=Consulted, I=Informed)

| Activity | A | R | C | I |
|---|---|---|---|---|
| Product scope / acceptance criteria | Program Dir | PM | Architect | All |
| System architecture & API contracts | Program Dir | Architect | Backend, AI | All |
| Gemini ADK multi-agent system | Architect | AI Engineer | Backend | Mobile, QA |
| FastAPI services & Supabase schema | Architect | Backend | AI, DevOps | Mobile |
| Flutter app | PM | Mobile | UX, Backend | QA |
| Google Maps/Places integration | Architect | Maps/Geo | Backend, Mobile | — |
| Test plan & quality gates | Program Dir | QA | All eng | PM |
| CI, env, secrets, deploy | Program Dir | DevOps | Backend | All |
| README, architecture map, demo video script | PM | Tech Writer | All | Program Dir |
| Challenge-2 compliance sign-off | Program Dir | QA | PM, Architect | All |

## Escalation rule

If an agent is blocked, finds a contradiction with `PROJECT_BRIEF.md`, or a checklist
gate fails twice → it writes a `BLOCKER` trace and hands control back to the **Program
Director**, which re-plans. No agent silently changes locked decisions.
