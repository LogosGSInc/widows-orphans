# Widows & Orphans — Architecture Overview

> Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
> Proprietary and confidential.

## Mission

Widows & Orphans is a closed-loop community care coordination platform.
It connects people in need with local helpers, churches, and ministries —
without turning suffering into engagement metrics.

## Governing Design Law

**The app should have nothing to show you when your work is done.**

No feed. No engagement loops. No social primitives. No vanity metrics.
This is a task-state driven tool, not a social platform.

## Core Loop (V1)

```
Submit Request → Review/Match → Claim → Fulfill → Confirm Close
```

## Architecture Rules

1. No public identity layer. No profiles visible to others.
2. Requesters see only their own need status.
3. Helpers see only matched/assigned needs — never a browse-all feed.
4. Sponsor admins see only aggregate stats — never individual requester identity.
5. All routing is rule-based (no AI at launch).
6. RLS policies enforce data access at the database layer.
7. Fulfillment count is internal only — never a leaderboard.

## Tech Stack

| Layer | Technology | Role |
|-------|-----------|------|
| Mobile Client | Flutter 3.x (Dart) | iOS & Android app |
| Web Client | Flutter Web (Dart) | Partner org dashboards, sponsor admin |
| Backend API | Dart Frog | REST / WebSocket API server |
| Database | PostgreSQL (Supabase) | Primary relational store |
| Auth | Supabase Auth | JWT, RLS, role-based access |
| Realtime | Supabase Realtime | Need status push updates |
| Storage | Supabase Storage | Optional media |
| State Mgmt | Riverpod 2.x | Reactive state with code generation |
| Navigation | GoRouter | Declarative, role-aware routing |
| Models | Freezed + json_serializable | Immutable models, JSON contracts |
| Testing | flutter_test + mocktail | Unit, widget, integration coverage |
| CI/CD | GitHub Actions | Build, test, deploy pipeline |
| Monitoring | Sentry | Crash reporting, error tracking |

## Monorepo Structure

```
apps/mobile/       — Flutter mobile app (iOS + Android)
apps/web/          — Flutter web app (partner org dashboards)
packages/domain/   — Shared Dart package: domain models, enums, value objects
packages/api_client/ — Generated Dart API client
packages/ui_kit/   — Shared Flutter widget library
backend/           — Dart Frog API server
supabase/          — Migrations, RLS policies, seed SQL
infra/             — Docker, GitHub Actions CI/CD
docs/              — Architecture documentation
```

## Data Model

### Core User Roles

| Role | Responsibility |
|------|---------------|
| Requester | Submits a need with category, location zone, urgency, and optional description |
| Helper | Sees locally-eligible or assigned needs; claims and fulfills them |
| Partner Org | Church, ministry, or nonprofit with a dashboard, queue, and coordination tools |
| Moderator | Reviews flagged or sensitive needs; manages escalation and coverage gaps |
| Sponsor | Underwrites need categories or regions; no direct access to requester identities |

### Need Lifecycle

```
OPEN → UNDER_REVIEW → MATCHED → IN_PROGRESS → FULFILLED → CLOSED
                                                     ↗
                                          ESCALATED ──┘
```

## Monetization

The person asking for help will never pay. The platform monetizes infrastructure, not suffering.

| Revenue Stream | Description |
|---------------|-------------|
| Partner Org Dashboard | $49–$199/month |
| Organization Onboarding | $250 one-time setup |
| Sponsor Lane Subscription | $250–$500/month |
| Premium Moderation Tools | Higher tiers for large organizations |
| Multi-Site License | Network-wide access pricing |
