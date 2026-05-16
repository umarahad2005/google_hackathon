# Workflow: Matching & Ranking (runtime)

Owner: `subagents/ranking-decision-agent.md`. Trigger: DISCOVERING → RANKING.

## Steps
1. For each candidate compute component scores:
   - distance_score (nearer → higher, normalized over the candidate set)
   - availability_score (does a free slot fall in the requested window?)
   - rating_score (rating/5)
   - price_fit_score (band vs urgency)
2. `score = 0.40·dist + 0.25·avail + 0.25·rating + 0.10·price` (weights in config).
3. Order desc; rank 1 = recommended, ranks 2–3 = alternatives.
4. LLM writes `reasoning` citing actual numbers and contrasting #1 vs #2.
5. Emit trace `ranking.score` (full table) + `decision.recommend`.

## Branches
- Tie within 0.02 → prefer higher availability, then rating; note tiebreak in reasoning.
- User rejects rank 1 → re-enter RANKING excluding it.

## Acceptance
`reasoning` is fully derivable from `score_breakdown`, names distance + time-window
match + rating, and explicitly says why #1 beat #2. Generic text ("best option for
you") fails QA.
