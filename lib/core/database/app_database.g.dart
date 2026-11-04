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
        isParsed,
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
    if (data.containsKey('is_parsed')) {
      context.handle(_isParsedMeta,
          isParsed.isAcceptableOrUnknown(data['is_parsed']!, _isParsedMeta));
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
      isParsed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_parsed'])!,
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
  final bool isParsed;
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
      required this.isParsed,
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
    map['is_parsed'] = Variable<bool>(isParsed);
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
      isParsed: Value(isParsed),
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
      isParsed: serializer.fromJson<bool>(json['isParsed']),
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
      'isParsed': serializer.toJson<bool>(isParsed),
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
          bool? isParsed,
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
        isParsed: isParsed ?? this.isParsed,
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
      isParsed: data.isParsed.present ? data.isParsed.value : this.isParsed,
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
          ..write('isParsed: $isParsed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      isParsed,
      createdAt);
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
          other.isParsed == this.isParsed &&
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
  final Value<bool> isParsed;
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
    this.isParsed = const Value.absent(),
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
    this.isParsed = const Value.absent(),
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
    Expression<bool>? isParsed,
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
      if (isParsed != null) 'is_parsed': isParsed,
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
      Value<bool>? isParsed,
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
      isParsed: isParsed ?? this.isParsed,
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
    if (isParsed.present) {
      map['is_parsed'] = Variable<bool>(isParsed.value);
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
          ..write('isParsed: $isParsed, ')
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
      [id, name, icon, colorHex, parentId, isDefault, createdAt];
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
  final DateTime createdAt;
  const Category(
      {required this.id,
      required this.name,
      required this.icon,
      required this.colorHex,
      this.parentId,
      required this.isDefault,
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
          DateTime? createdAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorHex: colorHex ?? this.colorHex,
        parentId: parentId.present ? parentId.value : this.parentId,
        isDefault: isDefault ?? this.isDefault,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, colorHex, parentId, isDefault, createdAt);
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
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> colorHex;
  final Value<int?> parentId;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? colorHex,
    Expression<int>? parentId,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorHex != null) 'color_hex': colorHex,
      if (parentId != null) 'parent_id': parentId,
      if (isDefault != null) 'is_default': isDefault,
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
      Value<DateTime>? createdAt}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      parentId: parentId ?? this.parentId,
      isDefault: isDefault ?? this.isDefault,
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $FulizaRecordsTable fulizaRecords = $FulizaRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [transactions, categories, fulizaRecords];
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
  Value<bool> isParsed,
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
  Value<bool> isParsed,
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

  ColumnFilters<bool> get isParsed => $composableBuilder(
      column: $table.isParsed, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<bool> get isParsed => $composableBuilder(
      column: $table.isParsed, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<bool> get isParsed =>
      $composableBuilder(column: $table.isParsed, builder: (column) => column);

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
            Value<bool> isParsed = const Value.absent(),
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
            isParsed: isParsed,
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
            Value<bool> isParsed = const Value.absent(),
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
            isParsed: isParsed,
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
  Value<DateTime> createdAt,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> colorHex,
  Value<int?> parentId,
  Value<bool> isDefault,
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
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            icon: icon,
            colorHex: colorHex,
            parentId: parentId,
            isDefault: isDefault,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> icon = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            colorHex: colorHex,
            parentId: parentId,
            isDefault: isDefault,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$FulizaRecordsTableTableManager get fulizaRecords =>
      $$FulizaRecordsTableTableManager(_db, _db.fulizaRecords);
}
