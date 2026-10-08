// Settings: everything configurable, nothing else (PRD §27).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_state.dart';
import '../../core/store.dart' as store;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool notifPrice = store.getBool('notifPrice', fallback: true);
  late bool notifAvail = store.getBool('notifAvail', fallback: true);
  late bool notifRoute = store.getBool('notifRoute');

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(prefsProvider);
    final saved = ref.watch(savedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _group(context, 'APPEARANCE'),
          Card(
            child: Column(children: [
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
            ]),
          ),
          _group(context, 'NOTIFICATIONS'),
          Card(
            child: Column(children: [
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
            ]),
          ),
          _group(context, 'PRIVACY'),
          Card(
            child: ListTile(
              title: Text('Saved stations (${saved.length})'),
              trailing: TextButton(
                onPressed: saved.isEmpty
                    ? null
                    : () {
                        for (final id in ref.read(savedProvider).toList()) {
                          ref.read(savedProvider.notifier).toggle(id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved stations cleared')));
                      },
                child: const Text('Clear'),
              ),
            ),
          ),
          _group(context, 'ABOUT'),
          const Card(
            child: ListTile(
              title: Text('TankUp 1.0.0 (scaffold)'),
              subtitle: Text('Find the right place to power your vehicle.'),
            ),
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
