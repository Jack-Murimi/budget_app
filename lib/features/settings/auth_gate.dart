import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock immediately on first launch if biometric is on
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(biometricEnabledProvider)) {
        ref.read(appLockedProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bioEnabled = ref.read(biometricEnabledProvider);
    if (!bioEnabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt = DateTime.now();
      setSecureFlag(true); // hide in app switcher immediately
    } else if (state == AppLifecycleState.resumed) {
      final lockAfter = ref.read(autoLockSecondsProvider);
      final bg = _backgroundedAt;
      if (bg != null &&
          DateTime.now().difference(bg).inSeconds >= lockAfter) {
        ref.read(appLockedProvider.notifier).state = true;
      } else {
        setSecureFlag(false); // coming back without locking — show again
      }
      _backgroundedAt = null;
    }
  }

  Future<void> _unlock() async {
    final ok = await authenticate();
    if (ok && mounted) {
      ref.read(appLockedProvider.notifier).state = false;
      setSecureFlag(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockedProvider);
    if (!locked) return widget.child;

    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text('App Locked', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _unlock,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
