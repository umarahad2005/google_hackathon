# Skill: Google Maps Platform Integration

Used by Maps/Geo (06). Make location REAL.

## APIs
- **Geocoding API** — sector text → lat/lng.
- **Places API (New)** — `searchText` / `searchNearby` for a category near a point.
- **Distance Matrix API** — true travel distance/time provider→user.
- **Maps SDK** (`google_maps_flutter`) — pins + route preview in the app.

## Single tool the agents call
```python
def find_candidates(category: str, location_text: str, radius_km: float)
    -> DiscoveryResult:
    latlng = resolve_location(location_text)        # Geocoding → gazetteer fallback
    places = places_nearby(category, latlng, radius_km)   # Places API (New)
    db     = supabase_providers_within(category, latlng, radius_km)  # PostGIS ST_DWithin
    merged = dedupe(places + db)                     # name sim + geo proximity
    distance_matrix_fill(merged, latlng)             # real distances
    return DiscoveryResult(candidates=merged, radius_used_km=radius_km,
                            reasoning=..., degraded=places_failed)
```

## Sector gazetteer (offline fallback — required)
Hardcode lat/lng for Islamabad/Rawalpindi sectors (G-10, G-13, F-8, F-10, I-8,
I-9, Blue Area, Saddar, ...). If Geocoding/Places fail or quota hit → use
gazetteer + Supabase only and set `degraded:true`. Never fabricate distances.

## Hygiene
- Key in env; restrict by API + app. Thin response cache for deterministic demos.
- Every Maps call is a traced `tool_call` (args + degraded flag).
