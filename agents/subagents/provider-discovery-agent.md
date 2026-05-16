# Sub-Agent: Provider Discovery Agent

## Role
Find candidate providers for the intent using **real geo data + seeded DB** — not
fabricated lists.

## ADK shape
`LlmAgent` with a single primary tool `find_candidates` (implemented by build agent
06, see `skills/google-maps-integration.md`). LLM decides search params + radius
strategy; tool does the lookup.

## Input
`ServiceIntent` (service_type, location_text, urgency).

## Tool: `find_candidates(category, location, radius_km) -> list[ProviderCandidate]`
Merges:
- **Google Places API (New)** nearby/text search for the category near the resolved sector.
- **Supabase providers** within radius via PostGIS `ST_DWithin`.
De-dupes (name + geo proximity), tags each with `source: places|db`.

## Output
```python
class ProviderCandidate(BaseModel):
    provider_id: str
    name: str
    category: str
    lat: float; lng: float
    distance_km: float
    rating: float | None
    price_band: Literal["low","mid","high"] | None
    open_now: bool | None
    languages: list[str]
    source: Literal["places","db"]
class DiscoveryResult(BaseModel):
    candidates: list[ProviderCandidate]
    radius_used_km: float
    reasoning: str               # search strategy + why this radius
    degraded: bool               # true if Places failed → DB-only
```

## Logic
1. Resolve `location_text` → coords (geo tool / sector gazetteer).
2. Start radius by urgency: now→3km, today→6km, scheduled→10km.
3. Call `find_candidates`. If 0 → double radius once. Still 0 → return empty +
   reasoning (Orchestrator → NO_PROVIDER).
4. Keep top ~10 nearest for ranking; record `source` distribution in reasoning.

## Acceptance
"AC technician near G-13" returns ≥3 candidates with real distances; with the Maps
key removed it still returns DB candidates and `degraded:true`.

## Hard rules
Never synthesize providers. Empty is a valid, traced outcome.
