// App-wide UI state (Riverpod Notifiers — guest-local for now, sync in Phase 8).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

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

class Saved extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void toggle(String id) {
    final next = Set<String>.from(state);
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
  }
}

final savedProvider = NotifierProvider<Saved, Set<String>>(Saved.new);

class Vehicles extends Notifier<List<Vehicle>> {
  @override
  List<Vehicle> build() => const [
        Vehicle(nickname: 'Work Van', energy: Fuel.cng, active: true),
        Vehicle(nickname: 'Personal', energy: Fuel.petrol),
      ];

  void activate(int i) {
    state = [for (var j = 0; j < state.length; j++) state[j].copyWith(active: i == j)];
  }

  void add(String nickname, Fuel energy) {
    state = [...state, Vehicle(nickname: nickname, energy: energy)];
  }

  void remove(int i) {
    if (state.length <= 1) return;
    final next = [...state]..removeAt(i);
    if (!next.any((v) => v.active)) next[0] = next[0].copyWith(active: true);
    state = next;
  }
}

final vehiclesProvider = NotifierProvider<Vehicles, List<Vehicle>>(Vehicles.new);

class Prefs extends Notifier<({String name, bool dark, bool miles, bool voice})> {
  @override
  ({String name, bool dark, bool miles, bool voice}) build() =>
      (name: 'Driver', dark: false, miles: false, voice: true);

  void setName(String v) => state = (name: v, dark: state.dark, miles: state.miles, voice: state.voice);
  void setDark(bool v) => state = (name: state.name, dark: v, miles: state.miles, voice: state.voice);
  void setMiles(bool v) => state = (name: state.name, dark: state.dark, miles: v, voice: state.voice);
  void setVoice(bool v) => state = (name: state.name, dark: state.dark, miles: state.miles, voice: v);
}

final prefsProvider =
    NotifierProvider<Prefs, ({String name, bool dark, bool miles, bool voice})>(Prefs.new);
