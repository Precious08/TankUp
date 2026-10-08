-- TankUp community reports — unverified user submissions, moderation queue.
-- Nothing here is shown publicly until reviewed (Phase 9 moderation UI).

create table if not exists station_reports (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid references drivers (id) on delete set null,
  station_id uuid references stations (id) on delete set null,
  kind text not null check (kind in ('price', 'edit', 'new_station')),
  -- price: {fuel, price} · edit: {field, value} · new_station: full station draft
  payload jsonb not null default '{}',
  note text not null default '',
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);
create index if not exists reports_status_idx on station_reports (status, created_at desc);
create index if not exists reports_station_idx on station_reports (station_id);

alter table station_reports enable row level security;

-- Anyone (including guests) may submit; nobody reads except service role.
drop policy if exists reports_insert on station_reports;
create policy reports_insert on station_reports
  for insert with check (true);
