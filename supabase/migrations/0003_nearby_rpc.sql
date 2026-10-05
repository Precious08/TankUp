-- TankUp nearby search — referenced by docs/api/contract.md (Phase 3 exit item).
-- PostGIS KNN search over the stations GiST index from 0001.

create or replace function nearby_stations(
  lat double precision,
  lng double precision,
  radius_m int default 10000,
  fuel energy_type default null,
  open_only boolean default false,
  lim int default 20
)
returns setof stations
language sql stable
as $$
  select s.*
  from stations s
  where ST_DWithin(
      s.location,
      ST_GeogFromText('SRID=4326;POINT(' || lng || ' ' || lat || ')'),
      radius_m
    )
    and (fuel is null or fuel = any (s.fuels))
    and (not open_only or s.is_open)
  order by s.location <-> ST_GeogFromText('SRID=4326;POINT(' || lng || ' ' || lat || ')')
  limit lim;
$$;

grant execute on function nearby_stations(double precision, double precision, int, energy_type, boolean, int)
  to anon, authenticated;
