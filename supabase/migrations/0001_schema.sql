-- TankUp schema — Phase 3.
-- Run in Supabase SQL editor (or `supabase db push`). Idempotent where cheap.
-- Conventions: driver-owned rows keyed to auth.uid(); stations are public-read,
-- service-role-write; every table has created_at; mutable rows have updated_at.

create extension if not exists postgis;

do $$ begin
  create type energy_type as enum ('Petrol', 'CNG', 'EV');
exception when duplicate_object then null; end $$;

-- ---------- drivers ----------
create table if not exists drivers (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default 'Driver',
  avatar_url text,
  phone text unique,
  email text unique,
  created_at timestamptz not null default now()
);

-- ---------- vehicles ----------
create table if not exists vehicles (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references drivers (id) on delete cascade,
  nickname text not null,
  energy energy_type not null,
  make text, model text, year int, plate text,
  connector text, -- EV only: CCS / CHAdeMO / Type 2
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists vehicles_driver_idx on vehicles (driver_id);

-- Exactly one active vehicle per driver (enforced at app layer + this guard:
-- a partial unique index so the DB rejects a second active row).
create unique index if not exists vehicles_one_active
  on vehicles (driver_id) where is_active;

-- ---------- preferences ----------
create table if not exists preferences (
  driver_id uuid primary key references drivers (id) on delete cascade,
  theme text not null default 'system',      -- system | light | dark
  language text not null default 'en',
  units text not null default 'km',          -- km | mi
  currency text not null default 'NGN',
  map_style text not null default 'standard',-- standard | satellite | traffic
  default_fuels energy_type[] not null default '{}',
  open_now_only boolean not null default false,
  max_distance_km int not null default 10,
  voice_on boolean not null default true,
  avoid_tolls boolean not null default false,
  avoid_highways boolean not null default false,
  notif_price boolean not null default true,
  notif_avail boolean not null default true,
  notif_route boolean not null default false,
  quiet_hours text,                            -- e.g. '22:00-06:00'
  updated_at timestamptz not null default now()
);

-- ---------- stations (public catalogue) ----------
create table if not exists stations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  area text not null,                          -- e.g. 'Lekki'
  address text not null,
  location geography(Point, 4326) not null,
  fuels energy_type[] not null default '{}',
  petrol_price numeric(10,2),
  cng_price numeric(10,2),
  ev_price numeric(10,2),                       -- per kWh
  price_unit text not null default '/L',
  price_updated_at timestamptz,
  is_open boolean not null default true,
  availability jsonb not null default '{}',     -- {"Petrol":"available","EV":"2/6 stalls"}
  hours text not null default 'Open 24 hrs',
  rating numeric(2,1) not null default 0,
  review_count int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists stations_location_idx on stations using gist (location);
create index if not exists stations_area_idx on stations (area);

-- ---------- driver collections ----------
create table if not exists saved_stations (
  driver_id uuid not null references drivers (id) on delete cascade,
  station_id uuid not null references stations (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (driver_id, station_id)
);

create table if not exists recent_stations (
  driver_id uuid not null references drivers (id) on delete cascade,
  station_id uuid not null references stations (id) on delete cascade,
  viewed_at timestamptz not null default now(),
  primary key (driver_id, station_id)
);

create table if not exists recent_searches (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references drivers (id) on delete cascade,
  query text not null,
  created_at timestamptz not null default now()
);
create index if not exists recent_searches_driver_idx
  on recent_searches (driver_id, created_at desc);

create table if not exists routes (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid references drivers (id) on delete set null,
  from_text text not null,
  to_text text not null,
  created_at timestamptz not null default now()
);

create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  station_id uuid not null references stations (id) on delete cascade,
  driver_id uuid references drivers (id) on delete set null,
  rating int not null check (rating between 1 and 5),
  body text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists reviews_station_idx on reviews (station_id, created_at desc);

-- ---------- updated_at trigger ----------
create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists trg_vehicles_touch on vehicles;
create trigger trg_vehicles_touch before update on vehicles
  for each row execute function touch_updated_at();
drop trigger if exists trg_stations_touch on stations;
create trigger trg_stations_touch before update on stations
  for each row execute function touch_updated_at();

-- ---------- RLS ----------
alter table drivers enable row level security;
alter table vehicles enable row level security;
alter table preferences enable row level security;
alter table stations enable row level security;
alter table saved_stations enable row level security;
alter table recent_stations enable row level security;
alter table recent_searches enable row level security;
alter table routes enable row level security;
alter table reviews enable row level security;

-- drivers: owners only
drop policy if exists drivers_owner on drivers;
create policy drivers_owner on drivers
  for all using (auth.uid() = id) with check (auth.uid() = id);

-- vehicles / preferences / collections: own driver_id only
drop policy if exists vehicles_owner on vehicles;
create policy vehicles_owner on vehicles
  for all using (auth.uid() = driver_id) with check (auth.uid() = driver_id);

drop policy if exists preferences_owner on preferences;
create policy preferences_owner on preferences
  for all using (auth.uid() = driver_id) with check (auth.uid() = driver_id);

drop policy if exists saved_owner on saved_stations;
create policy saved_owner on saved_stations
  for all using (auth.uid() = driver_id) with check (auth.uid() = driver_id);

drop policy if exists recent_owner on recent_stations;
create policy recent_owner on recent_stations
  for all using (auth.uid() = driver_id) with check (auth.uid() = driver_id);

drop policy if exists searches_owner on recent_searches;
create policy searches_owner on recent_searches
  for all using (auth.uid() = driver_id) with check (auth.uid() = driver_id);

drop policy if exists routes_owner on routes;
create policy routes_owner on routes
  for all using (auth.uid() = driver_id) with check (auth.uid() = driver_id);

-- stations: anyone reads; only service role writes (no write policy for anon/authenticated)
drop policy if exists stations_read on stations;
create policy stations_read on stations for select using (true);

-- reviews: anyone reads; owners write their own
drop policy if exists reviews_read on reviews;
create policy reviews_read on reviews for select using (true);
drop policy if exists reviews_write on reviews;
create policy reviews_write on reviews
  for insert with check (auth.uid() = driver_id);
drop policy if exists reviews_delete on reviews;
create policy reviews_delete on reviews
  for delete using (auth.uid() = driver_id);

-- ---------- avatar storage ----------
insert into storage.buckets (id, name, public, file_size_limit)
values ('avatars', 'avatars', true, 5242880)
on conflict (id) do update set public = true, file_size_limit = 5242880;

drop policy if exists avatars_read on storage.objects;
create policy avatars_read on storage.objects
  for select using (bucket_id = 'avatars');

drop policy if exists avatars_write on storage.objects;
create policy avatars_write on storage.objects
  for insert with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists avatars_delete on storage.objects;
create policy avatars_delete on storage.objects
  for delete using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
