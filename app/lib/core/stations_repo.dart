// Station source: live Supabase when configured, bundled sample otherwise.
// Keys come from --dart-define (never committed). See docs/api/contract.md.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

const sbUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const sbKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
bool get backendOn => sbUrl.isNotEmpty && sbKey.isNotEmpty;

Station _row(Map<String, dynamic> r, int i) {
  double lng = 0, lat = 0;
  final loc = r['location'];
  if (loc is String) {
    final m = RegExp(r'(-?[\d.]+)\s+(-?[\d.]+)').firstMatch(loc);
    if (m != null) {
      lng = double.tryParse(m.group(1)!) ?? 0;
      lat = double.tryParse(m.group(2)!) ?? 0;
    }
  } else if (loc is Map) {
    final c = loc['coordinates'];
    if (c is List && c.length >= 2) {
      lng = (c[0] as num).toDouble();
      lat = (c[1] as num).toDouble();
    }
  }
  final fuels = ((r['fuels'] as List?) ?? ['Petrol'])
      .map((e) => fuelFrom(e.toString()))
      .whereType<Fuel>()
      .toList();
  String avail = 'Available';
  final a = r['availability'];
  try {
    final Map<String, dynamic> o =
        a is String ? Map<String, dynamic>.from(_parseJson(a)) : Map<String, dynamic>.from(a ?? {});
    if (o.values.isNotEmpty) {
      final s = o.values.first.toString();
      avail = s[0].toUpperCase() + s.substring(1);
    }
  } catch (_) {}
  double priceOf(String k) => (r[k] as num?)?.toDouble() ?? 0;
  final price = r['petrol_price'] != null
      ? priceOf('petrol_price')
      : (r['cng_price'] != null ? priceOf('cng_price') : priceOf('ev_price'));
  return Station(
    id: 'db-$i',
    name: (r['name'] ?? 'Station').toString(),
    state: (r['state'] ?? 'Lagos').toString(),
    lga: (r['lga'] ?? '').toString(),
    area: (r['area'] ?? '').toString(),
    address: (r['address'] ?? '').toString(),
    lng: lng,
    lat: lat,
    fuels: fuels.isEmpty ? const [Fuel.petrol] : fuels,
    price: price,
    unit: (r['price_unit'] ?? '/L').toString(),
    open: r['is_open'] != false,
    availability: avail,
    hours: (r['hours'] ?? 'Open 24 hrs').toString(),
    rating: ((r['rating'] as num?) ?? 4.0).toDouble(),
    reviews: (r['review_count'] as num?)?.toInt() ?? 0,
  );
}

Map<String, dynamic> _parseJson(String s) {
  // minimal {"k":"v"} reader — avoids dart:convert import weight debates; safe for our shape.
  final out = <String, dynamic>{};
  for (final m in RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"').allMatches(s)) {
    out[m.group(1)!] = m.group(2)!;
  }
  return out;
}

// Bundled Lagos sample (mirrors supabase/seed.sql wave 1) for offline/demo.
List<Station> sampleStations() => const [
      Station(id: 's1', name: 'TotalEnergies — Lekki P1', state: 'Lagos', lga: 'Eti-Osa', area: 'Lekki', address: 'Admiralty Way, Lekki', lng: 3.555, lat: 6.447, fuels: [Fuel.petrol, Fuel.cng], price: 865, unit: '/L', open: true, availability: 'Available', hours: 'Open 24 hrs', rating: 4.2, reviews: 318),
      Station(id: 's2', name: 'NNPC — Ikoyi Rd', state: 'Lagos', lga: 'Eti-Osa', area: 'Ikoyi', address: 'Ikoyi Road', lng: 3.445, lat: 6.452, fuels: [Fuel.petrol], price: 859, unit: '/L', open: true, availability: 'Available', hours: 'Open · closes 11pm', rating: 4.0, reviews: 204),
      Station(id: 's3', name: 'ChargePoint — VI Hub', state: 'Lagos', lga: 'Eti-Osa', area: 'Victoria Island', address: 'Adeola Odeku, VI', lng: 3.421, lat: 6.431, fuels: [Fuel.ev], price: 310, unit: '/kWh', open: true, availability: '2/6 stalls free', hours: 'Open 24 hrs', rating: 4.6, reviews: 97),
      Station(id: 's4', name: 'Mobil — Admiralty', state: 'Lagos', lga: 'Eti-Osa', area: 'Lekki', address: 'Admiralty Way, Lekki', lng: 3.548, lat: 6.443, fuels: [Fuel.petrol, Fuel.ev], price: 870, unit: '/L', open: true, availability: 'Petrol low', hours: 'Open 24 hrs', rating: 3.9, reviews: 411),
      Station(id: 's5', name: 'CNG Express — Lekki', state: 'Lagos', lga: 'Eti-Osa', area: 'Lekki', address: 'Chevron Drive, Lekki', lng: 3.562, lat: 6.439, fuels: [Fuel.cng], price: 490, unit: '/SCM', open: false, availability: 'Available', hours: 'Closed · opens 6am', rating: 4.4, reviews: 58),
      Station(id: 's6', name: 'AP — Ozumba Mbadiwe', state: 'Lagos', lga: 'Eti-Osa', area: 'Victoria Island', address: 'Ozumba Mbadiwe, VI', lng: 3.438, lat: 6.428, fuels: [Fuel.petrol, Fuel.cng, Fuel.ev], price: 872, unit: '/L', open: true, availability: 'Available', hours: 'Open 24 hrs', rating: 4.1, reviews: 156),
      Station(id: 's7', name: 'Eterna — Lekki Epe', state: 'Lagos', lga: 'Eti-Osa', area: 'Lekki', address: 'Lekki-Epe Expressway', lng: 3.585, lat: 6.449, fuels: [Fuel.petrol], price: 855, unit: '/L', open: true, availability: 'Available', hours: 'Open · closes 10pm', rating: 3.8, reviews: 89),
      Station(id: 's8', name: 'VoltHub — Ikoyi', state: 'Lagos', lga: 'Eti-Osa', area: 'Ikoyi', address: 'Bourdillon Rd, Ikoyi', lng: 3.451, lat: 6.458, fuels: [Fuel.ev], price: 295, unit: '/kWh', open: true, availability: '4/8 stalls free', hours: 'Open 24 hrs', rating: 4.7, reviews: 64),
    ];

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  if (!backendOn) return sampleStations();
  try {
    final rows = await Supabase.instance.client
        .from('stations')
        .select()
        .order('name')
        .limit(500);
    final list = <Station>[];
    for (var i = 0; i < (rows as List).length; i++) {
      list.add(_row(Map<String, dynamic>.from(rows[i] as Map), i));
    }
    return list.isEmpty ? sampleStations() : list;
  } catch (_) {
    return sampleStations(); // offline fallback (ADR 003)
  }
});
