// Station bottom sheet: info, compare, reviews, actions (PRD §8-§10, §19).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/stations_repo.dart';
import '../../design/theme.dart';
import '../navigation/nav_screen.dart';

class StationSheet extends ConsumerWidget {
  final Station station;
  const StationSheet({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = station;
    final saved = ref.watch(savedProvider).contains(s.id);
    final inCmp = ref.watch(compareProvider).contains(s.id);
    final all = ref.watch(stationsProvider).value ?? const <Station>[];
    final key = s.fuels.contains(Fuel.petrol) ? Fuel.petrol : s.fuels.first;
    final nearby = all.where((x) => x.fuels.contains(key) && x.open).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    final top = nearby.take(3).toList();
    final best = top.isEmpty ? s.price : top.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final reviews = ref.watch(reviewsProvider)[s.name] ?? const [];
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Center(
            child: Container(
                width: 44, height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(99))),
          ),
          const SizedBox(height: 12),
          Text(s.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${s.address}, ${s.lga} · ${s.state}',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final f in s.fuels)
                  Builder(builder: (_) {
                    final t = fuelChip(f, brightness);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: t.bg, borderRadius: BorderRadius.circular(7)),
                      child: Text(fuelName(f).toUpperCase(),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: t.fg)),
                    );
                  }),
              ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.priceLabel,
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 2),
                Text('${s.open ? "Open" : "Closed"} · ${s.availability} · updated recently',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _kv('Availability', s.availability),
          const Divider(height: 1),
          _kv('Hours', s.hours),
          const Divider(height: 1),
          _kv('Rating', '${s.rating} ★ (${s.reviews})'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: FilledButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => NavCard(station: s),
                ),
                child: const Text('Directions'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => ref.read(savedProvider.notifier).toggle(s.id),
                child: Text(saved ? '♥ Saved' : '♡ Save'),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              final ok = ref.read(compareProvider.notifier).toggle(s.id);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Comparison holds 3 max — remove one first')));
              }
            },
            child: Text(inCmp ? '✓ In comparison — tap to remove' : '＋ Compare with others'),
          ),
          const SizedBox(height: 12),
          Text('Reviews (${reviews.length})', style: Theme.of(context).textTheme.titleMedium),
          if (reviews.isEmpty)
            const Text('No reviews yet — be the first.',
                style: TextStyle(color: Colors.grey)),
          for (final r in reviews)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.text),
              trailing: Text('${r.stars}★',
                  style: const TextStyle(
                      color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
            ),
          OutlinedButton(
            onPressed: () => _writeReview(context, ref, s),
            child: const Text('Write a review'),
          ),
          const SizedBox(height: 12),
          Text('Spot something wrong?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _reportPrice(context, ref, s),
                child: const Text('Report price'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _suggestEdit(context, ref, s),
                child: const Text('Suggest edit'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text('Compare nearby ${fuelName(key)}',
              style: Theme.of(context).textTheme.titleMedium),
          for (final r in top)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.name),
              trailing: Text(r.priceLabel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: r.price == best
                          ? Theme.of(context).colorScheme.primary
                          : null)),
            ),
        ],
      ),
    );
  }

  Future<void> _reportPrice(
      BuildContext context, WidgetRef ref, Station s) async {
    final price = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report price change'),
        content: TextField(
          controller: price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'New price in ₦ (${s.unit})'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send')),
        ],
      ),
    );
    final v = double.tryParse(price.text.trim());
    if (ok != true || v == null || v <= 0) return;
    final sent = await ref.read(reportsProvider.notifier).submit(
          kind: 'price',
          payload: {
            'station': s.name,
            'area': s.area,
            'state': s.state,
            'fuel': s.fuels.contains(Fuel.petrol) ? 'Petrol' : fuelName(s.fuels.first),
            'price': v,
          },
          note: 'via app',
          client: backendOn ? Supabase.instance.client : null,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(sent
              ? 'Thanks — price report sent for review ✓'
              : 'Saved — will send when online ✓')));
    }
  }

  Future<void> _suggestEdit(
      BuildContext context, WidgetRef ref, Station s) async {
    const fields = ['Hours', 'Availability', 'Address', 'Other'];
    var field = fields[0];
    final value = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setD) => AlertDialog(
          title: const Text('Suggest an edit'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButton<String>(
              value: field,
              isExpanded: true,
              items: [for (final f in fields) DropdownMenuItem(value: f, child: Text(f))],
              onChanged: (x) => setD(() => field = x ?? field),
            ),
            TextField(controller: value, decoration: const InputDecoration(labelText: 'Correct value')),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Send')),
          ],
        ),
      ),
    );
    if (ok != true || value.text.trim().isEmpty) return;
    final sent = await ref.read(reportsProvider.notifier).submit(
          kind: 'edit',
          payload: {
            'station': s.name,
            'area': s.area,
            'state': s.state,
            'field': field,
            'value': value.text.trim(),
          },
          note: 'via app',
          client: backendOn ? Supabase.instance.client : null,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(sent
              ? 'Thanks — edit sent for review ✓'
              : 'Saved — will send when online ✓')));
    }
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: Colors.grey)),
          Flexible(child: Text(v, textAlign: TextAlign.right)),
        ]),
      );

  Future<void> _writeReview(BuildContext context, WidgetRef ref, Station s) async {
    final text = TextEditingController();
    var stars = 5;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('Review ${s.name.split('—').first.trim()}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: text, autofocus: true,
                decoration: const InputDecoration(labelText: 'Your review')),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(i <= stars ? Icons.star : Icons.star_outline,
                        color: const Color(0xFFB45309)),
                    onPressed: () => setD(() => stars = i),
                  ),
              ],
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Post')),
          ],
        ),
      ),
    );
    if (ok == true && text.text.trim().isNotEmpty) {
      ref.read(reviewsProvider.notifier).add(s.name, text.text.trim(), stars);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Review posted — thanks!')));
      }
    }
  }
}

class CompareSheet extends ConsumerWidget {
  final List<String> ids;
  const CompareSheet({super.key, required this.ids});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(stationsProvider).value ?? const <Station>[];
    final rows = [for (final id in ids) ...all.where((s) => s.id == id)];
    if (rows.isEmpty) {
      return const SafeArea(child: Center(child: Text('Nothing to compare.')));
    }
    final best = rows.map((r) => r.price).reduce((a, b) => a < b ? a : b);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('Side by side', style: Theme.of(context).textTheme.headlineSmall),
          const Text('Cheapest ★', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          for (final r in rows)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.name),
              subtitle: Text('${r.fuels.map(fuelName).join(' · ')} · ${r.availability}'),
              trailing: Text('${r.priceLabel}${r.price == best ? ' ★' : ''}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: r.price == best
                          ? Theme.of(context).colorScheme.primary
                          : null)),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              ref.read(compareProvider.notifier).clear();
              Navigator.of(context).pop();
            },
            child: const Text('Done — clear comparison'),
          ),
        ],
      ),
    );
  }
}
