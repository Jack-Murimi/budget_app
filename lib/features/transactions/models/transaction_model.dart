import '../../../core/database/app_database.dart';

class TransactionModel {
  final int id;
  final String header;
  final String description;
  final double amount;
  final double transactionCost;
  final double fulizaAmount;
  final double fulizaFee;
  final String type;
  final int? categoryId;
  final DateTime transactionDate;
  final String? mpesaRef;
  final String counterpartyName;
  final String counterpartyAccount;
  final bool isParsed;
  final DateTime createdAt;
  final int? accountId;
  final int? toAccountId;
  final bool excludeFromBudget;

  const TransactionModel({
    required this.id,
    required this.header,
    this.description = '',
    required this.amount,
    this.transactionCost = 0.0,
    this.fulizaAmount = 0.0,
    this.fulizaFee = 0.0,
    this.type = 'expense',
    this.categoryId,
    required this.transactionDate,
    this.mpesaRef,
    this.counterpartyName = '',
    this.counterpartyAccount = '',
    this.isParsed = false,
    required this.createdAt,
    this.accountId,
    this.toAccountId,
    this.excludeFromBudget = false,
  });
}

extension TransactionToModel on Transaction {
  TransactionModel toModel() => TransactionModel(
    id: id,
    header: header,
    description: description,
    amount: amount,
    transactionCost: transactionCost,
    fulizaAmount: fulizaAmount,
    fulizaFee: fulizaFee,
    type: type,
    categoryId: categoryId,
    transactionDate: transactionDate,
    mpesaRef: mpesaRef,
    counterpartyName: counterpartyName,
    counterpartyAccount: counterpartyAccount,
    isParsed: isParsed,
    createdAt: createdAt,
    accountId: accountId,
    toAccountId: toAccountId,
    excludeFromBudget: excludeFromBudget,
  );
}
