import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const porcelain = Color(0xFFFAF7F0);
  static const paper = Color(0xFFFFFDF8);
  static const ocean = Color(0xFF183B4E);
  static const oceanSoft = Color(0xFF2C586C);
  static const leaf = Color(0xFF4F8B63);
  static const pumpkin = Color(0xFFE78942);
  static const corn = Color(0xFFE8C85B);
  static const beet = Color(0xFFA95066);
  static const mist = Color(0xFFD8E6E8);
  static const ink = Color(0xFF142B3A);
  static const mutedInk = Color(0xFF65747D);
  static const outline = Color(0xFFE1DED7);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.ocean,
      brightness: Brightness.light,
      surface: AppPalette.paper,
      primary: AppPalette.ocean,
      secondary: AppPalette.leaf,
      tertiary: AppPalette.pumpkin,
      error: AppPalette.beet,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.porcelain,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: AppPalette.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 14,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.porcelain,
        foregroundColor: AppPalette.ink,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppPalette.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppPalette.outline),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.ocean, width: 1.4),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppPalette.outline,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: AppPalette.paper,
        indicatorColor: AppPalette.mist,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppPalette.ocean
                : AppPalette.mutedInk,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            letterSpacing: 0,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppPalette.ocean
                : AppPalette.mutedInk,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppPalette.ocean
                : AppPalette.paper,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : AppPalette.ink,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppPalette.outline),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(48, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.ocean,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppPalette.ocean,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.paper,
        side: const BorderSide(color: AppPalette.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
