# TankUp — Implementation Plan

Source of truth: `TankUp-PRD.md` (§22 MVP = 14 items, §27 Driver Dashboard/Backend).
Repo state at planning time: `README.md` + PRD only, no code, git clean, `main` in sync with `origin/main`. No `.gitignore` yet.

How to use this plan: work phases in order. Each phase has a goal, tasks, and exit criteria. Do not start the next phase until exit criteria pass.

---

## Stack (decide once, Phase 0) — ALL FREE NOW, upscale later

Everything below is $0 with no credit card. The "Upscale" column names the highly recommended paid step when a free limit (not a preference) forces it.

| Layer | Now (free) | Why it meets the task | Upscale (highly recommended later) |
|---|---|---|---|
| Mobile app | Flutter | One codebase iOS+Android, strong map plugins, offline story | Native modules only if a feature proves impossible in Flutter |
| Backend/Auth/DB/Storage | Supabase Free | Auth (email OTP, Google/Apple), Postgres+RLS, avatar storage; 2 projects (dev+prod), 500MB DB, 1GB storage, 50k MAU | Supabase Pro $25/mo — backups, never pauses, 8GB DB, 100GB storage |
| Maps + search + routing | Mapbox (all three) | Generous free allowance, no card; Maps + Geocoding + Directions cover §6/§12/§13 for MVP | Google Maps Platform Places — best Nigerian POI/station search; mobile SDK loads unlimited free, Places/Directions have per-SKU caps (~10k/5k per SKU/mo). Needs billing account + card. Old $200 credit ended Mar 2025 |
| Push | FCM direct | Free, unlimited | OneSignal (easier dashboard/segmentation) if push ops grow |
| Crash + analytics | Firebase Crashlytics + Analytics | Free, no card | Sentry (richer crash triage) + PostHog/Mixpanel (product funnels) |
| Beta distribution | Firebase App Distribution + TestFlight | Free | — |
| CI | GitHub Actions | Free minutes included | Codemagic (Flutter device farms) when device matrix grows |
| Design | Penpot | Free, unlimited files, open source | Figma Professional when real-time designer collaboration demands it |
| State (app) | Riverpod (Flutter) | Free | — |
| SMS OTP | Deferred — email OTP + Google/Apple only | SMS is never free | Termii (Nigerian, pay-as-you-go in naira) |

Rules: no tool requiring a credit card enters the stack before traction. No SMS spend before traction. Record the final call in `docs/adr/001-stack.md`.

If you prefer React Native, swap Flutter→React Native + TanStack Query; everything else stays.

---

## Phase 0 — Repo & ways of working

Goal: safe ground to build on.

- [x] Add `.gitignore` (Flutter-ready + `.env` + `*.keystore`/`*.jks`).
- [x] Rename PRD file to `docs/TankUp-PRD.md`. README link updated.
- [x] Branching: `main` (protected) + `dev` + `feat/<name>` branches. PRs into `dev`, release PRs into `main`. (Branch plan also in README.)
- [x] Secrets: `.env.example` committed, real `.env` never committed. Maps key + Supabase keys per environment (dev/staging/prod).
- [ ] Tooling: format/lint on save, pre-commit hook, conventional commits (`feat:`, `fix:`, `docs:`). — starts with first app code.

Exit: `git status` clean, `.gitignore` present, branch plan written in README, keys load from `.env`.

---

## Phase 1 — Design system (before any feature UI) — DONE (pending sunlight sign-off)

Goal: every screen looks like TankUp from day one. Maps PRD §24 (simple, fast, safety-conscious).

- [x] Tokens in `lib/design/tokens.dart` (color, type, spacing, radii — gallery-mirrored, AA-checked).
- [x] Gallery in `gallery.html` (9 sections: color, type, spacing, buttons, inputs, card+sheet, markers, toggles/banners/loading, rules checklist) with working light+dark toggle.
- [x] Contrast pass: action green #15803D/white 5.0:1, secondary #475569 7.5:1, dark-mode flips (luminous tags, glowing primary button), dedicated light shimmer gradient.
- [ ] Sunlight sign-off: approve gallery + markers on a real phone outdoors (owner task).

1. **Tokens** (`lib/design/tokens.dart` or equivalent):
   - Colors: primary (energy green), Petrol/CNG/EV marker colors (3 distinct, colorblind-safe), surface, error, warning (closed/no-fuel states). Light + dark values.
   - Typography: display / title / body / caption scale, min body 16sp for driving legibility.
   - Spacing (4/8/16/24), radii, elevation, motion durations.
2. **Components**: AppBar+search field, filter chip, station card, station details sheet, marker pins (3 energy types + selected state), buttons (primary Get Directions, secondary Save), empty states, offline banner, skeleton loaders.
3. **Map styling**: standard/satellite/traffic styles, marker set for Petrol/CNG/EV + closed/greyed variant, user-location dot.
4. **Rules**: tap targets ≥48dp, contrast ≥4.5:1, no heavy interaction while navigating (large Get Directions, voice-first).
5. **Deliverable**: a `DesignGallery` screen rendering every token/component in light + dark.

Exit: gallery screen approved on a real phone in sunlight; markers distinguishable without reading labels.

---

## Phase 2 — Architecture decisions — DONE

Goal: no rework later. One-page ADRs in `docs/adr/` — all five accepted:

1. `001-stack.md` — final stack (see table above).
2. `002-app-structure.md` — feature-first folders: `features/{home,search,saved,trips,profile,stations,navigation}/…` + `core/{network,location,storage,design}/…`.
3. `003-data-flow.md` — offline-first: local cache (SQLite/Hive) is read source; Supabase syncs in background; every settings edit queues when offline (§27.9).
4. `004-auth.md` — guest mode default; OTP (phone) + Google/Apple on upgrade; guest data migrates on sign-up (§17).
5. `005-maps.md` — Mapbox for ALL map needs (display + Geocoding + Directions), no card. Google Places is documented as the upscale pick for §6 search quality, not a dependency. Distance/ETA from Mapbox Directions; fallback straight-line distance offline. Corridor search cached to stay inside the free allowance; add a Mapbox usage dashboard check to the weekly routine.

Exit: 5 ADRs merged; folder skeleton exists with no dead code.

---

## Phase 3 — Data model + API contract — DONE

Goal: backend and app agree before coding (§27.9).

- [x] Schema in `supabase/migrations/0001_schema.sql` (9 tables, PostGIS geo, one-active-vehicle guard, `updated_at` triggers, full RLS, `avatars` bucket ≤5MB).
- [x] Seed in `supabase/seed.sql` (wave 1: 30 Lagos stations, mixed fuels/prices/availability).
- [x] National scope: `state/lga/lcda` on stations (`0002_coverage.sql` + Lagos backfill); rollout waves + gates in `supabase/seed-national.md` (36 states + FCT, every LGA/LCDA).
- [x] Contract in `docs/api/contract.md` (endpoints, avatar flow, validation, RLS summary).

Tables (Supabase Postgres):
- `drivers(id, display_name, avatar_url, phone, email, created_at)`
- `vehicles(id, driver_id, nickname, energy_type, make, model, year, plate, connector, is_active)`
- `preferences(driver_id PK, theme, language, units, currency, map_style, default_filters, nav_avoid, voice_on, notif_* , quiet_hours)`
- `stations(id, name, address, lat, lng, energy_types[], petrol_price, cng_price, ev_info, open_hours, is_open, availability{}, rating, review_count)`
- `saved_stations(driver_id, station_id, created_at)` / `recent_stations(...)` / `recent_searches(...)` / `routes(id, driver_id, from, to, created_at)`
- `reviews(id, station_id, driver_id, rating, text, created_at)`

API (Supabase REST + Storage):
- `GET/PATCH /me`, `POST /me/avatar` (5MB, square crop, initials fallback)
- `CRUD /me/vehicles` (exactly one `is_active`; deleting active forces repick)
- `GET/PUT /me/preferences`, `CRUD /me/saved`, history endpoints with per-item + clear-all delete
- Validation: unique phone/email with OTP/email re-verify; RLS so drivers only touch their rows.

Seed: 30–50 Lagos stations (Lekki/Ikoyi/VI) with mixed energy types, prices in ₦, open/availability flags — enough to demo compare + route Lagos→Ibadan.

Exit: contract doc reviewed against §16/§17/§27; seed data queryable; avatar upload round-trips.

---

## Phase 4 — Backend build — MOSTLY DONE (live project running)

Goal: working API + auth + storage before app features.

Done: `tankup-dev` live, migrations 0001–0003 + both seeds run (215 rows verified), Email OTP on, Google OAuth on (Cloud project `tankup`, Web client, test user added), `avatars` bucket public with policies, demos reading live with bundled fallback (`config.local.js`, gitignored). Left: `tankup-prod` clone before launch. First real Google-login click-test happens with the app login screen (Phase 5).

- [ ] Supabase project (dev + prod = the 2 Free projects), migrations for all tables, RLS policies, seed script.
- [ ] Auth: email OTP + Google/Apple + guest→account migration. Phone (SMS) OTP explicitly deferred — SMS is never free; use Termii pay-as-you-go only after traction.
- [ ] Free-tier survival: keep dev project active (Free pauses after 7 idle days); weekly manual DB export committed nowhere secret (Free has no backups); compress avatars on-device before upload to stay inside 1GB storage.
- [ ] Storage bucket `avatars` with resize rules.
- [ ] Push hooks (price/availability change events stubbed; real triggers in Phase 9).
- [ ] Health endpoint + seed verify.

Exit: Postman/HTTP file runs green against dev; RLS blocks cross-driver reads (tested).

---

## Phase 5 — App scaffold + navigation shell (PRD §21) — SCAFFOLD DONE (in `app/`)

Goal: five tabs with empty-but-routed screens.

- Tabs: Home / Search / Saved / Trips / Profile (Home is primary).
- Onboarding (§18): Welcome → Choose vehicle → Nearby explainer, skippable, guest allowed.
- Location permission flow with graceful denied-state UI.
- Guest banner in Profile ("Sign in to sync"), all settings still editable locally.

Exit: app launches cold to map tab <2s on mid-range Android; onboarding completable in 3 taps.

---

## Phase 6 — Discovery: map, search, filters, card, details, compare (PRD §6–§11)

Goal: Open → Find → Compare → Choose.

Surface strategy (decided): `mobile.html` is the single demo surface (retired `demo.html` to `docs/archive/` — it duplicated mobile and doubled maintenance).

- Home map: user dot, station markers (3 types), re-center button, bottom sheet (nearby list + quick filters + saved/recent).
- Search: station/area/street/destination; "Lekki" returns stations around Lekki.
- Filters: Petrol/CNG/EV, price, distance, availability, Open now — one tap, no leaving map.
- Station card (§8): name, distance, ETA, energy chips, price, availability, open/closed + View details / Get directions.
- Details (§9): full info + rating/reviews + map snippet + Save.
- Compare (§10): simple table of nearby same-fuel prices.
- Availability (§11): open/closed PLUS per-energy availability (open ≠ has fuel).

Exit: with seed data, find→compare→open details in <30s; filters re-render map instantly.

---

## Phase 7 — Route discovery + in-app navigation (PRD §12–§13)

Goal: stations along the route, then guidance.

- Route input (e.g. Lagos → Ibadan); corridor search returns on-route stations (not just nearest).
- Select station → in-app navigation: current location, route polyline, distance, ETA, turn-by-turn, persistent station chip (energy, price, availability).
- Voice guidance toggle; safety: minimal taps while moving.

Exit: Lagos→Ibadan shows ≥3 on-route options; navigation keeps station chip visible; ETA updates live.

---

## Phase 8 — Driver dashboard + settings (§27, §16–§17)

Goal: driver can change everything in <30s per item, all inside Profile.

- 27.1 layout: avatar header + groups (Vehicles, Preferences, Stations&Trips, Notifications, Privacy, Support, Sign out/Delete).
- 27.2 profile: avatar/photo/crop/remove, name, phone/email re-verify, home/work.
- 27.3 vehicles: full CRUD + active switch re-filters Home instantly; EV connector fields only for EV.
- 27.4–27.6 prefs: theme/language/units/currency/map style/default filters; nav avoidances; granular notifications + quiet hours.
- 27.7–27.8: manage saved/recent/trips, clear history, download data, sign out everywhere, delete account.
- Sync states everywhere: Synced / Sync pending; offline edits queue.

Exit: script test — change avatar, name, vehicle, notif prefs each <30s; reinstall restores everything via login.

---

## Phase 9 — Ratings, trips, notifications (§19, §20, Trips tab)

- Ratings/reviews read + write; secondary placement, never blocking discovery.
- Trips tab: recent + planned routes, re-run route search.
- Notifications: price/availability/route events for saved stations, user-controlled.

Exit: review posts and appears; toggling a notification stops that category within 1 minute.

---

## Phase 10 — Quality gates

- Testing: unit (pricing/filter logic), widget (card/details/dashboard), integration (onboarding→navigate), RLS security tests.
- Performance: cold start <2s, map pan 60fps target, images cached, list virtualization.
- Offline: airplane-mode pass for map cache + queued settings + saved stations.
- Accessibility + driving safety review (§24): font scaling, TalkBack, sun-glare check.
- Battery: location throttling while navigating.

Exit: all gates green on 2 real devices (low-end + mid-range Android).

---

## Phase 11 — Beta, release, learn

- Closed beta (20–50 Lagos drivers across Petrol/CNG/EV), analytics: find→navigate conversion, time-to-station, filter usage, settings success.
- Success bar (PRD §25): driver completes Open→Find→Compare→Choose→Navigate quickly; can state price + availability before leaving.
- Store release (Play first), crash monitoring, staged rollout.
- Post-MVP parking lot (§23): payments, reservations, loyalty, community reporting — explicitly out of MVP.

---

## Appendix A — MVP traceability (§22)

| # | MVP item | Phase |
|---|---|---|
| 1–4 | Map discovery, 3 fuel types, search, filters | 6 |
| 5–8 | Cards, details, compare, availability | 6 |
| 9–10 | Saved, vehicle pref | 6, 8 |
| 11–12 | Route discovery, in-app nav | 7 |
| 13 | Optional account | 4, 5 |
| 14 | Driver dashboard/settings backend | 3, 4, 8 |

## Appendix B — Top risks

1. Station data accuracy (prices/availability) → seed + community-report stub, show "updated X ago".
2. Map/routing caps → all-Mapbox stack, corridor-search caching, weekly usage check; Google Places parked as upscale pick.
3. SMS OTP costs → email OTP + Google/Apple for MVP; Termii only after traction.
4. Supabase Free pause (7 idle days) + no backups → keep-alive habit, weekly manual exports.
5. Em-dash filenames/line-endings → rename + `.gitignore` + format hook in Phase 0.
6. Scope creep (§23) → any Future-Feature request goes to parking lot, not MVP.

## Appendix D — Spend order: $0 now, upscale when forced

Now ($0, no card): Flutter + Supabase Free + Mapbox + FCM + Crashlytics/Analytics + Penpot + Actions.

Upscale menu (in order, each only when a free limit forces it):

| # | Trigger | Move |
|---|---|---|
| 1 | Need phone OTP / user demand | Termii SMS, pay-as-you-go |
| 2 | Staging keeps pausing or backups/audit needed | Supabase Pro $25/mo |
| 3 | Ready to ship Android | Play Console $25 one-time |
| 4 | Station search quality complaints (§6) or Mapbox caps hit | Google Maps Platform Places/Directions (card required) |
| 5 | Need funnels/experiments | PostHog/Mixpanel |
| 6 | Crash triage outgrows Crashlytics | Sentry |
| 7 | Shipping iOS | Apple Developer $99/yr |

## Parked (resume on owner's word — do not start unprompted)

1. **Mobile feature gap** (est. ~1.5h in 4 rounds): compare tray → reviews → trips planner → profile/vehicles in `mobile.html`. Plan agreed, awaiting "start".
2. **Real station data hunt**: retry OSM Overpass pull when servers recover, then convert via `scripts/` pipeline.

## Appendix C — What to build first (if time-boxed)

Walking skeleton: Phase 0 → 2 → 3 → 5 → 6 (map + mock stations + card) → demo. Then 4 → 7 → 8 → 9 → 10 → 11.
