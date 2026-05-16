-- ================================================================
-- Zimma AI — Supabase Schema Migration (Phase 0)
-- Postgres + PostGIS
-- Source of truth: agents/skills/supabase-data-layer.md
--                  agents/skills/agent-trace-logging.md
-- ================================================================

-- Enable PostGIS for geographic queries
create extension if not exists postgis;

-- ----------------------------------------------------------------
-- Users
-- ----------------------------------------------------------------
create table if not exists users (
    id           uuid primary key default gen_random_uuid(),
    display_name text,
    lang_pref    text default 'en',
    created_at   timestamptz default now()
);

-- ----------------------------------------------------------------
-- Providers (synthetic seed data — is_synthetic always true)
-- ----------------------------------------------------------------
create table if not exists providers (
    id            uuid primary key default gen_random_uuid(),
    name          text not null,
    category      text not null,
    geo           geography(Point, 4326) not null,
    rating        numeric(2,1),
    price_band    text check (price_band in ('low', 'mid', 'high')),
    languages     text[] default '{}',
    working_hours jsonb,
    phone         text,
    is_synthetic  boolean default true,
    created_at    timestamptz default now()
);

create index if not exists providers_geo_gix  on providers using gist (geo);
create index if not exists providers_cat_ix   on providers (category);

-- ----------------------------------------------------------------
-- Provider Availability (time slots)
-- ----------------------------------------------------------------
create table if not exists provider_availability (
    id          bigint generated always as identity primary key,
    provider_id uuid references providers(id) on delete cascade,
    slot_start  timestamptz not null,
    slot_end    timestamptz not null,
    is_booked   boolean default false
);

create index if not exists avail_provider_ix on provider_availability (provider_id, slot_start);

-- ----------------------------------------------------------------
-- Service Requests (the user's NL message + lifecycle state)
-- ----------------------------------------------------------------
create table if not exists service_requests (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid references users(id),
    raw_message text not null,
    audio_url   text,
    intent      jsonb,
    state       text not null default 'NEW',
    result      jsonb,
    created_at  timestamptz default now(),
    updated_at  timestamptz default now()
);

create index if not exists sr_state_ix on service_requests (state);

-- ----------------------------------------------------------------
-- Bookings (the CRITICAL state change judges must see)
-- ----------------------------------------------------------------
create table if not exists bookings (
    id             uuid primary key default gen_random_uuid(),
    request_id     uuid references service_requests(id) on delete cascade,
    provider_id    uuid references providers(id),
    user_id        uuid references users(id),
    slot_start     timestamptz not null,
    slot_end       timestamptz not null,
    status         text not null default 'confirmed',
    price_estimate text,
    receipt_url    text,
    confirmation   jsonb,
    created_at     timestamptz default now()
);

-- ----------------------------------------------------------------
-- Follow-ups (scheduled reminders, status updates, completion)
-- ----------------------------------------------------------------
create table if not exists follow_ups (
    id         uuid primary key default gen_random_uuid(),
    booking_id uuid references bookings(id) on delete cascade,
    kind       text not null check (kind in ('reminder', 'status', 'completion', 'rating_request')),
    fire_at    timestamptz not null,
    status     text not null default 'scheduled' check (status in ('scheduled', 'sent', 'done')),
    message    text,
    simulated  boolean default true,
    created_at timestamptz default now()
);

create index if not exists fu_booking_ix on follow_ups (booking_id, fire_at);

-- ----------------------------------------------------------------
-- Agent Traces (the gradable agentic trace — 25% + 20% of score)
-- Source: agents/skills/agent-trace-logging.md
-- ----------------------------------------------------------------
create table if not exists agent_traces (
    id         bigint generated always as identity primary key,
    request_id uuid not null references service_requests(id) on delete cascade,
    seq        int not null,
    agent      text not null,
    step       text not null,
    input      jsonb,
    reasoning  text not null,
    tool_calls jsonb default '[]',
    output     jsonb,
    latency_ms int,
    degraded   boolean default false,
    simulated  boolean default false,
    model      text,
    ts         timestamptz default now(),
    unique (request_id, seq)
);

create index if not exists at_req_seq_ix on agent_traces (request_id, seq);

-- ----------------------------------------------------------------
-- Enable Supabase Realtime on key tables (live app timeline)
-- ----------------------------------------------------------------
alter publication supabase_realtime add table service_requests;
alter publication supabase_realtime add table agent_traces;
alter publication supabase_realtime add table follow_ups;
alter publication supabase_realtime add table bookings;
