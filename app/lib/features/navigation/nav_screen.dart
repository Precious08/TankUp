// In-app navigation stub (PRD §13): route summary + live steps.
// Turn-by-turn engine + Mapbox guidance arrive in Phase 7.
import 'package:flutter/material.dart';
import '../../core/models.dart';

class NavScreen extends StatelessWidget {
  final Station station;
  const NavScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final s = station;
    return Scaffold(
      appBar: AppBar(title: const Text('Navigating')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('To ${s.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${s.fuels.map(fuelName).join(' · ')} · ${s.priceLabel} · ${s.availability}'),
            ),
          ),
          const ListTile(
              leading: Icon(Icons.navigation), title: Text('Head toward the station area')),
          ListTile(
              leading: const Icon(Icons.location_on),
              title: Text('Arrive at ${s.name.split('—').first.trim()}')),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Live GPS guidance lands in Phase 7 — this preview holds your route.',
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
