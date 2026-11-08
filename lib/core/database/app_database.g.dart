// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _headerMeta = const VerificationMeta('header');
  @override
  late final GeneratedColumn<String> header = GeneratedColumn<String>(
      'header', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _transactionCostMeta =
      const VerificationMeta('transactionCost');
  @override
  late final GeneratedColumn<double> transactionCost = GeneratedColumn<double>(
      'transaction_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fulizaAmountMeta =
      const VerificationMeta('fulizaAmount');
  @override
  late final GeneratedColumn<double> fulizaAmount = GeneratedColumn<double>(
      'fuliza_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fulizaFeeMeta =
      const VerificationMeta('fulizaFee');
  @override
  late final GeneratedColumn<double> fulizaFee = GeneratedColumn<double>(
      'fuliza_fee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('expense'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _mpesaRefMeta =
      const VerificationMeta('mpesaRef');
  @override
  late final GeneratedColumn<String> mpesaRef = GeneratedColumn<String>(
      'mpesa_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _counterpartyNameMeta =
      const VerificationMeta('counterpartyName');
  @override
  late final GeneratedColumn<String> counterpartyName = GeneratedColumn<String>(
      'counterparty_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _counterpartyAccountMeta =
      const VerificationMeta('counterpartyAccount');
  @override
  late final GeneratedColumn<String> counterpartyAccount =
      GeneratedColumn<String>('counterparty_account', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _toAccountIdMeta =
      const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<int> toAccountId = GeneratedColumn<int>(
      'to_account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isParsedMeta =
      const VerificationMeta('isParsed');
  @override
  late final GeneratedColumn<bool> isParsed = GeneratedColumn<bool>(
      'is_parsed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_parsed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _excludeFromBudgetMeta =
      const VerificationMeta('excludeFromBudget');
  @override
  late final GeneratedColumn<bool> excludeFromBudget = GeneratedColumn<bool>(
      'exclude_from_budget', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("exclude_from_budget" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurrenceIdMeta =
      const VerificationMeta('recurrenceId');
  @override
  late final GeneratedColumn<int> recurrenceId = GeneratedColumn<int>(
      'recurrence_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<int> debtId = GeneratedColumn<int>(
      'debt_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        header,
        description,
        amount,
        transactionCost,
        fulizaAmount,
        fulizaFee,
        type,
        categoryId,
        transactionDate,
        mpesaRef,
        counterpartyName,
        counterpartyAccount,
        accountId,
        toAccountId,
        isParsed,
        excludeFromBudget,
        recurrenceId,
        isRecurring,
        debtId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('header')) {
      context.handle(_headerMeta,
          header.isAcceptableOrUnknown(data['header']!, _headerMeta));
    } else if (isInserting) {
      context.missing(_headerMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('transaction_cost')) {
      context.handle(
          _transactionCostMeta,
          transactionCost.isAcceptableOrUnknown(
              data['transaction_cost']!, _transactionCostMeta));
    }
    if (data.containsKey('fuliza_amount')) {
      context.handle(
          _fulizaAmountMeta,
          fulizaAmount.isAcceptableOrUnknown(
              data['fuliza_amount']!, _fulizaAmountMeta));
    }
    if (data.containsKey('fuliza_fee')) {
      context.handle(_fulizaFeeMeta,
          fulizaFee.isAcceptableOrUnknown(data['fuliza_fee']!, _fulizaFeeMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('mpesa_ref')) {
      context.handle(_mpesaRefMeta,
          mpesaRef.isAcceptableOrUnknown(data['mpesa_ref']!, _mpesaRefMeta));
    }
    if (data.containsKey('counterparty_name')) {
      context.handle(
          _counterpartyNameMeta,
          counterpartyName.isAcceptableOrUnknown(
              data['counterparty_name']!, _counterpartyNameMeta));
    }
    if (data.containsKey('counterparty_account')) {
      context.handle(
          _counterpartyAccountMeta,
          counterpartyAccount.isAcceptableOrUnknown(
              data['counterparty_account']!, _counterpartyAccountMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
          _toAccountIdMeta,
          toAccountId.isAcceptableOrUnknown(
              data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('is_parsed')) {
      context.handle(_isParsedMeta,
          isParsed.isAcceptableOrUnknown(data['is_parsed']!, _isParsedMeta));
    }
    if (data.containsKey('exclude_from_budget')) {
      context.handle(
          _excludeFromBudgetMeta,
          excludeFromBudget.isAcceptableOrUnknown(
              data['exclude_from_budget']!, _excludeFromBudgetMeta));
    }
    if (data.containsKey('recurrence_id')) {
      context.handle(
          _recurrenceIdMeta,
          recurrenceId.isAcceptableOrUnknown(
              data['recurrence_id']!, _recurrenceIdMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('debt_id')) {
      context.handle(_debtIdMeta,
          debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {mpesaRef},
      ];
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      header: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}header'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      transactionCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}transaction_cost'])!,
      fulizaAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fuliza_amount'])!,
      fulizaFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fuliza_fee'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date'])!,
      mpesaRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mpesa_ref']),
      counterpartyName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}counterparty_name'])!,
      counterpartyAccount: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}counterparty_account'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      toAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}to_account_id']),
      isParsed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_parsed'])!,
      excludeFromBudget: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}exclude_from_budget'])!,
      recurrenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_id']),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      debtId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}debt_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
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
  final int? accountId;
  final int? toAccountId;
  final bool isParsed;
  final bool excludeFromBudget;
  final int? recurrenceId;
  final bool isRecurring;
  final int? debtId;
  final DateTime createdAt;
  const Transaction(
      {required this.id,
      required this.header,
      required this.description,
      required this.amount,
      required this.transactionCost,
      required this.fulizaAmount,
      required this.fulizaFee,
      required this.type,
      this.categoryId,
      required this.transactionDate,
      this.mpesaRef,
      required this.counterpartyName,
      required this.counterpartyAccount,
      this.accountId,
      this.toAccountId,
      required this.isParsed,
      required this.excludeFromBudget,
      this.recurrenceId,
      required this.isRecurring,
      this.debtId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['header'] = Variable<String>(header);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['transaction_cost'] = Variable<double>(transactionCost);
    map['fuliza_amount'] = Variable<double>(fulizaAmount);
    map['fuliza_fee'] = Variable<double>(fulizaFee);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || mpesaRef != null) {
      map['mpesa_ref'] = Variable<String>(mpesaRef);
    }
    map['counterparty_name'] = Variable<String>(counterpartyName);
    map['counterparty_account'] = Variable<String>(counterpartyAccount);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<int>(toAccountId);
    }
    map['is_parsed'] = Variable<bool>(isParsed);
    map['exclude_from_budget'] = Variable<bool>(excludeFromBudget);
    if (!nullToAbsent || recurrenceId != null) {
      map['recurrence_id'] = Variable<int>(recurrenceId);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || debtId != null) {
      map['debt_id'] = Variable<int>(debtId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      header: Value(header),
      description: Value(description),
      amount: Value(amount),
      transactionCost: Value(transactionCost),
      fulizaAmount: Value(fulizaAmount),
      fulizaFee: Value(fulizaFee),
      type: Value(type),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      transactionDate: Value(transactionDate),
      mpesaRef: mpesaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(mpesaRef),
      counterpartyName: Value(counterpartyName),
      counterpartyAccount: Value(counterpartyAccount),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      isParsed: Value(isParsed),
      excludeFromBudget: Value(excludeFromBudget),
      recurrenceId: recurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceId),
      isRecurring: Value(isRecurring),
      debtId:
          debtId == null && nullToAbsent ? const Value.absent() : Value(debtId),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      header: serializer.fromJson<String>(json['header']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      transactionCost: serializer.fromJson<double>(json['transactionCost']),
      fulizaAmount: serializer.fromJson<double>(json['fulizaAmount']),
      fulizaFee: serializer.fromJson<double>(json['fulizaFee']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      mpesaRef: serializer.fromJson<String?>(json['mpesaRef']),
      counterpartyName: serializer.fromJson<String>(json['counterpartyName']),
      counterpartyAccount:
          serializer.fromJson<String>(json['counterpartyAccount']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      toAccountId: serializer.fromJson<int?>(json['toAccountId']),
      isParsed: serializer.fromJson<bool>(json['isParsed']),
      excludeFromBudget: serializer.fromJson<bool>(json['excludeFromBudget']),
      recurrenceId: serializer.fromJson<int?>(json['recurrenceId']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      debtId: serializer.fromJson<int?>(json['debtId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'header': serializer.toJson<String>(header),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'transactionCost': serializer.toJson<double>(transactionCost),
      'fulizaAmount': serializer.toJson<double>(fulizaAmount),
      'fulizaFee': serializer.toJson<double>(fulizaFee),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<int?>(categoryId),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'mpesaRef': serializer.toJson<String?>(mpesaRef),
      'counterpartyName': serializer.toJson<String>(counterpartyName),
      'counterpartyAccount': serializer.toJson<String>(counterpartyAccount),
      'accountId': serializer.toJson<int?>(accountId),
      'toAccountId': serializer.toJson<int?>(toAccountId),
      'isParsed': serializer.toJson<bool>(isParsed),
      'excludeFromBudget': serializer.toJson<bool>(excludeFromBudget),
      'recurrenceId': serializer.toJson<int?>(recurrenceId),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'debtId': serializer.toJson<int?>(debtId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith(
          {int? id,
          String? header,
          String? description,
          double? amount,
          double? transactionCost,
          double? fulizaAmount,
          double? fulizaFee,
          String? type,
          Value<int?> categoryId = const Value.absent(),
          DateTime? transactionDate,
          Value<String?> mpesaRef = const Value.absent(),
          String? counterpartyName,
          String? counterpartyAccount,
          Value<int?> accountId = const Value.absent(),
          Value<int?> toAccountId = const Value.absent(),
          bool? isParsed,
          bool? excludeFromBudget,
          Value<int?> recurrenceId = const Value.absent(),
          bool? isRecurring,
          Value<int?> debtId = const Value.absent(),
          DateTime? createdAt}) =>
      Transaction(
        id: id ?? this.id,
        header: header ?? this.header,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        transactionCost: transactionCost ?? this.transactionCost,
        fulizaAmount: fulizaAmount ?? this.fulizaAmount,
        fulizaFee: fulizaFee ?? this.fulizaFee,
        type: type ?? this.type,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        transactionDate: transactionDate ?? this.transactionDate,
        mpesaRef: mpesaRef.present ? mpesaRef.value : this.mpesaRef,
        counterpartyName: counterpartyName ?? this.counterpartyName,
        counterpartyAccount: counterpartyAccount ?? this.counterpartyAccount,
        accountId: accountId.present ? accountId.value : this.accountId,
        toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
        isParsed: isParsed ?? this.isParsed,
        excludeFromBudget: excludeFromBudget ?? this.excludeFromBudget,
        recurrenceId:
            recurrenceId.present ? recurrenceId.value : this.recurrenceId,
        isRecurring: isRecurring ?? this.isRecurring,
        debtId: debtId.present ? debtId.value : this.debtId,
        createdAt: createdAt ?? this.createdAt,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      header: data.header.present ? data.header.value : this.header,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionCost: data.transactionCost.present
          ? data.transactionCost.value
          : this.transactionCost,
      fulizaAmount: data.fulizaAmount.present
          ? data.fulizaAmount.value
          : this.fulizaAmount,
      fulizaFee: data.fulizaFee.present ? data.fulizaFee.value : this.fulizaFee,
      type: data.type.present ? data.type.value : this.type,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      mpesaRef: data.mpesaRef.present ? data.mpesaRef.value : this.mpesaRef,
      counterpartyName: data.counterpartyName.present
          ? data.counterpartyName.value
          : this.counterpartyName,
      counterpartyAccount: data.counterpartyAccount.present
          ? data.counterpartyAccount.value
          : this.counterpartyAccount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId:
          data.toAccountId.present ? data.toAccountId.value : this.toAccountId,
      isParsed: data.isParsed.present ? data.isParsed.value : this.isParsed,
      excludeFromBudget: data.excludeFromBudget.present
          ? data.excludeFromBudget.value
          : this.excludeFromBudget,
      recurrenceId: data.recurrenceId.present
          ? data.recurrenceId.value
          : this.recurrenceId,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('header: $header, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('transactionCost: $transactionCost, ')
          ..write('fulizaAmount: $fulizaAmount, ')
          ..write('fulizaFee: $fulizaFee, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('mpesaRef: $mpesaRef, ')
          ..write('counterpartyName: $counterpartyName, ')
          ..write('counterpartyAccount: $counterpartyAccount, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('isParsed: $isParsed, ')
          ..write('excludeFromBudget: $excludeFromBudget, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('debtId: $debtId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        header,
        description,
        amount,
        transactionCost,
        fulizaAmount,
        fulizaFee,
        type,
        categoryId,
        transactionDate,
        mpesaRef,
        counterpartyName,
        counterpartyAccount,
        accountId,
        toAccountId,
        isParsed,
        excludeFromBudget,
        recurrenceId,
        isRecurring,
        debtId,
        createdAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.header == this.header &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.transactionCost == this.transactionCost &&
          other.fulizaAmount == this.fulizaAmount &&
          other.fulizaFee == this.fulizaFee &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.transactionDate == this.transactionDate &&
          other.mpesaRef == this.mpesaRef &&
          other.counterpartyName == this.counterpartyName &&
          other.counterpartyAccount == this.counterpartyAccount &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.isParsed == this.isParsed &&
          other.excludeFromBudget == this.excludeFromBudget &&
          other.recurrenceId == this.recurrenceId &&
          other.isRecurring == this.isRecurring &&
          other.debtId == this.debtId &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> header;
  final Value<String> description;
  final Value<double> amount;
  final Value<double> transactionCost;
  final Value<double> fulizaAmount;
  final Value<double> fulizaFee;
  final Value<String> type;
  final Value<int?> categoryId;
  final Value<DateTime> transactionDate;
  final Value<String?> mpesaRef;
  final Value<String> counterpartyName;
  final Value<String> counterpartyAccount;
  final Value<int?> accountId;
  final Value<int?> toAccountId;
  final Value<bool> isParsed;
  final Value<bool> excludeFromBudget;
  final Value<int?> recurrenceId;
  final Value<bool> isRecurring;
  final Value<int?> debtId;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.header = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionCost = const Value.absent(),
    this.fulizaAmount = const Value.absent(),
    this.fulizaFee = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.mpesaRef = const Value.absent(),
    this.counterpartyName = const Value.absent(),
    this.counterpartyAccount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.isParsed = const Value.absent(),
    this.excludeFromBudget = const Value.absent(),
    this.recurrenceId = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.debtId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String header,
    this.description = const Value.absent(),
    required double amount,
    this.transactionCost = const Value.absent(),
    this.fulizaAmount = const Value.absent(),
    this.fulizaFee = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    required DateTime transactionDate,
    this.mpesaRef = const Value.absent(),
    this.counterpartyName = const Value.absent(),
    this.counterpartyAccount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.isParsed = const Value.absent(),
    this.excludeFromBudget = const Value.absent(),
    this.recurrenceId = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.debtId = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : header = Value(header),
        amount = Value(amount),
        transactionDate = Value(transactionDate);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? header,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<double>? transactionCost,
    Expression<double>? fulizaAmount,
    Expression<double>? fulizaFee,
    Expression<String>? type,
    Expression<int>? categoryId,
    Expression<DateTime>? transactionDate,
    Expression<String>? mpesaRef,
    Expression<String>? counterpartyName,
    Expression<String>? counterpartyAccount,
    Expression<int>? accountId,
    Expression<int>? toAccountId,
    Expression<bool>? isParsed,
    Expression<bool>? excludeFromBudget,
    Expression<int>? recurrenceId,
    Expression<bool>? isRecurring,
    Expression<int>? debtId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (header != null) 'header': header,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (transactionCost != null) 'transaction_cost': transactionCost,
      if (fulizaAmount != null) 'fuliza_amount': fulizaAmount,
      if (fulizaFee != null) 'fuliza_fee': fulizaFee,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (mpesaRef != null) 'mpesa_ref': mpesaRef,
      if (counterpartyName != null) 'counterparty_name': counterpartyName,
      if (counterpartyAccount != null)
        'counterparty_account': counterpartyAccount,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (isParsed != null) 'is_parsed': isParsed,
      if (excludeFromBudget != null) 'exclude_from_budget': excludeFromBudget,
      if (recurrenceId != null) 'recurrence_id': recurrenceId,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (debtId != null) 'debt_id': debtId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? header,
      Value<String>? description,
      Value<double>? amount,
      Value<double>? transactionCost,
      Value<double>? fulizaAmount,
      Value<double>? fulizaFee,
      Value<String>? type,
      Value<int?>? categoryId,
      Value<DateTime>? transactionDate,
      Value<String?>? mpesaRef,
      Value<String>? counterpartyName,
      Value<String>? counterpartyAccount,
      Value<int?>? accountId,
      Value<int?>? toAccountId,
      Value<bool>? isParsed,
      Value<bool>? excludeFromBudget,
      Value<int?>? recurrenceId,
      Value<bool>? isRecurring,
      Value<int?>? debtId,
      Value<DateTime>? createdAt}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      header: header ?? this.header,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      transactionCost: transactionCost ?? this.transactionCost,
      fulizaAmount: fulizaAmount ?? this.fulizaAmount,
      fulizaFee: fulizaFee ?? this.fulizaFee,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      transactionDate: transactionDate ?? this.transactionDate,
      mpesaRef: mpesaRef ?? this.mpesaRef,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      counterpartyAccount: counterpartyAccount ?? this.counterpartyAccount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      isParsed: isParsed ?? this.isParsed,
      excludeFromBudget: excludeFromBudget ?? this.excludeFromBudget,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      isRecurring: isRecurring ?? this.isRecurring,
      debtId: debtId ?? this.debtId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (header.present) {
      map['header'] = Variable<String>(header.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (transactionCost.present) {
      map['transaction_cost'] = Variable<double>(transactionCost.value);
    }
    if (fulizaAmount.present) {
      map['fuliza_amount'] = Variable<double>(fulizaAmount.value);
    }
    if (fulizaFee.present) {
      map['fuliza_fee'] = Variable<double>(fulizaFee.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (mpesaRef.present) {
      map['mpesa_ref'] = Variable<String>(mpesaRef.value);
    }
    if (counterpartyName.present) {
      map['counterparty_name'] = Variable<String>(counterpartyName.value);
    }
    if (counterpartyAccount.present) {
      map['counterparty_account'] = Variable<String>(counterpartyAccount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<int>(toAccountId.value);
    }
    if (isParsed.present) {
      map['is_parsed'] = Variable<bool>(isParsed.value);
    }
    if (excludeFromBudget.present) {
      map['exclude_from_budget'] = Variable<bool>(excludeFromBudget.value);
    }
    if (recurrenceId.present) {
      map['recurrence_id'] = Variable<int>(recurrenceId.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<int>(debtId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('header: $header, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('transactionCost: $transactionCost, ')
          ..write('fulizaAmount: $fulizaAmount, ')
          ..write('fulizaFee: $fulizaFee, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('mpesaRef: $mpesaRef, ')
          ..write('counterpartyName: $counterpartyName, ')
          ..write('counterpartyAccount: $counterpartyAccount, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('isParsed: $isParsed, ')
          ..write('excludeFromBudget: $excludeFromBudget, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('debtId: $debtId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('category'));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#6750A4'));
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        icon,
        colorHex,
        parentId,
        isDefault,
        isArchived,
        sortOrder,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String icon;
  final String colorHex;
  final int? parentId;
  final bool isDefault;
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;
  const Category(
      {required this.id,
      required this.name,
      required this.icon,
      required this.colorHex,
      this.parentId,
      required this.isDefault,
      required this.isArchived,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color_hex'] = Variable<String>(colorHex);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      colorHex: Value(colorHex),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isDefault: Value(isDefault),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'colorHex': serializer.toJson<String>(colorHex),
      'parentId': serializer.toJson<int?>(parentId),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith(
          {int? id,
          String? name,
          String? icon,
          String? colorHex,
          Value<int?> parentId = const Value.absent(),
          bool? isDefault,
          bool? isArchived,
          int? sortOrder,
          DateTime? createdAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorHex: colorHex ?? this.colorHex,
        parentId: parentId.present ? parentId.value : this.parentId,
        isDefault: isDefault ?? this.isDefault,
        isArchived: isArchived ?? this.isArchived,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('parentId: $parentId, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, colorHex, parentId, isDefault,
      isArchived, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorHex == this.colorHex &&
          other.parentId == this.parentId &&
          other.isDefault == this.isDefault &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> colorHex;
  final Value<int?> parentId;
  final Value<bool> isDefault;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? colorHex,
    Expression<int>? parentId,
    Expression<bool>? isDefault,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorHex != null) 'color_hex': colorHex,
      if (parentId != null) 'parent_id': parentId,
      if (isDefault != null) 'is_default': isDefault,
      if (isArchived != null) 'is_archived': isArchived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<String>? colorHex,
      Value<int?>? parentId,
      Value<bool>? isDefault,
      Value<bool>? isArchived,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      parentId: parentId ?? this.parentId,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('parentId: $parentId, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FulizaRecordsTable extends FulizaRecords
    with TableInfo<$FulizaRecordsTable, FulizaRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FulizaRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mpesaRefMeta =
      const VerificationMeta('mpesaRef');
  @override
  late final GeneratedColumn<String> mpesaRef = GeneratedColumn<String>(
      'mpesa_ref', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fulizaAmountMeta =
      const VerificationMeta('fulizaAmount');
  @override
  late final GeneratedColumn<double> fulizaAmount = GeneratedColumn<double>(
      'fuliza_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accessFeeMeta =
      const VerificationMeta('accessFee');
  @override
  late final GeneratedColumn<double> accessFee = GeneratedColumn<double>(
      'access_fee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _outstandingTotalMeta =
      const VerificationMeta('outstandingTotal');
  @override
  late final GeneratedColumn<double> outstandingTotal = GeneratedColumn<double>(
      'outstanding_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mpesaRef,
        fulizaAmount,
        accessFee,
        outstandingTotal,
        dueDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuliza_records';
  @override
  VerificationContext validateIntegrity(Insertable<FulizaRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mpesa_ref')) {
      context.handle(_mpesaRefMeta,
          mpesaRef.isAcceptableOrUnknown(data['mpesa_ref']!, _mpesaRefMeta));
    } else if (isInserting) {
      context.missing(_mpesaRefMeta);
    }
    if (data.containsKey('fuliza_amount')) {
      context.handle(
          _fulizaAmountMeta,
          fulizaAmount.isAcceptableOrUnknown(
              data['fuliza_amount']!, _fulizaAmountMeta));
    } else if (isInserting) {
      context.missing(_fulizaAmountMeta);
    }
    if (data.containsKey('access_fee')) {
      context.handle(_accessFeeMeta,
          accessFee.isAcceptableOrUnknown(data['access_fee']!, _accessFeeMeta));
    }
    if (data.containsKey('outstanding_total')) {
      context.handle(
          _outstandingTotalMeta,
          outstandingTotal.isAcceptableOrUnknown(
              data['outstanding_total']!, _outstandingTotalMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {mpesaRef},
      ];
  @override
  FulizaRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FulizaRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mpesaRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mpesa_ref'])!,
      fulizaAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fuliza_amount'])!,
      accessFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}access_fee'])!,
      outstandingTotal: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}outstanding_total'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FulizaRecordsTable createAlias(String alias) {
    return $FulizaRecordsTable(attachedDatabase, alias);
  }
}

class FulizaRecord extends DataClass implements Insertable<FulizaRecord> {
  final int id;
  final String mpesaRef;
  final double fulizaAmount;
  final double accessFee;
  final double outstandingTotal;
  final DateTime? dueDate;
  final DateTime createdAt;
  const FulizaRecord(
      {required this.id,
      required this.mpesaRef,
      required this.fulizaAmount,
      required this.accessFee,
      required this.outstandingTotal,
      this.dueDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mpesa_ref'] = Variable<String>(mpesaRef);
    map['fuliza_amount'] = Variable<double>(fulizaAmount);
    map['access_fee'] = Variable<double>(accessFee);
    map['outstanding_total'] = Variable<double>(outstandingTotal);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FulizaRecordsCompanion toCompanion(bool nullToAbsent) {
    return FulizaRecordsCompanion(
      id: Value(id),
      mpesaRef: Value(mpesaRef),
      fulizaAmount: Value(fulizaAmount),
      accessFee: Value(accessFee),
      outstandingTotal: Value(outstandingTotal),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
    );
  }

  factory FulizaRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FulizaRecord(
      id: serializer.fromJson<int>(json['id']),
      mpesaRef: serializer.fromJson<String>(json['mpesaRef']),
      fulizaAmount: serializer.fromJson<double>(json['fulizaAmount']),
      accessFee: serializer.fromJson<double>(json['accessFee']),
      outstandingTotal: serializer.fromJson<double>(json['outstandingTotal']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mpesaRef': serializer.toJson<String>(mpesaRef),
      'fulizaAmount': serializer.toJson<double>(fulizaAmount),
      'accessFee': serializer.toJson<double>(accessFee),
      'outstandingTotal': serializer.toJson<double>(outstandingTotal),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FulizaRecord copyWith(
          {int? id,
          String? mpesaRef,
          double? fulizaAmount,
          double? accessFee,
          double? outstandingTotal,
          Value<DateTime?> dueDate = const Value.absent(),
          DateTime? createdAt}) =>
      FulizaRecord(
        id: id ?? this.id,
        mpesaRef: mpesaRef ?? this.mpesaRef,
        fulizaAmount: fulizaAmount ?? this.fulizaAmount,
        accessFee: accessFee ?? this.accessFee,
        outstandingTotal: outstandingTotal ?? this.outstandingTotal,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        createdAt: createdAt ?? this.createdAt,
      );
  FulizaRecord copyWithCompanion(FulizaRecordsCompanion data) {
    return FulizaRecord(
      id: data.id.present ? data.id.value : this.id,
      mpesaRef: data.mpesaRef.present ? data.mpesaRef.value : this.mpesaRef,
      fulizaAmount: data.fulizaAmount.present
          ? data.fulizaAmount.value
          : this.fulizaAmount,
      accessFee: data.accessFee.present ? data.accessFee.value : this.accessFee,
      outstandingTotal: data.outstandingTotal.present
          ? data.outstandingTotal.value
          : this.outstandingTotal,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FulizaRecord(')
          ..write('id: $id, ')
          ..write('mpesaRef: $mpesaRef, ')
          ..write('fulizaAmount: $fulizaAmount, ')
          ..write('accessFee: $accessFee, ')
          ..write('outstandingTotal: $outstandingTotal, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mpesaRef, fulizaAmount, accessFee,
      outstandingTotal, dueDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FulizaRecord &&
          other.id == this.id &&
          other.mpesaRef == this.mpesaRef &&
          other.fulizaAmount == this.fulizaAmount &&
          other.accessFee == this.accessFee &&
          other.outstandingTotal == this.outstandingTotal &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt);
}

class FulizaRecordsCompanion extends UpdateCompanion<FulizaRecord> {
  final Value<int> id;
  final Value<String> mpesaRef;
  final Value<double> fulizaAmount;
  final Value<double> accessFee;
  final Value<double> outstandingTotal;
  final Value<DateTime?> dueDate;
  final Value<DateTime> createdAt;
  const FulizaRecordsCompanion({
    this.id = const Value.absent(),
    this.mpesaRef = const Value.absent(),
    this.fulizaAmount = const Value.absent(),
    this.accessFee = const Value.absent(),
    this.outstandingTotal = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FulizaRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String mpesaRef,
    required double fulizaAmount,
    this.accessFee = const Value.absent(),
    this.outstandingTotal = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : mpesaRef = Value(mpesaRef),
        fulizaAmount = Value(fulizaAmount);
  static Insertable<FulizaRecord> custom({
    Expression<int>? id,
    Expression<String>? mpesaRef,
    Expression<double>? fulizaAmount,
    Expression<double>? accessFee,
    Expression<double>? outstandingTotal,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mpesaRef != null) 'mpesa_ref': mpesaRef,
      if (fulizaAmount != null) 'fuliza_amount': fulizaAmount,
      if (accessFee != null) 'access_fee': accessFee,
      if (outstandingTotal != null) 'outstanding_total': outstandingTotal,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FulizaRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? mpesaRef,
      Value<double>? fulizaAmount,
      Value<double>? accessFee,
      Value<double>? outstandingTotal,
      Value<DateTime?>? dueDate,
      Value<DateTime>? createdAt}) {
    return FulizaRecordsCompanion(
      id: id ?? this.id,
      mpesaRef: mpesaRef ?? this.mpesaRef,
      fulizaAmount: fulizaAmount ?? this.fulizaAmount,
      accessFee: accessFee ?? this.accessFee,
      outstandingTotal: outstandingTotal ?? this.outstandingTotal,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mpesaRef.present) {
      map['mpesa_ref'] = Variable<String>(mpesaRef.value);
    }
    if (fulizaAmount.present) {
      map['fuliza_amount'] = Variable<double>(fulizaAmount.value);
    }
    if (accessFee.present) {
      map['access_fee'] = Variable<double>(accessFee.value);
    }
    if (outstandingTotal.present) {
      map['outstanding_total'] = Variable<double>(outstandingTotal.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FulizaRecordsCompanion(')
          ..write('id: $id, ')
          ..write('mpesaRef: $mpesaRef, ')
          ..write('fulizaAmount: $fulizaAmount, ')
          ..write('accessFee: $accessFee, ')
          ..write('outstandingTotal: $outstandingTotal, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mpesa'));
  static const VerificationMeta _initialBalanceMeta =
      const VerificationMeta('initialBalance');
  @override
  late final GeneratedColumn<double> initialBalance = GeneratedColumn<double>(
      'initial_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('KES'));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#1B5E20'));
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('account_balance_wallet'));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        initialBalance,
        currency,
        colorHex,
        icon,
        isDefault,
        isArchived,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
          _initialBalanceMeta,
          initialBalance.isAcceptableOrUnknown(
              data['initial_balance']!, _initialBalanceMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      initialBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}initial_balance'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final String type;
  final double initialBalance;
  final String currency;
  final String colorHex;
  final String icon;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  const Account(
      {required this.id,
      required this.name,
      required this.type,
      required this.initialBalance,
      required this.currency,
      required this.colorHex,
      required this.icon,
      required this.isDefault,
      required this.isArchived,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['initial_balance'] = Variable<double>(initialBalance);
    map['currency'] = Variable<String>(currency);
    map['color_hex'] = Variable<String>(colorHex);
    map['icon'] = Variable<String>(icon);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      initialBalance: Value(initialBalance),
      currency: Value(currency),
      colorHex: Value(colorHex),
      icon: Value(icon),
      isDefault: Value(isDefault),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      initialBalance: serializer.fromJson<double>(json['initialBalance']),
      currency: serializer.fromJson<String>(json['currency']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      icon: serializer.fromJson<String>(json['icon']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'initialBalance': serializer.toJson<double>(initialBalance),
      'currency': serializer.toJson<String>(currency),
      'colorHex': serializer.toJson<String>(colorHex),
      'icon': serializer.toJson<String>(icon),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Account copyWith(
          {int? id,
          String? name,
          String? type,
          double? initialBalance,
          String? currency,
          String? colorHex,
          String? icon,
          bool? isDefault,
          bool? isArchived,
          DateTime? createdAt}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        initialBalance: initialBalance ?? this.initialBalance,
        currency: currency ?? this.currency,
        colorHex: colorHex ?? this.colorHex,
        icon: icon ?? this.icon,
        isDefault: isDefault ?? this.isDefault,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      currency: data.currency.present ? data.currency.value : this.currency,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      icon: data.icon.present ? data.icon.value : this.icon,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currency: $currency, ')
          ..write('colorHex: $colorHex, ')
          ..write('icon: $icon, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, initialBalance, currency,
      colorHex, icon, isDefault, isArchived, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.initialBalance == this.initialBalance &&
          other.currency == this.currency &&
          other.colorHex == this.colorHex &&
          other.icon == this.icon &&
          other.isDefault == this.isDefault &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> initialBalance;
  final Value<String> currency;
  final Value<String> colorHex;
  final Value<String> icon;
  final Value<bool> isDefault;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currency = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.icon = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currency = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.icon = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? initialBalance,
    Expression<String>? currency,
    Expression<String>? colorHex,
    Expression<String>? icon,
    Expression<bool>? isDefault,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currency != null) 'currency': currency,
      if (colorHex != null) 'color_hex': colorHex,
      if (icon != null) 'icon': icon,
      if (isDefault != null) 'is_default': isDefault,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? type,
      Value<double>? initialBalance,
      Value<String>? currency,
      Value<String>? colorHex,
      Value<String>? icon,
      Value<bool>? isDefault,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      colorHex: colorHex ?? this.colorHex,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<double>(initialBalance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currency: $currency, ')
          ..write('colorHex: $colorHex, ')
          ..write('icon: $icon, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _rolloverMeta =
      const VerificationMeta('rollover');
  @override
  late final GeneratedColumn<bool> rollover = GeneratedColumn<bool>(
      'rollover', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("rollover" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        amount,
        period,
        categoryId,
        startDate,
        endDate,
        rollover,
        isArchived,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<Budget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('rollover')) {
      context.handle(_rolloverMeta,
          rollover.isAcceptableOrUnknown(data['rollover']!, _rolloverMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      rollover: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}rollover'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final String name;
  final double amount;
  final String period;
  final int? categoryId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool rollover;
  final bool isArchived;
  final DateTime createdAt;
  const Budget(
      {required this.id,
      required this.name,
      required this.amount,
      required this.period,
      this.categoryId,
      required this.startDate,
      this.endDate,
      required this.rollover,
      required this.isArchived,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['period'] = Variable<String>(period);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['rollover'] = Variable<bool>(rollover);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      period: Value(period),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      rollover: Value(rollover),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      period: serializer.fromJson<String>(json['period']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      rollover: serializer.fromJson<bool>(json['rollover']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(period),
      'categoryId': serializer.toJson<int?>(categoryId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'rollover': serializer.toJson<bool>(rollover),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Budget copyWith(
          {int? id,
          String? name,
          double? amount,
          String? period,
          Value<int?> categoryId = const Value.absent(),
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          bool? rollover,
          bool? isArchived,
          DateTime? createdAt}) =>
      Budget(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        period: period ?? this.period,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        rollover: rollover ?? this.rollover,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
      );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      period: data.period.present ? data.period.value : this.period,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      rollover: data.rollover.present ? data.rollover.value : this.rollover,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('categoryId: $categoryId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('rollover: $rollover, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, amount, period, categoryId,
      startDate, endDate, rollover, isArchived, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.categoryId == this.categoryId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.rollover == this.rollover &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> period;
  final Value<int?> categoryId;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> rollover;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rollover = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double amount,
    this.period = const Value.absent(),
    this.categoryId = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.rollover = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        amount = Value(amount),
        startDate = Value(startDate);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<int>? categoryId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? rollover,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (categoryId != null) 'category_id': categoryId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (rollover != null) 'rollover': rollover,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BudgetsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? amount,
      Value<String>? period,
      Value<int?>? categoryId,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<bool>? rollover,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rollover: rollover ?? this.rollover,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (rollover.present) {
      map['rollover'] = Variable<bool>(rollover.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('categoryId: $categoryId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('rollover: $rollover, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('expense'));
  static const VerificationMeta _payeeMeta = const VerificationMeta('payee');
  @override
  late final GeneratedColumn<String> payee = GeneratedColumn<String>(
      'payee', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _intervalCountMeta =
      const VerificationMeta('intervalCount');
  @override
  late final GeneratedColumn<int> intervalCount = GeneratedColumn<int>(
      'interval_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _autoRecordMeta =
      const VerificationMeta('autoRecord');
  @override
  late final GeneratedColumn<bool> autoRecord = GeneratedColumn<bool>(
      'auto_record', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("auto_record" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notifyMeta = const VerificationMeta('notify');
  @override
  late final GeneratedColumn<bool> notify = GeneratedColumn<bool>(
      'notify', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("notify" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        categoryId,
        amount,
        type,
        payee,
        notes,
        frequency,
        intervalCount,
        startDate,
        endDate,
        nextDueDate,
        autoRecord,
        notify,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('payee')) {
      context.handle(
          _payeeMeta, payee.isAcceptableOrUnknown(data['payee']!, _payeeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    }
    if (data.containsKey('interval_count')) {
      context.handle(
          _intervalCountMeta,
          intervalCount.isAcceptableOrUnknown(
              data['interval_count']!, _intervalCountMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('auto_record')) {
      context.handle(
          _autoRecordMeta,
          autoRecord.isAcceptableOrUnknown(
              data['auto_record']!, _autoRecordMeta));
    }
    if (data.containsKey('notify')) {
      context.handle(_notifyMeta,
          notify.isAcceptableOrUnknown(data['notify']!, _notifyMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payee: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      intervalCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_count'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      nextDueDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_due_date'])!,
      autoRecord: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_record'])!,
      notify: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}notify'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }
}

class RecurringTransaction extends DataClass
    implements Insertable<RecurringTransaction> {
  final int id;
  final int? accountId;
  final int? categoryId;
  final double amount;
  final String type;
  final String payee;
  final String notes;
  final String frequency;
  final int intervalCount;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool autoRecord;
  final bool notify;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecurringTransaction(
      {required this.id,
      this.accountId,
      this.categoryId,
      required this.amount,
      required this.type,
      required this.payee,
      required this.notes,
      required this.frequency,
      required this.intervalCount,
      required this.startDate,
      this.endDate,
      required this.nextDueDate,
      required this.autoRecord,
      required this.notify,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    map['payee'] = Variable<String>(payee);
    map['notes'] = Variable<String>(notes);
    map['frequency'] = Variable<String>(frequency);
    map['interval_count'] = Variable<int>(intervalCount);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['auto_record'] = Variable<bool>(autoRecord);
    map['notify'] = Variable<bool>(notify);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      type: Value(type),
      payee: Value(payee),
      notes: Value(notes),
      frequency: Value(frequency),
      intervalCount: Value(intervalCount),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      nextDueDate: Value(nextDueDate),
      autoRecord: Value(autoRecord),
      notify: Value(notify),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransaction(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      payee: serializer.fromJson<String>(json['payee']),
      notes: serializer.fromJson<String>(json['notes']),
      frequency: serializer.fromJson<String>(json['frequency']),
      intervalCount: serializer.fromJson<int>(json['intervalCount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      autoRecord: serializer.fromJson<bool>(json['autoRecord']),
      notify: serializer.fromJson<bool>(json['notify']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int?>(accountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'payee': serializer.toJson<String>(payee),
      'notes': serializer.toJson<String>(notes),
      'frequency': serializer.toJson<String>(frequency),
      'intervalCount': serializer.toJson<int>(intervalCount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'autoRecord': serializer.toJson<bool>(autoRecord),
      'notify': serializer.toJson<bool>(notify),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecurringTransaction copyWith(
          {int? id,
          Value<int?> accountId = const Value.absent(),
          Value<int?> categoryId = const Value.absent(),
          double? amount,
          String? type,
          String? payee,
          String? notes,
          String? frequency,
          int? intervalCount,
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          DateTime? nextDueDate,
          bool? autoRecord,
          bool? notify,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransaction(
        id: id ?? this.id,
        accountId: accountId.present ? accountId.value : this.accountId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        payee: payee ?? this.payee,
        notes: notes ?? this.notes,
        frequency: frequency ?? this.frequency,
        intervalCount: intervalCount ?? this.intervalCount,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        nextDueDate: nextDueDate ?? this.nextDueDate,
        autoRecord: autoRecord ?? this.autoRecord,
        notify: notify ?? this.notify,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RecurringTransaction copyWithCompanion(RecurringTransactionsCompanion data) {
    return RecurringTransaction(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      payee: data.payee.present ? data.payee.value : this.payee,
      notes: data.notes.present ? data.notes.value : this.notes,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      intervalCount: data.intervalCount.present
          ? data.intervalCount.value
          : this.intervalCount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      autoRecord:
          data.autoRecord.present ? data.autoRecord.value : this.autoRecord,
      notify: data.notify.present ? data.notify.value : this.notify,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransaction(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('payee: $payee, ')
          ..write('notes: $notes, ')
          ..write('frequency: $frequency, ')
          ..write('intervalCount: $intervalCount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('autoRecord: $autoRecord, ')
          ..write('notify: $notify, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      accountId,
      categoryId,
      amount,
      type,
      payee,
      notes,
      frequency,
      intervalCount,
      startDate,
      endDate,
      nextDueDate,
      autoRecord,
      notify,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransaction &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.payee == this.payee &&
          other.notes == this.notes &&
          other.frequency == this.frequency &&
          other.intervalCount == this.intervalCount &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.nextDueDate == this.nextDueDate &&
          other.autoRecord == this.autoRecord &&
          other.notify == this.notify &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransaction> {
  final Value<int> id;
  final Value<int?> accountId;
  final Value<int?> categoryId;
  final Value<double> amount;
  final Value<String> type;
  final Value<String> payee;
  final Value<String> notes;
  final Value<String> frequency;
  final Value<int> intervalCount;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> nextDueDate;
  final Value<bool> autoRecord;
  final Value<bool> notify;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.payee = const Value.absent(),
    this.notes = const Value.absent(),
    this.frequency = const Value.absent(),
    this.intervalCount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.autoRecord = const Value.absent(),
    this.notify = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required double amount,
    this.type = const Value.absent(),
    this.payee = const Value.absent(),
    this.notes = const Value.absent(),
    this.frequency = const Value.absent(),
    this.intervalCount = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required DateTime nextDueDate,
    this.autoRecord = const Value.absent(),
    this.notify = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : amount = Value(amount),
        startDate = Value(startDate),
        nextDueDate = Value(nextDueDate);
  static Insertable<RecurringTransaction> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? payee,
    Expression<String>? notes,
    Expression<String>? frequency,
    Expression<int>? intervalCount,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? nextDueDate,
    Expression<bool>? autoRecord,
    Expression<bool>? notify,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (payee != null) 'payee': payee,
      if (notes != null) 'notes': notes,
      if (frequency != null) 'frequency': frequency,
      if (intervalCount != null) 'interval_count': intervalCount,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (autoRecord != null) 'auto_record': autoRecord,
      if (notify != null) 'notify': notify,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RecurringTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? accountId,
      Value<int?>? categoryId,
      Value<double>? amount,
      Value<String>? type,
      Value<String>? payee,
      Value<String>? notes,
      Value<String>? frequency,
      Value<int>? intervalCount,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<DateTime>? nextDueDate,
      Value<bool>? autoRecord,
      Value<bool>? notify,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      payee: payee ?? this.payee,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      intervalCount: intervalCount ?? this.intervalCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      autoRecord: autoRecord ?? this.autoRecord,
      notify: notify ?? this.notify,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payee.present) {
      map['payee'] = Variable<String>(payee.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (intervalCount.present) {
      map['interval_count'] = Variable<int>(intervalCount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (autoRecord.present) {
      map['auto_record'] = Variable<bool>(autoRecord.value);
    }
    if (notify.present) {
      map['notify'] = Variable<bool>(notify.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('payee: $payee, ')
          ..write('notes: $notes, ')
          ..write('frequency: $frequency, ')
          ..write('intervalCount: $intervalCount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('autoRecord: $autoRecord, ')
          ..write('notify: $notify, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _counterpartyMeta =
      const VerificationMeta('counterparty');
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
      'counterparty', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _productMeta =
      const VerificationMeta('product');
  @override
  late final GeneratedColumn<String> product = GeneratedColumn<String>(
      'product', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('personal'));
  static const VerificationMeta _principalMeta =
      const VerificationMeta('principal');
  @override
  late final GeneratedColumn<double> principal = GeneratedColumn<double>(
      'principal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _outstandingMeta =
      const VerificationMeta('outstanding');
  @override
  late final GeneratedColumn<double> outstanding = GeneratedColumn<double>(
      'outstanding', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _interestMeta =
      const VerificationMeta('interest');
  @override
  late final GeneratedColumn<double> interest = GeneratedColumn<double>(
      'interest', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        direction,
        counterparty,
        product,
        principal,
        outstanding,
        interest,
        dueDate,
        accountId,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(Insertable<Debt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('counterparty')) {
      context.handle(
          _counterpartyMeta,
          counterparty.isAcceptableOrUnknown(
              data['counterparty']!, _counterpartyMeta));
    } else if (isInserting) {
      context.missing(_counterpartyMeta);
    }
    if (data.containsKey('product')) {
      context.handle(_productMeta,
          product.isAcceptableOrUnknown(data['product']!, _productMeta));
    }
    if (data.containsKey('principal')) {
      context.handle(_principalMeta,
          principal.isAcceptableOrUnknown(data['principal']!, _principalMeta));
    } else if (isInserting) {
      context.missing(_principalMeta);
    }
    if (data.containsKey('outstanding')) {
      context.handle(
          _outstandingMeta,
          outstanding.isAcceptableOrUnknown(
              data['outstanding']!, _outstandingMeta));
    } else if (isInserting) {
      context.missing(_outstandingMeta);
    }
    if (data.containsKey('interest')) {
      context.handle(_interestMeta,
          interest.isAcceptableOrUnknown(data['interest']!, _interestMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      counterparty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}counterparty'])!,
      product: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product'])!,
      principal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}principal'])!,
      outstanding: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}outstanding'])!,
      interest: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}interest'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final int id;
  final String direction;
  final String counterparty;
  final String product;
  final double principal;
  final double outstanding;
  final double interest;
  final DateTime? dueDate;
  final int? accountId;
  final String notes;
  final DateTime createdAt;
  const Debt(
      {required this.id,
      required this.direction,
      required this.counterparty,
      required this.product,
      required this.principal,
      required this.outstanding,
      required this.interest,
      this.dueDate,
      this.accountId,
      required this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['direction'] = Variable<String>(direction);
    map['counterparty'] = Variable<String>(counterparty);
    map['product'] = Variable<String>(product);
    map['principal'] = Variable<double>(principal);
    map['outstanding'] = Variable<double>(outstanding);
    map['interest'] = Variable<double>(interest);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      direction: Value(direction),
      counterparty: Value(counterparty),
      product: Value(product),
      principal: Value(principal),
      outstanding: Value(outstanding),
      interest: Value(interest),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Debt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<int>(json['id']),
      direction: serializer.fromJson<String>(json['direction']),
      counterparty: serializer.fromJson<String>(json['counterparty']),
      product: serializer.fromJson<String>(json['product']),
      principal: serializer.fromJson<double>(json['principal']),
      outstanding: serializer.fromJson<double>(json['outstanding']),
      interest: serializer.fromJson<double>(json['interest']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'direction': serializer.toJson<String>(direction),
      'counterparty': serializer.toJson<String>(counterparty),
      'product': serializer.toJson<String>(product),
      'principal': serializer.toJson<double>(principal),
      'outstanding': serializer.toJson<double>(outstanding),
      'interest': serializer.toJson<double>(interest),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'accountId': serializer.toJson<int?>(accountId),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Debt copyWith(
          {int? id,
          String? direction,
          String? counterparty,
          String? product,
          double? principal,
          double? outstanding,
          double? interest,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<int?> accountId = const Value.absent(),
          String? notes,
          DateTime? createdAt}) =>
      Debt(
        id: id ?? this.id,
        direction: direction ?? this.direction,
        counterparty: counterparty ?? this.counterparty,
        product: product ?? this.product,
        principal: principal ?? this.principal,
        outstanding: outstanding ?? this.outstanding,
        interest: interest ?? this.interest,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        accountId: accountId.present ? accountId.value : this.accountId,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      direction: data.direction.present ? data.direction.value : this.direction,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      product: data.product.present ? data.product.value : this.product,
      principal: data.principal.present ? data.principal.value : this.principal,
      outstanding:
          data.outstanding.present ? data.outstanding.value : this.outstanding,
      interest: data.interest.present ? data.interest.value : this.interest,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('counterparty: $counterparty, ')
          ..write('product: $product, ')
          ..write('principal: $principal, ')
          ..write('outstanding: $outstanding, ')
          ..write('interest: $interest, ')
          ..write('dueDate: $dueDate, ')
          ..write('accountId: $accountId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, direction, counterparty, product,
      principal, outstanding, interest, dueDate, accountId, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.direction == this.direction &&
          other.counterparty == this.counterparty &&
          other.product == this.product &&
          other.principal == this.principal &&
          other.outstanding == this.outstanding &&
          other.interest == this.interest &&
          other.dueDate == this.dueDate &&
          other.accountId == this.accountId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<int> id;
  final Value<String> direction;
  final Value<String> counterparty;
  final Value<String> product;
  final Value<double> principal;
  final Value<double> outstanding;
  final Value<double> interest;
  final Value<DateTime?> dueDate;
  final Value<int?> accountId;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.direction = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.product = const Value.absent(),
    this.principal = const Value.absent(),
    this.outstanding = const Value.absent(),
    this.interest = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.accountId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DebtsCompanion.insert({
    this.id = const Value.absent(),
    required String direction,
    required String counterparty,
    this.product = const Value.absent(),
    required double principal,
    required double outstanding,
    this.interest = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.accountId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : direction = Value(direction),
        counterparty = Value(counterparty),
        principal = Value(principal),
        outstanding = Value(outstanding);
  static Insertable<Debt> custom({
    Expression<int>? id,
    Expression<String>? direction,
    Expression<String>? counterparty,
    Expression<String>? product,
    Expression<double>? principal,
    Expression<double>? outstanding,
    Expression<double>? interest,
    Expression<DateTime>? dueDate,
    Expression<int>? accountId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (direction != null) 'direction': direction,
      if (counterparty != null) 'counterparty': counterparty,
      if (product != null) 'product': product,
      if (principal != null) 'principal': principal,
      if (outstanding != null) 'outstanding': outstanding,
      if (interest != null) 'interest': interest,
      if (dueDate != null) 'due_date': dueDate,
      if (accountId != null) 'account_id': accountId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DebtsCompanion copyWith(
      {Value<int>? id,
      Value<String>? direction,
      Value<String>? counterparty,
      Value<String>? product,
      Value<double>? principal,
      Value<double>? outstanding,
      Value<double>? interest,
      Value<DateTime?>? dueDate,
      Value<int?>? accountId,
      Value<String>? notes,
      Value<DateTime>? createdAt}) {
    return DebtsCompanion(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      counterparty: counterparty ?? this.counterparty,
      product: product ?? this.product,
      principal: principal ?? this.principal,
      outstanding: outstanding ?? this.outstanding,
      interest: interest ?? this.interest,
      dueDate: dueDate ?? this.dueDate,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (product.present) {
      map['product'] = Variable<String>(product.value);
    }
    if (principal.present) {
      map['principal'] = Variable<double>(principal.value);
    }
    if (outstanding.present) {
      map['outstanding'] = Variable<double>(outstanding.value);
    }
    if (interest.present) {
      map['interest'] = Variable<double>(interest.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('counterparty: $counterparty, ')
          ..write('product: $product, ')
          ..write('principal: $principal, ')
          ..write('outstanding: $outstanding, ')
          ..write('interest: $interest, ')
          ..write('dueDate: $dueDate, ')
          ..write('accountId: $accountId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DebtRepaymentsTable extends DebtRepayments
    with TableInfo<$DebtRepaymentsTable, DebtRepayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtRepaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<int> debtId = GeneratedColumn<int>(
      'debt_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, debtId, amount, accountId, paymentDate, transactionId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_repayments';
  @override
  VerificationContext validateIntegrity(Insertable<DebtRepayment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('debt_id')) {
      context.handle(_debtIdMeta,
          debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta));
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtRepayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtRepayment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      debtId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}debt_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DebtRepaymentsTable createAlias(String alias) {
    return $DebtRepaymentsTable(attachedDatabase, alias);
  }
}

class DebtRepayment extends DataClass implements Insertable<DebtRepayment> {
  final int id;
  final int debtId;
  final double amount;
  final int? accountId;
  final DateTime paymentDate;
  final int? transactionId;
  final DateTime createdAt;
  const DebtRepayment(
      {required this.id,
      required this.debtId,
      required this.amount,
      this.accountId,
      required this.paymentDate,
      this.transactionId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['debt_id'] = Variable<int>(debtId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<int>(transactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DebtRepaymentsCompanion toCompanion(bool nullToAbsent) {
    return DebtRepaymentsCompanion(
      id: Value(id),
      debtId: Value(debtId),
      amount: Value(amount),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      paymentDate: Value(paymentDate),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      createdAt: Value(createdAt),
    );
  }

  factory DebtRepayment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtRepayment(
      id: serializer.fromJson<int>(json['id']),
      debtId: serializer.fromJson<int>(json['debtId']),
      amount: serializer.fromJson<double>(json['amount']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      transactionId: serializer.fromJson<int?>(json['transactionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'debtId': serializer.toJson<int>(debtId),
      'amount': serializer.toJson<double>(amount),
      'accountId': serializer.toJson<int?>(accountId),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'transactionId': serializer.toJson<int?>(transactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DebtRepayment copyWith(
          {int? id,
          int? debtId,
          double? amount,
          Value<int?> accountId = const Value.absent(),
          DateTime? paymentDate,
          Value<int?> transactionId = const Value.absent(),
          DateTime? createdAt}) =>
      DebtRepayment(
        id: id ?? this.id,
        debtId: debtId ?? this.debtId,
        amount: amount ?? this.amount,
        accountId: accountId.present ? accountId.value : this.accountId,
        paymentDate: paymentDate ?? this.paymentDate,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
        createdAt: createdAt ?? this.createdAt,
      );
  DebtRepayment copyWithCompanion(DebtRepaymentsCompanion data) {
    return DebtRepayment(
      id: data.id.present ? data.id.value : this.id,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtRepayment(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, debtId, amount, accountId, paymentDate, transactionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtRepayment &&
          other.id == this.id &&
          other.debtId == this.debtId &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.paymentDate == this.paymentDate &&
          other.transactionId == this.transactionId &&
          other.createdAt == this.createdAt);
}

class DebtRepaymentsCompanion extends UpdateCompanion<DebtRepayment> {
  final Value<int> id;
  final Value<int> debtId;
  final Value<double> amount;
  final Value<int?> accountId;
  final Value<DateTime> paymentDate;
  final Value<int?> transactionId;
  final Value<DateTime> createdAt;
  const DebtRepaymentsCompanion({
    this.id = const Value.absent(),
    this.debtId = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DebtRepaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int debtId,
    required double amount,
    this.accountId = const Value.absent(),
    required DateTime paymentDate,
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : debtId = Value(debtId),
        amount = Value(amount),
        paymentDate = Value(paymentDate);
  static Insertable<DebtRepayment> custom({
    Expression<int>? id,
    Expression<int>? debtId,
    Expression<double>? amount,
    Expression<int>? accountId,
    Expression<DateTime>? paymentDate,
    Expression<int>? transactionId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtId != null) 'debt_id': debtId,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (transactionId != null) 'transaction_id': transactionId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DebtRepaymentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? debtId,
      Value<double>? amount,
      Value<int?>? accountId,
      Value<DateTime>? paymentDate,
      Value<int?>? transactionId,
      Value<DateTime>? createdAt}) {
    return DebtRepaymentsCompanion(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<int>(debtId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtRepaymentsCompanion(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
      'target_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, targetAmount, currentAmount, targetDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(Insertable<SavingsGoal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}target_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoal extends DataClass implements Insertable<SavingsGoal> {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final DateTime createdAt;
  const SavingsGoal(
      {required this.id,
      required this.name,
      required this.targetAmount,
      required this.currentAmount,
      this.targetDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      createdAt: Value(createdAt),
    );
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavingsGoal copyWith(
          {int? id,
          String? name,
          double? targetAmount,
          double? currentAmount,
          Value<DateTime?> targetDate = const Value.absent(),
          DateTime? createdAt}) =>
      SavingsGoal(
        id: id ?? this.id,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        targetDate: targetDate.present ? targetDate.value : this.targetDate,
        createdAt: createdAt ?? this.createdAt,
      );
  SavingsGoal copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, targetAmount, currentAmount, targetDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoal &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoal> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<DateTime?> targetDate;
  final Value<DateTime> createdAt;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        targetAmount = Value(targetAmount);
  static Insertable<SavingsGoal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SavingsGoalsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? targetAmount,
      Value<double>? currentAmount,
      Value<DateTime?>? targetDate,
      Value<DateTime>? createdAt}) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GoalContributionsTable extends GoalContributions
    with TableInfo<$GoalContributionsTable, GoalContribution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _contributionDateMeta =
      const VerificationMeta('contributionDate');
  @override
  late final GeneratedColumn<DateTime> contributionDate =
      GeneratedColumn<DateTime>('contribution_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, goalId, amount, accountId, transactionId, contributionDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_contributions';
  @override
  VerificationContext validateIntegrity(Insertable<GoalContribution> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    if (data.containsKey('contribution_date')) {
      context.handle(
          _contributionDateMeta,
          contributionDate.isAcceptableOrUnknown(
              data['contribution_date']!, _contributionDateMeta));
    } else if (isInserting) {
      context.missing(_contributionDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalContribution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalContribution(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id']),
      contributionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}contribution_date'])!,
    );
  }

  @override
  $GoalContributionsTable createAlias(String alias) {
    return $GoalContributionsTable(attachedDatabase, alias);
  }
}

class GoalContribution extends DataClass
    implements Insertable<GoalContribution> {
  final int id;
  final int goalId;
  final double amount;
  final int? accountId;
  final int? transactionId;
  final DateTime contributionDate;
  const GoalContribution(
      {required this.id,
      required this.goalId,
      required this.amount,
      this.accountId,
      this.transactionId,
      required this.contributionDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<int>(transactionId);
    }
    map['contribution_date'] = Variable<DateTime>(contributionDate);
    return map;
  }

  GoalContributionsCompanion toCompanion(bool nullToAbsent) {
    return GoalContributionsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      amount: Value(amount),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      contributionDate: Value(contributionDate),
    );
  }

  factory GoalContribution.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalContribution(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      amount: serializer.fromJson<double>(json['amount']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      transactionId: serializer.fromJson<int?>(json['transactionId']),
      contributionDate: serializer.fromJson<DateTime>(json['contributionDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'amount': serializer.toJson<double>(amount),
      'accountId': serializer.toJson<int?>(accountId),
      'transactionId': serializer.toJson<int?>(transactionId),
      'contributionDate': serializer.toJson<DateTime>(contributionDate),
    };
  }

  GoalContribution copyWith(
          {int? id,
          int? goalId,
          double? amount,
          Value<int?> accountId = const Value.absent(),
          Value<int?> transactionId = const Value.absent(),
          DateTime? contributionDate}) =>
      GoalContribution(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        amount: amount ?? this.amount,
        accountId: accountId.present ? accountId.value : this.accountId,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
        contributionDate: contributionDate ?? this.contributionDate,
      );
  GoalContribution copyWithCompanion(GoalContributionsCompanion data) {
    return GoalContribution(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      contributionDate: data.contributionDate.present
          ? data.contributionDate.value
          : this.contributionDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalContribution(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('transactionId: $transactionId, ')
          ..write('contributionDate: $contributionDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, goalId, amount, accountId, transactionId, contributionDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalContribution &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.transactionId == this.transactionId &&
          other.contributionDate == this.contributionDate);
}

class GoalContributionsCompanion extends UpdateCompanion<GoalContribution> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<double> amount;
  final Value<int?> accountId;
  final Value<int?> transactionId;
  final Value<DateTime> contributionDate;
  const GoalContributionsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.contributionDate = const Value.absent(),
  });
  GoalContributionsCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    required double amount,
    this.accountId = const Value.absent(),
    this.transactionId = const Value.absent(),
    required DateTime contributionDate,
  })  : goalId = Value(goalId),
        amount = Value(amount),
        contributionDate = Value(contributionDate);
  static Insertable<GoalContribution> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<double>? amount,
    Expression<int>? accountId,
    Expression<int>? transactionId,
    Expression<DateTime>? contributionDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (contributionDate != null) 'contribution_date': contributionDate,
    });
  }

  GoalContributionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? goalId,
      Value<double>? amount,
      Value<int?>? accountId,
      Value<int?>? transactionId,
      Value<DateTime>? contributionDate}) {
    return GoalContributionsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      transactionId: transactionId ?? this.transactionId,
      contributionDate: contributionDate ?? this.contributionDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (contributionDate.present) {
      map['contribution_date'] = Variable<DateTime>(contributionDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalContributionsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('transactionId: $transactionId, ')
          ..write('contributionDate: $contributionDate')
          ..write(')'))
        .toString();
  }
}

class $PayeeCategoryRulesTable extends PayeeCategoryRules
    with TableInfo<$PayeeCategoryRulesTable, PayeeCategoryRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayeeCategoryRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _payeePatternMeta =
      const VerificationMeta('payeePattern');
  @override
  late final GeneratedColumn<String> payeePattern = GeneratedColumn<String>(
      'payee_pattern', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hitCountMeta =
      const VerificationMeta('hitCount');
  @override
  late final GeneratedColumn<int> hitCount = GeneratedColumn<int>(
      'hit_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [payeePattern, categoryId, hitCount, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payee_category_rules';
  @override
  VerificationContext validateIntegrity(Insertable<PayeeCategoryRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payee_pattern')) {
      context.handle(
          _payeePatternMeta,
          payeePattern.isAcceptableOrUnknown(
              data['payee_pattern']!, _payeePatternMeta));
    } else if (isInserting) {
      context.missing(_payeePatternMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('hit_count')) {
      context.handle(_hitCountMeta,
          hitCount.isAcceptableOrUnknown(data['hit_count']!, _hitCountMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {payeePattern};
  @override
  PayeeCategoryRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayeeCategoryRule(
      payeePattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee_pattern'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      hitCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hit_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PayeeCategoryRulesTable createAlias(String alias) {
    return $PayeeCategoryRulesTable(attachedDatabase, alias);
  }
}

class PayeeCategoryRule extends DataClass
    implements Insertable<PayeeCategoryRule> {
  final String payeePattern;
  final int categoryId;
  final int hitCount;
  final DateTime updatedAt;
  const PayeeCategoryRule(
      {required this.payeePattern,
      required this.categoryId,
      required this.hitCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payee_pattern'] = Variable<String>(payeePattern);
    map['category_id'] = Variable<int>(categoryId);
    map['hit_count'] = Variable<int>(hitCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PayeeCategoryRulesCompanion toCompanion(bool nullToAbsent) {
    return PayeeCategoryRulesCompanion(
      payeePattern: Value(payeePattern),
      categoryId: Value(categoryId),
      hitCount: Value(hitCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory PayeeCategoryRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayeeCategoryRule(
      payeePattern: serializer.fromJson<String>(json['payeePattern']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      hitCount: serializer.fromJson<int>(json['hitCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'payeePattern': serializer.toJson<String>(payeePattern),
      'categoryId': serializer.toJson<int>(categoryId),
      'hitCount': serializer.toJson<int>(hitCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PayeeCategoryRule copyWith(
          {String? payeePattern,
          int? categoryId,
          int? hitCount,
          DateTime? updatedAt}) =>
      PayeeCategoryRule(
        payeePattern: payeePattern ?? this.payeePattern,
        categoryId: categoryId ?? this.categoryId,
        hitCount: hitCount ?? this.hitCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PayeeCategoryRule copyWithCompanion(PayeeCategoryRulesCompanion data) {
    return PayeeCategoryRule(
      payeePattern: data.payeePattern.present
          ? data.payeePattern.value
          : this.payeePattern,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      hitCount: data.hitCount.present ? data.hitCount.value : this.hitCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayeeCategoryRule(')
          ..write('payeePattern: $payeePattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('hitCount: $hitCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(payeePattern, categoryId, hitCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayeeCategoryRule &&
          other.payeePattern == this.payeePattern &&
          other.categoryId == this.categoryId &&
          other.hitCount == this.hitCount &&
          other.updatedAt == this.updatedAt);
}

class PayeeCategoryRulesCompanion extends UpdateCompanion<PayeeCategoryRule> {
  final Value<String> payeePattern;
  final Value<int> categoryId;
  final Value<int> hitCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PayeeCategoryRulesCompanion({
    this.payeePattern = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.hitCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayeeCategoryRulesCompanion.insert({
    required String payeePattern,
    required int categoryId,
    this.hitCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : payeePattern = Value(payeePattern),
        categoryId = Value(categoryId),
        updatedAt = Value(updatedAt);
  static Insertable<PayeeCategoryRule> custom({
    Expression<String>? payeePattern,
    Expression<int>? categoryId,
    Expression<int>? hitCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (payeePattern != null) 'payee_pattern': payeePattern,
      if (categoryId != null) 'category_id': categoryId,
      if (hitCount != null) 'hit_count': hitCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayeeCategoryRulesCompanion copyWith(
      {Value<String>? payeePattern,
      Value<int>? categoryId,
      Value<int>? hitCount,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PayeeCategoryRulesCompanion(
      payeePattern: payeePattern ?? this.payeePattern,
      categoryId: categoryId ?? this.categoryId,
      hitCount: hitCount ?? this.hitCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (payeePattern.present) {
      map['payee_pattern'] = Variable<String>(payeePattern.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (hitCount.present) {
      map['hit_count'] = Variable<int>(hitCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayeeCategoryRulesCompanion(')
          ..write('payeePattern: $payeePattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('hitCount: $hitCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmsInboxItemsTable extends SmsInboxItems
    with TableInfo<$SmsInboxItemsTable, SmsInboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsInboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rawBodyMeta =
      const VerificationMeta('rawBody');
  @override
  late final GeneratedColumn<String> rawBody = GeneratedColumn<String>(
      'raw_body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parsedTypeMeta =
      const VerificationMeta('parsedType');
  @override
  late final GeneratedColumn<String> parsedType = GeneratedColumn<String>(
      'parsed_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parsedAmountMeta =
      const VerificationMeta('parsedAmount');
  @override
  late final GeneratedColumn<double> parsedAmount = GeneratedColumn<double>(
      'parsed_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _parsedPayeeMeta =
      const VerificationMeta('parsedPayee');
  @override
  late final GeneratedColumn<String> parsedPayee = GeneratedColumn<String>(
      'parsed_payee', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parsedRefMeta =
      const VerificationMeta('parsedRef');
  @override
  late final GeneratedColumn<String> parsedRef = GeneratedColumn<String>(
      'parsed_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parsedDateMeta =
      const VerificationMeta('parsedDate');
  @override
  late final GeneratedColumn<int> parsedDate = GeneratedColumn<int>(
      'parsed_date', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _parseNoteMeta =
      const VerificationMeta('parseNote');
  @override
  late final GeneratedColumn<String> parseNote = GeneratedColumn<String>(
      'parse_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        rawBody,
        parsedType,
        parsedAmount,
        parsedPayee,
        parsedRef,
        parsedDate,
        status,
        parseNote,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_inbox_items';
  @override
  VerificationContext validateIntegrity(Insertable<SmsInboxItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_body')) {
      context.handle(_rawBodyMeta,
          rawBody.isAcceptableOrUnknown(data['raw_body']!, _rawBodyMeta));
    } else if (isInserting) {
      context.missing(_rawBodyMeta);
    }
    if (data.containsKey('parsed_type')) {
      context.handle(
          _parsedTypeMeta,
          parsedType.isAcceptableOrUnknown(
              data['parsed_type']!, _parsedTypeMeta));
    }
    if (data.containsKey('parsed_amount')) {
      context.handle(
          _parsedAmountMeta,
          parsedAmount.isAcceptableOrUnknown(
              data['parsed_amount']!, _parsedAmountMeta));
    }
    if (data.containsKey('parsed_payee')) {
      context.handle(
          _parsedPayeeMeta,
          parsedPayee.isAcceptableOrUnknown(
              data['parsed_payee']!, _parsedPayeeMeta));
    }
    if (data.containsKey('parsed_ref')) {
      context.handle(_parsedRefMeta,
          parsedRef.isAcceptableOrUnknown(data['parsed_ref']!, _parsedRefMeta));
    }
    if (data.containsKey('parsed_date')) {
      context.handle(
          _parsedDateMeta,
          parsedDate.isAcceptableOrUnknown(
              data['parsed_date']!, _parsedDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('parse_note')) {
      context.handle(_parseNoteMeta,
          parseNote.isAcceptableOrUnknown(data['parse_note']!, _parseNoteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsInboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsInboxItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rawBody: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_body'])!,
      parsedType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parsed_type']),
      parsedAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}parsed_amount']),
      parsedPayee: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parsed_payee']),
      parsedRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parsed_ref']),
      parsedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parsed_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      parseNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parse_note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SmsInboxItemsTable createAlias(String alias) {
    return $SmsInboxItemsTable(attachedDatabase, alias);
  }
}

class SmsInboxItem extends DataClass implements Insertable<SmsInboxItem> {
  final int id;
  final String rawBody;
  final String? parsedType;
  final double? parsedAmount;
  final String? parsedPayee;
  final String? parsedRef;
  final int? parsedDate;
  final String status;
  final String? parseNote;
  final DateTime createdAt;
  const SmsInboxItem(
      {required this.id,
      required this.rawBody,
      this.parsedType,
      this.parsedAmount,
      this.parsedPayee,
      this.parsedRef,
      this.parsedDate,
      required this.status,
      this.parseNote,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_body'] = Variable<String>(rawBody);
    if (!nullToAbsent || parsedType != null) {
      map['parsed_type'] = Variable<String>(parsedType);
    }
    if (!nullToAbsent || parsedAmount != null) {
      map['parsed_amount'] = Variable<double>(parsedAmount);
    }
    if (!nullToAbsent || parsedPayee != null) {
      map['parsed_payee'] = Variable<String>(parsedPayee);
    }
    if (!nullToAbsent || parsedRef != null) {
      map['parsed_ref'] = Variable<String>(parsedRef);
    }
    if (!nullToAbsent || parsedDate != null) {
      map['parsed_date'] = Variable<int>(parsedDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || parseNote != null) {
      map['parse_note'] = Variable<String>(parseNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SmsInboxItemsCompanion toCompanion(bool nullToAbsent) {
    return SmsInboxItemsCompanion(
      id: Value(id),
      rawBody: Value(rawBody),
      parsedType: parsedType == null && nullToAbsent
          ? const Value.absent()
          : Value(parsedType),
      parsedAmount: parsedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(parsedAmount),
      parsedPayee: parsedPayee == null && nullToAbsent
          ? const Value.absent()
          : Value(parsedPayee),
      parsedRef: parsedRef == null && nullToAbsent
          ? const Value.absent()
          : Value(parsedRef),
      parsedDate: parsedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(parsedDate),
      status: Value(status),
      parseNote: parseNote == null && nullToAbsent
          ? const Value.absent()
          : Value(parseNote),
      createdAt: Value(createdAt),
    );
  }

  factory SmsInboxItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsInboxItem(
      id: serializer.fromJson<int>(json['id']),
      rawBody: serializer.fromJson<String>(json['rawBody']),
      parsedType: serializer.fromJson<String?>(json['parsedType']),
      parsedAmount: serializer.fromJson<double?>(json['parsedAmount']),
      parsedPayee: serializer.fromJson<String?>(json['parsedPayee']),
      parsedRef: serializer.fromJson<String?>(json['parsedRef']),
      parsedDate: serializer.fromJson<int?>(json['parsedDate']),
      status: serializer.fromJson<String>(json['status']),
      parseNote: serializer.fromJson<String?>(json['parseNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawBody': serializer.toJson<String>(rawBody),
      'parsedType': serializer.toJson<String?>(parsedType),
      'parsedAmount': serializer.toJson<double?>(parsedAmount),
      'parsedPayee': serializer.toJson<String?>(parsedPayee),
      'parsedRef': serializer.toJson<String?>(parsedRef),
      'parsedDate': serializer.toJson<int?>(parsedDate),
      'status': serializer.toJson<String>(status),
      'parseNote': serializer.toJson<String?>(parseNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SmsInboxItem copyWith(
          {int? id,
          String? rawBody,
          Value<String?> parsedType = const Value.absent(),
          Value<double?> parsedAmount = const Value.absent(),
          Value<String?> parsedPayee = const Value.absent(),
          Value<String?> parsedRef = const Value.absent(),
          Value<int?> parsedDate = const Value.absent(),
          String? status,
          Value<String?> parseNote = const Value.absent(),
          DateTime? createdAt}) =>
      SmsInboxItem(
        id: id ?? this.id,
        rawBody: rawBody ?? this.rawBody,
        parsedType: parsedType.present ? parsedType.value : this.parsedType,
        parsedAmount:
            parsedAmount.present ? parsedAmount.value : this.parsedAmount,
        parsedPayee: parsedPayee.present ? parsedPayee.value : this.parsedPayee,
        parsedRef: parsedRef.present ? parsedRef.value : this.parsedRef,
        parsedDate: parsedDate.present ? parsedDate.value : this.parsedDate,
        status: status ?? this.status,
        parseNote: parseNote.present ? parseNote.value : this.parseNote,
        createdAt: createdAt ?? this.createdAt,
      );
  SmsInboxItem copyWithCompanion(SmsInboxItemsCompanion data) {
    return SmsInboxItem(
      id: data.id.present ? data.id.value : this.id,
      rawBody: data.rawBody.present ? data.rawBody.value : this.rawBody,
      parsedType:
          data.parsedType.present ? data.parsedType.value : this.parsedType,
      parsedAmount: data.parsedAmount.present
          ? data.parsedAmount.value
          : this.parsedAmount,
      parsedPayee:
          data.parsedPayee.present ? data.parsedPayee.value : this.parsedPayee,
      parsedRef: data.parsedRef.present ? data.parsedRef.value : this.parsedRef,
      parsedDate:
          data.parsedDate.present ? data.parsedDate.value : this.parsedDate,
      status: data.status.present ? data.status.value : this.status,
      parseNote: data.parseNote.present ? data.parseNote.value : this.parseNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsInboxItem(')
          ..write('id: $id, ')
          ..write('rawBody: $rawBody, ')
          ..write('parsedType: $parsedType, ')
          ..write('parsedAmount: $parsedAmount, ')
          ..write('parsedPayee: $parsedPayee, ')
          ..write('parsedRef: $parsedRef, ')
          ..write('parsedDate: $parsedDate, ')
          ..write('status: $status, ')
          ..write('parseNote: $parseNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rawBody, parsedType, parsedAmount,
      parsedPayee, parsedRef, parsedDate, status, parseNote, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsInboxItem &&
          other.id == this.id &&
          other.rawBody == this.rawBody &&
          other.parsedType == this.parsedType &&
          other.parsedAmount == this.parsedAmount &&
          other.parsedPayee == this.parsedPayee &&
          other.parsedRef == this.parsedRef &&
          other.parsedDate == this.parsedDate &&
          other.status == this.status &&
          other.parseNote == this.parseNote &&
          other.createdAt == this.createdAt);
}

class SmsInboxItemsCompanion extends UpdateCompanion<SmsInboxItem> {
  final Value<int> id;
  final Value<String> rawBody;
  final Value<String?> parsedType;
  final Value<double?> parsedAmount;
  final Value<String?> parsedPayee;
  final Value<String?> parsedRef;
  final Value<int?> parsedDate;
  final Value<String> status;
  final Value<String?> parseNote;
  final Value<DateTime> createdAt;
  const SmsInboxItemsCompanion({
    this.id = const Value.absent(),
    this.rawBody = const Value.absent(),
    this.parsedType = const Value.absent(),
    this.parsedAmount = const Value.absent(),
    this.parsedPayee = const Value.absent(),
    this.parsedRef = const Value.absent(),
    this.parsedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.parseNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SmsInboxItemsCompanion.insert({
    this.id = const Value.absent(),
    required String rawBody,
    this.parsedType = const Value.absent(),
    this.parsedAmount = const Value.absent(),
    this.parsedPayee = const Value.absent(),
    this.parsedRef = const Value.absent(),
    this.parsedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.parseNote = const Value.absent(),
    required DateTime createdAt,
  })  : rawBody = Value(rawBody),
        createdAt = Value(createdAt);
  static Insertable<SmsInboxItem> custom({
    Expression<int>? id,
    Expression<String>? rawBody,
    Expression<String>? parsedType,
    Expression<double>? parsedAmount,
    Expression<String>? parsedPayee,
    Expression<String>? parsedRef,
    Expression<int>? parsedDate,
    Expression<String>? status,
    Expression<String>? parseNote,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawBody != null) 'raw_body': rawBody,
      if (parsedType != null) 'parsed_type': parsedType,
      if (parsedAmount != null) 'parsed_amount': parsedAmount,
      if (parsedPayee != null) 'parsed_payee': parsedPayee,
      if (parsedRef != null) 'parsed_ref': parsedRef,
      if (parsedDate != null) 'parsed_date': parsedDate,
      if (status != null) 'status': status,
      if (parseNote != null) 'parse_note': parseNote,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SmsInboxItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? rawBody,
      Value<String?>? parsedType,
      Value<double?>? parsedAmount,
      Value<String?>? parsedPayee,
      Value<String?>? parsedRef,
      Value<int?>? parsedDate,
      Value<String>? status,
      Value<String?>? parseNote,
      Value<DateTime>? createdAt}) {
    return SmsInboxItemsCompanion(
      id: id ?? this.id,
      rawBody: rawBody ?? this.rawBody,
      parsedType: parsedType ?? this.parsedType,
      parsedAmount: parsedAmount ?? this.parsedAmount,
      parsedPayee: parsedPayee ?? this.parsedPayee,
      parsedRef: parsedRef ?? this.parsedRef,
      parsedDate: parsedDate ?? this.parsedDate,
      status: status ?? this.status,
      parseNote: parseNote ?? this.parseNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawBody.present) {
      map['raw_body'] = Variable<String>(rawBody.value);
    }
    if (parsedType.present) {
      map['parsed_type'] = Variable<String>(parsedType.value);
    }
    if (parsedAmount.present) {
      map['parsed_amount'] = Variable<double>(parsedAmount.value);
    }
    if (parsedPayee.present) {
      map['parsed_payee'] = Variable<String>(parsedPayee.value);
    }
    if (parsedRef.present) {
      map['parsed_ref'] = Variable<String>(parsedRef.value);
    }
    if (parsedDate.present) {
      map['parsed_date'] = Variable<int>(parsedDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (parseNote.present) {
      map['parse_note'] = Variable<String>(parseNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsInboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('rawBody: $rawBody, ')
          ..write('parsedType: $parsedType, ')
          ..write('parsedAmount: $parsedAmount, ')
          ..write('parsedPayee: $parsedPayee, ')
          ..write('parsedRef: $parsedRef, ')
          ..write('parsedDate: $parsedDate, ')
          ..write('status: $status, ')
          ..write('parseNote: $parseNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $FulizaRecordsTable fulizaRecords = $FulizaRecordsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $DebtRepaymentsTable debtRepayments = $DebtRepaymentsTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $GoalContributionsTable goalContributions =
      $GoalContributionsTable(this);
  late final $PayeeCategoryRulesTable payeeCategoryRules =
      $PayeeCategoryRulesTable(this);
  late final $SmsInboxItemsTable smsInboxItems = $SmsInboxItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        transactions,
        categories,
        fulizaRecords,
        accounts,
        budgets,
        recurringTransactions,
        debts,
        debtRepayments,
        savingsGoals,
        goalContributions,
        payeeCategoryRules,
        smsInboxItems
      ];
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required String header,
  Value<String> description,
  required double amount,
  Value<double> transactionCost,
  Value<double> fulizaAmount,
  Value<double> fulizaFee,
  Value<String> type,
  Value<int?> categoryId,
  required DateTime transactionDate,
  Value<String?> mpesaRef,
  Value<String> counterpartyName,
  Value<String> counterpartyAccount,
  Value<int?> accountId,
  Value<int?> toAccountId,
  Value<bool> isParsed,
  Value<bool> excludeFromBudget,
  Value<int?> recurrenceId,
  Value<bool> isRecurring,
  Value<int?> debtId,
  Value<DateTime> createdAt,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<String> header,
  Value<String> description,
  Value<double> amount,
  Value<double> transactionCost,
  Value<double> fulizaAmount,
  Value<double> fulizaFee,
  Value<String> type,
  Value<int?> categoryId,
  Value<DateTime> transactionDate,
  Value<String?> mpesaRef,
  Value<String> counterpartyName,
  Value<String> counterpartyAccount,
  Value<int?> accountId,
  Value<int?> toAccountId,
  Value<bool> isParsed,
  Value<bool> excludeFromBudget,
  Value<int?> recurrenceId,
  Value<bool> isRecurring,
  Value<int?> debtId,
  Value<DateTime> createdAt,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get header => $composableBuilder(
      column: $table.header, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get transactionCost => $composableBuilder(
      column: $table.transactionCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fulizaAmount => $composableBuilder(
      column: $table.fulizaAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fulizaFee => $composableBuilder(
      column: $table.fulizaFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mpesaRef => $composableBuilder(
      column: $table.mpesaRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get counterpartyName => $composableBuilder(
      column: $table.counterpartyName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get counterpartyAccount => $composableBuilder(
      column: $table.counterpartyAccount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toAccountId => $composableBuilder(
      column: $table.toAccountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isParsed => $composableBuilder(
      column: $table.isParsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get excludeFromBudget => $composableBuilder(
      column: $table.excludeFromBudget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceId => $composableBuilder(
      column: $table.recurrenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get debtId => $composableBuilder(
      column: $table.debtId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get header => $composableBuilder(
      column: $table.header, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get transactionCost => $composableBuilder(
      column: $table.transactionCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fulizaAmount => $composableBuilder(
      column: $table.fulizaAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fulizaFee => $composableBuilder(
      column: $table.fulizaFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mpesaRef => $composableBuilder(
      column: $table.mpesaRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get counterpartyName => $composableBuilder(
      column: $table.counterpartyName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get counterpartyAccount => $composableBuilder(
      column: $table.counterpartyAccount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toAccountId => $composableBuilder(
      column: $table.toAccountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isParsed => $composableBuilder(
      column: $table.isParsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get excludeFromBudget => $composableBuilder(
      column: $table.excludeFromBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceId => $composableBuilder(
      column: $table.recurrenceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get debtId => $composableBuilder(
      column: $table.debtId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get header =>
      $composableBuilder(column: $table.header, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get transactionCost => $composableBuilder(
      column: $table.transactionCost, builder: (column) => column);

  GeneratedColumn<double> get fulizaAmount => $composableBuilder(
      column: $table.fulizaAmount, builder: (column) => column);

  GeneratedColumn<double> get fulizaFee =>
      $composableBuilder(column: $table.fulizaFee, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<String> get mpesaRef =>
      $composableBuilder(column: $table.mpesaRef, builder: (column) => column);

  GeneratedColumn<String> get counterpartyName => $composableBuilder(
      column: $table.counterpartyName, builder: (column) => column);

  GeneratedColumn<String> get counterpartyAccount => $composableBuilder(
      column: $table.counterpartyAccount, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get toAccountId => $composableBuilder(
      column: $table.toAccountId, builder: (column) => column);

  GeneratedColumn<bool> get isParsed =>
      $composableBuilder(column: $table.isParsed, builder: (column) => column);

  GeneratedColumn<bool> get excludeFromBudget => $composableBuilder(
      column: $table.excludeFromBudget, builder: (column) => column);

  GeneratedColumn<int> get recurrenceId => $composableBuilder(
      column: $table.recurrenceId, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<int> get debtId =>
      $composableBuilder(column: $table.debtId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> header = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double> transactionCost = const Value.absent(),
            Value<double> fulizaAmount = const Value.absent(),
            Value<double> fulizaFee = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<DateTime> transactionDate = const Value.absent(),
            Value<String?> mpesaRef = const Value.absent(),
            Value<String> counterpartyName = const Value.absent(),
            Value<String> counterpartyAccount = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> toAccountId = const Value.absent(),
            Value<bool> isParsed = const Value.absent(),
            Value<bool> excludeFromBudget = const Value.absent(),
            Value<int?> recurrenceId = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<int?> debtId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion(
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
            accountId: accountId,
            toAccountId: toAccountId,
            isParsed: isParsed,
            excludeFromBudget: excludeFromBudget,
            recurrenceId: recurrenceId,
            isRecurring: isRecurring,
            debtId: debtId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String header,
            Value<String> description = const Value.absent(),
            required double amount,
            Value<double> transactionCost = const Value.absent(),
            Value<double> fulizaAmount = const Value.absent(),
            Value<double> fulizaFee = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required DateTime transactionDate,
            Value<String?> mpesaRef = const Value.absent(),
            Value<String> counterpartyName = const Value.absent(),
            Value<String> counterpartyAccount = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> toAccountId = const Value.absent(),
            Value<bool> isParsed = const Value.absent(),
            Value<bool> excludeFromBudget = const Value.absent(),
            Value<int?> recurrenceId = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<int?> debtId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
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
            accountId: accountId,
            toAccountId: toAccountId,
            isParsed: isParsed,
            excludeFromBudget: excludeFromBudget,
            recurrenceId: recurrenceId,
            isRecurring: isRecurring,
            debtId: debtId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  Value<String> icon,
  Value<String> colorHex,
  Value<int?> parentId,
  Value<bool> isDefault,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> colorHex,
  Value<int?> parentId,
  Value<bool> isDefault,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            icon: icon,
            colorHex: colorHex,
            parentId: parentId,
            isDefault: isDefault,
            isArchived: isArchived,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> icon = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            colorHex: colorHex,
            parentId: parentId,
            isDefault: isDefault,
            isArchived: isArchived,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$FulizaRecordsTableCreateCompanionBuilder = FulizaRecordsCompanion
    Function({
  Value<int> id,
  required String mpesaRef,
  required double fulizaAmount,
  Value<double> accessFee,
  Value<double> outstandingTotal,
  Value<DateTime?> dueDate,
  Value<DateTime> createdAt,
});
typedef $$FulizaRecordsTableUpdateCompanionBuilder = FulizaRecordsCompanion
    Function({
  Value<int> id,
  Value<String> mpesaRef,
  Value<double> fulizaAmount,
  Value<double> accessFee,
  Value<double> outstandingTotal,
  Value<DateTime?> dueDate,
  Value<DateTime> createdAt,
});

class $$FulizaRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FulizaRecordsTable> {
  $$FulizaRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mpesaRef => $composableBuilder(
      column: $table.mpesaRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fulizaAmount => $composableBuilder(
      column: $table.fulizaAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accessFee => $composableBuilder(
      column: $table.accessFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get outstandingTotal => $composableBuilder(
      column: $table.outstandingTotal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FulizaRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FulizaRecordsTable> {
  $$FulizaRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mpesaRef => $composableBuilder(
      column: $table.mpesaRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fulizaAmount => $composableBuilder(
      column: $table.fulizaAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accessFee => $composableBuilder(
      column: $table.accessFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get outstandingTotal => $composableBuilder(
      column: $table.outstandingTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FulizaRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FulizaRecordsTable> {
  $$FulizaRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mpesaRef =>
      $composableBuilder(column: $table.mpesaRef, builder: (column) => column);

  GeneratedColumn<double> get fulizaAmount => $composableBuilder(
      column: $table.fulizaAmount, builder: (column) => column);

  GeneratedColumn<double> get accessFee =>
      $composableBuilder(column: $table.accessFee, builder: (column) => column);

  GeneratedColumn<double> get outstandingTotal => $composableBuilder(
      column: $table.outstandingTotal, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FulizaRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FulizaRecordsTable,
    FulizaRecord,
    $$FulizaRecordsTableFilterComposer,
    $$FulizaRecordsTableOrderingComposer,
    $$FulizaRecordsTableAnnotationComposer,
    $$FulizaRecordsTableCreateCompanionBuilder,
    $$FulizaRecordsTableUpdateCompanionBuilder,
    (
      FulizaRecord,
      BaseReferences<_$AppDatabase, $FulizaRecordsTable, FulizaRecord>
    ),
    FulizaRecord,
    PrefetchHooks Function()> {
  $$FulizaRecordsTableTableManager(_$AppDatabase db, $FulizaRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FulizaRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FulizaRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FulizaRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> mpesaRef = const Value.absent(),
            Value<double> fulizaAmount = const Value.absent(),
            Value<double> accessFee = const Value.absent(),
            Value<double> outstandingTotal = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FulizaRecordsCompanion(
            id: id,
            mpesaRef: mpesaRef,
            fulizaAmount: fulizaAmount,
            accessFee: accessFee,
            outstandingTotal: outstandingTotal,
            dueDate: dueDate,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String mpesaRef,
            required double fulizaAmount,
            Value<double> accessFee = const Value.absent(),
            Value<double> outstandingTotal = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FulizaRecordsCompanion.insert(
            id: id,
            mpesaRef: mpesaRef,
            fulizaAmount: fulizaAmount,
            accessFee: accessFee,
            outstandingTotal: outstandingTotal,
            dueDate: dueDate,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FulizaRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FulizaRecordsTable,
    FulizaRecord,
    $$FulizaRecordsTableFilterComposer,
    $$FulizaRecordsTableOrderingComposer,
    $$FulizaRecordsTableAnnotationComposer,
    $$FulizaRecordsTableCreateCompanionBuilder,
    $$FulizaRecordsTableUpdateCompanionBuilder,
    (
      FulizaRecord,
      BaseReferences<_$AppDatabase, $FulizaRecordsTable, FulizaRecord>
    ),
    FulizaRecord,
    PrefetchHooks Function()>;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> type,
  Value<double> initialBalance,
  Value<String> currency,
  Value<String> colorHex,
  Value<String> icon,
  Value<bool> isDefault,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<double> initialBalance,
  Value<String> currency,
  Value<String> colorHex,
  Value<String> icon,
  Value<bool> isDefault,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get initialBalance => $composableBuilder(
      column: $table.initialBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get initialBalance => $composableBuilder(
      column: $table.initialBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get initialBalance => $composableBuilder(
      column: $table.initialBalance, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> initialBalance = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            type: type,
            initialBalance: initialBalance,
            currency: currency,
            colorHex: colorHex,
            icon: icon,
            isDefault: isDefault,
            isArchived: isArchived,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> type = const Value.absent(),
            Value<double> initialBalance = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            type: type,
            initialBalance: initialBalance,
            currency: currency,
            colorHex: colorHex,
            icon: icon,
            isDefault: isDefault,
            isArchived: isArchived,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  required String name,
  required double amount,
  Value<String> period,
  Value<int?> categoryId,
  required DateTime startDate,
  Value<DateTime?> endDate,
  Value<bool> rollover,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> amount,
  Value<String> period,
  Value<int?> categoryId,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<bool> rollover,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rollover => $composableBuilder(
      column: $table.rollover, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rollover => $composableBuilder(
      column: $table.rollover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get rollover =>
      $composableBuilder(column: $table.rollover, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<bool> rollover = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            name: name,
            amount: amount,
            period: period,
            categoryId: categoryId,
            startDate: startDate,
            endDate: endDate,
            rollover: rollover,
            isArchived: isArchived,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double amount,
            Value<String> period = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            Value<bool> rollover = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            name: name,
            amount: amount,
            period: period,
            categoryId: categoryId,
            startDate: startDate,
            endDate: endDate,
            rollover: rollover,
            isArchived: isArchived,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()>;
typedef $$RecurringTransactionsTableCreateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  Value<int> id,
  Value<int?> accountId,
  Value<int?> categoryId,
  required double amount,
  Value<String> type,
  Value<String> payee,
  Value<String> notes,
  Value<String> frequency,
  Value<int> intervalCount,
  required DateTime startDate,
  Value<DateTime?> endDate,
  required DateTime nextDueDate,
  Value<bool> autoRecord,
  Value<bool> notify,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$RecurringTransactionsTableUpdateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  Value<int> id,
  Value<int?> accountId,
  Value<int?> categoryId,
  Value<double> amount,
  Value<String> type,
  Value<String> payee,
  Value<String> notes,
  Value<String> frequency,
  Value<int> intervalCount,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> nextDueDate,
  Value<bool> autoRecord,
  Value<bool> notify,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payee => $composableBuilder(
      column: $table.payee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intervalCount => $composableBuilder(
      column: $table.intervalCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoRecord => $composableBuilder(
      column: $table.autoRecord, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notify => $composableBuilder(
      column: $table.notify, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payee => $composableBuilder(
      column: $table.payee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intervalCount => $composableBuilder(
      column: $table.intervalCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoRecord => $composableBuilder(
      column: $table.autoRecord, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notify => $composableBuilder(
      column: $table.notify, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payee =>
      $composableBuilder(column: $table.payee, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get intervalCount => $composableBuilder(
      column: $table.intervalCount, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<bool> get autoRecord => $composableBuilder(
      column: $table.autoRecord, builder: (column) => column);

  GeneratedColumn<bool> get notify =>
      $composableBuilder(column: $table.notify, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecurringTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTransactionsTable,
    RecurringTransaction,
    $$RecurringTransactionsTableFilterComposer,
    $$RecurringTransactionsTableOrderingComposer,
    $$RecurringTransactionsTableAnnotationComposer,
    $$RecurringTransactionsTableCreateCompanionBuilder,
    $$RecurringTransactionsTableUpdateCompanionBuilder,
    (
      RecurringTransaction,
      BaseReferences<_$AppDatabase, $RecurringTransactionsTable,
          RecurringTransaction>
    ),
    RecurringTransaction,
    PrefetchHooks Function()> {
  $$RecurringTransactionsTableTableManager(
      _$AppDatabase db, $RecurringTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> payee = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<int> intervalCount = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> nextDueDate = const Value.absent(),
            Value<bool> autoRecord = const Value.absent(),
            Value<bool> notify = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            type: type,
            payee: payee,
            notes: notes,
            frequency: frequency,
            intervalCount: intervalCount,
            startDate: startDate,
            endDate: endDate,
            nextDueDate: nextDueDate,
            autoRecord: autoRecord,
            notify: notify,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required double amount,
            Value<String> type = const Value.absent(),
            Value<String> payee = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<int> intervalCount = const Value.absent(),
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            required DateTime nextDueDate,
            Value<bool> autoRecord = const Value.absent(),
            Value<bool> notify = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion.insert(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            type: type,
            payee: payee,
            notes: notes,
            frequency: frequency,
            intervalCount: intervalCount,
            startDate: startDate,
            endDate: endDate,
            nextDueDate: nextDueDate,
            autoRecord: autoRecord,
            notify: notify,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecurringTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RecurringTransactionsTable,
        RecurringTransaction,
        $$RecurringTransactionsTableFilterComposer,
        $$RecurringTransactionsTableOrderingComposer,
        $$RecurringTransactionsTableAnnotationComposer,
        $$RecurringTransactionsTableCreateCompanionBuilder,
        $$RecurringTransactionsTableUpdateCompanionBuilder,
        (
          RecurringTransaction,
          BaseReferences<_$AppDatabase, $RecurringTransactionsTable,
              RecurringTransaction>
        ),
        RecurringTransaction,
        PrefetchHooks Function()>;
typedef $$DebtsTableCreateCompanionBuilder = DebtsCompanion Function({
  Value<int> id,
  required String direction,
  required String counterparty,
  Value<String> product,
  required double principal,
  required double outstanding,
  Value<double> interest,
  Value<DateTime?> dueDate,
  Value<int?> accountId,
  Value<String> notes,
  Value<DateTime> createdAt,
});
typedef $$DebtsTableUpdateCompanionBuilder = DebtsCompanion Function({
  Value<int> id,
  Value<String> direction,
  Value<String> counterparty,
  Value<String> product,
  Value<double> principal,
  Value<double> outstanding,
  Value<double> interest,
  Value<DateTime?> dueDate,
  Value<int?> accountId,
  Value<String> notes,
  Value<DateTime> createdAt,
});

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get counterparty => $composableBuilder(
      column: $table.counterparty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get product => $composableBuilder(
      column: $table.product, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get principal => $composableBuilder(
      column: $table.principal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get outstanding => $composableBuilder(
      column: $table.outstanding, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get interest => $composableBuilder(
      column: $table.interest, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get counterparty => $composableBuilder(
      column: $table.counterparty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get product => $composableBuilder(
      column: $table.product, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get principal => $composableBuilder(
      column: $table.principal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get outstanding => $composableBuilder(
      column: $table.outstanding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get interest => $composableBuilder(
      column: $table.interest, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
      column: $table.counterparty, builder: (column) => column);

  GeneratedColumn<String> get product =>
      $composableBuilder(column: $table.product, builder: (column) => column);

  GeneratedColumn<double> get principal =>
      $composableBuilder(column: $table.principal, builder: (column) => column);

  GeneratedColumn<double> get outstanding => $composableBuilder(
      column: $table.outstanding, builder: (column) => column);

  GeneratedColumn<double> get interest =>
      $composableBuilder(column: $table.interest, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DebtsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DebtsTable,
    Debt,
    $$DebtsTableFilterComposer,
    $$DebtsTableOrderingComposer,
    $$DebtsTableAnnotationComposer,
    $$DebtsTableCreateCompanionBuilder,
    $$DebtsTableUpdateCompanionBuilder,
    (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
    Debt,
    PrefetchHooks Function()> {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<String> counterparty = const Value.absent(),
            Value<String> product = const Value.absent(),
            Value<double> principal = const Value.absent(),
            Value<double> outstanding = const Value.absent(),
            Value<double> interest = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DebtsCompanion(
            id: id,
            direction: direction,
            counterparty: counterparty,
            product: product,
            principal: principal,
            outstanding: outstanding,
            interest: interest,
            dueDate: dueDate,
            accountId: accountId,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String direction,
            required String counterparty,
            Value<String> product = const Value.absent(),
            required double principal,
            required double outstanding,
            Value<double> interest = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DebtsCompanion.insert(
            id: id,
            direction: direction,
            counterparty: counterparty,
            product: product,
            principal: principal,
            outstanding: outstanding,
            interest: interest,
            dueDate: dueDate,
            accountId: accountId,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DebtsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DebtsTable,
    Debt,
    $$DebtsTableFilterComposer,
    $$DebtsTableOrderingComposer,
    $$DebtsTableAnnotationComposer,
    $$DebtsTableCreateCompanionBuilder,
    $$DebtsTableUpdateCompanionBuilder,
    (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
    Debt,
    PrefetchHooks Function()>;
typedef $$DebtRepaymentsTableCreateCompanionBuilder = DebtRepaymentsCompanion
    Function({
  Value<int> id,
  required int debtId,
  required double amount,
  Value<int?> accountId,
  required DateTime paymentDate,
  Value<int?> transactionId,
  Value<DateTime> createdAt,
});
typedef $$DebtRepaymentsTableUpdateCompanionBuilder = DebtRepaymentsCompanion
    Function({
  Value<int> id,
  Value<int> debtId,
  Value<double> amount,
  Value<int?> accountId,
  Value<DateTime> paymentDate,
  Value<int?> transactionId,
  Value<DateTime> createdAt,
});

class $$DebtRepaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DebtRepaymentsTable> {
  $$DebtRepaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get debtId => $composableBuilder(
      column: $table.debtId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DebtRepaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtRepaymentsTable> {
  $$DebtRepaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get debtId => $composableBuilder(
      column: $table.debtId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DebtRepaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtRepaymentsTable> {
  $$DebtRepaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get debtId =>
      $composableBuilder(column: $table.debtId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<int> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DebtRepaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DebtRepaymentsTable,
    DebtRepayment,
    $$DebtRepaymentsTableFilterComposer,
    $$DebtRepaymentsTableOrderingComposer,
    $$DebtRepaymentsTableAnnotationComposer,
    $$DebtRepaymentsTableCreateCompanionBuilder,
    $$DebtRepaymentsTableUpdateCompanionBuilder,
    (
      DebtRepayment,
      BaseReferences<_$AppDatabase, $DebtRepaymentsTable, DebtRepayment>
    ),
    DebtRepayment,
    PrefetchHooks Function()> {
  $$DebtRepaymentsTableTableManager(
      _$AppDatabase db, $DebtRepaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtRepaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtRepaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtRepaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> debtId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<int?> transactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DebtRepaymentsCompanion(
            id: id,
            debtId: debtId,
            amount: amount,
            accountId: accountId,
            paymentDate: paymentDate,
            transactionId: transactionId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int debtId,
            required double amount,
            Value<int?> accountId = const Value.absent(),
            required DateTime paymentDate,
            Value<int?> transactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DebtRepaymentsCompanion.insert(
            id: id,
            debtId: debtId,
            amount: amount,
            accountId: accountId,
            paymentDate: paymentDate,
            transactionId: transactionId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DebtRepaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DebtRepaymentsTable,
    DebtRepayment,
    $$DebtRepaymentsTableFilterComposer,
    $$DebtRepaymentsTableOrderingComposer,
    $$DebtRepaymentsTableAnnotationComposer,
    $$DebtRepaymentsTableCreateCompanionBuilder,
    $$DebtRepaymentsTableUpdateCompanionBuilder,
    (
      DebtRepayment,
      BaseReferences<_$AppDatabase, $DebtRepaymentsTable, DebtRepayment>
    ),
    DebtRepayment,
    PrefetchHooks Function()>;
typedef $$SavingsGoalsTableCreateCompanionBuilder = SavingsGoalsCompanion
    Function({
  Value<int> id,
  required String name,
  required double targetAmount,
  Value<double> currentAmount,
  Value<DateTime?> targetDate,
  Value<DateTime> createdAt,
});
typedef $$SavingsGoalsTableUpdateCompanionBuilder = SavingsGoalsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> targetAmount,
  Value<double> currentAmount,
  Value<DateTime?> targetDate,
  Value<DateTime> createdAt,
});

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavingsGoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavingsGoalsTable,
    SavingsGoal,
    $$SavingsGoalsTableFilterComposer,
    $$SavingsGoalsTableOrderingComposer,
    $$SavingsGoalsTableAnnotationComposer,
    $$SavingsGoalsTableCreateCompanionBuilder,
    $$SavingsGoalsTableUpdateCompanionBuilder,
    (
      SavingsGoal,
      BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>
    ),
    SavingsGoal,
    PrefetchHooks Function()> {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<DateTime?> targetDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SavingsGoalsCompanion(
            id: id,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: targetDate,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double targetAmount,
            Value<double> currentAmount = const Value.absent(),
            Value<DateTime?> targetDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SavingsGoalsCompanion.insert(
            id: id,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: targetDate,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavingsGoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavingsGoalsTable,
    SavingsGoal,
    $$SavingsGoalsTableFilterComposer,
    $$SavingsGoalsTableOrderingComposer,
    $$SavingsGoalsTableAnnotationComposer,
    $$SavingsGoalsTableCreateCompanionBuilder,
    $$SavingsGoalsTableUpdateCompanionBuilder,
    (
      SavingsGoal,
      BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>
    ),
    SavingsGoal,
    PrefetchHooks Function()>;
typedef $$GoalContributionsTableCreateCompanionBuilder
    = GoalContributionsCompanion Function({
  Value<int> id,
  required int goalId,
  required double amount,
  Value<int?> accountId,
  Value<int?> transactionId,
  required DateTime contributionDate,
});
typedef $$GoalContributionsTableUpdateCompanionBuilder
    = GoalContributionsCompanion Function({
  Value<int> id,
  Value<int> goalId,
  Value<double> amount,
  Value<int?> accountId,
  Value<int?> transactionId,
  Value<DateTime> contributionDate,
});

class $$GoalContributionsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contributionDate => $composableBuilder(
      column: $table.contributionDate,
      builder: (column) => ColumnFilters(column));
}

class $$GoalContributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contributionDate => $composableBuilder(
      column: $table.contributionDate,
      builder: (column) => ColumnOrderings(column));
}

class $$GoalContributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<DateTime> get contributionDate => $composableBuilder(
      column: $table.contributionDate, builder: (column) => column);
}

class $$GoalContributionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalContributionsTable,
    GoalContribution,
    $$GoalContributionsTableFilterComposer,
    $$GoalContributionsTableOrderingComposer,
    $$GoalContributionsTableAnnotationComposer,
    $$GoalContributionsTableCreateCompanionBuilder,
    $$GoalContributionsTableUpdateCompanionBuilder,
    (
      GoalContribution,
      BaseReferences<_$AppDatabase, $GoalContributionsTable, GoalContribution>
    ),
    GoalContribution,
    PrefetchHooks Function()> {
  $$GoalContributionsTableTableManager(
      _$AppDatabase db, $GoalContributionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalContributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalContributionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalContributionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> goalId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> transactionId = const Value.absent(),
            Value<DateTime> contributionDate = const Value.absent(),
          }) =>
              GoalContributionsCompanion(
            id: id,
            goalId: goalId,
            amount: amount,
            accountId: accountId,
            transactionId: transactionId,
            contributionDate: contributionDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int goalId,
            required double amount,
            Value<int?> accountId = const Value.absent(),
            Value<int?> transactionId = const Value.absent(),
            required DateTime contributionDate,
          }) =>
              GoalContributionsCompanion.insert(
            id: id,
            goalId: goalId,
            amount: amount,
            accountId: accountId,
            transactionId: transactionId,
            contributionDate: contributionDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalContributionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalContributionsTable,
    GoalContribution,
    $$GoalContributionsTableFilterComposer,
    $$GoalContributionsTableOrderingComposer,
    $$GoalContributionsTableAnnotationComposer,
    $$GoalContributionsTableCreateCompanionBuilder,
    $$GoalContributionsTableUpdateCompanionBuilder,
    (
      GoalContribution,
      BaseReferences<_$AppDatabase, $GoalContributionsTable, GoalContribution>
    ),
    GoalContribution,
    PrefetchHooks Function()>;
typedef $$PayeeCategoryRulesTableCreateCompanionBuilder
    = PayeeCategoryRulesCompanion Function({
  required String payeePattern,
  required int categoryId,
  Value<int> hitCount,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PayeeCategoryRulesTableUpdateCompanionBuilder
    = PayeeCategoryRulesCompanion Function({
  Value<String> payeePattern,
  Value<int> categoryId,
  Value<int> hitCount,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PayeeCategoryRulesTableFilterComposer
    extends Composer<_$AppDatabase, $PayeeCategoryRulesTable> {
  $$PayeeCategoryRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get payeePattern => $composableBuilder(
      column: $table.payeePattern, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hitCount => $composableBuilder(
      column: $table.hitCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PayeeCategoryRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayeeCategoryRulesTable> {
  $$PayeeCategoryRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get payeePattern => $composableBuilder(
      column: $table.payeePattern,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hitCount => $composableBuilder(
      column: $table.hitCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PayeeCategoryRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayeeCategoryRulesTable> {
  $$PayeeCategoryRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get payeePattern => $composableBuilder(
      column: $table.payeePattern, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get hitCount =>
      $composableBuilder(column: $table.hitCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PayeeCategoryRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PayeeCategoryRulesTable,
    PayeeCategoryRule,
    $$PayeeCategoryRulesTableFilterComposer,
    $$PayeeCategoryRulesTableOrderingComposer,
    $$PayeeCategoryRulesTableAnnotationComposer,
    $$PayeeCategoryRulesTableCreateCompanionBuilder,
    $$PayeeCategoryRulesTableUpdateCompanionBuilder,
    (
      PayeeCategoryRule,
      BaseReferences<_$AppDatabase, $PayeeCategoryRulesTable, PayeeCategoryRule>
    ),
    PayeeCategoryRule,
    PrefetchHooks Function()> {
  $$PayeeCategoryRulesTableTableManager(
      _$AppDatabase db, $PayeeCategoryRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayeeCategoryRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayeeCategoryRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayeeCategoryRulesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> payeePattern = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int> hitCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeeCategoryRulesCompanion(
            payeePattern: payeePattern,
            categoryId: categoryId,
            hitCount: hitCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String payeePattern,
            required int categoryId,
            Value<int> hitCount = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeeCategoryRulesCompanion.insert(
            payeePattern: payeePattern,
            categoryId: categoryId,
            hitCount: hitCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PayeeCategoryRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PayeeCategoryRulesTable,
    PayeeCategoryRule,
    $$PayeeCategoryRulesTableFilterComposer,
    $$PayeeCategoryRulesTableOrderingComposer,
    $$PayeeCategoryRulesTableAnnotationComposer,
    $$PayeeCategoryRulesTableCreateCompanionBuilder,
    $$PayeeCategoryRulesTableUpdateCompanionBuilder,
    (
      PayeeCategoryRule,
      BaseReferences<_$AppDatabase, $PayeeCategoryRulesTable, PayeeCategoryRule>
    ),
    PayeeCategoryRule,
    PrefetchHooks Function()>;
typedef $$SmsInboxItemsTableCreateCompanionBuilder = SmsInboxItemsCompanion
    Function({
  Value<int> id,
  required String rawBody,
  Value<String?> parsedType,
  Value<double?> parsedAmount,
  Value<String?> parsedPayee,
  Value<String?> parsedRef,
  Value<int?> parsedDate,
  Value<String> status,
  Value<String?> parseNote,
  required DateTime createdAt,
});
typedef $$SmsInboxItemsTableUpdateCompanionBuilder = SmsInboxItemsCompanion
    Function({
  Value<int> id,
  Value<String> rawBody,
  Value<String?> parsedType,
  Value<double?> parsedAmount,
  Value<String?> parsedPayee,
  Value<String?> parsedRef,
  Value<int?> parsedDate,
  Value<String> status,
  Value<String?> parseNote,
  Value<DateTime> createdAt,
});

class $$SmsInboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SmsInboxItemsTable> {
  $$SmsInboxItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawBody => $composableBuilder(
      column: $table.rawBody, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parsedType => $composableBuilder(
      column: $table.parsedType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get parsedAmount => $composableBuilder(
      column: $table.parsedAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parsedPayee => $composableBuilder(
      column: $table.parsedPayee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parsedRef => $composableBuilder(
      column: $table.parsedRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parsedDate => $composableBuilder(
      column: $table.parsedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parseNote => $composableBuilder(
      column: $table.parseNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SmsInboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SmsInboxItemsTable> {
  $$SmsInboxItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawBody => $composableBuilder(
      column: $table.rawBody, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parsedType => $composableBuilder(
      column: $table.parsedType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get parsedAmount => $composableBuilder(
      column: $table.parsedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parsedPayee => $composableBuilder(
      column: $table.parsedPayee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parsedRef => $composableBuilder(
      column: $table.parsedRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parsedDate => $composableBuilder(
      column: $table.parsedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parseNote => $composableBuilder(
      column: $table.parseNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SmsInboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmsInboxItemsTable> {
  $$SmsInboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawBody =>
      $composableBuilder(column: $table.rawBody, builder: (column) => column);

  GeneratedColumn<String> get parsedType => $composableBuilder(
      column: $table.parsedType, builder: (column) => column);

  GeneratedColumn<double> get parsedAmount => $composableBuilder(
      column: $table.parsedAmount, builder: (column) => column);

  GeneratedColumn<String> get parsedPayee => $composableBuilder(
      column: $table.parsedPayee, builder: (column) => column);

  GeneratedColumn<String> get parsedRef =>
      $composableBuilder(column: $table.parsedRef, builder: (column) => column);

  GeneratedColumn<int> get parsedDate => $composableBuilder(
      column: $table.parsedDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get parseNote =>
      $composableBuilder(column: $table.parseNote, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SmsInboxItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SmsInboxItemsTable,
    SmsInboxItem,
    $$SmsInboxItemsTableFilterComposer,
    $$SmsInboxItemsTableOrderingComposer,
    $$SmsInboxItemsTableAnnotationComposer,
    $$SmsInboxItemsTableCreateCompanionBuilder,
    $$SmsInboxItemsTableUpdateCompanionBuilder,
    (
      SmsInboxItem,
      BaseReferences<_$AppDatabase, $SmsInboxItemsTable, SmsInboxItem>
    ),
    SmsInboxItem,
    PrefetchHooks Function()> {
  $$SmsInboxItemsTableTableManager(_$AppDatabase db, $SmsInboxItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsInboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsInboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsInboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> rawBody = const Value.absent(),
            Value<String?> parsedType = const Value.absent(),
            Value<double?> parsedAmount = const Value.absent(),
            Value<String?> parsedPayee = const Value.absent(),
            Value<String?> parsedRef = const Value.absent(),
            Value<int?> parsedDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> parseNote = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SmsInboxItemsCompanion(
            id: id,
            rawBody: rawBody,
            parsedType: parsedType,
            parsedAmount: parsedAmount,
            parsedPayee: parsedPayee,
            parsedRef: parsedRef,
            parsedDate: parsedDate,
            status: status,
            parseNote: parseNote,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rawBody,
            Value<String?> parsedType = const Value.absent(),
            Value<double?> parsedAmount = const Value.absent(),
            Value<String?> parsedPayee = const Value.absent(),
            Value<String?> parsedRef = const Value.absent(),
            Value<int?> parsedDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> parseNote = const Value.absent(),
            required DateTime createdAt,
          }) =>
              SmsInboxItemsCompanion.insert(
            id: id,
            rawBody: rawBody,
            parsedType: parsedType,
            parsedAmount: parsedAmount,
            parsedPayee: parsedPayee,
            parsedRef: parsedRef,
            parsedDate: parsedDate,
            status: status,
            parseNote: parseNote,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SmsInboxItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SmsInboxItemsTable,
    SmsInboxItem,
    $$SmsInboxItemsTableFilterComposer,
    $$SmsInboxItemsTableOrderingComposer,
    $$SmsInboxItemsTableAnnotationComposer,
    $$SmsInboxItemsTableCreateCompanionBuilder,
    $$SmsInboxItemsTableUpdateCompanionBuilder,
    (
      SmsInboxItem,
      BaseReferences<_$AppDatabase, $SmsInboxItemsTable, SmsInboxItem>
    ),
    SmsInboxItem,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$FulizaRecordsTableTableManager get fulizaRecords =>
      $$FulizaRecordsTableTableManager(_db, _db.fulizaRecords);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$DebtRepaymentsTableTableManager get debtRepayments =>
      $$DebtRepaymentsTableTableManager(_db, _db.debtRepayments);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$GoalContributionsTableTableManager get goalContributions =>
      $$GoalContributionsTableTableManager(_db, _db.goalContributions);
  $$PayeeCategoryRulesTableTableManager get payeeCategoryRules =>
      $$PayeeCategoryRulesTableTableManager(_db, _db.payeeCategoryRules);
  $$SmsInboxItemsTableTableManager get smsInboxItems =>
      $$SmsInboxItemsTableTableManager(_db, _db.smsInboxItems);
}
