import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n.dart';
import '../../shared/providers/locale_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/widgets/motion.dart';
import 'auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final localeCode = locale?.languageCode ?? 'system';
    final oled = ref.watch(oledDarkProvider);
    final dynColor = ref.watch(dynamicColorProvider);
    final bioEnabled = ref.watch(biometricEnabledProvider);
    final autoLock = ref.watch(autoLockSecondsProvider);

    final reduced = Motion.reduced(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, l10n.settingsAppearance),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioGroup<ThemeMode>(
                    groupValue: themeMode,
                    onChanged: (v) {
                      if (v != null) {
                        HapticFeedback.selectionClick();
                        ref.read(themeModeProvider.notifier).set(v);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.system,
                          title: Text(l10n.settingsThemeSystem),
                          secondary:
                              const Icon(Icons.brightness_auto_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.light,
                          title: Text(l10n.settingsThemeLight),
                          secondary: const Icon(Icons.light_mode_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.dark,
                          title: Text(l10n.settingsThemeDark),
                          secondary: const Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: oled,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref.read(oledDarkProvider.notifier).set(v);
                        },
                        title: Text(l10n.settingsThemePureDark),
                        subtitle: Text(l10n.settingsOledSubtitle),
                        secondary: const Icon(Icons.contrast),
                      ),
                      SwitchListTile(
                        value: dynColor,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref.read(dynamicColorProvider.notifier).set(v);
                        },
                        title: Text(l10n.settingsDynamicColor),
                        subtitle: Text(l10n.settingsDynamicColorDesc),
                        secondary: const Icon(Icons.palette_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FadeSlideIn(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, l10n.settingsLanguage),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioGroup<String>(
                    groupValue: localeCode,
                    onChanged: (v) {
                      if (v == null) return;
                      HapticFeedback.selectionClick();
                      ref
                          .read(localeProvider.notifier)
                          .set(v == 'system' ? null : Locale(v));
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'system',
                          title: Text(l10n.settingsLanguageSystem),
                          secondary: const Icon(Icons.language_outlined),
                        ),
                        RadioListTile<String>(
                          value: 'en',
                          title: Text(l10n.settingsLanguageEnglish),
                          secondary: const Icon(Icons.translate_outlined),
                        ),
                        RadioListTile<String>(
                          value: 'sw',
                          title: Text(l10n.settingsLanguageSwahili),
                          secondary: const Icon(Icons.translate_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          FadeSlideIn(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, l10n.settingsSecurity),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: bioEnabled,
                        onChanged: (v) async {
                          HapticFeedback.selectionClick();
                          final auth = ref.read(authServiceProvider);
                          if (v) {
                            final available = await auth.biometricAvailable();
                            if (!available) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(l10n.settingsBiometricUnavailable),
                                  ),
                                );
                              }
                              return;
                            }
                            final ok = await auth.authenticate(
                              localizedReason: l10n.biometricPrompt,
                            );
                            if (!ok) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(l10n.settingsBiometricRequired),
                                  ),
                                );
                              }
                              return;
                            }
                            await ref
                                .read(biometricEnabledProvider.notifier)
                                .set(true);
                          } else {
                            await ref
                                .read(biometricEnabledProvider.notifier)
                                .set(false);
                            ref.read(appLockedProvider.notifier).unlock();
                            await auth.setSecureFlag(false);
                          }
                        },
                        title: Text(l10n.settingsBiometric),
                        subtitle: Text(l10n.settingsBiometricDesc),
                        secondary: const Icon(Icons.fingerprint),
                      ),
                      AnimatedSize(
                        duration: reduced ? Duration.zero : Motion.fast,
                        curve: Motion.emphasized,
                        child: bioEnabled
                            ? Column(
                                children: [
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        l10n.settingsAutoLock,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant),
                                      ),
                                    ),
                                  ),
                                  RadioGroup<int>(
                                    groupValue: autoLock,
                                    onChanged: (v) {
                                      if (v != null) {
                                        HapticFeedback.selectionClick();
                                        ref
                                            .read(autoLockSecondsProvider
                                                .notifier)
                                            .set(v);
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        RadioListTile<int>(
                                          value: 0,
                                          title: Text(
                                              l10n.settingsAutoLockImmediate),
                                        ),
                                        RadioListTile<int>(
                                          value: 60,
                                          title:
                                              Text(l10n.settingsAutoLock1min),
                                        ),
                                        RadioListTile<int>(
                                          value: 300,
                                          title:
                                              Text(l10n.settingsAutoLock5min),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FadeSlideIn(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, l10n.settingsAbout),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.appTitle),
                    subtitle: Text(l10n.settingsAboutSubtitle),
                    trailing: Text('v1.0.0', style: theme.textTheme.bodySmall),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
