# PR / Change Review Checklist

Any agent reviewing another agent's change runs this before accepting.

## Scope
- [ ] Change stays inside the author's ownership (`ORG_CHART.md`)
- [ ] No frozen contract modified (Phase-1 schemas/API). If needed → CHANGE_REQUEST to 02
- [ ] Smallest correct change; no unrelated refactors

## Correctness
- [ ] Matches the API/data/ADK contract exactly
- [ ] Acceptance criteria from the hand-off packet demonstrably met
- [ ] Edge cases from the relevant workflow handled (empty, conflict, degraded)

## Traceability
- [ ] New runtime decisions emit a trace event with non-empty `reasoning`
- [ ] External effects flagged `degraded`/`simulated` correctly

## Quality
- [ ] Matches surrounding code style/naming; typed (pydantic/Dart models)
- [ ] No secret/key committed; inputs validated
- [ ] Tests added/updated and green

## Hand-off
- [ ] Trace/note recorded; next owner can start with zero questions

Reject with specific, actionable feedback. Approve only when all boxes pass.
