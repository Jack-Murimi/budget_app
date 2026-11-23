import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../budgets/screens/budgets_screen.dart';
import '../../more/screens/more_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../providers/navigation_providers.dart';
import '../widgets/floating_action_buttons.dart';
import 'home_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selectedIndex = ref.watch(selectedTabProvider);
    final clampedIndex = selectedIndex.clamp(0, 3);

    return Scaffold(
      body: IndexedStack(
        index: clampedIndex,
        children: const [
          HomeScreen(),
          TransactionsScreen(isEmbedded: true),
          BudgetsScreen(),
          MoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: clampedIndex,
        onDestinationSelected: (i) {
          ref.read(selectedTabProvider.notifier).state = i;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l10n.navBudgets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.navMore,
          ),
        ],
      ),
      floatingActionButton: (clampedIndex == 0 || clampedIndex == 1)
          ? const HomeFloatingActionButtons()
          : null,
    );
  }
}
