class TransactionModel {
  final int id;
  final String header;
  final String description;
  final double amount;
  final double transactionCost;
  final String type;
  final int? categoryId;
  final DateTime transactionDate;
  final String? mpesaRef;
  final String counterpartyName;
  final String counterpartyAccount;
  final bool isParsed;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.header,
    this.description = '',
    required this.amount,
    this.transactionCost = 0.0,
    this.type = 'expense',
    this.categoryId,
    required this.transactionDate,
    this.mpesaRef,
    this.counterpartyName = '',
    this.counterpartyAccount = '',
    this.isParsed = false,
    required this.createdAt,
  });
}
