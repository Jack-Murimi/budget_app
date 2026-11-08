import '../../../core/database/app_database.dart';

class DebtWithRepayments {
  final Debt debt;
  final List<DebtRepayment> repayments;
  final List<Transaction> disbursements;
  const DebtWithRepayments({required this.debt, required this.repayments, this.disbursements = const []});
  double get repaid => debt.principal + debt.interest - debt.outstanding;
  bool get isSettled => debt.outstanding <= 0.005;
}
