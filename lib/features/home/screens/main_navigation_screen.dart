import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/motion.dart';
import '../../budgets/screens/budgets_screen.dart';
import '../../more/screens/more_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../providers/navigation_providers.dart';
import '../widgets/floating_action_buttons.dart';
import 'home_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final Set<int> _mountedTabs = {};

  static const _pages = <Widget>[
    HomeScreen(),
    TransactionsScreen(isEmbedded: true),
    BudgetsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedIndex = ref.watch(selectedTabProvider);
    final clampedIndex = selectedIndex.clamp(0, 3);
    final showFab = clampedIndex == 0 || clampedIndex == 1;
    _mountedTabs.add(clampedIndex);

    return Scaffold(
      body: IndexedStack(
        index: clampedIndex,
        children: [
          for (var i = 0; i < _pages.length; i++)
            _mountedTabs.contains(i)
                ? _TabFade(active: i == clampedIndex, child: _pages[i])
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: clampedIndex,
        animationDuration: Motion.medium,
        onDestinationSelected: (i) {
          if (i != clampedIndex) HapticFeedback.selectionClick();
          ref.read(selectedTabProvider.notifier).state = i;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: const Icon(Icons.pie_chart_rounded),
            label: l10n.navBudgets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_rounded),
            selectedIcon: const Icon(Icons.more_horiz_rounded),
            label: l10n.navMore,
          ),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: Motion.medium,
        switchInCurve: Motion.emphasizedDecelerate,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: showFab
            ? const HomeFloatingActionButtons(key: ValueKey('fabs'))
            : const SizedBox.shrink(key: ValueKey('no-fab')),
      ),
    );
  }
}

/// Fade-through + subtle rise whenever a tab becomes active.
class _TabFade extends StatelessWidget {
  final bool active;
  final Widget child;
  const _TabFade({required this.active, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: active ? Motion.medium : Duration.zero,
      curve: Motion.emphasizedDecelerate,
      child: AnimatedSlide(
        offset: active ? Offset.zero : const Offset(0, 0.015),
        duration: active ? Motion.medium : Duration.zero,
        curve: Motion.emphasizedDecelerate,
        child: child,
      ),
    );
  }
}
