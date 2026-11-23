/// Stable identifiers for built-in system categories whose behavior drives
/// specialized flows (e.g. loans & debt tracking), independent of display name.
abstract final class CategorySystemKeys {
  static const loanGiven = 'loan_given';
  static const loanReceived = 'loan_received';
  static const loanRepayment = 'loan_repayment';
  static const loanRepaymentReceived = 'loan_repayment_received';
}
