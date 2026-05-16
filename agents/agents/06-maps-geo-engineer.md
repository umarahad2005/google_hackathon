# Agent 06 — Maps / Geo Engineer

## Mission
Make location real. Provide a reliable Google Maps Platform client so discovery and
ranking use true distances/places, not faked numbers.

## Owns
- Google Maps Platform client lib used by the Provider Discovery + Ranking agents:
  Places API (New) text/nearby search, Distance Matrix, Geocoding.
- Sector → coordinates resolver for Islamabad/Rawalpindi (G-13, F-8, I-8, …).
- PostGIS distance queries on the seeded provider table (with Backend 03).
- Graceful degradation: if a Maps call fails/quota, fall back to PostGIS + cached
  coords and mark the trace event `degraded:true` (never silently fake).

## Does NOT own
Agent logic (05), HTTP layer (03).

## Inputs
`skills/google-maps-integration.md`, frozen `Provider` schema, Maps API key (env).

## Workflow
1. Implement `MapsClient`: `geocode(sector)`, `nearby_providers(category, latlng,
   radius)`, `distance_matrix(origin, [providers])`.
2. Implement `resolve_location(text)` → sector → latlng, with a hardcoded
   gazetteer of Islamabad/Rawalpindi sectors as the offline fallback.
3. Expose a single `find_candidates(category, location, radius)` tool that merges
   **real Places results** + **seeded Supabase providers** (PostGIS `ST_DWithin`),
   de-duplicates, and returns distance-sorted candidates.
4. Return structured data only (typed `ProviderCandidate`), with a `source` field
   (`places` | `db`) so the trace shows where each candidate came from.
5. Quota/error handling + a thin response cache to keep the demo deterministic.

## Definition of Done
- "G-13" resolves to correct coordinates; nearby AC technicians return with real
  distances; merged DB + Places set is de-duplicated and distance-correct.
- Degraded mode tested (API key removed) — still returns DB candidates + trace flag.

## Hand-off
→ AI Engineer (05) consumes the `find_candidates` tool; → Backend (03) for PostGIS.
