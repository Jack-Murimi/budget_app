import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';
const _kOledKey = 'oled_dark';
const _kDynColorKey = 'dynamic_color';

// Loaded once at startup in main.dart via ProviderScope overrides (null in tests)
final sharedPreferencesProvider = Provider<SharedPreferences?>((_) => null);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _map = {
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
    'system': ThemeMode.system,
  };
  static const _reverse = {
    ThemeMode.light: 'light',
    ThemeMode.dark: 'dark',
    ThemeMode.system: 'system',
  };

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _map[prefs?.getString(_kThemeKey)] ?? ThemeMode.system;
  }

  void set(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider)?.setString(_kThemeKey, _reverse[mode]!);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ── OLED pure dark ────────────────────────────────────────────────────────────
class OledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs?.getBool(_kOledKey) ?? false;
  }

  void set(bool value) {
    state = value;
    ref.read(sharedPreferencesProvider)?.setBool(_kOledKey, value);
  }
}

final oledDarkProvider = NotifierProvider<OledNotifier, bool>(OledNotifier.new);

// ── Dynamic color ─────────────────────────────────────────────────────────────
class DynamicColorNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs?.getBool(_kDynColorKey) ?? true;
  }

  void set(bool value) {
    state = value;
    ref.read(sharedPreferencesProvider)?.setBool(_kDynColorKey, value);
  }
}

final dynamicColorProvider =
    NotifierProvider<DynamicColorNotifier, bool>(DynamicColorNotifier.new);
