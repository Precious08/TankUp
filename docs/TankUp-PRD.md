# **TankUp — Product Requirements Document**

## **1\. Product Overview**

**TankUp** is a mobile app that helps drivers find, compare, and navigate to vehicle energy stations.

It supports:

* Petrol  
* CNG  
* EV charging

TankUp helps drivers quickly answer:

**“Where can I get the energy I need, how much will it cost, and how do I get there?”**

---

## **2\. Problem**

Drivers can struggle to:

* Find nearby petrol, CNG, or EV stations.  
* Know which energy type is available.  
* Compare prices between nearby stations.  
* Know whether a station is open or has the needed energy available.  
* Find suitable stations along their route.  
* Remember useful stations they have used before.

TankUp brings these needs into one simple experience.

---

## **3\. Target Users**

TankUp is designed for **all drivers**, including:

* Everyday drivers  
* Commercial drivers  
* Delivery drivers  
* Petrol vehicle owners  
* CNG vehicle owners  
* EV owners

The experience should work regardless of the vehicle type.

---

## **4\. Product Goals**

### **Primary goal**

Make finding and accessing vehicle energy **fast and simple**.

### **Secondary goals**

* Help drivers compare nearby stations.  
* Show useful station information before they travel.  
* Help drivers find stations along their route.  
* Allow users to save stations and preferences.  
* Provide navigation to selected stations.

---

# **5\. Core User Flow**

### **New user**

**Open TankUp → Select vehicle type → See map → Search/filter stations → Select station → View details → Get directions → Navigate**

### **Returning user**

**Open TankUp → Map automatically prioritizes their vehicle type → Find station → Compare → Navigate**

---

# **6\. Home Screen**

The home screen is **map-first**.

### **Main elements**

**Top**

* Search bar  
* Profile/account access

**Map**

* User location  
* Nearby stations  
* Station markers  
* Different markers for Petrol, CNG, and EV

**Bottom**

* Nearby station information  
* Quick filters  
* Saved/recent stations

### **Search**

Users can search for:

* Station names  
* Areas  
* Streets  
* Destinations

Example:

> “Lekki”

TankUp then shows relevant stations around the searched location.

---

# **7\. Filters**

Users can quickly filter stations by:

* Petrol  
* CNG  
* EV  
* Price  
* Distance  
* Availability  
* Open now

Filters should be easy to access without leaving the map.

---

# **8\. Station Card**

When a user selects a station, the station card should show:

### **Primary information**

* Station name  
* Distance  
* Estimated travel time  
* Available energy types  
* Current price  
* Availability  
* Open/closed status

### **Secondary information**

* Rating  
* Number of reviews  
* Address  
* Opening hours

### **Actions**

**View details**

**Get directions**

---

# **9\. Station Details**

The station details page gives the user enough information to make a decision.

### **Information**

* Station name  
* Address  
* Distance  
* Estimated travel time  
* Petrol price  
* CNG price  
* EV charging information  
* Availability  
* Opening hours  
* Rating  
* Reviews  
* Location on map

### **Primary action**

**Get directions**

### **Secondary action**

**Save station**

---

# **10\. Price Comparison**

TankUp allows users to compare prices between nearby stations.

Example:

| Station | Petrol |
| ----- | ----- |
| Station A | ₦X/L |
| Station B | ₦Y/L |
| Station C | ₦Z/L |

The comparison should be simple and easy to scan.

Price should not overwhelm the station discovery experience.

---

# **11\. Availability**

TankUp should show both:

### **Station status**

* Open  
* Closed

### **Energy availability**

* Petrol available  
* CNG available  
* EV charging available

This prevents situations where a station is technically open but does not have the energy the driver needs.

---

# **12\. Route-Based Discovery**

TankUp should allow users to find stations **along their route**.

Example:

**Lagos → Ibadan**

TankUp can show suitable petrol, CNG, or EV stations along the journey.

The user can then select a station and navigate to it.

This is different from simply showing the nearest station because the nearest station may require the driver to leave their route.

---

# **13\. Navigation**

TankUp will provide **navigation inside the app**.

The navigation experience should show:

* Current location  
* Destination station  
* Route  
* Distance  
* Estimated arrival time  
* Turn-by-turn directions  
* Energy type  
* Price  
* Availability

The selected station should remain visible during navigation.

---

# **14\. Saved Stations**

Users can save stations they frequently use.

### **Saved section**

Users can see:

* Saved stations  
* Station location  
* Energy type  
* Price  
* Availability

Users should be able to remove a station from their saved list at any time.

---

# **15\. Recent Stations**

TankUp should automatically remember recently viewed stations.

This is separate from saved stations.

**Saved \= intentionally bookmarked**

**Recent \= automatically remembered**

This makes it easy for users to return to stations they previously checked.

---

# **16\. Vehicle Profile**

TankUp should allow users to select their vehicle energy type:

* Petrol  
* CNG  
* EV

TankUp remembers this preference and uses it to prioritize relevant stations.

Users can change their vehicle type at any time from Profile → My Vehicles.

This should not prevent users from viewing other energy types.

### **Multi-vehicle support**

* Users can add multiple vehicles (e.g. personal petrol car + commercial CNG van).  
* Each vehicle stores: nickname (e.g. “Work Van”), energy type, make/model/year (optional), license plate (optional).  
* One vehicle is marked as Active/Default. Map, filters, and route discovery prioritize the active vehicle.  
* Users can add, edit, switch active vehicle, and delete vehicles at any time.

---

# **17\. Account & Driver Backend**

TankUp should use an **optional account model**.

Users can use the core product without creating an account.

An account becomes useful for:

* Saved stations  
* Vehicle preference  
* Recent searches  
* User preferences  
* Personal settings  
* Cross-device sync

This removes unnecessary friction for first-time users.

### **Backend requirements**

Every driver with an account gets a persistent backend profile:

* Auth: phone and/or email + OTP, plus optional Google/Apple sign-in. Guest mode stays fully usable.  
* Driver record: user ID, display name, avatar URL, contact, created date.  
* Vehicle records linked to driver.  
* Preferences record (units, currency, map, navigation, notifications — see §27).  
* Saved stations, recent stations/searches/routes stored server-side so they survive reinstall and sync across devices.  
* Avatar upload: image picker → crop → upload to file storage → avatar URL saved to profile. Support remove/replace, with default avatar fallback.  
* All settings changes must save instantly, work offline with queued sync, and never block map/discovery.

---

# **18\. Onboarding**

Onboarding should be short.

### **Screen 1**

**Welcome to TankUp**

Find the right place to refuel or charge.

### **Screen 2**

**Choose your vehicle**

* Petrol  
* CNG  
* EV

### **Screen 3**

**Find nearby stations**

See stations, prices, availability, and directions.

Users should be able to skip account creation.

---

# **19\. Ratings & Reviews**

Users should be able to see station ratings and reviews.

Reviews can help users understand:

* General station experience  
* Service quality  
* Charging/fueling experience  
* Accuracy of station information

Ratings are secondary information and should not dominate the station discovery experience.

---

# **20\. Notifications**

Notifications should be useful rather than excessive.

Potential notifications:

* Saved station price changes  
* Saved station availability updates  
* Important station information  
* Route-related station updates

Users should have control over which notifications they receive.

---

# **21\. Navigation Structure**

TankUp can use five main sections:

### **1\. Home**

Map, search, nearby stations, filters.

### **2\. Search**

Search locations, stations, and destinations.

### **3\. Saved**

Saved stations and frequently used locations.

### **4\. Trips**

Recent and planned routes.

### **5\. Profile / Driver Dashboard**

Driver backend and settings hub. Entry point for everything a driver can change about themselves (full spec in §27):

* Profile: avatar, display name, phone, email  
* My Vehicles: type, make/model, active vehicle  
* App preferences: theme, language, units, currency, map style  
* Navigation preferences, notification preferences  
* Saved, Recent, Trips management  
* Privacy, security, delete account

The **Home** section remains the primary experience.

---

# **22\. Core Features**

### **MVP**

The first version should focus on:

1. Map-based station discovery  
2. Petrol, CNG, and EV support  
3. Search  
4. Filters  
5. Station cards  
6. Station details  
7. Price comparison  
8. Availability and opening status  
9. Saved stations  
10. Vehicle preference  
11. Route-based station discovery  
12. In-app navigation  
13. Optional account  
14. Driver dashboard & settings backend (§27)

---

# **23\. Future Features**

Features that can be considered after the core experience is established:

* Fuel/charging payment  
* Fueling or charging reservations  
* Loyalty programs  
* Station promotions  
* Community reporting  
* Fuel consumption tracking  
* Trip cost estimation  
* Vehicle maintenance reminders  
* Charging session tracking  
* Emergency roadside assistance

These should not distract from TankUp's primary purpose.

---

# **24\. Design Principles**

### **Simple**

Users should understand what to do immediately.

### **Fast**

A driver should find a suitable station with minimal steps.

### **Location-focused**

The map should remain the center of the experience.

### **Informative**

Show the information that affects the user's decision: **distance, energy type, price, availability, and opening status.**

### **Flexible**

Support Petrol, CNG, and EV without making the interface complicated.

### **Safety-conscious**

Navigation and important information should remain clear and easy to scan while driving. Users should not be encouraged to interact heavily with the app while the vehicle is moving.

---

# **25\. Success Criteria**

TankUp should make the following journey feel straightforward:

**Open → Find → Compare → Choose → Navigate**

A successful experience means a driver can quickly:

* Find an appropriate station.  
* Understand what energy is available.  
* Compare nearby options.  
* Check important station information.  
* Save a useful station.  
* Start navigation to the selected station.

---

# **26\. Product Positioning**

**TankUp is a vehicle energy discovery and navigation app for modern drivers.**

It brings **petrol, CNG, and EV charging** into one experience instead of treating them as separate problems.

### **Core product promise**

**Find the right place to power your vehicle.**

---

# **27\. Driver Dashboard, Backend & Settings**

This is the driver-facing backend: one place where every driver can view and change anything about themselves, their vehicles, and how the app behaves.

Design rule: **if the driver owns the data, the driver can change it here.** No setting should require contacting support.

## **27.1 Dashboard layout (Profile tab)**

Top:

* Avatar (tap to change), display name, vehicle badge (e.g. “CNG • Work Van”), Edit Profile button

Groups:

1. My Vehicles  
2. Preferences  
3. Stations & Trips  
4. Notifications  
5. Privacy & Security  
6. Support & About  
7. Sign out / Delete account

Guest state: show “Sign in to sync” banner, but all local settings remain editable.

## **27.2 Profile settings**

Editable fields:

* Avatar: take photo / choose from gallery / remove. Crop square, max ~5MB, show upload progress, fallback to initials avatar on error.  
* Display name  
* Phone number (OTP re-verify on change)  
* Email (verify on change)  
* Home / Work locations (optional, for quick trips)

Rules:

* Avatar and name change reflect immediately across Home, reviews, and dashboard.  
* Guests store profile locally; on sign-up, local profile migrates to backend account.

## **27.3 Vehicle settings**

Full CRUD for vehicles:

* Add vehicle: nickname, energy type (Petrol / CNG / EV), make, model, year, plate (all except energy type optional).  
* Set Active vehicle — drives map prioritization, default filters, and route search.  
* Edit / delete any vehicle. Deleting active vehicle prompts to pick a new active one.  
* EV extras (optional fields): connector type (CCS / CHAdeMO / Type 2), battery capacity. Shown only for EV to keep UI simple.  
* Switching vehicles instantly re-filters Home map without leaving Profile.

## **27.4 App preferences**

* Theme: System / Light / Dark  
* Language (default English, expandable)  
* Distance units: km / mi  
* Currency display: ₦ (auto)  
* Map style: Standard / Satellite / Traffic  
* Default filters: preferred energy types, “Open now only”, max distance

## **27.5 Navigation preferences**

* Voice guidance on/off, voice volume  
* Avoid tolls / highways / ferries toggles  
* Default navigation mode per vehicle type

## **27.6 Notification settings**

Master toggle + granular toggles (maps to §20):

* Saved station price changes  
* Saved station availability updates  
* Important station info  
* Route-related updates

Plus: quiet hours, push vs in-app toggles. Changing these must update backend subscription immediately.

## **27.7 Stations & Trips management**

From dashboard, drivers can:

* View/edit/remove saved stations  
* Clear recent stations / recent searches / trip history individually or all at once  
* Manage home/work/frequent destinations

## **27.8 Privacy & Security**

* Location permission status + shortcut to OS settings  
* Download my data, clear history, sign out all devices  
* Delete account with confirmation (deletes backend profile, vehicles, saved data; keeps anonymous reviews optional)

## **27.9 Backend behavior**

* Single Driver API: `GET/PATCH /me`, `POST /me/avatar`, `CRUD /me/vehicles`, `GET/PUT /me/preferences`, `CRUD /me/saved`, trip/search history endpoints.  
* Offline-first: edits queue locally and sync when online; show “Synced / Sync pending” state.  
* Validation: avatar file-type/size check, phone/email uniqueness, at least one vehicle if user deletes all (fallback to onboarding vehicle picker).  
* Success criteria add-on: driver can change avatar, name, vehicle type, and notification prefs in <30 seconds each without leaving Profile.

---

# **28\. Tooling Decisions — Free Now, Upscale Later**

Every tool below is free with no credit card and meets its task for the MVP. Upscale picks are named so we switch only when a free limit forces it.

## **Backend — Supabase Free now**

* Covers auth, Postgres relations, avatar storage, and row-level security in one service — matches §17 and §27.9 with minimal ops.  
* Free tier (2 projects, 500MB database, 1GB storage, 50k monthly users) carries the full MVP at $0.  
* Trade-offs accepted: projects pause after 7 idle days, no backups on Free (weekly manual exports).  
* **Upscale:** Supabase Pro ($25/mo) — backups, never pauses, bigger limits.

## **Maps, search, routing — Mapbox now**

* Mapbox handles display, Geocoding, and Directions on a free allowance with no card — covers §6, §12, and §13 for the MVP.  
* **Upscale:** Google Maps Platform Places — best Nigerian station/POI search quality. Needs a billing account with a card (its $200 credit ended March 2025; per-SKU free caps now apply).

## **Sign-in — email OTP + Google/Apple now**

* Free via Supabase and enough for the MVP.  
* SMS is never free, so phone OTP waits until traction.  
* **Upscale:** Termii (Nigerian, pay-as-you-go) for SMS OTP.

## **Push, crash, analytics — FCM + Firebase now**

* Push, crash reporting, analytics, and beta distribution all free with no card.  
* **Upscale:** OneSignal (push ops), Sentry (crash triage), PostHog/Mixpanel (funnels) — only if the free tools prove insufficient.

## **Design, CI — Penpot + GitHub Actions now**

* Both free with no limiting caps for this project.  
* **Upscale:** Figma Professional (designer collaboration), Codemagic (device farms) — only on demand.

Rule: no card-required tool enters the stack before traction. Spend order when forced: Termii SMS → Supabase Pro → Play Console ($25 one-time) → Google Places → Apple Developer ($99/yr, iOS only).

---

# **29\. Design Changelog**

Live preview: `design.html` (repo root). Tokens feed Phase 1 (`lib/design/tokens.dart`).

## **v2 — Minimal refinement**

* **Minimal:** removed boxed cards with shadows; hairline dividers, airy spacing, small-caps section labels.  
* **Font:** system stack → Plus Jakarta Sans (Google Fonts + system fallback) — friendlier, still legible on low-end screens.  
* **Contrast fixes:** button green #16A34A + white (~3.3:1, failed AA) → action green #15803D (5.0:1); secondary text #6B7280 → #475569 (7.5:1 on white); energy tags changed to dark-text-on-tint; error darkened to #B91C1C. All text now ≥ 4.5:1.  
* **Buttons:** solid green pill (soft shadow, hover lift, pressed + focus-visible states) for the driving-critical action; quiet hairline button for secondary; small + disabled variants added.

## **v1 — Initial preview (superseded)**

* Dark header, card grid, system font, original greens/grays. Kept in git history (`5b01b1f` and earlier).

## **Phase 1 gallery — `gallery.html` + `lib/design/tokens.dart`**

* 9-section gallery (color, typography, spacing/radii, buttons, inputs, station card + bottom sheet, markers, toggles/banners/loading, rules checklist) with light+dark toggle.  
* Dark mode reworked: luminous tag tones, glowing primary button (#22C55E + near-black text), corrected chip inversion, deeper card shadows.  
* Loading shimmer given its own gradient after dark looked better than light.  
* Tokens extracted to code (`lib/design/tokens.dart`) so the Flutter scaffold (Phase 5) consumes them directly — no re-spec needed.

---

# **30\. National Coverage — 36 States + FCT, Every LGA/LCDA**

TankUp is a national product. It covers **all 36 states and the FCT**, down to **every LGA and LCDA** — not Lagos alone.

* Every station record carries `state`, `lga`, and `lcda` (schema migration `0002_coverage.sql`). Search, filters, and route discovery all accept a state/LGA scope (§6, §7, §12).  
* Rollout is waved, not big-bang: Lagos first (proves the pipeline), then Oyo, Ogun, Rivers, Kano, and FCT, then remaining states by real driver demand. Strategy and quality gates live in `supabase/seed-national.md`.  
* A state/LGA ships only when its busiest LGAs are mapped well enough to trust — a thin national spread that misleads drivers is worse than a smaller honest footprint. Coverage depth per state is shown in-app so drivers know what to expect.

