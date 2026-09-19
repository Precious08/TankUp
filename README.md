# TankUp

**Find the right place to power your vehicle.**

TankUp is a mobile app that helps drivers find, compare, and navigate to vehicle energy stations — Petrol, CNG, and EV charging — in one simple experience.

> Initial version: PRD + project scaffold. No app code yet.

## What it does

Answer: **"Where can I get the energy I need, how much will it cost, and how do I get there?"**

- Map-first station discovery (Petrol / CNG / EV markers)
- Search by station name, area, street, destination (e.g. "Lekki")
- Quick filters: energy type, price, distance, availability, open now
- Station card + details: distance, ETA, prices, availability, open/closed, rating, hours, address
- Price comparison between nearby stations
- Route-based discovery (e.g. Lagos → Ibadan)
- In-app navigation with turn-by-turn
- Saved stations vs Recent stations
- Vehicle profile + optional account
- Driver dashboard & settings backend (avatar, vehicles, preferences)

## Repo structure

```
TankUp/
├── README.md
└── docs/
    └── TankUp — Product Requirements Document.md
```

## Product docs

Full spec: `docs/TankUp — Product Requirements Document.md`

Key sections:
- §5 Core user flow: Open → vehicle type → map → search/filter → details → directions → navigate
- §6-13 Home, filters, station card/details, comparison, availability, route discovery, navigation
- §16 Vehicle profile (multi-vehicle support)
- §17 Account & driver backend
- §21 Navigation: Home / Search / Saved / Trips / Profile (Driver Dashboard)
- §22 MVP (14 items)
- §27 Driver Dashboard, Backend & Settings (profile, avatar, vehicles, app/nav/notification prefs, privacy)

## Driver dashboard (summary)

Every driver can change anything they own from Profile, no support needed:

- Profile: avatar (photo/gallery/remove), display name, phone, email, home/work
- My Vehicles: nickname, type, make/model/year/plate, EV connector, active vehicle
- App prefs: theme, language, km/mi, currency, map style, default filters
- Navigation prefs: voice, avoid tolls/highways/ferries
- Notifications: price changes, availability, station info, route updates + quiet hours
- Privacy: location status, clear history, download data, delete account
- Backend: `GET/PATCH /me`, `POST /me/avatar`, `CRUD /me/vehicles`, `PUT /me/preferences`, saved/trips APIs, offline-first sync

## Status

- [x] PRD v1 with §27 dashboard/backend
- [ ] Architecture / data model
- [ ] API contract
- [ ] App scaffold (TBD: Flutter / React Native / native)
- [ ] MVP build

## Next steps

1. Decide stack (client, backend, maps, auth, storage)
2. Define data model + API contract from §27.9
3. Scaffold app + backend
4. Build MVP flow: Open → Find → Compare → Choose → Navigate

## License

TBD.
