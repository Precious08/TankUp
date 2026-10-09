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
    const ink = Color(0xFF0F172A);
    const sub = Color(0xFFB6C0CE);
    return SafeArea(
      child: Container(
        color: ink,
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
                  fontSize: 10, fontWeight: FontWeight.bold, color: sub)),
          const SizedBox(height: 4),
          const Text('On your way',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('To ${s.name.split('—').first.trim()}',
              style: const TextStyle(color: sub, fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(s.fuels.map(fuelName).join(' · '),
                    style: const TextStyle(color: sub, fontSize: 13)),
                Text(s.priceLabel,
                    style: const TextStyle(
                        color: Color(0xFF4ADE80),
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                Text('${s.availability} · ${s.hours} · ${s.rating} ★',
                    style: const TextStyle(color: sub, fontSize: 12)),
              ],
            ),
          ),
          _step('1. Head toward ${s.area}', 'ahead', cur: true),
          _step('2. Arrive at ${s.name.split('—').first.trim()}',
              s.open ? 'Open' : 'Closed'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white),
                label: Text(_muted ? 'Muted' : 'Voice on',
                    style: const TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54)),
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
      ),
    );
  }

  Widget _step(String t, String d, {bool cur = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: cur ? const Color(0x1F4ADE80) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
            bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
        Text(d, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }
}
