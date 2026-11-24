import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF1F9D55); // deeper "money" green
  static const _fontFamily = 'Poppins';

  static ThemeData? _cachedDefaultLight;
  static ThemeData? _cachedDefaultDark;
  static ThemeData? _cachedDefaultOledDark;

  static ColorScheme? _lastDynamicLightScheme;
  static ThemeData? _lastDynamicLightTheme;

  static ColorScheme? _lastDynamicDarkScheme;
  static bool? _lastDynamicDarkOled;
  static ThemeData? _lastDynamicDarkTheme;

  static ColorScheme _lightBase([ColorScheme? dynamic]) =>
      dynamic ??
      ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);

  static ColorScheme _darkBase([ColorScheme? dynamic]) =>
      dynamic ??
      ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);

  static ThemeData light([ColorScheme? dynamicScheme]) {
    if (dynamicScheme == null) {
      return _cachedDefaultLight ??= _build(_lightBase(null));
    }
    if (identical(dynamicScheme, _lastDynamicLightScheme) ||
        dynamicScheme == _lastDynamicLightScheme) {
      return _lastDynamicLightTheme!;
    }
    final built = _build(dynamicScheme);
    _lastDynamicLightScheme = dynamicScheme;
    _lastDynamicLightTheme = built;
    return built;
  }

  static ThemeData dark([ColorScheme? dynamicScheme, bool oled = false]) {
    if (dynamicScheme == null) {
      if (oled) {
        return _cachedDefaultOledDark ??=
            _build(_applyOled(_darkBase(null)), darkText: true, oled: true);
      }
      return _cachedDefaultDark ??= _build(_darkBase(null), darkText: true);
    }
    if ((identical(dynamicScheme, _lastDynamicDarkScheme) ||
            dynamicScheme == _lastDynamicDarkScheme) &&
        oled == _lastDynamicDarkOled) {
      return _lastDynamicDarkTheme!;
    }
    final base = oled ? _applyOled(dynamicScheme) : dynamicScheme;
    final built = _build(base, darkText: true, oled: oled);
    _lastDynamicDarkScheme = dynamicScheme;
    _lastDynamicDarkOled = oled;
    _lastDynamicDarkTheme = built;
    return built;
  }

  static ColorScheme _applyOled(ColorScheme base) => base.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainerHigh: const Color(0xFF111111),
      );

  /// Editorial type scale: large, tight, heavy headlines; calm, roomy body.
  static TextTheme _typography(TextTheme t) {
    TextStyle? s(TextStyle? x, {double? ls, FontWeight? w, double? h}) =>
        x?.copyWith(letterSpacing: ls, fontWeight: w, height: h);
    return t.copyWith(
      displaySmall: s(t.displaySmall, ls: -1.2, w: FontWeight.w700, h: 1.1),
      headlineLarge: s(t.headlineLarge, ls: -0.9, w: FontWeight.w700, h: 1.15),
      headlineMedium:
          s(t.headlineMedium, ls: -0.8, w: FontWeight.w700, h: 1.15),
      headlineSmall: s(t.headlineSmall, ls: -0.5, w: FontWeight.w600, h: 1.2),
      titleLarge: s(t.titleLarge, ls: -0.3, w: FontWeight.w600),
      titleMedium: s(t.titleMedium, ls: -0.1, w: FontWeight.w600),
      titleSmall: s(t.titleSmall, ls: 0, w: FontWeight.w600),
      bodyLarge: s(t.bodyLarge, ls: 0, h: 1.45),
      bodyMedium: s(t.bodyMedium, ls: 0, h: 1.45),
      bodySmall: s(t.bodySmall, ls: 0.1, h: 1.4),
      labelLarge: s(t.labelLarge, ls: 0.1, w: FontWeight.w600),
      labelMedium: s(t.labelMedium, ls: 0.4, w: FontWeight.w500),
      labelSmall: s(t.labelSmall, ls: 0.5, w: FontWeight.w500),
    );
  }

  static ThemeData _build(ColorScheme base,
      {bool darkText = false, bool oled = false}) {
    final baseTextTheme = (darkText
            ? ThemeData.dark(useMaterial3: true).textTheme
            : ThemeData.light(useMaterial3: true).textTheme)
        .apply(fontFamily: _fontFamily);
    final textTheme = _typography(baseTextTheme).apply(
      bodyColor: base.onSurface,
      displayColor: base.onSurface,
    );

    final surface = oled ? Colors.black : base.surface;
    final outline = base.outlineVariant.withValues(alpha: oled ? 0.5 : 0.6);
    const radius = 20.0;

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: base,
      scaffoldBackgroundColor: oled ? Colors.black : null,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 22,
          letterSpacing: -0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: outline),
        ),
        color: oled ? const Color(0xFF0D0D0D) : base.surfaceContainerLow,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: oled ? Colors.black : base.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: base.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? base.onSurface : base.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          side: BorderSide(color: base.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(
          color: base.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor:
            oled ? const Color(0xFF0D0D0D) : base.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: textTheme.headlineSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor:
            oled ? const Color(0xFF0D0D0D) : base.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: base.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: base.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: outline),
        labelStyle: textTheme.labelMedium,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearMinHeight: 6,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      dividerTheme: DividerThemeData(color: outline, space: 1),
    );
  }
}
