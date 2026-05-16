-- ================================================================
-- Zimma AI — PostGIS RPC Function for Provider Discovery
-- Called by backend/app/services/supabase.py
-- ================================================================

create or replace function find_providers_nearby(
    cat text,
    lat double precision,
    lng double precision,
    radius_m double precision,
    max_results int default 10
)
returns table (
    id uuid,
    name text,
    category text,
    lat double precision,
    lng double precision,
    distance_km double precision,
    rating numeric,
    price_band text,
    languages text[],
    working_hours jsonb,
    phone text
)
language sql
stable
as $$
    select
        p.id,
        p.name,
        p.category,
        ST_Y(p.geo::geometry) as lat,
        ST_X(p.geo::geometry) as lng,
        ST_Distance(p.geo, ST_MakePoint(lng, lat)::geography) / 1000.0 as distance_km,
        p.rating,
        p.price_band,
        p.languages,
        p.working_hours,
        p.phone
    from providers p
    where p.category = cat
      and ST_DWithin(p.geo, ST_MakePoint(lng, lat)::geography, radius_m)
    order by distance_km
    limit max_results;
$$;
