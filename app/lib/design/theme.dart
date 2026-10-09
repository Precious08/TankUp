// TankUp Material themes built from tokens.dart (Phase 1).
// Note: Plus Jakarta Sans via google_fonts is parked — v9 trips the
// analyzer on this SDK (see dev log). System stack until then.
import 'package:flutter/material.dart';
import '../core/models.dart';
import 'tokens.dart';

/// Per-fuel tint pair, AA-safe in both themes (dark-text-on-tint).
({Color bg, Color fg}) fuelChip(Fuel f, Brightness b) {
  final dark = b == Brightness.dark;
  return switch (f) {
    Fuel.petrol => (
        bg: Color(dark ? TankColors.petrolBgD : TankColors.petrolBgL),
        fg: Color(dark ? TankColors.petrolTxD : TankColors.petrolTxL)
      ),
    Fuel.cng => (
        bg: Color(dark ? TankColors.cngBgD : TankColors.cngBgL),
        fg: Color(dark ? TankColors.cngTxD : TankColors.cngTxL)
      ),
    Fuel.ev => (
        bg: Color(dark ? TankColors.evBgD : TankColors.evBgL),
        fg: Color(dark ? TankColors.evTxD : TankColors.evTxL)
      ),
  };
}

ThemeData tankLight() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(TankColors.actionL),
    brightness: Brightness.light,
  );
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    colorScheme: scheme.copyWith(primary: const Color(TankColors.actionL)),
    scaffoldBackgroundColor: const Color(TankColors.washL),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: Color(0xFFE8EDF3)),
      ),
      margin: EdgeInsets.fromLTRB(12, 0, 12, 10),
    ),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 3,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
    ),
  );
}

ThemeData tankDark() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(TankColors.actionD),
    brightness: Brightness.dark,
  );
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    colorScheme: scheme.copyWith(primary: const Color(TankColors.actionD)),
    scaffoldBackgroundColor: const Color(TankColors.washD),
  );
}
