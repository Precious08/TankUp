// Home: pannable/zoomable map, tappable pins, filters, nearby list (PRD §6-§8).
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/stations_repo.dart';
import '../../design/theme.dart';
import '../profile/profile_screen.dart';
import '../stations/station_details.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationsProvider);
    final f = ref.watch(filtersProvider);
    final cmp = ref.watch(compareProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TankUp'),
        actions: [
          IconButton(
            tooltip: 'Add missing station',
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () {
              final known = ref.read(stationsProvider).value ?? const <Station>[];
              final states = <String>{for (final s in known) s.state}.toList()..sort();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => _AddStationSheet(states: states.isEmpty ? ['Lagos'] : states),
              );
            },
          ),
          if (!backendOn)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Chip(label: Text('SAMPLE'), visualDensity: VisualDensity.compact),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _AvatarButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ),
        ],
      ),
      body: stations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load stations: $e')),
        data: (all) {
          final items = all.where((s) {
            if (f.fuel != null && !s.fuels.contains(f.fuel)) return false;
            if (f.openOnly && !s.open) return false;
            if (f.state != 'All' && s.state != f.state) return false;
            if (f.query.isNotEmpty &&
                !(s.name + s.address + s.area).toLowerCase().contains(f.query.toLowerCase())) {
              return false;
            }
            return true;
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: SearchBar(
                  hintText: 'Search stations, areas…',
                  leading: const Icon(Icons.search),
                  onChanged: (v) => ref.read(filtersProvider.notifier).setQuery(v),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ActionChip(
                        avatar: const Icon(Icons.map_outlined, size: 18),
                        label: Text(f.state),
                        onPressed: () async {
                          final states = <String>{
                            for (final s in all) s.state
                          }.toList()
                            ..sort();
                          final pick = await showDialog<String>(
                            context: context,
                            builder: (_) => SimpleDialog(
                              title: const Text('Choose state'),
                              children: [
                                for (final t in states)
                                  SimpleDialogOption(
                                    onPressed: () => Navigator.pop(context, t),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text('$t (${all.where((s) => s.state == t).length})'),
                                    ),
                                  ),
                              ],
                            ),
                          );
                          if (pick != null) {
                            ref.read(filtersProvider.notifier).setState(pick);
                          }
                        },
                      ),
                    ),
                    for (final opt in const [null, Fuel.petrol, Fuel.cng, Fuel.ev])
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          label: Text(opt == null ? 'All' : fuelName(opt)),
                          selected: f.fuel == opt,
                          onSelected: (_) => ref.read(filtersProvider.notifier).setFuel(opt),
                        ),
                      ),
                    FilterChip(
                      label: const Text('Open now'),
                      selected: f.openOnly,
                      onSelected: (v) => ref.read(filtersProvider.notifier).setOpenOnly(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(height: 220, child: _MapView(stations: items)),
              if (cmp.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Card(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    child: ListTile(
                      dense: true,
                      title: Text('⚖️ ${cmp.length} to compare',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onInverseSurface)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        TextButton(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (_) => CompareSheet(ids: cmp.toList()),
                          ),
                          child: const Text('Compare'),
                        ),
                        TextButton(
                          onPressed: () => ref.read(compareProvider.notifier).clear(),
                          child: const Text('Clear'),
                        ),
                      ]),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Nearby · ${items.length}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No stations match — loosen a filter.'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) => StationTile(station: items[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Pan/zoom map with tappable pins, Google-style controls, avatar shortcut.
/// Native Mapbox tiles land in Phase 6; geometry is already real lng/lat.
class _MapView extends ConsumerStatefulWidget {
  final List<Station> stations;
  const _MapView({required this.stations});

  @override
  ConsumerState<_MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<_MapView> {
  final TransformationController _controller = TransformationController();
  ({double lat, double lng})? _me;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoom(double f) {
    final size = context.size;
    final c = size == null ? Offset.zero : Offset(size.width / 2, size.height / 2);
    final cur = _controller.value;
    final s1 = (cur.getMaxScaleOnAxis() * f).clamp(0.6, 5.0);
    final t = cur.getTranslation();
    // keep the viewport centre fixed while rescaling around it
    final k = s1 / cur.getMaxScaleOnAxis();
    _controller.value = Matrix4.diagonal3Values(s1, s1, 1)
      ..setTranslationRaw(c.dx - (c.dx - t.x) * k, c.dy - (c.dy - t.y) * k, 0);
  }

  Future<void> _locate() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')));
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _me = (lat: pos.latitude, lng: pos.longitude));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Centered on you')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location unavailable right now')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stations = [...widget.stations];
    var x0 = 1e9, x1 = -1e9, y0 = 1e9, y1 = -1e9;
    void eat(double lng, double lat) {
      if (lng < x0) x0 = lng;
      if (lng > x1) x1 = lng;
      if (lat < y0) y0 = lat;
      if (lat > y1) y1 = lat;
    }

    for (final s in stations) {
      eat(s.lng, s.lat);
    }
    if (_me != null) eat(_me!.lng, _me!.lat);
    if (stations.isEmpty && _me == null) {
      return const Center(child: Text('No stations in view'));
    }
    final dx = (x1 - x0) < 0.01 ? 0.01 : (x1 - x0);
    final dy = (y1 - y0) < 0.01 ? 0.01 : (y1 - y0);
    Color pin(Station s) => switch (s.fuels.first) {
          Fuel.petrol => const Color(0xFFB45309),
          Fuel.cng => const Color(0xFF075985),
          Fuel.ev => const Color(0xFF5B21B6),
        };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, box) {
        Offset px(double lng, double lat) => Offset(
              (lng - x0) / dx * (box.maxWidth - 24),
              (1 - (lat - y0) / dy) * (box.maxHeight - 24),
            );
        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _controller,
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.6,
              maxScale: 5,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: SizedBox(
                  width: box.maxWidth,
                  height: box.maxHeight,
                  child: CustomPaint(
                    painter: _GridPainter(
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF26334D)
                            : const Color(0xFFDDE5D8)),
                    child: Stack(
                      children: [
                        for (final s in stations)
                          Builder(builder: (_) {
                            final p = px(s.lng, s.lat);
                            return Positioned(
                              left: p.dx,
                              top: p.dy,
                              child: GestureDetector(
                                onTap: () => showStationSheet(context, s),
                                child: Transform.rotate(
                                  angle: -0.7853982,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: s.open ? pin(s) : Colors.grey,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(13),
                                        topRight: Radius.circular(13),
                                        bottomRight: Radius.circular(13),
                                        bottomLeft: Radius.circular(3),
                                      ),
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0x8C0F172A),
                                            blurRadius: 4,
                                            spreadRadius: 1)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        if (_me != null)
                          Builder(builder: (_) {
                            final p = px(_me!.lng, _me!.lat);
                            return Positioned(
                              left: p.dx - 9,
                              top: p.dy - 9,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Column(children: [
                _MapBtn(icon: Icons.add, onTap: () => _zoom(1.4)),
                const SizedBox(height: 8),
                _MapBtn(icon: Icons.remove, onTap: () => _zoom(1 / 1.4)),
                const SizedBox(height: 8),
                _MapBtn(icon: Icons.my_location, onTap: _locate),
              ]),
            ),
          ],
        );
      }),
    );
  }
}

class _AvatarButton extends ConsumerWidget {
  final VoidCallback onTap;
  const _AvatarButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final bytes = ref.watch(avatarBytesProvider);
    final avatar = bytes != null
        ? CircleAvatar(backgroundImage: MemoryImage(Uint8List.fromList(bytes)))
        : CircleAvatar(
            child: Text(prefs.name.isEmpty ? 'D' : prefs.name[0].toUpperCase()));
    return GestureDetector(onTap: onTap, child: avatar);
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, size: 20)),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void showStationSheet(BuildContext context, Station s) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => StationSheet(station: s),
  );
}

class _AddStationSheet extends ConsumerStatefulWidget {
  final List<String> states;
  const _AddStationSheet({required this.states});

  @override
  ConsumerState<_AddStationSheet> createState() => _AddStationSheetState();
}

class _AddStationSheetState extends ConsumerState<_AddStationSheet> {
  final name = TextEditingController();
  final area = TextEditingController();
  final price = TextEditingController();
  late String state = widget.states.first;
  Fuel fuel = Fuel.petrol;

  @override
  void dispose() {
    name.dispose();
    area.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(reportsProvider).length;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(
            20, 8, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
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
          Text('Add missing station',
              style: Theme.of(context).textTheme.headlineSmall),
          const Text('Our team pins it on the map after review.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(controller: name,
              decoration: const InputDecoration(labelText: 'Station name')),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: state,
            isExpanded: true,
            items: [for (final s in widget.states) DropdownMenuItem(value: s, child: Text(s))],
            onChanged: (v) => setState(() => state = v ?? state),
          ),
          const SizedBox(height: 8),
          TextField(controller: area,
              decoration: const InputDecoration(labelText: 'Area / street')),
          const SizedBox(height: 8),
          SegmentedButton<Fuel>(
            segments: const [
              ButtonSegment(value: Fuel.petrol, label: Text('Petrol')),
              ButtonSegment(value: Fuel.cng, label: Text('CNG')),
              ButtonSegment(value: Fuel.ev, label: Text('EV')),
            ],
            selected: {fuel},
            onSelectionChanged: (s) => setState(() => fuel = s.first),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Price in ₦ (if known)'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Give the station a name first')));
                return;
              }
              final sent = await ref.read(reportsProvider.notifier).submit(
                    kind: 'new_station',
                    payload: {
                      'name': name.text.trim(),
                      'state': state,
                      'area': area.text.trim(),
                      'fuel': fuelName(fuel),
                      'price': double.tryParse(price.text.trim()),
                    },
                    note: 'via app',
                    client: backendOn ? Supabase.instance.client : null,
                  );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(sent
                        ? 'Thanks — station sent for review ✓'
                        : 'Saved — will send when online ✓')));
              }
            },
            child: const Text('Send for review'),
          ),
          if (pending > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('$pending report(s) waiting for connection',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class StationTile extends ConsumerWidget {
  final Station station;
  const StationTile({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = station;
    final saved = ref.watch(savedProvider).contains(s.id);
    final scheme = Theme.of(context).colorScheme;
    final tint = fuelChip(
        s.fuels.first, Theme.of(context).brightness);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: s.open ? tint.bg : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.location_on,
              color: s.open ? tint.fg : Colors.grey),
        ),
        title: Text(s.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
              '${s.area}, ${s.state} · ${s.open ? "Open" : "Closed"} · ${s.availability}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            constraints: const BoxConstraints(minWidth: 92),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(s.priceLabel,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: scheme.onPrimaryContainer)),
          ),
          IconButton(
            icon: Icon(saved ? Icons.favorite : Icons.favorite_outline),
            onPressed: () => ref.read(savedProvider.notifier).toggle(s.id),
          ),
        ]),
        onTap: () => showStationSheet(context, s),
      ),
    );
  }
}
