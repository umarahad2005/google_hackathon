# Workflow: Provider Discovery (runtime)

Owner: `subagents/provider-discovery-agent.md`. Trigger: UNDERSTANDING → DISCOVERING.

## Steps
1. Resolve `location_text` → coords (Geocoding API → sector gazetteer fallback).
2. Pick start radius by urgency: now 3km / today 6km / scheduled 10km.
3. Call `find_candidates(category, latlng, radius)`:
   - Google Places API (New) nearby/text search for the category, AND
   - Supabase `providers` via PostGIS `ST_DWithin`.
4. Merge + de-dup (name similarity + geo proximity); tag `source`.
5. 0 results → double radius, retry once → still 0 → DiscoveryResult empty.
6. Keep ~10 nearest; emit trace `discovery.search` (radius, counts, source split).

## Branches
- empty after retry → Orchestrator → NO_PROVIDER (graceful bilingual message).
- Places quota/error → DB-only, `degraded:true` in trace, continue.

## Acceptance
"AC technician near G-13" → ≥3 candidates with real distances. Maps key removed →
still returns DB candidates + `degraded:true`. De-dup verified (no double entries).
