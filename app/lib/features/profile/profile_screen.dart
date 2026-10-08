// Driver profile: who you are and what you drive.
// Opened from the home avatar. Settings live under the Settings tab.
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAvatar(WidgetRef ref, BuildContext context) async {
    try {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
      if (img == null) return;
      final bytes = await img.readAsBytes();
      ref.read(avatarBytesProvider.notifier).set(bytes);
      ref.read(prefsProvider.notifier).setAvatarPath(img.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Avatar updated ✓')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open gallery')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final bytes = ref.watch(avatarBytesProvider);
    final vehicles = ref.watch(vehiclesProvider);
    final active = vehicles.firstWhere((v) => v.active, orElse: () => vehicles.first);
    final saved = ref.watch(savedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(children: [
              GestureDetector(
                onTap: () => _pickAvatar(ref, context),
                child: bytes != null
                    ? CircleAvatar(
                        radius: 44,
                        backgroundImage: MemoryImage(Uint8List.fromList(bytes)))
                    : CircleAvatar(
                        radius: 44,
                        child: Text(
                          prefs.name.isEmpty ? 'D' : prefs.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
              ),
              TextButton(
                onPressed: () => _pickAvatar(ref, context),
                child: const Text('Change photo'),
              ),
            ]),
          ),
          Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(prefs.name, style: Theme.of(context).textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
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
              ),
            ]),
          ),
          Text(
            '${fuelName(active.energy)} · ${active.nickname} · ${saved.length} saved',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text('My vehicles', style: Theme.of(context).textTheme.titleMedium),
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
        ],
      ),
    );
  }
}
