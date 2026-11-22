import '../../core/database/converters/cents_converter.dart';
import '../../features/transactions/models/transaction_model.dart';

/// Shared integer-cents cashflow helpers to prevent floating-point drift
/// and ensure transfers and transaction fees are handled uniformly.
class CashflowCalculator {
  const CashflowCalculator._();

  /// Total outflow in integer cents for a single transaction,
  /// including transaction cost and Fuliza access fee.
  static int expenseTotalCents(TransactionModel t) =>
      CentsConverter.toCents(t.amount) +
      CentsConverter.toCents(t.transactionCost) +
      CentsConverter.toCents(t.fulizaFee);

  /// Total outflow in KES for a single transaction.
  static double expenseTotal(TransactionModel t) =>
      CentsConverter.fromCents(expenseTotalCents(t));

  /// Summarizes income, expenses (including fees), and net cashflow.
  /// Transfers are explicitly excluded from income and expenses.
  static ({double income, double expenses, double net}) summarize(
    Iterable<TransactionModel> transactions,
  ) {
    var incomeCents = 0;
    var expenseCents = 0;
    for (final t in transactions) {
      if (t.type == 'income') {
        incomeCents += CentsConverter.toCents(t.amount);
      } else if (t.type == 'expense') {
        expenseCents += expenseTotalCents(t);
      }
    }
    return (
      income: CentsConverter.fromCents(incomeCents),
      expenses: CentsConverter.fromCents(expenseCents),
      net: CentsConverter.fromCents(incomeCents - expenseCents),
    );
  }
}
