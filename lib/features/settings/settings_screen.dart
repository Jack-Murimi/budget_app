import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/theme_provider.dart';
import 'auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final oled = ref.watch(oledDarkProvider);
    final dynColor = ref.watch(dynamicColorProvider);
    final bioEnabled = ref.watch(biometricEnabledProvider);
    final autoLock = ref.watch(autoLockSecondsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _header(context, 'Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).set(v!),
                  title: const Text('System default'),
                  secondary: const Icon(Icons.brightness_auto_outlined),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).set(v!),
                  title: const Text('Light'),
                  secondary: const Icon(Icons.light_mode_outlined),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).set(v!),
                  title: const Text('Dark'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  value: oled,
                  onChanged: (v) =>
                      ref.read(oledDarkProvider.notifier).set(v),
                  title: const Text('Pure Dark (OLED)'),
                  subtitle: const Text('True black background in dark mode'),
                  secondary: const Icon(Icons.contrast),
                ),
                SwitchListTile(
                  value: dynColor,
                  onChanged: (v) =>
                      ref.read(dynamicColorProvider.notifier).set(v),
                  title: const Text('Dynamic color'),
                  subtitle: const Text('Use wallpaper colors (Android 12+)'),
                  secondary: const Icon(Icons.palette_outlined),
                ),
              ],
            ),
          ),
          _header(context, 'Security'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  value: bioEnabled,
                  onChanged: (v) async {
                    if (v) {
                      final available = await biometricAvailable();
                      if (!available && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Biometrics not available on this device')),
                        );
                        return;
                      }
                    }
                    ref.read(biometricEnabledProvider.notifier).set(v);
                  },
                  title: const Text('Biometric lock'),
                  subtitle: const Text('Fingerprint or face to open app'),
                  secondary: const Icon(Icons.fingerprint),
                ),
                if (bioEnabled) ...[
                  const Divider(height: 1),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Auto-lock after',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.colorScheme.outline)),
                    ),
                  ),
                  RadioListTile<int>(
                    value: 0,
                    groupValue: autoLock,
                    onChanged: (v) =>
                        ref.read(autoLockSecondsProvider.notifier).set(v!),
                    title: const Text('Immediately'),
                  ),
                  RadioListTile<int>(
                    value: 60,
                    groupValue: autoLock,
                    onChanged: (v) =>
                        ref.read(autoLockSecondsProvider.notifier).set(v!),
                    title: const Text('After 1 minute'),
                  ),
                  RadioListTile<int>(
                    value: 300,
                    groupValue: autoLock,
                    onChanged: (v) =>
                        ref.read(autoLockSecondsProvider.notifier).set(v!),
                    title: const Text('After 5 minutes'),
                  ),
                ],
              ],
            ),
          ),
          _header(context, 'About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Budget KE'),
              subtitle: const Text('M-Pesa budget tracker'),
              trailing:
                  Text('v1.0.0', style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}
