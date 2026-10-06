// Search locations, stations, destinations (PRD §6).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/stations_repo.dart';
import '../home/home_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final stations = ref.watch(stationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SearchBar(
            hintText: 'Station, area, street… (try “Lekki”)',
            leading: const Icon(Icons.search),
            onChanged: (v) => setState(() => q = v),
          ),
        ),
        Expanded(
          child: stations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (all) {
              final items = all
                  .where((s) => q.isEmpty ||
                      (s.name + s.address + s.area + s.state)
                          .toLowerCase()
                          .contains(q.toLowerCase()))
                  .toList();
              if (items.isEmpty) {
                return const Center(child: Text('No matches — try another search.'));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => StationTile(station: items[i]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
