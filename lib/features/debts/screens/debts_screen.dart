import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../models/debt_model.dart';
import '../providers/debt_providers.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Loans & Debts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add debt'),
      ),
      body: debts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load debts: $error')),
        data: (items) => items.isEmpty
            ? const _EmptyDebts()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: items.map((item) => _DebtCard(item: item)).toList(),
              ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final principal = TextEditingController();
    final interest = TextEditingController(text: '0');
    var direction = 'borrowed';
    var product = 'personal';
    DateTime? dueDate;
    await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setState) => AlertDialog(
                  title: const Text('Add loan or debt'),
                  content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: name,
                        decoration: const InputDecoration(
                            labelText: 'Person or lender',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                        initialValue: direction,
                        decoration: const InputDecoration(
                            labelText: 'Direction',
                            border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(
                              value: 'borrowed', child: Text('I borrowed')),
                          DropdownMenuItem(value: 'lent', child: Text('I lent'))
                        ],
                        onChanged: (value) =>
                            setState(() => direction = value!)),
                    const SizedBox(height: 12),
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
                              child: Text('Hustler Fund'))
                        ],
                        onChanged: (value) => setState(() => product = value!)),
                    const SizedBox(height: 12),
                    TextField(
                        controller: principal,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Principal (KES)',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                        controller: interest,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Total interest (KES)',
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
                          final account = await ref
                              .read(accountRepositoryProvider)
                              .getDefaultAccount();
                          await ref.read(debtRepositoryProvider).create(
                              direction: direction,
                              counterparty: name.text,
                              principal: amount,
                              interest: fee,
                              product: product,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyFormatter.format(debt.outstanding),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        overdue ? Theme.of(context).colorScheme.error : null)),
            if (!item.isSettled)
              TextButton(
                  onPressed: () => _repay(context, ref),
                  child: const Text('Repay'))
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
  const _EmptyDebts();
  @override
  Widget build(BuildContext context) => const Center(
      child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.handshake_outlined, size: 56),
            SizedBox(height: 12),
            Text('No loans or debts'),
            SizedBox(height: 4),
            Text('Track money borrowed, lent, and repayments.',
                textAlign: TextAlign.center)
          ])));
}
