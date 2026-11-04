import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seedColor = Color(0xFF4CAF50); // green — money

  static ThemeData light() {
    final base = ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: base.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: base.surfaceContainerLow,
      ),
    );
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: base.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: base.surfaceContainerLow,
      ),
    );
  }
}
