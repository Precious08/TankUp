// Saved stations (PRD §14).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_state.dart';
import '../../core/stations_repo.dart';
import '../home/home_screen.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationsProvider);
    final saved = ref.watch(savedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: stations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) {
          final items = all.where((s) => saved.contains(s.id)).toList();
          if (items.isEmpty) {
            return const Center(
                child: Text('Nothing saved yet — open a station and tap ♡ Save.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => StationTile(station: items[i]),
          );
        },
      ),
    );
  }
}
