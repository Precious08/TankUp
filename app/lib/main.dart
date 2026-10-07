// TankUp — find the right place to power your vehicle.
// Phase 5 scaffold: 5 tabs, Supabase-or-sample data, guest by default (ADR 004).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_state.dart';
import 'core/stations_repo.dart';
import 'core/store.dart';
import 'design/theme.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/saved/saved_screen.dart';
import 'features/search/search_screen.dart';
import 'features/trips/trips_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStore();
  if (backendOn) {
    try {
      await Supabase.initialize(url: sbUrl, publishableKey: sbKey);
    } catch (_) {
      // fall through to bundled sample (offline-first, ADR 003)
    }
  }
  runApp(const ProviderScope(child: TankUpApp()));
}

class TankUpApp extends ConsumerWidget {
  const TankUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(prefsProvider).dark;
    return MaterialApp(
      title: 'TankUp',
      debugShowCheckedModeBanner: false,
      theme: tankLight(),
      darkTheme: tankDark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const TabsShell(),
    );
  }
}

class TabsShell extends ConsumerStatefulWidget {
  const TabsShell({super.key});
  @override
  ConsumerState<TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends ConsumerState<TabsShell> {
  static const _tabs = [
    HomeScreen(),
    SearchScreen(),
    SavedScreen(),
    TripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final i = ref.watch(tabIndexProvider);
    return Scaffold(
      body: IndexedStack(index: i, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => ref.read(tabIndexProvider.notifier).go(v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
