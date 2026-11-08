import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../accounts/screens/accounts_screen.dart';
import '../../budgets/screens/budgets_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../debts/screens/debts_screen.dart';
import '../../fuliza/screens/fuliza_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../recurring/screens/recurring_screen.dart';
import '../../settings/settings_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../providers/navigation_providers.dart';
import '../widgets/floating_action_buttons.dart';
import 'home_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.handshake_outlined),
              title: const Text('Loans & Debts'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DebtsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('Insights'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const InsightsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Accounts'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AccountsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Recurring & Bills'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RecurringScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CategoriesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync_problem_rounded),
              title: const Text('Fuliza'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FulizaScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    // 3 real tabs: 0=Home, 1=Transactions, 2=Budgets; index 3=More sheet
    final clampedIndex = selectedIndex.clamp(0, 2);

    return Scaffold(
      body: IndexedStack(
        index: clampedIndex,
        children: const [
          HomeScreen(),
          TransactionsScreen(isEmbedded: true),
          BudgetsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: clampedIndex,
        onDestinationSelected: (i) {
          if (i == 3) {
            _showMoreSheet(context);
          } else {
            ref.read(selectedTabProvider.notifier).state = i;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
      floatingActionButton: const HomeFloatingActionButtons(),
    );
  }
}
