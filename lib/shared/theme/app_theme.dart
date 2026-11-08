import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seedColor = Color(0xFF4CAF50); // green — money

  static ColorScheme _lightBase([ColorScheme? dynamic]) =>
      dynamic ??
      ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);

  static ColorScheme _darkBase([ColorScheme? dynamic]) =>
      dynamic ??
      ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);

  static ThemeData light([ColorScheme? dynamicScheme]) {
    final base = _lightBase(dynamicScheme);
    return _build(base);
  }

  static ThemeData dark([ColorScheme? dynamicScheme, bool oled = false]) {
    var base = _darkBase(dynamicScheme);
    if (oled) {
      base = base.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainerHigh: const Color(0xFF111111),
      );
    }
    return _build(base, darkText: true, oled: oled);
  }

  static ThemeData _build(ColorScheme base,
      {bool darkText = false, bool oled = false}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: oled ? Colors.black : null,
      textTheme: darkText
          ? GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
          : GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: oled ? Colors.black : base.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: oled ? const Color(0xFF0D0D0D) : base.surfaceContainerLow,
      ),
    );
  }
}
