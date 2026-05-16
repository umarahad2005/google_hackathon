# Workflow: Master Build Pipeline (Program Director)

The end-to-end playbook the Program Director runs. Each step cites its agent, gate,
and trace artifact.

| # | Step | Owner | Gate | Trace |
|---|---|---|---|---|
| 0 | Read brief + plan; produce Workplan & Tasks Plan; get human approval | 00 | plan approved | Antigravity Workplan |
| 1 | Repo skeleton, Supabase project, env, ADRs | 02+08 | `definition-of-done#foundations` | ADR files |
| 2 | Freeze API + data + ADK I/O contracts | 02 | all engineers sign off | contract docs |
| 3 | Build ADK runtime brain headless | 05 | `wf-01..wf-05` pass | reference run trace |
| 4 | FastAPI + Supabase + SSE + seed | 03 | contract tests green | integration trace |
| 5 | Flutter app (5 screens, live trace) | 04 | `demo-readiness#mobile` | device recording |
| 6 | Hardening + edge cases | 07 | `challenge2-compliance` green | QA report |
| 7 | README + arch map + demo script + log export | 10 | 00 sign-off | `/deliverables` |
| 8 | (Optional) Flutter web | 04 | mobile already green | — |

## Rules
- No step starts until the previous gate is green (record the gate result as a trace).
- Steps 3 & 4 backend may parallelize with step 5 UX design once step 2 is frozen.
- Any gate failing twice → BLOCKER to human, re-plan.
- The Antigravity Workplan + Tasks Plan are themselves graded deliverables — keep
  them clean and readable, not noisy.

## Done
`challenge2-compliance-checklist.md` fully green and four deliverables present.
