import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_en.dart';

export 'app_localizations.dart';

final _fallbackEn = AppLocalizationsEn();

extension BuildContextL10n on BuildContext {
  /// Returns the active [AppLocalizations] from the nearest localization scope,
  /// falling back to English when a widget test omits `localizationsDelegates`.
  AppLocalizations get l10n => AppLocalizations.of(this) ?? _fallbackEn;
}
