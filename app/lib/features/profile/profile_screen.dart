// Driver settings hub (PRD §27): profile, appearance, vehicles, notifications.
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/store.dart' as store;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late bool notifPrice = store.getBool('notifPrice', fallback: true);
  late bool notifAvail = store.getBool('notifAvail', fallback: true);
  late bool notifRoute = store.getBool('notifRoute');

  Future<void> _pickAvatar() async {
    try {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
      if (img == null) return;
      final bytes = await img.readAsBytes();
      ref.read(avatarBytesProvider.notifier).set(bytes);
      ref.read(prefsProvider.notifier).setAvatarPath(img.path);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Avatar updated ✓')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open gallery')));
      }
    }
  }

  Widget _avatar(double r, String name, List<int>? bytes) {
    if (bytes != null) {
      return CircleAvatar(radius: r, backgroundImage: MemoryImage(Uint8List.fromList(bytes)));
    }
    return CircleAvatar(
        radius: r, child: Text(name.isEmpty ? 'D' : name[0].toUpperCase()));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(prefsProvider);
    final bytes = ref.watch(avatarBytesProvider);
    final vehicles = ref.watch(vehiclesProvider);
    final active = vehicles.firstWhere((v) => v.active, orElse: () => vehicles.first);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            GestureDetector(onTap: _pickAvatar, child: _avatar(28, prefs.name, bytes)),
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
          TextButton.icon(
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Change avatar photo'),
            onPressed: _pickAvatar,
          ),
          _group(context, 'APPEARANCE'),
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
          _group(context, 'MY VEHICLES'),
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
                builder: (_) => StatefulBuilder(
                  builder: (_, setD) => AlertDialog(
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
                  ),
                ),
              );
              if (ok == true && nickname.text.trim().isNotEmpty) {
                ref.read(vehiclesProvider.notifier).add(nickname.text.trim(), energy);
              }
            },
          ),
          _group(context, 'NOTIFICATIONS'),
          SwitchListTile(
            title: const Text('Price changes'),
            value: notifPrice,
            onChanged: (v) {
              setState(() => notifPrice = v);
              store.setBool('notifPrice', v);
            },
          ),
          SwitchListTile(
            title: const Text('Availability updates'),
            value: notifAvail,
            onChanged: (v) {
              setState(() => notifAvail = v);
              store.setBool('notifAvail', v);
            },
          ),
          SwitchListTile(
            title: const Text('Route updates'),
            value: notifRoute,
            onChanged: (v) {
              setState(() => notifRoute = v);
              store.setBool('notifRoute', v);
            },
          ),
          _group(context, 'PRIVACY'),
          OutlinedButton(
            onPressed: () {
              for (final id in ref.read(savedProvider).toList()) {
                ref.read(savedProvider.notifier).toggle(id);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved stations cleared')));
            },
            child: const Text('Clear saved stations'),
          ),
          _group(context, 'ABOUT'),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('TankUp 1.0.0 (scaffold)'),
            subtitle: Text('Find the right place to power your vehicle.'),
          ),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      );
}
