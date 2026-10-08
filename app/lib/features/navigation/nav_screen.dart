// In-app navigation as a bottom card (PRD §13), not a page.
// Spoken steps, hands-free. Live Mapbox guidance + GPS arrive in Phase 7.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';

class NavCard extends ConsumerStatefulWidget {
  final Station station;
  const NavCard({super.key, required this.station});

  @override
  ConsumerState<NavCard> createState() => _NavCardState();
}

class _NavCardState extends ConsumerState<NavCard> {
  final FlutterTts _tts = FlutterTts();
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak('Navigating to ${widget.station.name}. Head toward ${widget.station.area}.');
    });
  }

  Future<void> _speak(String text) async {
    if (!ref.read(prefsProvider).voice || _muted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.station;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(99))),
          ),
          const SizedBox(height: 8),
          const Text('DEMO · SIMULATED MOVEMENT, NOT GPS',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text('On your way', style: Theme.of(context).textTheme.headlineSmall),
          Text('To ${s.name.split('—').first.trim()}',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${s.fuels.map(fuelName).join(' · ')} · ${s.priceLabel} · ${s.availability}'),
            ),
          ),
          const ListTile(
              leading: Icon(Icons.navigation), title: Text('1. Head toward the area')),
          ListTile(
              leading: const Icon(Icons.location_on),
              title: Text('2. Arrive at ${s.name.split('—').first.trim()}')),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                label: Text(_muted ? 'Muted' : 'Voice on'),
                onPressed: () {
                  setState(() => _muted = !_muted);
                  if (_muted) {
                    _tts.stop();
                  } else {
                    _speak('Voice guidance on.');
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('End'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
