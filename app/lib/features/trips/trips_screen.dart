// Trips: planned routes with on-route stations + recents.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/stations_repo.dart';
import '../home/home_screen.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});
  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  String from = 'Lagos';
  String to = 'Oyo';
  List<String> recent = const [];
  List<String>? planned;

  @override
  Widget build(BuildContext context) {
    final stations = ref.watch(stationsProvider);
    final stateList = _states(stations.value);
    final fromValue = stateList.contains(from) ? from : stateList.first;
    final toValue = stateList.contains(to) ? to : stateList.last;
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Plan a route',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Text('FROM'),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: fromValue,
                    isExpanded: true,
                    items: stateList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => from = v ?? from),
                  ),
                  const SizedBox(height: 12),
                  const Text('TO'),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: toValue,
                    isExpanded: true,
                    items: stateList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => to = v ?? to),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        planned = [from, to];
                        recent = ['$from → $to · just now', ...recent].take(5).toList();
                      });
                    },
                    child: const Text('Find stations on route'),
                  ),
                ],
              ),
            ),
          ),
          if (planned != null) ...[
            const SizedBox(height: 16),
            Text('On ${planned![0]} → ${planned![1]} · cheapest first',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            stations.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (all) {
                final opts = all
                    .where((s) =>
                        (s.state == planned![0] || s.state == planned![1]) && s.open)
                    .toList()
                  ..sort((a, b) => a.price.compareTo(b.price));
                final top = opts.take(6).toList();
                if (top.isEmpty) {
                  return const Card(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No open stations on this route yet.'),
                  ));
                }
                return Column(
                    children: [for (final s in top) StationTile(station: s)]);
              },
            ),
          ],
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Recent', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final r in recent) Card(child: ListTile(title: Text(r))),
          ],
          const SizedBox(height: 8),
          const Text('Corridor search (stations truly along the road) lands in Phase 7.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  List<String> _states(List<Station>? all) {
    if (all == null || all.isEmpty) return [from, to];
    final list = <String>{for (final s in all) s.state}.toList()..sort();
    return list;
  }
}
