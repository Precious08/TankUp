// Driver dashboard, local-first (PRD §27; server sync in Phase 8).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final vehicles = ref.watch(vehiclesProvider);
    final active = vehicles.firstWhere((v) => v.active, orElse: () => vehicles.first);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            CircleAvatar(
              radius: 28,
              child: Text(prefs.name.isEmpty ? 'D' : prefs.name[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prefs.name, style: Theme.of(context).textTheme.titleLarge),
              Text('${fuelName(active.energy)} · ${active.nickname} · local',
                  style: const TextStyle(color: Colors.grey)),
            ]),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final c = TextEditingController(text: prefs.name);
                final v = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Display name'),
                    content: TextField(controller: c, autofocus: true),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, c.text.trim()),
                          child: const Text('Save')),
                    ],
                  ),
                );
                if (v != null && v.isNotEmpty) {
                  ref.read(prefsProvider.notifier).setName(v);
                }
              },
              child: const Text('Edit'),
            ),
          ]),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: prefs.dark,
            onChanged: (v) => ref.read(prefsProvider.notifier).setDark(v),
          ),
          SwitchListTile(
            title: const Text('Miles instead of km'),
            value: prefs.miles,
            onChanged: (v) => ref.read(prefsProvider.notifier).setMiles(v),
          ),
          SwitchListTile(
            title: const Text('Voice guidance'),
            value: prefs.voice,
            onChanged: (v) => ref.read(prefsProvider.notifier).setVoice(v),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text('My vehicles', style: Theme.of(context).textTheme.titleMedium),
          ),
          for (var i = 0; i < vehicles.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_car),
              title: Text(vehicles[i].nickname),
              subtitle: Text(
                  '${fuelName(vehicles[i].energy)}${vehicles[i].active ? ' · active' : ''}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (!vehicles[i].active)
                  TextButton(
                    onPressed: () {
                      ref.read(vehiclesProvider.notifier).activate(i);
                      ref.read(filtersProvider.notifier).setFuel(vehicles[i].energy);
                    },
                    child: const Text('Use'),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref.read(vehiclesProvider.notifier).remove(i),
                ),
              ]),
            ),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add vehicle'),
            onPressed: () async {
              Fuel energy = Fuel.petrol;
              final nickname = TextEditingController();
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => StatefulBuilder(builder: (_, setD) => AlertDialog(
                      title: const Text('Add vehicle'),
                      content: Column(mainAxisSize: MainAxisSize.min, children: [
                        TextField(
                            controller: nickname,
                            decoration: const InputDecoration(labelText: 'Nickname')),
                        const SizedBox(height: 8),
                        SegmentedButton<Fuel>(
                          segments: const [
                            ButtonSegment(value: Fuel.petrol, label: Text('Petrol')),
                            ButtonSegment(value: Fuel.cng, label: Text('CNG')),
                            ButtonSegment(value: Fuel.ev, label: Text('EV')),
                          ],
                          selected: {energy},
                          onSelectionChanged: (s) => setD(() => energy = s.first),
                        ),
                      ]),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Add')),
                      ],
                    )),
              );
              if (ok == true && nickname.text.trim().isNotEmpty) {
                ref.read(vehiclesProvider.notifier).add(nickname.text.trim(), energy);
              }
            },
          ),
        ],
      ),
    );
  }
}
