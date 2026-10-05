# Supabase Runbook — Phase 4 (live project setup)

Do this once, in order. Nothing here costs money (Free plan).

## 1. Create the projects

1. Sign up at supabase.com (free, no card).
2. Create project `tankup-dev`, region closest to Nigeria (EU West is fine).
3. Save the project URL + `anon` key into your local `.env` (see `.env.example`). Never paste keys into chat, docs, or git.

## 2. Run the migrations (SQL editor, in order)

1. Paste `supabase/migrations/0001_schema.sql` → Run. Expect success, 9 tables.
2. Paste `supabase/migrations/0002_coverage.sql` → Run. Expect success.
3. Paste `supabase/seed.sql` → Run. Expect 30 rows.
4. Paste `supabase/seed-wave2.sql` → Run. Expect 185 rows.

## 3. Verify (the smoke test Phase 3 was missing)

```sql
select count(*) from stations;                       -- expect 215
select state, count(*) from stations group by state; -- expect 36 + FCT
select * from stations where area = 'Lekki' limit 3; -- sanity look
```

## 4. Auth + storage checks

1. Auth → enable Email OTP + Google (Apple needs a paid dev account — defer).
2. Storage → confirm `avatars` bucket exists, public, 5MB limit.
3. Table editor → confirm RLS enabled on all 9 tables.

## 5. Repeat for `tankup-prod` when dev is green

Free plan = 2 projects: dev + prod. Keep dev active (a Free project pauses after 7 idle days); export a backup weekly (Free has no backups).
