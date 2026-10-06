// Home: map placeholder + filters + nearby list (PRD §6-§8).
// Native Mapbox tiles land in Phase 6; pins already plot from real lng/lat.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/stations_repo.dart';
import '../stations/station_details.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationsProvider);
    final f = ref.watch(filtersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TankUp'),
        actions: [
          if (!backendOn)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Chip(label: Text('SAMPLE'), visualDensity: VisualDensity.compact),
            ),
        ],
      ),
      body: stations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load stations: $e')),
        data: (all) {
          final items = all.where((s) {
            if (f.fuel != null && !s.fuels.contains(f.fuel)) return false;
            if (f.openOnly && !s.open) return false;
            if (f.state != 'All' && s.state != f.state) return false;
            if (f.query.isNotEmpty &&
                !(s.name + s.address + s.area).toLowerCase().contains(f.query.toLowerCase())) {
              return false;
            }
            return true;
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: SearchBar(
                  hintText: 'Search stations, areas…',
                  leading: const Icon(Icons.search),
                  onChanged: (v) => ref.read(filtersProvider.notifier).setQuery(v),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    for (final opt in const [null, Fuel.petrol, Fuel.cng, Fuel.ev])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(opt == null ? 'All' : fuelName(opt)),
                          selected: f.fuel == opt,
                          onSelected: (_) => ref.read(filtersProvider.notifier).setFuel(opt),
                        ),
                      ),
                    FilterChip(
                      label: const Text('Open now'),
                      selected: f.openOnly,
                      onSelected: (v) => ref.read(filtersProvider.notifier).setOpenOnly(v),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 170, child: _MapPreview(stations: items)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Nearby · ${items.length}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No stations match — loosen a filter.'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) => StationTile(station: items[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Stylised live map preview: real lng/lat geometry, Mapbox tiles in Phase 6.
class _MapPreview extends StatelessWidget {
  final List<Station> stations;
  const _MapPreview({required this.stations});

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return const Center(child: Text('No stations in view'));
    }
    var x0 = stations.first.lng, x1 = x0, y0 = stations.first.lat, y1 = y0;
    for (final s in stations) {
      if (s.lng < x0) x0 = s.lng;
      if (s.lng > x1) x1 = s.lng;
      if (s.lat < y0) y0 = s.lat;
      if (s.lat > y1) y1 = s.lat;
    }
    final dx = (x1 - x0) < 0.01 ? 0.01 : (x1 - x0);
    final dy = (y1 - y0) < 0.01 ? 0.01 : (y1 - y0);
    Color pin(Station s) => switch (s.fuels.first) {
          Fuel.petrol => const Color(0xFFB45309),
          Fuel.cng => const Color(0xFF075985),
          Fuel.ev => const Color(0xFF5B21B6),
        };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: LayoutBuilder(builder: (_, box) {
          return Stack(
            children: [
              for (final s in stations)
                Positioned(
                  left: (s.lng - x0) / dx * (box.maxWidth - 24),
                  top: (1 - (s.lat - y0) / dy) * (box.maxHeight - 24),
                  child: Icon(Icons.location_on,
                      color: s.open ? pin(s) : Colors.grey, size: 26),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFDDE5D8)..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StationTile extends ConsumerWidget {
  final Station station;
  const StationTile({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = station;
    final saved = ref.watch(savedProvider).contains(s.id);
    return ListTile(
      leading: Icon(Icons.location_on, color: s.open ? null : Colors.grey),
      title: Text(s.name),
      subtitle: Text('${s.area}, ${s.state} · ${s.open ? "Open" : "Closed"} · ${s.availability}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(s.priceLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(saved ? Icons.favorite : Icons.favorite_outline),
          onPressed: () => ref.read(savedProvider.notifier).toggle(s.id),
        ),
      ]),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StationDetails(station: s)),
      ),
    );
  }
}
