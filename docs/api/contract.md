# TankUp API Contract — Phase 3

Base: Supabase REST (`/rest/v1`) + Auth + Storage. All driver endpoints require a
Bearer JWT; `driver_id` always equals `auth.uid()` — clients never send another
driver's id (RLS rejects it anyway).

## Conventions

- Errors: Supabase/PostgREST JSON `{code, message}`; app maps to toast copy.
- Timestamps: ISO-8601 UTC. Money: NGN numbers (`pp: 865` means ₦865).
- Lists: `?order=viewed_at.desc&limit=20`. Offline queue (ADR 003) replays in order.

## Driver (`drivers`)

| Method | Path | Body / notes |
|---|---|---|
| `GET` | `/drivers?id=eq.<uid>&select=*` | Own profile |
| `PATCH` | `/drivers?id=eq.<uid>` | `{display_name}` (1–40 chars). Phone/email changes go through verify-first flow below, not direct PATCH |

## Avatar (`storage.objects`, bucket `avatars`)

1. Client crops square, compresses ≤ 5MB (PRD §27.2).
2. `POST /storage/v1/object/avatars/<uid>/<uuid>.jpg` (own folder only — policy enforced).
3. `PATCH /drivers` with the public URL. Remove = set `avatar_url` null (+ delete object).

## Vehicles

| Method | Path | Notes |
|---|---|---|
| `GET` | `/vehicles?driver_id=eq.<uid>&order=created_at` | All + `is_active` |
| `POST` | `/vehicles` | `{nickname, energy, make?, model?, year?, plate?, connector?}` — energy ∈ Petrol/CNG/EV; connector EV-only |
| `PATCH` | `/vehicles?id=eq.<id>` | Edit fields; setting `is_active=true` requires first unsetting the current active (partial unique index guards doubles) |
| `DELETE` | `/vehicles?id=eq.<id>` | Deleting the active vehicle: client must promote another first (API returns 409 if it was the last one) |

## Preferences

| Method | Path | Notes |
|---|---|---|
| `GET` | `/preferences?driver_id=eq.<uid>` | Single row; created on first save (upsert) |
| `PUT` | `/preferences` (upsert `on_conflict=driver_id`) | Full preference object; validated enums (`theme`, `units`, `map_style`) |

## Saved / recent / searches / routes

- `GET/POST/DELETE /saved_stations?driver_id=eq.<uid>` (POST body `{station_id}`; DELETE by `station_id=eq.`)
- `GET/POST/DELETE /recent_stations` — same shape; capped at 10 client-side.
- `GET/POST/DELETE /recent_searches` — `{query}`; clear-all = `DELETE ?driver_id=eq.<uid>`.
- `GET/POST/DELETE /routes` — `{from_text, to_text}` for Trips tab.

## Stations (public catalogue)

- `GET /stations?select=*` + filters: `area=eq.Lekki`, `fuels=cs.{Petrol}`, `is_open=is.true`.
- Nearby: `order=location.desc&...` with PostGIS `ST_DWithin` via RPC `nearby_stations(lat,lng,radius_m)` (to be added with backend build; MVP reads seed + client-side distance).
- Write: service role only. Community price reports land in a moderation queue (Phase 9), never direct PATCH.

## Reviews

- `GET /reviews?station_id=eq.<id>&order=created_at.desc` — public.
- `POST /reviews` — `{station_id, rating 1–5, body}`; own rows deletable.

## Validation summary

Avatar type/size · phone/email uniqueness + OTP/email re-verify · ≥1 vehicle (fallback to onboarding picker) · rating 1–5 · enum fields rejected outside vocab.

## Exit mapping (plan Phase 3)

Contract reviewed vs §16/§17/§27 ✓ (this file) · seed queryable ✓ (`seed.sql`, 30 rows) · avatar round-trip defined ✓ (flow above; live test in Phase 4).
