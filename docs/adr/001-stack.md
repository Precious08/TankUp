# ADR 001 — Stack: Flutter + Supabase + Mapbox

Status: Accepted.

## Context

TankUp needs iOS + Android from a solo/beginner team at $0 with no credit card (PRD §28 rule). Backend must cover auth, relations, avatar storage, and per-driver privacy (§17, §27.9). Maps must cover display, search, and routing (§6, §12, §13).

## Decision

- App: **Flutter** (Riverpod for state). One codebase, strong map plugins, good offline story.
- Backend: **Supabase Free** — Postgres + Auth + Storage + row-level security. 2 projects (dev/prod), 500MB DB, 1GB storage, 50k MAU.
- Maps/search/routing: **Mapbox, all three** — free allowance, no card.
- Push/crash/analytics/beta: **FCM + Firebase Crashlytics/Analytics + App Distribution**.
- CI/design: **GitHub Actions + Penpot**.

## Consequences

- Good: $0 until traction; upscale path documented per layer (Termii → Pro $25 → Play $25 → Google Places → Apple $99).
- Watch: Supabase Free pauses after 7 idle days and has no backups → weekly manual exports (Phase 4 task). Mapbox POI search is weaker than Google → Google Places parked as the upscale pick, not a dependency.
