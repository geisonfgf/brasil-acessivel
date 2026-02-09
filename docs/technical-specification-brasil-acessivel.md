# Technical Specification - Brasil Acessivel

Date: 2026-02-09  
Version: v1.0  
Based on: `/Users/geisonfgf/Projects/saas/brasil-acessivel/docs/product-design-document-brasil-acessivel.md`  
Stack: Next.js (TypeScript), Supabase (Postgres/Auth/Storage/Realtime), Resend (email), Vercel (deploy)

## 1. Scope

This specification defines the technical implementation for the MVP and the near-term evolution (Phase 2 hooks) of Brasil Acessivel.

MVP capabilities covered:

- map-based search for accessible places;
- filters (category, distance, minimum accessibility);
- accessibility assistant;
- place details and confidence signals;
- authenticated community contributions;
- change history and audit trail;
- transactional email notifications.

## 2. Architecture Overview

## 2.1 High-level components

- `web-app` (Next.js App Router + TypeScript)
  - server components for initial render and SEO pages;
  - client components for map interactivity and forms.
- `api` (Next.js Route Handlers + Supabase RPC)
  - query endpoints for map and place details;
  - mutation endpoints for contributions, moderation hooks, and export.
- `database` (Supabase Postgres + PostGIS)
  - core entities, RLS policies, scoring functions, audit logs.
- `auth` (Supabase Auth)
  - email/password + magic link (optional OAuth later).
- `storage` (Supabase Storage)
  - evidence photos attached to contributions.
- `email` (Resend)
  - contribution receipt, moderation event, digest (phase 2).
- `deployment` (Vercel)
  - Preview and Production environments;
  - Edge-safe frontend with server-side route handlers.

## 2.2 Runtime flow

1. User opens app and shares geolocation.
2. Frontend requests nearby places via API (`/api/places/search`).
3. Backend queries Postgres/PostGIS, applies filters and score ordering.
4. Frontend renders map markers and list.
5. User opens place details and optionally submits contribution.
6. Contribution stored in DB + audit log; score recalculated.
7. Notification email sent via Resend to contributor and/or moderators.

## 3. Monorepo/Project Structure

Recommended structure:

```txt
brasil-acessivel/
  apps/
    web/
      src/
        app/
        components/
        lib/
        server/
        styles/
      public/
      next.config.ts
      middleware.ts
  packages/
    ui/
    types/
    eslint-config/
  infra/
    supabase/
      migrations/
      seeds/
      functions/   # optional edge functions
    vercel/
      env/
  docs/
```

If single app is preferred for MVP, keep only `apps/web` and `infra/supabase`.

## 4. Frontend Specification (Next.js + TypeScript)

## 4.1 Core technologies

- Next.js 15+ (App Router)
- TypeScript strict mode (`"strict": true`)
- React Query (TanStack Query) for client data fetching and cache
- Zod for runtime validation of API contracts
- Map provider SDK (Mapbox GL JS or Google Maps JS SDK)
- Accessibility baseline: semantic HTML + keyboard navigation + ARIA patterns

## 4.2 Routes

- `/` Home map screen
- `/place/[id]` Place details
- `/contribute/[id]` Contribution form
- `/login` Auth screen
- `/profile` User profile + contribution history
- `/about` Product info
- `/api/*` Route handlers (BFF style)

## 4.3 State model (client)

- `searchState`
  - `coords`, `queryText`, `radiusMeters`, `category[]`, `minStatus`, `assistantEnabled`
- `placesState`
  - `results[]`, `loading`, `error`, `lastFetchedAt`
- `sessionState`
  - `user`, `isAuthenticated`, `role`

## 4.4 Accessibility requirements

- full keyboard operation on map list interactions;
- high-contrast marker legend and status badges;
- focus management on modal/dialog transitions;
- proper labels on all filters and form controls;
- tested against WCAG 2.2 AA criteria for MVP critical paths.

## 5. Backend/API Specification

API style: REST-like JSON through Next.js Route Handlers.  
Auth: Supabase JWT in cookies/session; server validates role.

## 5.1 Endpoints (MVP)

1. `GET /api/places/search`
   - Query params:
     - `lat:number`
     - `lng:number`
     - `radius:number` (max 10000)
     - `category:string[]`
     - `min_status:accessible|partially_accessible|not_accessible|unknown`
     - `assistant:boolean`
   - Response:
     - list of places with computed score, status, distance, confidence signals.

2. `GET /api/places/:id`
   - Response:
     - place base info;
     - latest accessibility assessment;
     - evidence list;
     - change history summary.

3. `POST /api/places/:id/contributions`
   - Auth required.
   - Payload:
     - `status`
     - `entry_access`, `restroom_access`, `internal_mobility`, `parking_access`, `elevator_ramp_access`
     - `comment?`
     - `evidence_urls?`
   - Behavior:
     - insert contribution;
     - append audit log;
     - recalculate place score/status (RPC);
     - trigger Resend email receipt.

4. `POST /api/upload/evidence`
   - Auth required.
   - Returns signed upload URL for Supabase Storage.

5. `GET /api/places/:id/history`
   - Returns paginated change events.

6. `GET /api/export/a11yjson`
   - Returns A11yJSON-compatible payload for selected region.

## 5.2 Validation and error standard

- Input validation with Zod at route boundary.
- Standard error response:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "radius must be <= 10000"
  }
}
```

- HTTP status usage:
  - `200`, `201`, `400`, `401`, `403`, `404`, `409`, `429`, `500`.

## 6. Database Specification (Supabase/Postgres/PostGIS)

## 6.1 Extensions

- `postgis`
- `pgcrypto`
- `uuid-ossp` (if needed)

## 6.2 Enums

- `access_status`: `accessible`, `partially_accessible`, `not_accessible`, `unknown`
- `user_role`: `user`, `moderator`, `admin`, `partner`
- `source_type`: `community`, `partner`, `open_data`

## 6.3 Tables (MVP)

1. `profiles`
   - `id uuid pk` (same as `auth.users.id`)
   - `display_name text`
   - `role user_role default 'user'`
   - `city text`
   - `created_at timestamptz`

2. `places`
   - `id uuid pk`
   - `name text not null`
   - `category text not null`
   - `address text`
   - `location geography(Point, 4326) not null`
   - `status access_status default 'unknown'`
   - `score int default 0`
   - `confidence_score numeric(5,2) default 0`
   - `source source_type default 'open_data'`
   - `last_verified_at timestamptz`
   - `created_at timestamptz`
   - `updated_at timestamptz`

3. `accessibility_assessments`
   - `id uuid pk`
   - `place_id uuid fk -> places(id)`
   - `contributor_id uuid fk -> profiles(id) null` (null for imported data)
   - `status access_status not null`
   - `entry_access smallint check (entry_access between 0 and 2)`
   - `restroom_access smallint check (restroom_access between 0 and 2)`
   - `internal_mobility smallint check (internal_mobility between 0 and 2)`
   - `parking_access smallint check (parking_access between 0 and 2)`
   - `elevator_ramp_access smallint check (elevator_ramp_access between 0 and 2)`
   - `comment text`
   - `source source_type not null`
   - `created_at timestamptz`

4. `evidences`
   - `id uuid pk`
   - `assessment_id uuid fk -> accessibility_assessments(id)`
   - `storage_path text not null`
   - `mime_type text`
   - `created_at timestamptz`

5. `change_logs`
   - `id uuid pk`
   - `place_id uuid fk -> places(id)`
   - `actor_id uuid fk -> profiles(id) null`
   - `action text not null` (`create_assessment`, `update_place_status`, etc.)
   - `diff jsonb not null`
   - `created_at timestamptz`

6. `place_sources`
   - `id uuid pk`
   - `place_id uuid fk -> places(id)`
   - `external_provider text` (`osm`, `a11yjson`, etc.)
   - `external_id text`
   - `raw_payload jsonb`
   - `created_at timestamptz`

## 6.4 Indexing

- `places_location_gix` GiST on `places(location)`
- btree on `places(category, status)`
- btree on `accessibility_assessments(place_id, created_at desc)`
- btree on `change_logs(place_id, created_at desc)`

## 6.5 Scoring function (SQL RPC)

`recalculate_place_score(place_uuid uuid)`:

- uses weighted average of latest valid assessments;
- computes `score` (0-100);
- maps score to `status`;
- updates `confidence_score` based on recency + number of independent contributors;
- updates `places.updated_at`.

Weight suggestion:

- entry: 30%
- internal mobility: 25%
- restroom: 25%
- elevator/ramp: 10%
- parking: 10%

## 7. Security and RLS (Supabase)

## 7.1 Authentication

- Supabase Auth with email link/password for MVP.
- Anonymous read allowed for public place data.

## 7.2 Row Level Security policies

1. `places`
   - `SELECT`: public.
   - `INSERT/UPDATE/DELETE`: only service role or admin.

2. `accessibility_assessments`
   - `SELECT`: public.
   - `INSERT`: authenticated users.
   - `UPDATE/DELETE`: owner, moderator, or admin.

3. `evidences`
   - `SELECT`: public (or signed URL only, configurable).
   - `INSERT`: authenticated users tied to own assessment.
   - `DELETE`: owner/moderator/admin.

4. `change_logs`
   - `SELECT`: public summary endpoint only.
   - direct table access restricted to service role.

5. `profiles`
   - user can read/update own profile;
   - moderators/admin can read role metadata.

## 7.3 Abuse prevention

- endpoint rate limiting by IP + user id;
- contribution cooldown per place (`N` submissions/hour per user);
- captcha optional on suspicious traffic;
- server-side content sanitization for comments.

## 8. Email Specification (Resend)

## 8.1 Transactional emails (MVP)

1. Contribution receipt
   - Trigger: successful contribution insert.
   - Recipient: contributor.
   - Content: place name, submitted status, timestamp.

2. Moderation alert (optional feature flag for MVP)
   - Trigger: conflicting high-impact update (e.g., accessible -> not_accessible).
   - Recipient: moderation inbox.

## 8.2 Integration approach

- create `/api/internal/email/send` protected route or server utility;
- use Resend SDK server-side only;
- idempotency key per event (`event_type + contribution_id`) to avoid duplicates.

## 8.3 Email templates

- React Email templates versioned in repository;
- language: Portuguese (default), English fallback later;
- include unsubscribe/manage settings only for non-transactional emails.

## 9. Map and Geospatial Logic

## 9.1 Search query

- primary query by `ST_DWithin(places.location, userPoint, radiusMeters)`;
- order by:
  1. assistant mode: `status priority`, then `distance`, then `confidence_score`;
  2. normal mode: `distance`, then `status`, then `confidence_score`.

## 9.2 Assistant mode (MVP)

- if enabled:
  - clamp radius to `2500m` default;
  - require minimum status `partially_accessible` (or configurable);
  - sort for safest options first.

## 10. Interoperability (A11yJSON + OSM)

## 10.1 Internal canonical model

Canonical model is relational (Postgres), with mapping layers for:

- import from OSM tags;
- export to A11yJSON-compatible structure.

## 10.2 Mapping examples

- OSM `wheelchair=yes` -> `status=accessible`
- OSM `wheelchair=limited` -> `status=partially_accessible`
- OSM `toilets:wheelchair=yes` -> `restroom_access=2`

## 10.3 Export endpoint

`GET /api/export/a11yjson` supports:

- bbox and city filters;
- pagination;
- schema version in metadata.

## 11. Observability and Quality

## 11.1 Logging

- structured logs with request id;
- audit logs persisted in DB for domain events.

## 11.2 Metrics

- API p95 latency by endpoint;
- search success rate;
- contribution conversion;
- errors by type and status code.

## 11.3 Monitoring

- Vercel analytics + custom events;
- optional Sentry for frontend/backend error tracking.

## 12. CI/CD and Deployment (Vercel)

## 12.1 Environments

- `development` (local)
- `preview` (per PR on Vercel)
- `production` (main branch)

## 12.2 Pipeline

1. PR opened -> lint + typecheck + tests.
2. Vercel preview deploy created automatically.
3. Merge to main -> production deploy.
4. Supabase migrations applied before production promote.

## 12.3 Environment variables

Required:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` (server only)
- `RESEND_API_KEY`
- `RESEND_FROM_EMAIL`
- `NEXT_PUBLIC_APP_URL`
- `MAPS_API_KEY` (provider-specific)

Optional:

- `SENTRY_DSN`
- `FEATURE_MODERATION_ALERTS=true|false`

## 12.4 Domain and security headers

- custom domain on Vercel;
- enforce HTTPS;
- security headers via `next.config.ts`:
  - `Content-Security-Policy`
  - `X-Frame-Options`
  - `Referrer-Policy`
  - `Permissions-Policy`.

## 13. Testing Strategy

## 13.1 Unit tests

- scoring and status mapping functions;
- Zod validators;
- utility mappers (OSM/A11yJSON).

## 13.2 Integration tests

- API endpoints with test DB schema;
- RLS behavior for user/moderator/admin scenarios.

## 13.3 E2E tests

- search and filter flow;
- assistant mode flow;
- contribution submission with email trigger confirmation.

Tools:

- Vitest/Jest (unit/integration)
- Playwright (E2E)

## 14. Delivery Plan (Engineering)

## Sprint 1

- project bootstrap (Next.js + TS + Supabase clients);
- auth and base schema migrations;
- map view + nearby search endpoint.

## Sprint 2

- filters + assistant mode;
- place detail page;
- scoring RPC and confidence signals.

## Sprint 3

- contribution flow + evidence upload;
- change history;
- Resend transactional emails.

## Sprint 4

- accessibility hardening (WCAG checks);
- observability + performance pass;
- Vercel production readiness.

## 15. Open Technical Decisions

1. Map provider final choice (Mapbox vs Google Maps).
2. Evidence media moderation strategy for MVP.
3. Public visibility policy for raw evidence photos.
4. Import cadence for external open data sources.
5. Threshold values for status mapping and confidence score.

## 16. Definition of Done (MVP)

MVP is done when:

- all RF-01..RF-09 from PDD are implemented in production;
- RLS policies are enforced and tested;
- p95 search API latency is within agreed target for pilot cities;
- transactional emails are delivered for successful contributions;
- production deploy is stable on Vercel with monitoring enabled.
