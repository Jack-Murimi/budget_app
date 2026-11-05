import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../providers/navigation_providers.dart';
import '../widgets/floating_action_buttons.dart';
import 'home_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomeScreen(),
          TransactionsScreen(isEmbedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => ref.read(selectedTabProvider.notifier).state = i,
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
        ],
      ),
      floatingActionButton: const HomeFloatingActionButtons(),
    );
  }
}
