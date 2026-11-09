import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../shared/providers/theme_provider.dart';

const _kBioEnabled = 'bio_enabled';
const _kAutoLock = 'auto_lock_seconds'; // 0=immediate, 60=1min, 300=5min

final _localAuth = LocalAuthentication();
const _secureChannel = MethodChannel('budget_app/security');

/// Toggle FLAG_SECURE so the app content is hidden in the app switcher.
Future<void> setSecureFlag(bool enable) async {
  try {
    await _secureChannel
        .invokeMethod('setSecureFlag', {'enable': enable});
  } on MissingPluginException {
    // Not on Android — ignore
  } on PlatformException {
    // ignore
  }
}

// ── Biometric enabled toggle ──────────────────────────────────────────────────
class BiometricEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs?.getBool(_kBioEnabled) ?? false;
  }

  Future<void> set(bool value) async {
    state = value;
    await ref.read(sharedPreferencesProvider)?.setBool(_kBioEnabled, value);
  }
}

final biometricEnabledProvider =
    NotifierProvider<BiometricEnabledNotifier, bool>(BiometricEnabledNotifier.new);

// ── Auto-lock timeout ─────────────────────────────────────────────────────────
class AutoLockNotifier extends Notifier<int> {
  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs?.getInt(_kAutoLock) ?? 0;
  }

  Future<void> set(int seconds) async {
    state = seconds;
    await ref.read(sharedPreferencesProvider)?.setInt(_kAutoLock, seconds);
  }
}

final autoLockSecondsProvider =
    NotifierProvider<AutoLockNotifier, int>(AutoLockNotifier.new);

// ── App lock state ────────────────────────────────────────────────────────────
final appLockedProvider = StateProvider<bool>((ref) => false);

// ── Auth service ──────────────────────────────────────────────────────────────
Future<bool> biometricAvailable() async {
  try {
    return await _localAuth.isDeviceSupported() &&
        await _localAuth.canCheckBiometrics;
  } on PlatformException {
    return false;
  }
}

Future<bool> authenticate() async {
  try {
    return await _localAuth.authenticate(
      localizedReason: 'Authenticate to open Budget KE',
      persistAcrossBackgrounding: true,
    );
  } on PlatformException {
    return false;
  }
}
