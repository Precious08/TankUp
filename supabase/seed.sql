-- TankUp seed — wave 1: 30 Lagos stations (demo data, prices illustrative in NGN).
-- National rollout (36 states + FCT, every LGA/LCDA) ingests per state via
-- supabase/seed-national.md; this file stays as the Lagos sample.
-- Run after 0001_schema.sql (+ 0002 backfills LGA). To reseed cleanly:
-- delete from stations; then re-run.

insert into stations
  (name, area, address, location, fuels, petrol_price, cng_price, ev_price,
   price_unit, price_updated_at, is_open, availability, hours, rating, review_count)
values
 ('TotalEnergies — Lekki P1','Lekki','Admiralty Way, Lekki',ST_GeogFromText('SRID=4326;POINT(3.555 6.447)'),'{Petrol,CNG}',865,null,null,'/L',now(),true,'{"Petrol":"available","CNG":"available"}','Open 24 hrs',4.2,318),
 ('NNPC — Ikoyi Rd','Ikoyi','Ikoyi Road',ST_GeogFromText('SRID=4326;POINT(3.445 6.452)'),'{Petrol}',859,null,null,'/L',now(),true,'{"Petrol":"available"}','Open · closes 11pm',4.0,204),
 ('ChargePoint — VI Hub','Victoria Island','Adeola Odeku, VI',ST_GeogFromText('SRID=4326;POINT(3.421 6.431)'),'{EV}',null,null,310,'/kWh',now(),true,'{"EV":"2/6 stalls free"}','Open 24 hrs',4.6,97),
 ('Mobil — Admiralty','Lekki','Admiralty Way, Lekki',ST_GeogFromText('SRID=4326;POINT(3.548 6.443)'),'{Petrol,EV}',870,null,305,'/L',now(),true,'{"Petrol":"low","EV":"available"}','Open 24 hrs',3.9,411),
 ('CNG Express — Lekki','Lekki','Chevron Drive, Lekki',ST_GeogFromText('SRID=4326;POINT(3.562 6.439)'),'{CNG}',null,490,null,'/SCM',now(),false,'{"CNG":"available"}','Closed · opens 6am',4.4,58),
 ('AP — Ozumba Mbadiwe','Victoria Island','Ozumba Mbadiwe, VI',ST_GeogFromText('SRID=4326;POINT(3.438 6.428)'),'{Petrol,CNG,EV}',872,495,300,'/L',now(),true,'{"Petrol":"available","CNG":"available","EV":"1/4 stalls free"}','Open 24 hrs',4.1,156),
 ('Eterna — Lekki Epe','Lekki','Lekki-Epe Expressway',ST_GeogFromText('SRID=4326;POINT(3.585 6.449)'),'{Petrol}',855,null,null,'/L',now(),true,'{"Petrol":"available"}','Open · closes 10pm',3.8,89),
 ('VoltHub — Ikoyi','Ikoyi','Bourdillon Rd, Ikoyi',ST_GeogFromText('SRID=4326;POINT(3.451 6.458)'),'{EV}',null,null,295,'/kWh',now(),true,'{"EV":"4/8 stalls free"}','Open 24 hrs',4.7,64),
 ('Oando — Lekki P2','Lekki','Admiralty Way, Lekki P2',ST_GeogFromText('SRID=4326;POINT(3.551 6.446)'),'{Petrol}',862,null,null,'/L',now(),true,'{"Petrol":"available"}','Open 24 hrs',4.0,187),
 ('MRS — Victoria Island','Victoria Island','Ahmadu Bello Way, VI',ST_GeogFromText('SRID=4326;POINT(3.415 6.433)'),'{Petrol,CNG}',868,492,null,'/L',now(),true,'{"Petrol":"available","CNG":"low"}','Open 24 hrs',3.9,143),
 ('Shell — Ikoyi','Ikoyi','Kingsway Rd, Ikoyi',ST_GeogFromText('SRID=4326;POINT(3.441 6.449)'),'{Petrol}',866,null,null,'/L',now(),true,'{"Petrol":"available"}','Open · closes 11pm',4.3,226),
 ('GreenCharge — Lekki','Lekki','Fola Osibo, Lekki P1',ST_GeogFromText('SRID=4326;POINT(3.557 6.444)'),'{EV}',null,null,315,'/kWh',now(),true,'{"EV":"3/6 stalls free"}','Open 24 hrs',4.5,71),
 ('Forte Oil — Ajah','Ajah','Addo Rd, Ajah',ST_GeogFromText('SRID=4326;POINT(3.571 6.462)'),'{Petrol}',858,null,null,'/L',now(),true,'{"Petrol":"available"}','Open · closes 10pm',3.7,95),
 ('CNG City — Ajah','Ajah','Ajah Market Rd',ST_GeogFromText('SRID=4326;POINT(3.575 6.465)'),'{CNG}',null,488,null,'/SCM',now(),true,'{"CNG":"available"}','Open 24 hrs',4.2,44),
 ('TotalEnergies — VI','Victoria Island','Sanusi Fafunwa, VI',ST_GeogFromText('SRID=4326;POINT(3.426 6.429)'),'{Petrol,EV}',869,null,308,'/L',now(),true,'{"Petrol":"available","EV":"available"}','Open 24 hrs',4.1,178),
 ('NNPC — Yaba','Yaba','Herbert Macaulay Way, Yaba',ST_GeogFromText('SRID=4326;POINT(3.374 6.512)'),'{Petrol}',854,null,null,'/L',now(),true,'{"Petrol":"available"}','Open · closes 10pm',3.8,132),
 ('Mobil — Surulere','Surulere','Bode Thomas, Surulere',ST_GeogFromText('SRID=4326;POINT(3.352 6.501)'),'{Petrol,CNG}',861,491,null,'/L',now(),true,'{"Petrol":"available","CNG":"available"}','Open 24 hrs',4.0,119),
 ('Eko Electric Hub','Victoria Island','Eko Hotel Rd, VI',ST_GeogFromText('SRID=4326;POINT(3.419 6.427)'),'{EV}',null,null,320,'/kWh',now(),true,'{"EV":"5/10 stalls free"}','Open 24 hrs',4.8,203),
 ('Oando — Ikeja GRA','Ikeja','Oduduwa Way, GRA Ikeja',ST_GeogFromText('SRID=4326;POINT(3.342 6.592)'),'{Petrol}',860,null,null,'/L',now(),true,'{"Petrol":"available"}','Open 24 hrs',4.0,167),
 ('AP — Ikeja','Ikeja','Obafemi Awolowo Way, Ikeja',ST_GeogFromText('SRID=4326;POINT(3.338 6.596)'),'{Petrol,CNG}',864,494,null,'/L',now(),true,'{"Petrol":"low","CNG":"available"}','Open 24 hrs',3.9,88),
 ('Shell — Lekki Epe','Lekki','Lekki-Epe Expressway, km 12',ST_GeogFromText('SRID=4326;POINT(3.601 6.451)'),'{Petrol}',857,null,null,'/L',now(),true,'{"Petrol":"available"}','Open 24 hrs',4.1,76),
 ('CNG Express — Ikeja','Ikeja','Mobolaji Bank Anthony Way',ST_GeogFromText('SRID=4326;POINT(3.348 6.588)'),'{CNG}',null,493,null,'/SCM',now(),true,'{"CNG":"available"}','Open 24 hrs',4.3,52),
 ('VoltHub — Lekki','Lekki','Orchard Rd, Lekki',ST_GeogFromText('SRID=4326;POINT(3.553 6.441)'),'{EV}',null,null,300,'/kWh',now(),false,'{"EV":"0/4 stalls free"}','Closed · opens 7am',4.4,39),
 ('MRS — Ajah','Ajah','Abraham Adesanya Rd, Ajah',ST_GeogFromText('SRID=4326;POINT(3.568 6.459)'),'{Petrol}',856,null,null,'/L',now(),true,'{"Petrol":"available"}','Open · closes 11pm',3.9,104),
 ('Eterna — Surulere','Surulere','Western Ave, Surulere',ST_GeogFromText('SRID=4326;POINT(3.361 6.505)'),'{Petrol}',853,null,null,'/L',now(),true,'{"Petrol":"available"}','Open 24 hrs',3.7,81),
 ('TotalEnergies — Yaba','Yaba','Murtala Muhammed Way, Yaba',ST_GeogFromText('SRID=4326;POINT(3.379 6.508)'),'{Petrol,CNG}',867,496,null,'/L',now(),true,'{"Petrol":"available","CNG":"available"}','Open 24 hrs',4.2,149),
 ('Oando — Ikoyi','Ikoyi','Bourdillon Rd, Ikoyi',ST_GeogFromText('SRID=4326;POINT(3.454 6.456)'),'{Petrol}',863,null,null,'/L',now(),true,'{"Petrol":"available"}','Open · closes 11pm',4.0,112),
 ('GreenCharge — VI','Victoria Island','Karimu Kotun, VI',ST_GeogFromText('SRID=4326;POINT(3.431 6.435)'),'{EV}',null,null,312,'/kWh',now(),true,'{"EV":"2/4 stalls free"}','Open 24 hrs',4.5,83),
 ('NNPC — Surulere','Surulere','Iponri Estate Rd',ST_GeogFromText('SRID=4326;POINT(3.367 6.498)'),'{Petrol}',852,null,null,'/L',now(),false,'{"Petrol":"out"}','Closed · opens 6am',3.6,67),
 ('AP — Lekki P1','Lekki','Fola Osibo, Lekki P1',ST_GeogFromText('SRID=4326;POINT(3.559 6.445)'),'{Petrol,CNG,EV}',871,497,318,'/L',now(),true,'{"Petrol":"available","CNG":"available","EV":"available"}','Open 24 hrs',4.3,191)
on conflict do nothing;
