# ADR 004 — Auth: guest by default, upgrade to account

Status: Accepted.

## Context

PRD §17 demands an optional account: zero friction first run, sync later. SMS OTP is never free (PRD §28).

## Decision

- **Guest mode default**: full discovery, local vehicles/prefs/saved. Banner in Profile: "Sign in to sync".
- **Upgrade paths**: email OTP + Google/Apple via Supabase Auth. Phone (SMS) OTP deferred until traction, then Termii.
- **Migration**: on sign-up, local guest rows (vehicles, prefs, saved, recents) upload and link to the new driver id; duplicates merge by name/type.
- **Re-verify**: phone/email changes require fresh OTP/verify before the old value is replaced (§27.2).

## Consequences

- Good: onboarding stays 3 taps (§18); no SMS spend before traction.
- Watch: migration edge cases (guest with data + existing account) need an explicit merge test in Phase 10.
