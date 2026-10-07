// App-wide UI state (Riverpod Notifiers).
// Persisted locally via store.dart; server sync lands in Phase 8.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'store.dart' as store;

class Filters extends Notifier<({Fuel? fuel, bool openOnly, String query, String state})> {
  @override
  ({Fuel? fuel, bool openOnly, String query, String state}) build() =>
      (fuel: null, openOnly: false, query: '', state: 'Lagos');

  void setFuel(Fuel? f) => state = (fuel: f, openOnly: state.openOnly, query: state.query, state: state.state);
  void setOpenOnly(bool v) => state = (fuel: state.fuel, openOnly: v, query: state.query, state: state.state);
  void setQuery(String q) => state = (fuel: state.fuel, openOnly: state.openOnly, query: q, state: state.state);
  void setState(String s) => state = (fuel: state.fuel, openOnly: state.openOnly, query: state.query, state: s);
}

final filtersProvider = NotifierProvider<Filters, ({Fuel? fuel, bool openOnly, String query, String state})>(Filters.new);

class TabIndex extends Notifier<int> {
  @override
  int build() => 0;
  void go(int i) => state = i;
}

final tabIndexProvider = NotifierProvider<TabIndex, int>(TabIndex.new);

class Saved extends Notifier<Set<String>> {
  @override
  Set<String> build() => store.getStringList('saved').toSet();
  void toggle(String id) {
    final next = Set<String>.from(state);
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
    store.setStringList('saved', next.toList());
  }
}

final savedProvider = NotifierProvider<Saved, Set<String>>(Saved.new);

class Compare extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  bool toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      if (next.length >= 3) return false;
      next.add(id);
    }
    state = next;
    return true;
  }

  void clear() => state = {};
}

final compareProvider = NotifierProvider<Compare, Set<String>>(Compare.new);

class Reviews extends Notifier<Map<String, List<({String text, int stars})>>> {
  @override
  Map<String, List<({String text, int stars})>> build() {
    final out = <String, List<({String text, int stars})>>{
      'TotalEnergies — Lekki P1': [
        (text: 'Fast pumps, accurate meter.', stars: 5),
        (text: 'Queue at rush hour.', stars: 3),
      ],
      'Mobil — Admiralty': [
        (text: 'Petrol ran low on Sunday.', stars: 2),
      ],
    };
    for (final key in store.getStringList('reviewKeys')) {
      final texts = store.getStringList('review:$key:text');
      final stars = store.getStringList('review:$key:stars');
      out[key] = [
        for (var i = 0; i < texts.length; i++)
          (text: texts[i], stars: int.tryParse(i < stars.length ? stars[i] : '5') ?? 5),
      ];
    }
    return out;
  }

  void add(String station, String text, int stars) {
    final next = Map<String, List<({String text, int stars})>>.from(state);
    next[station] = [(text: text, stars: stars), ...?next[station]];
    state = next;
    final keys = Set<String>.from(store.getStringList('reviewKeys'))..add(station);
    store.setStringList('reviewKeys', keys.toList());
    store.setStringList('review:$station:text', next[station]!.map((r) => r.text).toList());
    store.setStringList('review:$station:stars', next[station]!.map((r) => r.stars.toString()).toList());
  }
}

final reviewsProvider = NotifierProvider<Reviews, Map<String, List<({String text, int stars})>>>(Reviews.new);

class Vehicles extends Notifier<List<Vehicle>> {
  @override
  List<Vehicle> build() {
    final names = store.getStringList('vehicles');
    if (names.isEmpty) {
      return const [
        Vehicle(nickname: 'Work Van', energy: Fuel.cng, active: true),
        Vehicle(nickname: 'Personal', energy: Fuel.petrol),
      ];
    }
    return [
      for (final n in names)
        Vehicle(
          nickname: n.split('|')[0],
          energy: Fuel.values.byName(n.split('|')[1]),
          active: n.split('|')[2] == '1',
        ),
    ];
  }

  void _save() => store.setStringList(
      'vehicles', [for (final v in state) '${v.nickname}|${v.energy.name}|${v.active ? 1 : 0}']);

  void activate(int i) {
    state = [for (var j = 0; j < state.length; j++) state[j].copyWith(active: i == j)];
    _save();
  }

  void add(String nickname, Fuel energy) {
    state = [...state, Vehicle(nickname: nickname, energy: energy)];
    _save();
  }

  void remove(int i) {
    if (state.length <= 1) return;
    final next = [...state]..removeAt(i);
    if (!next.any((v) => v.active)) next[0] = next[0].copyWith(active: true);
    state = next;
    _save();
  }
}

final vehiclesProvider = NotifierProvider<Vehicles, List<Vehicle>>(Vehicles.new);

class Prefs extends Notifier<({String name, bool dark, bool miles, bool voice, String avatarPath})> {
  @override
  ({String name, bool dark, bool miles, bool voice, String avatarPath}) build() => (
        name: store.getString('name') ?? 'Driver',
        dark: store.getBool('dark'),
        miles: store.getBool('miles'),
        voice: store.getBool('voice', fallback: true),
        avatarPath: store.getString('avatarPath') ?? '',
      );

  void setName(String v) {
    state = (name: v, dark: state.dark, miles: state.miles, voice: state.voice, avatarPath: state.avatarPath);
    store.setString('name', v);
  }

  void setDark(bool v) {
    state = (name: state.name, dark: v, miles: state.miles, voice: state.voice, avatarPath: state.avatarPath);
    store.setBool('dark', v);
  }

  void setMiles(bool v) {
    state = (name: state.name, dark: state.dark, miles: v, voice: state.voice, avatarPath: state.avatarPath);
    store.setBool('miles', v);
  }

  void setVoice(bool v) {
    state = (name: state.name, dark: state.dark, miles: state.miles, voice: v, avatarPath: state.avatarPath);
    store.setBool('voice', v);
  }

  void setAvatarPath(String v) {
    state = (name: state.name, dark: state.dark, miles: state.miles, voice: state.voice, avatarPath: v);
    store.setString('avatarPath', v);
  }
}

final prefsProvider = NotifierProvider<Prefs,
    ({String name, bool dark, bool miles, bool voice, String avatarPath})>(Prefs.new);

/// In-memory custom avatar bytes (gallery pick). Path persists; bytes refresh per launch.
class AvatarBytes extends Notifier<List<int>?> {
  @override
  List<int>? build() => null;
  void set(List<int>? b) => state = b;
}

final avatarBytesProvider = NotifierProvider<AvatarBytes, List<int>?>(AvatarBytes.new);
