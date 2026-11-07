class RecurringModel {
  final int id;
  final int? accountId;
  final int? categoryId;
  final double amount;
  final String type; // income | expense | transfer
  final String payee;
  final String notes;
  final String frequency; // daily | weekly | monthly | yearly | custom
  final int intervalCount;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool autoRecord;
  final bool notify;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Enriched presentation fields
  final String? accountName;
  final String? categoryName;
  final String? categoryColorHex;
  final String? categoryIcon;

  const RecurringModel({
    required this.id,
    this.accountId,
    this.categoryId,
    required this.amount,
    this.type = 'expense',
    this.payee = '',
    this.notes = '',
    this.frequency = 'monthly',
    this.intervalCount = 1,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.autoRecord = false,
    this.notify = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.accountName,
    this.categoryName,
    this.categoryColorHex,
    this.categoryIcon,
  });

  bool get isOverdue => isActive && nextDueDate.isBefore(DateTime.now());

  bool isDueSoon({int days = 3}) {
    if (!isActive) return false;
    final diff = nextDueDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= days;
  }

  RecurringModel copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    double? amount,
    String? type,
    String? payee,
    String? notes,
    String? frequency,
    int? intervalCount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? autoRecord,
    bool? notify,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accountName,
    String? categoryName,
    String? categoryColorHex,
    String? categoryIcon,
  }) {
    return RecurringModel(
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
      accountName: accountName ?? this.accountName,
      categoryName: categoryName ?? this.categoryName,
      categoryColorHex: categoryColorHex ?? this.categoryColorHex,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}
