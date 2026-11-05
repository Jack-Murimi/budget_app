import '../../../core/database/app_database.dart';

class AccountWithBalance {
  final Account account;
  final double balance;

  const AccountWithBalance({
    required this.account,
    required this.balance,
  });

  int get id => account.id;
  String get name => account.name;
  String get type => account.type;
  String get currency => account.currency;
  String get colorHex => account.colorHex;
  String get icon => account.icon;
  bool get isDefault => account.isDefault;
  bool get isArchived => account.isArchived;
}
