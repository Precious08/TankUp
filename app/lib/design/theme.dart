// TankUp Material themes built from tokens.dart (Phase 1).
import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData tankLight() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(TankColors.actionL),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(primary: const Color(TankColors.actionL)),
    scaffoldBackgroundColor: const Color(TankColors.washL),
    fontFamilyFallback: const ['Segoe UI', 'Roboto', 'Arial'],
  );
}

ThemeData tankDark() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(TankColors.actionD),
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(primary: const Color(TankColors.actionD)),
    scaffoldBackgroundColor: const Color(TankColors.washD),
    fontFamilyFallback: const ['Segoe UI', 'Roboto', 'Arial'],
  );
}
