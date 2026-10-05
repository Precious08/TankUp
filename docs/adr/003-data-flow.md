# ADR 003 — Data flow: offline-first, local cache reads

Status: Accepted.

## Context

Drivers lose signal on highways; settings must never block discovery (PRD §27.9). Free-tier backend can also pause or throttle.

## Decision

- Local SQLite/Hive cache is the **read source** for stations, saved, vehicles, and preferences.
- Supabase syncs in the **background**; every write applies locally first, then queues for upload.
- Every settings screen shows **Synced / Sync pending** (PRD §27.9); conflicts resolve last-write-wins with a visible "updated just now" stamp.
- Station prices carry `updated_at`; UI shows "updated X ago" and never silently serves data older than 24h without a stale badge.

## Consequences

- Good: airplane-mode pass possible (map cache + queued settings + saved stations); backend pauses never blank the app.
- Watch: queue + conflict logic must be built once in `core/sync/` and reused — not per screen.
