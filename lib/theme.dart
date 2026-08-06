import 'package:flutter/material.dart';

/// The "My Finance" design palette — a warm, muted paper-and-forest scheme.
/// Hex values come straight from the Claude Design source so the app matches
/// the mockup exactly.
class AppColors {
  AppColors._();

  static const bg = Color(0xFFEDEAE1); // app canvas
  static const screen = Color(0xFFF7F5EF); // inside a device screen
  static const ink = Color(0xFF1E2E2A); // dark hero cards + primary text
  static const green = Color(0xFF3F6F63); // primary
  static const greenDark = Color(0xFF2C5048);

  // Accents (also the category / account dot palette).
  static const terracotta = Color(0xFFB15E45);
  static const brown = Color(0xFF9C7A54);
  static const blue = Color(0xFF5E7CA8);
  static const mint = Color(0xFF8FC7A9);
  static const peach = Color(0xFFEFA98A);
  static const olive = Color(0xFF7A8B6F);

  static const muted = Color(0xFF8A9690); // secondary label
  static const faint = Color(0xFF9AA69F); // tertiary label
  static const inactive = Color(0xFFB7C0BA); // inactive nav icon
  static const track = Color(0xFFF0ECE3); // progress-bar track
  static const cardBorder = Color(0x0F1E2E2A); // rgba(30,46,42,0.06)

  static const white = Colors.white;

  /// Cycled through for categories and accounts, matching the design's
  /// `colorPalette`.
  static const palette = [green, brown, blue, terracotta, olive];

  /// Colour [index] in the palette (wraps).
  static Color paletteAt(int index) => palette[index % palette.length];

  static const incomeColor = green;
  static const expenseColor = terracotta;
}

/// Parses a `#RRGGBB` string into a [Color], falling back to the primary green.
Color hexColor(String hex) {
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? AppColors.green : Color(value);
}

/// The app-wide Material theme: Manrope everywhere, warm surfaces, rounded
/// components. Amounts use Newsreader inline via [TextStyle] where needed.
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.green,
    primary: AppColors.green,
    surface: AppColors.screen,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.screen,
    colorScheme: scheme,
    textTheme: const TextTheme().apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}
