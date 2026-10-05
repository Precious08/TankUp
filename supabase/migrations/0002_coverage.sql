-- TankUp coverage — Phase 3 follow-up: national scope.
-- TankUp serves all 36 states + FCT, down to every LGA and LCDA — not Lagos only.
-- Veteran rule respected: 0001 is already merged, so this is a NEW migration,
-- never a rewrite.

alter table stations
  add column if not exists state text not null default 'Lagos',
  add column if not exists lga text not null default '',
  add column if not exists lcda text not null default '';

-- Backfill the Lagos seed rows (0001 used area names; map them to LGAs).
update stations set lga = case
  when area in ('Lekki', 'Ajah') then 'Eti-Osa'
  when area = 'Victoria Island' then 'Eti-Osa'
  when area = 'Ikoyi' then 'Eti-Osa'
  when area = 'Yaba' then 'Lagos Mainland'
  when area = 'Surulere' then 'Surulere'
  when area = 'Ikeja' then 'Ikeja'
  else lga end
where state = 'Lagos';

create index if not exists stations_state_idx on stations (state);
create index if not exists stations_lga_idx on stations (state, lga);
