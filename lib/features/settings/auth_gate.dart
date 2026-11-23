import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n.dart';
import 'auth_service.dart';

/// Wraps the app body. When [appLockedProvider] is true, shows lock screen.
class AuthGate extends ConsumerStatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (ref.read(appLockedProvider)) {
      ref.read(authServiceProvider).setSecureFlag(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bioEnabled = ref.read(biometricEnabledProvider);
    if (!bioEnabled || _authenticating) return;

    final auth = ref.read(authServiceProvider);
    if (state == AppLifecycleState.inactive) {
      auth.setSecureFlag(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt ??= DateTime.now();
      auth.setSecureFlag(true);
    } else if (state == AppLifecycleState.resumed) {
      final lockAfter = ref.read(autoLockSecondsProvider);
      final bg = _backgroundedAt;
      if (bg != null &&
          DateTime.now().difference(bg).inSeconds >= lockAfter) {
        ref.read(appLockedProvider.notifier).lock();
      } else if (!ref.read(appLockedProvider)) {
        auth.setSecureFlag(false);
      }
      _backgroundedAt = null;
    }
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    _authenticating = true;
    try {
      final auth = ref.read(authServiceProvider);
      final reason = mounted ? context.l10n.biometricPrompt : null;
      final ok = await auth.authenticate(localizedReason: reason);
      if (ok && mounted) {
        ref.read(appLockedProvider.notifier).unlock();
        await auth.setSecureFlag(false);
      }
    } finally {
      _authenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockedProvider);
    if (!locked) return widget.child;

    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(l10n.biometricLockedTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _unlock,
              icon: const Icon(Icons.fingerprint),
              label: Text(l10n.biometricUnlock),
            ),
          ],
        ),
      ),
    );
  }
}
