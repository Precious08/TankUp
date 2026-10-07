// In-app navigation (PRD §13): route card, spoken steps, hands-free.
// Live Mapbox guidance + GPS progression arrive in Phase 7.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';

class NavScreen extends ConsumerStatefulWidget {
  final Station station;
  const NavScreen({super.key, required this.station});

  @override
  ConsumerState<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends ConsumerState<NavScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  Future<void> _speak(String text) async {
    final voice = ref.read(prefsProvider).voice;
    if (!voice || _muted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _speakCurrent() {
    _speak('Navigating to ${widget.station.name}. Head toward ${widget.station.area}.');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.station;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigating'),
        actions: [
          IconButton(
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              setState(() => _muted = !_muted);
              if (_muted) _tts.stop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('DEMO · SIMULATED MOVEMENT, NOT GPS',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('To ${s.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${s.fuels.map(fuelName).join(' · ')} · ${s.priceLabel} · ${s.availability}'),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.navigation),
              title: Text('Head toward ${s.area}')),
          ListTile(
              leading: const Icon(Icons.location_on),
              title: Text('Arrive at ${s.name.split('—').first.trim()}')),
          FilledButton.tonal(
            onPressed: () {
              _speak('Welcome to ${s.name}. ${s.priceLabel}, ${s.availability}.');
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🎉 Welcome to ${s.name}')));
            },
            child: const Text("I've arrived"),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('End navigation'),
          ),
        ],
      ),
    );
  }
}
