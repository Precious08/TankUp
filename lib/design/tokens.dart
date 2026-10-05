// TankUp design tokens — Phase 1.
// Single source of truth for color, type, spacing, and radii.
// Mirrors gallery.html. No Flutter import: plain ints/doubles so the
// file stays valid until the app scaffold (Phase 5) lands.

/// ARGB color ints (0xFF + hex). Suffix L = light theme, D = dark theme.
class TankColors {
  TankColors._();

  // Action green: white text on L = 5.0:1 (AA). Bright green is
  // accent-only (graphics/large text) — never small white text on it.
  static const int actionL = 0xFF15803D;
  static const int actionHoverL = 0xFF166534;
  static const int actionD = 0xFF4ADE80; // text/icons on dark surfaces
  static const int accentL = 0xFF16A34A;
  static const int accentD = 0xFF4ADE80;

  // Dark-mode button fill: near-black text on green = 9:1.
  static const int buttonFillL = 0xFF15803D;
  static const int buttonTextL = 0xFFFFFFFF;
  static const int buttonFillD = 0xFF22C55E;
  static const int buttonTextD = 0xFF052E16;

  // Energy markers (map pins keep these hues in both themes).
  static const int petrolPin = 0xFFB45309;
  static const int cngPin = 0xFF075985;
  static const int evPin = 0xFF5B21B6;

  // Energy tag tints: dark-text-on-tint in both themes (AA-safe).
  static const int petrolBgL = 0xFFFEF3C7;
  static const int petrolTxL = 0xFF92400E;
  static const int cngBgL = 0xFFE0F2FE;
  static const int cngTxL = 0xFF075985;
  static const int evBgL = 0xFFEDE9FE;
  static const int evTxL = 0xFF5B21B6;
  static const int petrolBgD = 0xFF3A2A0B;
  static const int petrolTxD = 0xFFFCD34D;
  static const int cngBgD = 0xFF0B2A3A;
  static const int cngTxD = 0xFF7DD3FC;
  static const int evBgD = 0xFF251B4D;
  static const int evTxD = 0xFFC4B5FD;

  // Surfaces & text.
  static const int inkL = 0xFF0F172A;
  static const int secondaryL = 0xFF475569; // 7.5:1 on white
  static const int lineL = 0xFFE8EDF3;
  static const int washL = 0xFFF4F6F9;
  static const int cardL = 0xFFFFFFFF;
  static const int inkD = 0xFFF1F5F9;
  static const int secondaryD = 0xFFA7B4C6;
  static const int lineD = 0xFF26334D;
  static const int washD = 0xFF0B1220;
  static const int cardD = 0xFF141D33;

  static const int errorL = 0xFFB91C1C;
  static const int errorD = 0xFFFCA5A5;
  static const int userBlue = 0xFF2563EB; // location dot, both themes
}

/// Type scale (logical px). Body never below 16.
class TankType {
  TankType._();
  static const double display = 32;
  static const double title = 22;
  static const double body = 16.5;
  static const double caption = 13.5;
  static const String family = 'Plus Jakarta Sans';
}

/// 4-pt spacing rhythm + radii.
class TankSpace {
  TankSpace._();
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double rSm = 10;
  static const double rMd = 14;
  static const double rLg = 18;
  static const double tapTargetMin = 44; // driving safety rule
}
