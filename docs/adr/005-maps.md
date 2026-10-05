# ADR 005 — Maps: Mapbox now, Google Places as upscale

Status: Accepted.

## Context

Need display + search + routing at $0 with no card (PRD §28). Google's $200 credit ended March 2025 (per-SKU caps now) and requires a billing account.

## Decision

- **Mapbox** for display, Geocoding, and Directions in the MVP. Distance/ETA from Mapbox Directions; straight-line fallback offline.
- Corridor search for route discovery (§12) cached to stay inside the free allowance; weekly usage check routine.
- **Google Places/Directions parked as the upscale pick** for §6 search quality — adopted only when station-search complaints or Mapbox caps force it.

## Consequences

- Good: no card, no billing setup, one vendor for all three map needs.
- Watch: evaluate search quality against real Lagos queries before launch; keep Places integration shaped as a swappable provider in `core/location/`.
