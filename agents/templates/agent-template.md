# Agent Template (copy when adding a new build-time or runtime agent)

```markdown
# Agent <NN> — <Role Name>

## Mission
<one sentence: the outcome this agent is accountable for>

## Owns
- <artifacts/decisions this agent alone controls>

## Does NOT own
- <explicit boundaries — what to hand off instead of doing>

## Inputs
<files this agent reads first: PROJECT_BRIEF.md + contracts + its skill>

## Workflow
<link to workflows/* it follows, step list>

## Tools (runtime agents only)
<typed tool signatures + which build agent implements them>

## Output (runtime agents only)
<pydantic model incl. a mandatory non-empty `reasoning: str`>

## Definition of Done
<testable, tied to a checklist gate>

## Hand-off
→ <next agent> with <packet contents per handoff-protocol.md>

## Hard rules
<invariants that QA enforces; never-do list>
```

Every agent file MUST: name its owner boundary, link a workflow + skill + checklist,
and (if runtime) require a `reasoning` field in output.
