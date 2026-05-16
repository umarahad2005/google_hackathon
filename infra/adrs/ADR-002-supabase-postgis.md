# ADR-002: Supabase + PostGIS for Geo, Realtime, and Trace Store

## Status
Accepted

## Context
We need: (a) geospatial queries on providers, (b) realtime event streaming to the
mobile app, (c) durable storage for the agent trace, (d) auth for the demo user.
Options: Supabase (Postgres+PostGIS+Auth+Realtime), Firebase, custom Postgres+Redis.

## Decision
**Supabase** (managed Postgres + PostGIS + Auth + Realtime + Storage).

## Rationale
- **PostGIS** gives us `ST_DWithin` and `ST_Distance` natively — no external geo
  service needed for the seeded provider set.
- **Supabase Realtime** publishes row changes via websockets — the Flutter app
  subscribes to `agent_traces` and `follow_ups` for the live timeline.
- **Auth** is pre-built (anon key for client, service key for backend).
- **Storage** hosts receipt artifacts.
- Single platform = fewer credentials, simpler demo.

## Consequences
- Tied to Supabase free tier (sufficient for hackathon).
- PostGIS extension must be enabled on project creation.
- RLS policies needed for user-scoped tables.
