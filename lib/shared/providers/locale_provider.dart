import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';

const _kLocaleKey = 'app_locale';

/// Persisted locale preference (`null` = follow system locale).
class LocaleNotifier extends Notifier<Locale?> {
  static const supportedCodes = {'en', 'sw'};

  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs?.getString(_kLocaleKey);
    if (code != null && supportedCodes.contains(code)) {
      return Locale(code);
    }
    return null;
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs == null) return;
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
