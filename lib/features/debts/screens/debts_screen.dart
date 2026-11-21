import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../models/debt_model.dart';
import '../providers/debt_providers.dart';
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
          ref,
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

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref,
      {String? direction}) async {
    final name = TextEditingController();
    final principal = TextEditingController();
    final interest = TextEditingController(text: '0');
    final actualCredited = TextEditingController();
    var selectedDirection = direction ?? 'borrowed';
    var product = 'personal';
    DateTime? dueDate;
    await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setState) => AlertDialog(
                  title: Text(selectedDirection == 'lent'
                      ? 'Add loan given'
                      : 'Add debt'),
                  content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: name,
                        decoration: InputDecoration(
                            labelText: selectedDirection == 'lent'
                                ? 'Person (borrower)'
                                : 'Person or lender',
                            border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    if (direction == null) ...[
                      DropdownButtonFormField<String>(
                          initialValue: selectedDirection,
                          decoration: const InputDecoration(
                              labelText: 'Direction',
                              border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(
                                value: 'borrowed', child: Text('I borrowed')),
                            DropdownMenuItem(
                                value: 'lent', child: Text('I lent'))
                          ],
                          onChanged: (value) =>
                              setState(() => selectedDirection = value!)),
                      const SizedBox(height: 12),
                    ],
                    DropdownButtonFormField<String>(
                        initialValue: product,
                        decoration: const InputDecoration(
                            labelText: 'Type', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(
                              value: 'personal', child: Text('Personal')),
                          DropdownMenuItem(
                              value: 'mshwari', child: Text('M-Shwari')),
                          DropdownMenuItem(
                              value: 'fuliza', child: Text('Fuliza')),
                          DropdownMenuItem(
                              value: 'hustler_fund',
                              child: Text('Hustler Fund')),
                          DropdownMenuItem(
                              value: 'bridge', child: Text('Bridge')),
                        ],
                        onChanged: (value) =>
                            setState(() => product = value!)),
                    const SizedBox(height: 12),
                    TextField(
                        controller: principal,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Principal (KES)',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    if (product == 'bridge') ...[
                      TextField(
                          controller: actualCredited,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Actual amount credited (KES)',
                              helperText:
                                  'e.g. borrow 600 but only 570 hits your M-Pesa',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                        controller: interest,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Total interest/repayment extra (KES)',
                            border: OutlineInputBorder())),
                    TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                              context: dialogContext,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate: dueDate ?? DateTime.now());
                          if (picked != null) setState(() => dueDate = picked);
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(dueDate == null
                            ? 'Add due date'
                            : 'Due ${dueDate!.toLocal().toString().split(' ').first}')),
                  ])),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () async {
                          final amount = double.tryParse(principal.text);
                          final fee = double.tryParse(interest.text) ?? 0;
                          if (amount == null ||
                              amount <= 0 ||
                              fee < 0 ||
                              name.text.trim().isEmpty) {
                            return;
                          }
                          final credited =
                              double.tryParse(actualCredited.text);
                          final shortfall = (product == 'bridge' &&
                                  credited != null &&
                                  credited < amount)
                              ? amount - credited
                              : 0.0;
                          final account = await ref
                              .read(accountRepositoryProvider)
                              .getDefaultAccount();
                          await ref.read(debtRepositoryProvider).create(
                              direction: selectedDirection,
                              counterparty: name.text,
                              principal: amount,
                              interest: fee,
                              product: product,
                              disbursementShortfall: shortfall,
                              accountId: account?.id,
                              dueDate: dueDate);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: const Text('Save'))
                  ],
                )));
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
            color: isSelected ? Colors.white : primary,
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Settled',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
          ...settled.map((item) => Opacity(
                opacity: 0.65,
                child: _LoanPersonCard(item: item),
              )),
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
                color: isSettled ? Colors.grey : theme.colorScheme.primary,
              ),
            ),
            if (isSettled) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Settled',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
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
    final debt = item.debt;
    final overdue = debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now()) &&
        !item.isSettled;
    return Card(
        child: ListTile(
      leading: CircleAvatar(
          child: Icon(debt.direction == 'borrowed'
              ? Icons.south_west
              : Icons.north_east)),
      title: Text(debt.counterparty),
      subtitle: Text(
          '${debt.product.replaceAll('_', ' ')} | ${item.isSettled ? 'Settled' : overdue ? 'Overdue' : 'Outstanding'}${debt.dueDate == null ? '' : ' | Due ${debt.dueDate!.toLocal().toString().split(' ').first}'}'),
      trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyFormatter.format(debt.outstanding),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        overdue ? Theme.of(context).colorScheme.error : null)),
            if (!item.isSettled)
              SizedBox(
                height: 28,
                child: TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: () => _repay(context, ref),
                    child: const Text('Repay')),
              )
          ]),
    ));
  }

  Future<void> _repay(BuildContext context, WidgetRef ref) async {
    final amount = TextEditingController();
    await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: Text('Repay ${item.debt.counterparty}'),
                content: TextField(
                    controller: amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText:
                            'Amount, max ${CurrencyFormatter.format(item.debt.outstanding)}',
                        border: const OutlineInputBorder())),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () async {
                        final value = double.tryParse(amount.text);
                        if (value == null) {
                          return;
                        }
                        final account = await ref
                            .read(accountRepositoryProvider)
                            .getDefaultAccount();
                        try {
                          await ref.read(debtRepositoryProvider).repay(
                              debt: item.debt,
                              amount: value,
                              accountId: account?.id);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } on ArgumentError {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Enter an amount up to the outstanding balance')));
                        }
                      },
                      child: const Text('Record'))
                ]));
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.handshake_outlined, size: 56),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center)
          ])));
}
