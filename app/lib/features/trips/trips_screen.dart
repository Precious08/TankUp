// Trips: recent + planned routes (PRD §12 groundwork; corridor search in Phase 7).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/stations_repo.dart';
import '../home/home_screen.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});
  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  String from = 'Lekki';
  String to = 'Ibadan';
  List<String> recent = const ['Lekki → VI · yesterday'];

  @override
  Widget build(BuildContext context) {
    final stations = ref.watch(stationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('FROM'),
          DropdownButton<String>(
            value: from,
            isExpanded: true,
            items: const ['Lekki', 'Ikoyi', 'Victoria Island', 'Ibadan', 'Abuja']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => from = v ?? from),
          ),
          const Text('TO'),
          DropdownButton<String>(
            value: to,
            isExpanded: true,
            items: const ['Ibadan', 'Lekki', 'Victoria Island', 'Abuja', 'Epe']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => to = v ?? to),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              setState(() => recent = ['$from → $to · just now', ...recent].take(5).toList());
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Route planned — corridor search lands in Phase 7')));
            },
            child: const Text('Plan trip'),
          ),
          const SizedBox(height: 12),
          const Text('On this route (sample)'),
          stations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (all) {
              final opts = all.take(3).toList();
              return Column(
                  children: [for (final s in opts) StationTile(station: s)]);
            },
          ),
          const SizedBox(height: 8),
          const Text('Recent'),
          for (final r in recent) ListTile(title: Text(r)),
        ],
      ),
    );
  }
}
