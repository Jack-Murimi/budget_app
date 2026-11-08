/// Result of parsing an M-Pesa SMS message.
/// Fields that MUST be manually set by user: header, categoryId.
/// Fields auto-filled: transactionDate, amount, transactionCost,
///                     counterpartyName, counterpartyAccount, mpesaRef, type.
class MpesaParseResult {
  final String mpesaRef;
  final double amount;
  final double transactionCost;
  final DateTime transactionDate;
  final String counterpartyName;
  final String counterpartyAccount;
  final MpesaTransactionType type;
  final double newBalance;
  final bool isValid;
  final String? errorMessage;

  // Fuliza fields — populated when parsing a fulizaDrawdown message
  // These get attached to the paired transaction by the caller
  final double fulizaAmount;    // how much Fuliza credited
  final double fulizaAccessFee; // Fuliza's daily access fee
  final double outstandingTotal; // total Fuliza outstanding after this drawdown
  final DateTime? fulizaDueDate; // repayment due date

  const MpesaParseResult({
    required this.mpesaRef,
    required this.amount,
    required this.transactionCost,
    required this.transactionDate,
    required this.counterpartyName,
    required this.counterpartyAccount,
    required this.type,
    required this.newBalance,
    required this.isValid,
    this.errorMessage,
    this.fulizaAmount = 0.0,
    this.fulizaAccessFee = 0.0,
    this.outstandingTotal = 0.0,
    this.fulizaDueDate,
  });

  MpesaParseResult copyWith({
    double? fulizaAmount,
    double? fulizaAccessFee,
  }) => MpesaParseResult(
    mpesaRef: mpesaRef,
    amount: amount,
    transactionCost: transactionCost,
    transactionDate: transactionDate,
    counterpartyName: counterpartyName,
    counterpartyAccount: counterpartyAccount,
    type: type,
    newBalance: newBalance,
    isValid: isValid,
    errorMessage: errorMessage,
    fulizaAmount: fulizaAmount ?? this.fulizaAmount,
    fulizaAccessFee: fulizaAccessFee ?? this.fulizaAccessFee,
    outstandingTotal: outstandingTotal,
    fulizaDueDate: fulizaDueDate,
  );

  /// Auto-generated description from counterparty name.
  String get autoDescription =>
      counterpartyName.isNotEmpty ? counterpartyName : type.defaultDescription;

  static MpesaParseResult invalid(String error) => MpesaParseResult(
        mpesaRef: '',
        amount: 0,
        transactionCost: 0,
        transactionDate: DateTime.now(),
        counterpartyName: '',
        counterpartyAccount: '',
        type: MpesaTransactionType.unknown,
        newBalance: 0,
        isValid: false,
        errorMessage: error,
      );
}

enum MpesaTransactionType {
  sendMoney,
  receiveMoney,
  paybill,
  buyGoods,
  withdraw,
  agentCashout,       // "Give Ksh... cash to NAME"
  fulizaDrawdown,     // Fuliza credit — paired with send, skip saving
  fulizaRepayment,    // Paying back Fuliza
  airtime,
  pochiLaBiashara,    // Pochi la Biashara inflow/outflow
  mShwariLoan,        // M-Shwari loan disbursement
  mShwariRepayment,   // M-Shwari loan repayment
  mShwariSavings,     // M-Shwari lock/unlock savings
  reversal,           // Safaricom transaction reversal
  unknown;

  String get defaultDescription => switch (this) {
        MpesaTransactionType.sendMoney => 'Send Money',
        MpesaTransactionType.receiveMoney => 'Received Money',
        MpesaTransactionType.paybill => 'Paybill Payment',
        MpesaTransactionType.buyGoods => 'Buy Goods',
        MpesaTransactionType.withdraw => 'Withdrawal',
        MpesaTransactionType.agentCashout => 'Agent Cashout',
        MpesaTransactionType.fulizaDrawdown => 'Fuliza Drawdown',
        MpesaTransactionType.fulizaRepayment => 'Fuliza Repayment',
        MpesaTransactionType.airtime => 'Airtime',
        MpesaTransactionType.pochiLaBiashara => 'Pochi la Biashara',
        MpesaTransactionType.mShwariLoan => 'M-Shwari Loan',
        MpesaTransactionType.mShwariRepayment => 'M-Shwari Repayment',
        MpesaTransactionType.mShwariSavings => 'M-Shwari Savings',
        MpesaTransactionType.reversal => 'Reversal',
        MpesaTransactionType.unknown => 'M-Pesa Transaction',
      };

  String get transactionType => switch (this) {
        MpesaTransactionType.receiveMoney => 'income',
        MpesaTransactionType.pochiLaBiashara => 'income', // may be either; default income
        MpesaTransactionType.mShwariLoan => 'income',
        MpesaTransactionType.reversal => 'income', // money comes back
        _ => 'expense',
      };
}
