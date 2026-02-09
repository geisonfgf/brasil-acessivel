# Sprint Backlog - Brasil Acessivel MVP

Date: 2026-02-09  
Source documents:
- `/Users/geisonfgf/Projects/saas/brasil-acessivel/docs/product-design-document-brasil-acessivel.md`
- `/Users/geisonfgf/Projects/saas/brasil-acessivel/docs/technical-specification-brasil-acessivel.md`

## Planning assumptions

- Sprint length: 2 weeks
- Team base: 1 full-stack engineer + 1 frontend engineer + 1 product/designer (part-time)
- Release target: 4 sprints (8 weeks)
- Priority scale:
  - P0 = required for MVP launch
  - P1 = should-have in MVP if capacity allows
  - P2 = post-MVP

## Epic E1 - Platform Setup and Delivery Pipeline

Goal: make the project deployable, testable, and ready for iterative delivery.

### Story E1-S1 (P0)

As an engineer, I want a Next.js + TypeScript project scaffold so the team can start implementation.

Acceptance criteria:

1. App uses Next.js App Router with TypeScript strict mode enabled.
2. Basic routes exist: `/`, `/login`, `/about`.
3. Lint and typecheck scripts run successfully in CI.
4. README contains local run instructions.

### Story E1-S2 (P0)

As an engineer, I want Vercel environments configured so preview and production deploys are automated.

Acceptance criteria:

1. Every PR creates a Vercel preview deployment.
2. Merge to `main` deploys to production.
3. Required environment variables are documented and configured.
4. Health-check endpoint responds in deployed environments.

### Story E1-S3 (P0)

As an engineer, I want Supabase project and migration workflow configured so schema changes are versioned.

Acceptance criteria:

1. Supabase CLI workflow exists in `infra/supabase`.
2. Initial migration folder is committed.
3. Team can run migrations locally and in staging.
4. Seed command populates pilot data.

## Epic E2 - Data Model, Security and Scoring

Goal: implement stable geospatial data model and secure access controls.

### Story E2-S1 (P0)

As a system, I need core tables for places and assessments so accessibility data is persistable.

Acceptance criteria:

1. Tables created: `profiles`, `places`, `accessibility_assessments`, `evidences`, `change_logs`, `place_sources`.
2. Required constraints and enums are implemented.
3. PostGIS extension enabled and `places.location` uses geography point.
4. Migration rollback path is validated.

### Story E2-S2 (P0)

As an engineer, I want RLS policies implemented so public reads and controlled writes are enforced.

Acceptance criteria:

1. Anonymous users can read public place/search data.
2. Authenticated users can create contributions.
3. Only owner/moderator/admin can modify/delete own contribution.
4. Policy tests pass for user/moderator/admin scenarios.

### Story E2-S3 (P0)

As a user, I want place accessibility status to be computed consistently so ranking is trustworthy.

Acceptance criteria:

1. `recalculate_place_score` RPC is implemented.
2. Score (0-100), status enum, and confidence score are updated after contribution.
3. Weighting rules match technical spec defaults.
4. Unit tests cover status mapping and edge cases.

## Epic E3 - Search and Map Experience

Goal: deliver the main discovery flow (RF-01 to RF-05).

### Story E3-S1 (P0)

As a user, I want to open the app and see nearby accessible places on the map.

Acceptance criteria:

1. Geolocation permission flow is implemented.
2. Nearby query returns places by distance.
3. Markers and list render with status badges.
4. Empty/error states are accessible and clear.

### Story E3-S2 (P0)

As a user, I want to search by address/city so I can plan in another region.

Acceptance criteria:

1. Search input supports address/city text.
2. Map recenters to selected region.
3. Results refresh correctly with same filter context.
4. Invalid search terms show actionable feedback.

### Story E3-S3 (P0)

As a user, I want filters (category, distance, minimum accessibility) so I can narrow results.

Acceptance criteria:

1. Filter UI is keyboard-accessible.
2. API applies all filters server-side.
3. Filter state persists during navigation (URL params or equivalent).
4. Results count and applied filters are visible.

### Story E3-S4 (P0)

As a user, I want an accessibility assistant mode so I quickly get safer options.

Acceptance criteria:

1. Assistant toggle exists in search/filter panel.
2. Assistant clamps default radius to 2500m (configurable).
3. Sorting prioritizes accessibility and confidence before distance.
4. Assistant behavior is documented in UI hint text.

## Epic E4 - Place Details and Community Contribution

Goal: allow users to inspect and improve data (RF-06 to RF-08).

### Story E4-S1 (P0)

As a user, I want a place detail page so I can inspect accessibility attributes before deciding.

Acceptance criteria:

1. `/place/[id]` page shows status, score, confidence signals, and last update date.
2. Detail includes core attributes: entrance, internal mobility, restroom, parking, elevator/ramp.
3. Page loads from API and handles unknown/missing attributes.
4. Change history summary is visible.

### Story E4-S2 (P0)

As an authenticated user, I want to submit an accessibility contribution for a place.

Acceptance criteria:

1. Contribution form validates required fields client and server side.
2. Submission creates assessment row and change log row atomically.
3. Place score/status recalculates after success.
4. User receives success confirmation in UI.

### Story E4-S3 (P1)

As an authenticated user, I want to attach evidence images to increase trust.

Acceptance criteria:

1. Signed upload flow is implemented for Supabase Storage.
2. Allowed types and max file size are enforced.
3. Evidence records link to the generated assessment.
4. Unauthorized uploads are blocked.

## Epic E5 - Email and Notifications

Goal: establish transactional communication via Resend.

### Story E5-S1 (P0)

As a contributor, I want an email receipt confirming my submission.

Acceptance criteria:

1. Resend API integration is server-side only.
2. Contribution success triggers one idempotent receipt email.
3. Template includes place name, submitted status, and timestamp.
4. Delivery failures are logged and retriable.

### Story E5-S2 (P1)

As a moderator, I want alerts for conflicting high-impact updates.

Acceptance criteria:

1. Feature-flagged moderation alerts are implemented.
2. Conflict rule is defined (e.g., accessible -> not_accessible).
3. Alert email includes link to place details/history.
4. Events are tracked in logs.

## Epic E6 - Interoperability, Quality and Launch

Goal: ensure MVP is operable, measurable, and ready for production.

### Story E6-S1 (P0)

As a system, I want export in A11yJSON-compatible format so data can interoperate with external tools.

Acceptance criteria:

1. `GET /api/export/a11yjson` supports bbox/city filters.
2. Payload contains schema version metadata.
3. Output maps canonical model fields correctly.
4. Endpoint pagination is implemented.

### Story E6-S2 (P0)

As a product team, we want observability so we can monitor reliability and usage.

Acceptance criteria:

1. Structured logs include request ID and user role context.
2. Metrics exist for API latency, search success, and contribution conversion.
3. Error tracking is enabled in preview/production.
4. Dashboard or runbook location is documented.

### Story E6-S3 (P0)

As a user with assistive tech, I want critical flows to meet accessibility standards.

Acceptance criteria:

1. Core flows pass WCAG 2.2 AA checklist.
2. Keyboard-only navigation works for search and contribution.
3. Color contrast meets AA requirements.
4. Screen-reader labels are validated on critical controls.

## Sprint-to-story allocation

## Sprint 1 (Foundation)

- E1-S1, E1-S2, E1-S3
- E2-S1

Sprint goal:

- deployable skeleton with DB foundation and migration workflow.

## Sprint 2 (Core discovery)

- E2-S2, E2-S3
- E3-S1, E3-S2, E3-S3, E3-S4

Sprint goal:

- end-to-end search, filters, and assistant mode with secure backend.

## Sprint 3 (Contribution + trust)

- E4-S1, E4-S2, E4-S3
- E5-S1

Sprint goal:

- full contribution pipeline with scoring updates and receipt emails.

## Sprint 4 (Launch hardening)

- E5-S2
- E6-S1, E6-S2, E6-S3

Sprint goal:

- interoperability export, observability, and launch readiness.

## Definition of Ready (DoR)

Story is ready when:

1. business objective is clear;
2. dependencies are identified;
3. API/schema impact is documented;
4. acceptance criteria are testable.

## Definition of Done (DoD)

Story is done when:

1. code merged to `main`;
2. tests pass in CI;
3. deployed to preview (and production when applicable);
4. documentation updated (API, schema, runbook);
5. telemetry and logs verified for new functionality.

## Risk backlog

1. Map provider cost risk at scale.
2. Uneven data coverage across cities.
3. Contribution abuse/spam attempts.
4. Performance degradation on large-radius queries.
5. Delays in accessibility QA with real users.

## Suggested first GitHub Issues (ready to create)

1. Bootstrap Next.js + TypeScript + App Router
2. Configure Vercel preview/prod + env vars
3. Add Supabase schema migration v1 with PostGIS
4. Implement RLS policies for places/assessments/evidences
5. Build `/api/places/search` with geospatial filters
6. Build home map page with geolocation and filters
7. Implement assistant mode ranking
8. Build place details page
9. Implement contribution endpoint + score recalculation
10. Integrate Resend contribution receipt email
11. Add A11yJSON export endpoint
12. Add observability baseline (logs/metrics/errors)
