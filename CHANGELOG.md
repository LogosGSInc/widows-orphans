# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [0.1.0-pilot] — 2026-03-24

First pilot release. Stability, safety, and dignity above all.

### Added

#### Monitoring & Observability
- Sentry integration across mobile app, web app, and backend
- PII scrubbing in Sentry `beforeSend` callback — requester descriptions, location zones, names, and emails are never transmitted
- `SentryNavigatorObserver` for mobile route tracking
- Backend Sentry middleware for unhandled exception capture

#### Rate Limiting & Abuse Controls
- Rate limit middleware: 5 POST /needs per user per 24-hour window (429 response)
- Claim limit enforcement: max 3 active needs per helper (409 response)
- `POST /needs/:id/flag` endpoint — any authenticated user can flag a need
- Flagged needs auto-transition to UNDER_REVIEW status
- New `need_flags` table with RLS policies (migration 00005)

#### CI/CD
- GitHub Actions workflow at `.github/workflows/ci.yml`
- Four jobs: `analyze`, `test`, `build-web`, `build-backend`
- Build jobs gate on analyze + test success
- Build jobs run only on pushes to main

#### Testing
- Integration tests: core loop submission, anonymous privacy, RLS enforcement, rate limiting, flag/report flow
- Unit tests: domain enum serialization, rate limit middleware logic, JWT auth validation, Sentry PII scrubbing
- Widget tests: StatusBadge rendering for all statuses, NewRequestScreen form validation

#### Documentation
- Pilot onboarding package (`docs/pilot_onboarding.md`):
  - Care Pastor Quick Start — org setup, helper invitations, first need walkthrough
  - Requester Dignity Guide — language to use and avoid, privacy assurances
  - Helper Training Guide — claiming needs, fulfillment, anonymity rules, claim limits
  - Privacy Commitments — data collected, data never collected, role-by-role visibility
  - Support contact and response time commitment

#### Infrastructure
- Complete `.env.example` with all required environment variables
- Updated README.md with Phase 2–4 features, full API reference, and setup instructions

### Phase History

- **Phase 1** — Monorepo, Dart Frog backend, Supabase schema/RLS, domain models, Flutter auth
- **Phase 2** — Core loop (requester, helper, moderator flows), API routes, realtime
- **Phase 3** — Partner dashboard (queue, helpers, reports, settings, CSV export, sponsor tagging)
- **Phase 4** — Pilot hardening (this release)
