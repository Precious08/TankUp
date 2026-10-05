# TankUp National Seed Strategy — 36 states + FCT, every LGA/LCDA

Wave 1 (done): 30 Lagos stations in `seed.sql` — proves the pipeline.

## Rollout waves

1. Lagos (done) → 2. Oyo, Ogun, Rivers, Kano, FCT → 3. remaining states by driver demand (Trips data shows where users actually drive).

## Sources (in order of trust)

1. NMDPRA licensed-outlet lists (station existence + LGA).
2. Field/partner capture (coords, fuels, prices, hours, photos).
3. Community reports in-app (moderation queue, Phase 9) — never auto-publish prices.
4. OpenStreetMap `amenity=fuel` as a gap-finder only, always field-verified.

## Ingest format (CSV per state, columns)

`state,lga,lcda,name,area,address,lng,lat,fuels,petrol_price,cng_price,ev_price,price_unit,hours`

- `fuels`: semicolon list, e.g. `Petrol;CNG`. Prices in NGN, empty = unknown (never zero).
- Coords required (WGS84); rows without coords go to a review pile, not the DB.

## Quality gates per wave

- Dedupe on (name, address, LGA) before insert; keep the newest verified price.
- Every row carries `price_updated_at`; UI flags anything older than 24h (ADR 003).
- Wave ships only when its top-5 LGAs by traffic each have ≥ 80% of known outlets mapped.
