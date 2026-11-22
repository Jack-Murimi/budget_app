import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../models/debt_model.dart';
import '../providers/debt_providers.dart';
import '../widgets/debt_dialogs.dart';
import 'loan_detail_screen.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  int _selectedTab = 0; // 0: Lent ("They owe me"), 1: Borrowed ("I owe them")

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtsProvider);
    final isLentTab = _selectedTab == 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Loans & Debts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(
          context,
          direction: isLentTab ? 'lent' : 'borrowed',
        ),
        icon: const Icon(Icons.add),
        label: Text(isLentTab ? 'Lend money' : 'Add debt'),
      ),
      body: Column(
        children: [
          _TabSwitcher(
            selectedIndex: _selectedTab,
            onChanged: (index) => setState(() => _selectedTab = index),
          ),
          Expanded(
            child: debts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Unable to load debts: $error')),
              data: (items) => IndexedStack(
                index: _selectedTab,
                children: [
                  _LentTab(items: items),
                  _BorrowedTab(items: items),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context, {
    String? direction,
  }) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => CreateEditDebtDialog(initialDirection: direction),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TabSwitcher({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildPill(
              context: context,
              label: 'They owe me',
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
              primary: primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPill(
              context: context,
              label: 'I owe them',
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
              primary: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primary,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primary, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimary : primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _LentTab extends StatelessWidget {
  final List<DebtWithRepayments> items;
  const _LentTab({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lent = items.where((i) => i.debt.direction == 'lent').toList();
    if (lent.isEmpty) {
      return const _EmptyDebts(
        title: 'No loans given',
        subtitle: 'Track money you have lent to others.',
      );
    }

    final unsettled = lent.where((i) => !i.isSettled).toList()
      ..sort((a, b) => b.debt.outstanding.compareTo(a.debt.outstanding));
    final settled = lent.where((i) => i.isSettled).toList()
      ..sort((a, b) => b.debt.outstanding.compareTo(a.debt.outstanding));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...unsettled.map((item) => _LoanPersonCard(item: item)),
        if (settled.isNotEmpty) ...[
          if (unsettled.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Settled',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
          ...settled.map(
            (item) => Opacity(
              opacity: 0.65,
              child: _LoanPersonCard(item: item),
            ),
          ),
        ],
      ],
    );
  }
}

class _LoanPersonCard extends StatelessWidget {
  final DebtWithRepayments item;
  const _LoanPersonCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final debt = item.debt;
    final isSettled = item.isSettled;
    final initial = debt.counterparty.trim().isNotEmpty
        ? debt.counterparty.trim()[0].toUpperCase()
        : '?';

    final repaymentCount = item.repayments.length;
    final subtitleText = repaymentCount == 0
        ? 'No repayments yet'
        : '$repaymentCount repayment${repaymentCount == 1 ? '' : 's'}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => LoanDetailScreen(item: item),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: isSettled
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer,
          foregroundColor: isSettled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
          child: Text(
            initial,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          debt.counterparty,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSettled ? theme.colorScheme.outline : null,
          ),
        ),
        subtitle: Text(
          subtitleText,
          style: TextStyle(
            color: isSettled ? theme.colorScheme.outline : null,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(debt.outstanding),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSettled
                    ? theme.colorScheme.outline
                    : theme.colorScheme.primary,
              ),
            ),
            if (isSettled) ...[
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Settled',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BorrowedTab extends StatelessWidget {
  final List<DebtWithRepayments> items;
  const _BorrowedTab({required this.items});

  @override
  Widget build(BuildContext context) {
    final borrowed =
        items.where((i) => i.debt.direction == 'borrowed').toList();
    if (borrowed.isEmpty) {
      return const _EmptyDebts(
        title: 'No debts owed',
        subtitle: 'Track money you have borrowed from others.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: borrowed.map((item) => _DebtCard(item: item)).toList(),
    );
  }
}

class _DebtCard extends ConsumerWidget {
  final DebtWithRepayments item;
  const _DebtCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debt = item.debt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = debt.dueDate == null
        ? null
        : DateTime(debt.dueDate!.year, debt.dueDate!.month, debt.dueDate!.day);
    final overdue = dueDay != null && dueDay.isBefore(today) && !item.isSettled;
    final isBorrowed = debt.direction == 'borrowed';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => LoanDetailScreen(item: item),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: overdue
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.secondaryContainer,
          foregroundColor: overdue
              ? theme.colorScheme.onErrorContainer
              : theme.colorScheme.onSecondaryContainer,
          child: Icon(
            isBorrowed ? Icons.south_west : Icons.north_east,
          ),
        ),
        title: Text(debt.counterparty),
        subtitle: Text(
          '${debt.product.replaceAll('_', ' ')} | ${item.isSettled ? 'Settled' : overdue ? 'Overdue' : 'Outstanding'}${debt.dueDate == null ? '' : ' | Due ${debt.dueDate!.toLocal().toString().split(' ').first}'}',
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(debt.outstanding),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: overdue ? theme.colorScheme.error : null,
              ),
            ),
            if (!item.isSettled)
              SizedBox(
                height: 28,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _repay(context),
                  child: Text(isBorrowed ? 'Repay' : 'Record payment'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _repay(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => RecordRepaymentDialog(debt: item.debt),
    );
  }
}

class _EmptyDebts extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyDebts({
    this.title = 'No loans or debts',
    this.subtitle = 'Track money borrowed, lent, and repayments.',
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.handshake_outlined, size: 56),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
