# ADR 002 — App structure: feature-first

Status: Accepted.

## Context

Five tabs plus stations, navigation, and profile settings (PRD §21, §27). Flat `lib/` folders rot once features multiply.

## Decision

```
lib/
├── design/        # tokens.dart (Phase 1) + gallery widgets
├── core/          # network/ location/ storage/ sync/ (offline queue)
└── features/
    ├── home/      # map, sheet, filters
    ├── search/    # search + suggestions
    ├── saved/     # saved list
    ├── trips/     # recent + planned routes
    ├── profile/   # dashboard + vehicles + prefs (§27)
    ├── stations/  # card, details, compare, reviews (shared UI)
    └── navigation/# route mode, ETA, voice
```

Each feature owns its screens, widgets, and Riverpod providers. Shared station UI lives in `features/stations`, imported by home/search/saved/trips. Nothing imports sideways between sibling features — only down into `core/` and `design/`.

## Consequences

- Good: a feature can be built, tested, and deleted without touching others; maps 1:1 to PRD sections for review.
- Watch: shared widgets must stay in `stations/` or `design/` — no duplicates per tab.
