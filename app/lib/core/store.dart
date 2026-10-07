// Local persistence (Phase 8 moves this to Supabase sync; API stays the same).
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences store;

Future<void> initStore() async {
  store = await SharedPreferences.getInstance();
}

List<String> getStringList(String key) => store.getStringList(key) ?? const [];
Future<void> setStringList(String key, List<String> value) =>
    store.setStringList(key, value);
String? getString(String key) => store.getString(key);
Future<void> setString(String key, String value) => store.setString(key, value);
bool getBool(String key, {bool fallback = false}) =>
    store.getBool(key) ?? fallback;
Future<void> setBool(String key, bool value) => store.setBool(key, value);
