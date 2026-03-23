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
| Testing | flutter_test + mocktail |
| CI/CD | GitHub Actions |
| Monitoring | Sentry |

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
├── infra/                Docker, GitHub Actions CI/CD
├── docs/                 Architecture documentation
└── melos.yaml            Workspace configuration
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.10
- [Dart SDK](https://dart.dev/get-dart) >= 3.0
- [Melos](https://melos.invertase.dev/) — `dart pub global activate melos`
- A [Supabase](https://supabase.com/) project (for auth and database)

### Setup

```bash
# Clone the repository
git clone https://github.com/logos-gs/widows-orphans.git
cd widows-orphans

# Install dependencies across all packages
melos bootstrap

# Run static analysis
melos run analyze

# Run tests
melos run test

# Generate Freezed models
melos run generate
```

### Backend (Dart Frog)

```bash
cd backend
cp .env.example .env
# Edit .env with your Supabase credentials
dart_frog dev
```

### Supabase

Apply the SQL migrations in `supabase/migrations/` to your Supabase project in order:

1. `00001_create_partner_orgs.sql`
2. `00002_create_users.sql`
3. `00003_create_need_requests.sql`
4. `00004_rls_policies.sql`

### Mobile App

```bash
cd apps/mobile
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Architecture Rules

1. No public identity layer. No profiles visible to others.
2. Requesters see only their own need status.
3. Helpers see only matched/assigned needs — never a browse-all feed.
4. Sponsor admins see only aggregate stats — never individual requester identity.
5. All routing is rule-based (no AI at launch).
6. RLS policies enforce data access at the database layer.
7. Fulfillment count is internal only — never a leaderboard.

## License

**Proprietary** — LOGOS Governance Systems, Inc. All rights reserved.

Unauthorized copying, distribution, or use of this software is strictly prohibited.
