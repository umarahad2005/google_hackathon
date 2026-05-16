# `agents/` — The Zimma AI Software House

This folder is the **operating manual for a world-class software house, encoded as
files**. Google Antigravity reads it and runs the team to build **Zimma AI**
(Challenge 2: AI Service Orchestrator for Informal Economy).

It serves **two purposes at once**:

1. **Build-time org** — the agents in `agents/` are the *people* of the software
   house (PM, Architect, AI Engineer, Backend, Mobile, QA, DevOps, UX, Writer) that
   Antigravity role-plays to build the product.
2. **Runtime org** — the agents in `subagents/` are the *product's own brain*: the
   Gemini ADK multi-agent system that runs inside Zimma AI at runtime.

## Read order (do not skip)

1. `PROJECT_BRIEF.md` — single source of truth for product scope & tech decisions.
2. `MASTER_PROMPT.md` — the one prompt you paste into Antigravity to start.
3. `ORG_CHART.md` — who reports to whom, ownership boundaries.
4. `orchestration/orchestration.md` — how agents hand off and the build sequence.
5. The agent file for your current role in `agents/`.

## Folder map

| Folder | What it holds | Analogy |
|---|---|---|
| `PROJECT_BRIEF.md` | Locked product scope & stack | The product spec on the wall |
| `MASTER_PROMPT.md` | The kickoff prompt for Antigravity | The CEO's mission memo |
| `ORG_CHART.md` | Roles, reporting lines, RACI | The org chart |
| `agents/` | Build-time roles (PM, Arch, Eng…) | The employees |
| `subagents/` | Runtime Gemini ADK agents | The product's brain |
| `orchestration/` | Hand-off protocol, state machine, build sequence | The delivery process |
| `workflows/` | Step-by-step playbooks (build + runtime) | SOPs / runbooks |
| `checklists/` | Gates that must pass before moving on | QA gates / DoD |
| `templates/` | Fill-in artifacts (ADR, API contract, PR…) | Company templates |
| `skills/` | Reusable how-to recipes (ADK agent, FastAPI, Flutter…) | The engineering handbook |

## Operating principle

> An agent never works from memory. It opens its agent file → its workflow →
> the relevant skill → does the work → runs the checklist → records a trace →
> hands off per the orchestration protocol.

Every build-time action and every runtime decision produces a **trace artifact**.
Traceability is graded (25% Antigravity + 20% agentic reasoning) and is the product's
core feature — never treat it as optional logging.
