import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../debts/models/debt_model.dart';
import '../../debts/providers/debt_providers.dart';

final _bridgeDebtsProvider =
    StreamProvider.family<List<DebtWithRepayments>, _DateRange>(
  (ref, range) => ref
      .watch(debtRepositoryProvider)
      .watchBridgeDebts(from: range.from, to: range.to),
);

class _DateRange {
  final DateTime? from;
  final DateTime? to;
  const _DateRange({this.from, this.to});

  @override
  bool operator ==(Object other) =>
      other is _DateRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

class BridgeChargesScreen extends ConsumerStatefulWidget {
  const BridgeChargesScreen({super.key});

  @override
  ConsumerState<BridgeChargesScreen> createState() =>
      _BridgeChargesScreenState();
}

class _BridgeChargesScreenState extends ConsumerState<BridgeChargesScreen> {
  DateTime? _from;
  DateTime? _to;
  int _presetIndex = 0; // 0: All, 1: This Month, 2: Last Month, 3: Custom

  static final _fmt = DateFormat('dd MMM yyyy');

  void _applyPreset(int index) {
    final now = DateTime.now();
    setState(() {
      _presetIndex = index;
      switch (index) {
        case 0:
          _from = null;
          _to = null;
          break;
        case 1:
          _from = DateTime(now.year, now.month, 1);
          _to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 2:
          _from = DateTime(now.year, now.month - 1, 1);
          _to = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _presetIndex = 3;
      if (isFrom) {
        _from = picked;
        if (_to != null && _to!.isBefore(_from!)) _to = null;
      } else {
        _to = picked;
        if (_from != null && _from!.isAfter(_to!)) _from = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = _DateRange(from: _from, to: _to);
    final loansAsync = ref.watch(_bridgeDebtsProvider(range));

    return Scaffold(
      appBar: AppBar(title: const Text('Bridge Loan Charges')),
      body: Column(
        children: [
          // Filter presets
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All time'),
                  selected: _presetIndex == 0,
                  onSelected: (_) => _applyPreset(0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('This month'),
                  selected: _presetIndex == 1,
                  onSelected: (_) => _applyPreset(1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Last month'),
                  selected: _presetIndex == 2,
                  onSelected: (_) => _applyPreset(2),
                ),
              ],
            ),
          ),
          // Custom date pickers
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isFrom: true),
                    icon: const Icon(Icons.calendar_today, size: 14),
                    label: Text(
                      _from == null ? 'From' : _fmt.format(_from!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('–'),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isFrom: false),
                    icon: const Icon(Icons.calendar_today, size: 14),
                    label: Text(
                      _to == null ? 'To' : _fmt.format(_to!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                if (_from != null || _to != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => _applyPreset(0),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loansAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (loans) {
                if (loans.isEmpty) {
                  return _EmptyState(hasFilter: _from != null || _to != null);
                }

                final totalShortfall = loans.fold<double>(
                    0, (s, l) => s + l.debt.disbursementShortfall);
                final totalInterest = loans.fold<double>(
                    0, (s, l) => s + l.debt.interest);
                final totalCharges = totalShortfall + totalInterest;
                final totalPrincipal =
                    loans.fold<double>(0, (s, l) => s + l.debt.principal);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Bridge charges',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(totalCharges),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Upfront deductions (shortfall)',
                              value: totalShortfall,
                              tooltip:
                                  'Difference between borrowed principal and credited cash',
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Repayment interest',
                              value: totalInterest,
                              tooltip: 'Extra paid back on top of principal',
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Total principal borrowed',
                              value: totalPrincipal,
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Total loans',
                              count: loans.length,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Loans', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    ...loans.map((loan) => _LoanChargeRow(loan: loan)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double? value;
  final int? count;
  final String? tooltip;

  const _SummaryRow({
    required this.label,
    this.value,
    this.count,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = count != null
        ? '$count'
        : CurrencyFormatter.format(value ?? 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                )),
            if (tooltip != null) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: tooltip,
                child: Icon(Icons.info_outline,
                    size: 14,
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.6)),
              ),
            ],
          ],
        ),
        Text(
          display,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class _LoanChargeRow extends StatelessWidget {
  final DebtWithRepayments loan;
  const _LoanChargeRow({required this.loan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final debt = loan.debt;
    final charge = debt.disbursementShortfall + debt.interest;
    final isSettled = loan.isSettled;
    final lastRepayment = loan.repayments.isNotEmpty
        ? loan.repayments
            .reduce((a, b) => a.paymentDate.isAfter(b.paymentDate) ? a : b)
        : null;

    final statusBg = isSettled
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.tertiaryContainer;
    final statusFg = isSettled
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onTertiaryContainer;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusBg,
          child: Icon(
            Icons.account_balance,
            color: statusFg,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                'Borrowed ${CurrencyFormatter.format(debt.principal)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSettled ? 'Settled' : 'Active',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusFg,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (debt.disbursementShortfall > 0)
              Text(
                  'Upfront deduction: ${CurrencyFormatter.format(debt.disbursementShortfall)} (received ${CurrencyFormatter.format(debt.principal - debt.disbursementShortfall)})'),
            if (debt.interest > 0)
              Text('Repayment interest: ${CurrencyFormatter.format(debt.interest)}'),
            if (!isSettled)
              Text('Outstanding: ${CurrencyFormatter.format(debt.outstanding)}'),
            if (lastRepayment != null)
              Text(
                '${isSettled ? 'Settled' : 'Last payment'}: ${DateFormat('dd MMM yyyy').format(lastRepayment.paymentDate)}',
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(charge),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
                fontSize: 15,
              ),
            ),
            Text('total charges',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.error)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                hasFilter
                    ? 'No Bridge loans found in this period'
                    : 'No Bridge loans recorded yet',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Record a loan received from Bridge under Income with category "Loan Received"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
}
