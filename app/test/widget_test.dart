// TankUp smoke test: app boots, five tabs render, stations list.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tankup/core/store.dart';
import 'package:tankup/main.dart';

void main() {
  testWidgets('boots with five tabs and station list', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initStore();
    await tester.pumpWidget(const ProviderScope(child: TankUpApp()));
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Search', 'Saved', 'Trips', 'Settings']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.textContaining('TotalEnergies'), findsOneWidget);
    expect(find.textContaining('Nearby'), findsOneWidget);
  });
}
