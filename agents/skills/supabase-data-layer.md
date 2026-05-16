# Skill: Supabase Data Layer

Used by Backend (03), consulted by DevOps (08). Postgres + PostGIS + Auth + Realtime.
You have a Supabase MCP connected — use `apply_migration`, `execute_sql`,
`list_tables`, `get_advisors` directly.

## Schema (migration)
```sql
create extension if not exists postgis;

create table users (
  id uuid primary key default gen_random_uuid(),
  display_name text, lang_pref text, created_at timestamptz default now());

create table providers (
  id uuid primary key default gen_random_uuid(),
  name text not null, category text not null,
  geo geography(Point,4326) not null,
  rating numeric(2,1), price_band text, languages text[],
  working_hours jsonb, is_synthetic boolean default true);
create index providers_geo_gix on providers using gist (geo);
create index providers_cat_ix on providers (category);

create table provider_availability (
  id bigint generated always as identity primary key,
  provider_id uuid references providers(id),
  slot_start timestamptz, slot_end timestamptz, is_booked boolean default false);

create table service_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid, raw_message text, intent jsonb, state text,
  created_at timestamptz default now());

create table bookings (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references service_requests(id),
  provider_id uuid references providers(id), user_id uuid,
  slot_start timestamptz, slot_end timestamptz,
  status text, price_estimate text, receipt_url text,
  created_at timestamptz default now());

create table follow_ups (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references bookings(id),
  kind text, fire_at timestamptz, status text, message text,
  simulated boolean default true);

-- agent_traces: see skill agent-trace-logging.md
```

## Geo query (discovery)
```sql
select id,name,rating, ST_Distance(geo, ST_MakePoint(:lng,:lat)::geography)/1000 km
from providers
where category = :cat
  and ST_DWithin(geo, ST_MakePoint(:lng,:lat)::geography, :radius_m)
order by km limit 10;
```

## Rules
- Service-role key server-side only (FastAPI). Flutter uses anon key + RLS.
- Enable RLS on user-scoped tables; providers/traces read-only to client.
- Realtime on `service_requests.state`, `agent_traces`, `follow_ups` → live app.
- `seed.py` inserts 80–120 synthetic providers across Islamabad/Rawalpindi sectors
  with availability rows; `is_synthetic=true` always (no real data — brief rule).
- Run `get_advisors` (security + performance) before the compliance gate.
