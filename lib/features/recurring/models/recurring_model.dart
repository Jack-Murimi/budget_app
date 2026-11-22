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

  bool get isOverdue => isOverdueAt(DateTime.now());

  bool isOverdueAt(DateTime now) {
    if (!isActive) return false;
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    return due.isBefore(today);
  }

  bool isDueSoon({int days = 3}) => isDueSoonAt(DateTime.now(), days: days);

  bool isDueSoonAt(DateTime now, {int days = 3}) {
    if (!isActive) return false;
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    final diff = due.difference(today).inDays;
    return diff >= 0 && diff <= days;
  }

  RecurringModel copyWith({
    int? id,
    int? accountId,
    bool clearAccountId = false,
    int? categoryId,
    bool clearCategoryId = false,
    double? amount,
    String? type,
    String? payee,
    String? notes,
    String? frequency,
    int? intervalCount,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
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
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      amount: amount ?? this.amount,
      type: type ?? this.type,
      payee: payee ?? this.payee,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      intervalCount: intervalCount ?? this.intervalCount,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      nextDueDate: nextDueDate ?? this.nextDueDate,
      autoRecord: autoRecord ?? this.autoRecord,
      notify: notify ?? this.notify,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountName: clearAccountId ? null : (accountName ?? this.accountName),
      categoryName: clearCategoryId ? null : (categoryName ?? this.categoryName),
      categoryColorHex:
          clearCategoryId ? null : (categoryColorHex ?? this.categoryColorHex),
      categoryIcon: clearCategoryId ? null : (categoryIcon ?? this.categoryIcon),
    );
  }
}
