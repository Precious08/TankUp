// Station details + price comparison (PRD §9-§10). Reviews arrive in Phase 9.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/stations_repo.dart';
import '../navigation/nav_screen.dart';

class StationDetails extends ConsumerWidget {
  final Station station;
  const StationDetails({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = station;
    final saved = ref.watch(savedProvider).contains(s.id);
    final all = ref.watch(stationsProvider).value ?? const <Station>[];
    final key = s.fuels.contains(Fuel.petrol) ? Fuel.petrol : s.fuels.first;
    final nearby = all.where((x) => x.fuels.contains(key) && x.open).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    final top = nearby.take(3).toList();
    final best = top.isEmpty ? s.price : top.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    return Scaffold(
      appBar: AppBar(title: Text(s.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
              spacing: 6,
              children: [for (final f in s.fuels) Chip(label: Text(fuelName(f)))]),
          const SizedBox(height: 8),
          Text(s.priceLabel, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          _kv('Availability', s.availability),
          _kv('Hours', s.hours),
          _kv('Address', '${s.address}, ${s.lga}, ${s.state}'),
          _kv('Rating', '${s.rating} ★ (${s.reviews})'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NavScreen(station: s))),
                child: const Text('Get Directions'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => ref.read(savedProvider.notifier).toggle(s.id),
                child: Text(saved ? '♥ Saved' : '♡ Save'),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Text('Compare nearby ${fuelName(key)}', style: Theme.of(context).textTheme.titleMedium),
          for (final r in top)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.name),
              trailing: Text(r.priceLabel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: r.price == best
                          ? Theme.of(context).colorScheme.primary
                          : null)),
            ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: Colors.grey)),
          Flexible(child: Text(v, textAlign: TextAlign.right)),
        ]),
      );
}
