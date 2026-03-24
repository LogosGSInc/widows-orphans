# Widows & Orphans

**Dignified care coordination for the most vulnerable.**

> *The app should have nothing to show you when your work is done.*

A closed-loop community care platform that connects people in need with local helpers, churches, and ministries — without turning suffering into engagement metrics. No feed. No social primitives. No vanity metrics. Just a task-state driven tool for getting help to those who need it.

**Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.**

---

## Mission

The person asking for help will never pay. The platform monetizes infrastructure, not suffering.

Widows & Orphans routes care requests through trusted community networks — churches, ministries, nonprofits — using rule-based matching, role-based access, and row-level security to protect the dignity and privacy of every person who asks for help.

## Core Loop

```
Submit Request → Review/Match → Claim → Fulfill → Confirm Close
```

## Features

### Phase 1 — Foundation
- Monorepo structure with Melos
- Supabase schema with row-level security (RLS)
- Shared domain models (Freezed + json_serializable)
- Flutter authentication flow
- Dart Frog backend with JWT auth middleware

### Phase 2 — Core Loop
- Requester flow: submit needs, track status, fulfillment confirmation
- Helper flow: view available needs, claim, mark fulfilled
- Moderator/Org Admin flow: need queue, review, assign, escalate
- API routes for all core operations
- Realtime status updates via Supabase

### Phase 3 — Partner Dashboard
- Flutter Web partner portal
- Organization queue management
- Helper roster and invitation system
- Reporting and analytics dashboard
- CSV export for offline workflows
- Sponsor tagging for backed needs

### Phase 4 — Pilot Hardening
- **Sentry integration** across mobile, web, and backend with PII scrubbing
- **Rate limiting**: 5 needs per user per 24 hours (429 response)
- **Claim limits**: max 3 active needs per helper (409 response)
- **Flag/report endpoint**: any user can flag a need, auto-transitions to UNDER_REVIEW
- **GitHub Actions CI/CD**: analyze, test, build-web, build-backend
- **Integration and unit test suite**: core loop, rate limits, auth, widget tests
- **Pilot onboarding documentation** for Care Pastors and helpers

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Client | Flutter 3.x (Dart) — iOS & Android |
| Web Client | Flutter Web — Partner org dashboards |
| Backend API | Dart Frog |
| Database & Auth | Supabase (PostgreSQL, JWT, RLS, Realtime) |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| Models | Freezed + json_serializable |
| Monorepo | Melos |
| Testing | flutter_test + mocktail + integration_test |
| CI/CD | GitHub Actions |
| Monitoring | Sentry (with PII scrubbing) |

## Monorepo Structure

```
widows-orphans/
├── apps/
│   ├── mobile/           Flutter mobile app (iOS + Android)
│   └── web/              Flutter web app (partner dashboards)
├── packages/
│   ├── domain/           Shared domain models, enums, value objects
│   ├── api_client/       Generated Dart API client
│   └── ui_kit/           Shared Flutter widget library
├── backend/              Dart Frog API server
├── supabase/
│   └── migrations/       SQL schema + RLS policies
├── .github/
│   └── workflows/        GitHub Actions CI/CD
├── docs/                 Architecture & onboarding documentation
└── melos.yaml            Workspace configuration
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.10
- [Dart SDK](https://dart.dev/get-dart) >= 3.0
- [Melos](https://melos.invertase.dev/) — `dart pub global activate melos`
- A [Supabase](https://supabase.com/) project (for auth and database)
- A [Sentry](https://sentry.io/) project (for error monitoring)

### Setup

```bash
# Clone the repository
git clone https://github.com/logos-gs/widows-orphans.git
cd widows-orphans

# Install dependencies across all packages
melos bootstrap

# Generate Freezed models
melos run generate

# Run static analysis
melos run analyze

# Run tests
melos run test
```

### Backend (Dart Frog)

```bash
cd backend
cp .env.example .env
# Edit .env with your Supabase and Sentry credentials
dart_frog dev
```

**Environment variables** (see `backend/.env.example`):

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key |
| `SUPABASE_SERVICE_KEY` | Supabase service role key (backend only) |
| `JWT_SECRET` | Secret for JWT token verification |
| `SENTRY_DSN` | Sentry Data Source Name for error reporting |
| `ALLOWED_ORIGINS` | Comma-separated CORS origins |
| `PORT` | Server port (default: 8080) |

### Supabase

Apply the SQL migrations in `supabase/migrations/` to your Supabase project in order:

1. `00001_create_partner_orgs.sql` — Partner organization table
2. `00002_create_users.sql` — Users with roles and trust tiers
3. `00003_create_need_requests.sql` — Need requests with full lifecycle
4. `00004_rls_policies.sql` — Row-level security for all tables
5. `00005_add_flag_support.sql` — Need flagging for moderator review

### Mobile App

```bash
cd apps/mobile
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/id
```

### Web App (Partner Portal)

```bash
cd apps/web
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/id
```

### Running Tests

```bash
# All unit tests across packages
melos run test

# Mobile integration tests
cd apps/mobile && flutter test integration_test/

# Backend tests only
cd backend && dart test
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| POST | `/needs` | Create a need (rate limited: 5/day) |
| GET | `/needs/mine` | List requester's own needs |
| GET | `/needs/available` | List available needs for helpers |
| GET | `/needs/queue` | Organization need queue |
| GET | `/needs/:id` | Get a single need |
| PUT | `/needs/:id` | Update a need |
| PATCH | `/needs/:id/status` | Update need status |
| POST | `/needs/:id/assign` | Assign helper (claim limited: 3 active) |
| POST | `/needs/:id/escalate` | Escalate to moderator |
| POST | `/needs/:id/flag` | Flag need for review |
| GET | `/orgs/:id/stats` | Organization dashboard stats |
| GET | `/orgs/:id/reports` | Reporting and analytics |
| GET | `/orgs/:id/settings` | Organization settings |
| POST | `/orgs/:id/invite` | Invite a helper |
| GET | `/orgs/:id/helpers` | List organization helpers |

## Architecture Rules

1. No public identity layer. No profiles visible to others.
2. Requesters see only their own need status.
3. Helpers see only matched/assigned needs — never a browse-all feed.
4. Sponsor admins see only aggregate stats — never individual requester identity.
5. All routing is rule-based (no AI at launch).
6. RLS policies enforce data access at the database layer.
7. Fulfillment count is internal only — never a leaderboard.
8. Sentry never logs PII (descriptions, locations, names, emails).

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — System design and data model
- [Pilot Onboarding](docs/pilot_onboarding.md) — Guide for Care Pastors and helpers

## License

**Proprietary** — LOGOS Governance Systems, Inc. All rights reserved.

Unauthorized copying, distribution, or use of this software is strictly prohibited.
