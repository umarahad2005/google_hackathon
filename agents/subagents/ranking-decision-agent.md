# Sub-Agent: Ranking & Decision Agent

## Role
The decision-quality agent (20% of the score). Rank candidates and explain the choice
in plain, specific language — never "this is the best option" with no substance.

## ADK shape
`LlmAgent`, `gemini-2.x-pro`. Deterministic scoring in code; the LLM produces the
human-readable justification grounded in the computed scores.

## Input
`DiscoveryResult.candidates`, `ServiceIntent` (urgency, time).

## Scoring (transparent, in code — not hallucinated)
```
score = 0.40*distance_score      # nearer = higher (normalized)
      + 0.25*availability_score  # matches requested time slot
      + 0.25*rating_score        # rating/5 (db simulated or Places real)
      + 0.10*price_fit_score     # vs user urgency/expectation
```
Weights live in one config block (tunable, documented in README).

## Output
```python
class RankedProvider(ProviderCandidate):
    score: float
    score_breakdown: dict        # {distance:..., availability:..., rating:..., price:...}
    rank: int
class RankingResult(BaseModel):
    ranked: list[RankedProvider]          # full ordered list
    recommended: RankedProvider           # rank 1
    alternatives: list[RankedProvider]    # ranks 2–3
    reasoning: str   # e.g. "Ali AC Services chosen: 2.1 km (closest of 7),
                     # available tomorrow 10:00 in the requested morning window,
                     # 4.6★; next best Bilal Cooling is 3.8 km / no AM slot."
```

## Logic
1. Compute each component score; produce `score_breakdown` per provider.
2. Order; pick rank 1 as `recommended`, ranks 2–3 as `alternatives`.
3. LLM writes `reasoning` that **cites the actual numbers** and explicitly contrasts
   the winner with the runner-up. Generic praise is rejected by QA.
4. If the user later rejects rank 1, re-rank excluding it (Orchestrator re-enters RANKING).

## Acceptance
For the reference scenario, recommended provider's reasoning names distance, the
time-window match, rating, and why it beat the #2 — verifiable against `score_breakdown`.

## Hard rules
`reasoning` must be derivable from `score_breakdown`. No invented attributes.
