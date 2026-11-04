import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/categories_table.dart';
import 'tables/fuliza_records_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Transactions, Categories, FulizaRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For use in tests only — uses provided executor directly.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultCategories();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Add unique index on mpesaRef (nullable — NULLs are distinct in SQLite)
        await m.createIndex(
          Index('transactions', 'CREATE UNIQUE INDEX IF NOT EXISTS idx_transactions_mpesa_ref ON transactions (mpesa_ref) WHERE mpesa_ref IS NOT NULL'),
        );
      }
      if (from < 3) {
        await m.addColumn(transactions, transactions.fulizaAmount);
        await m.addColumn(transactions, transactions.fulizaFee);
        await m.createTable(fulizaRecords);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'budget_app_db');
  }

  Future<void> _seedDefaultCategories() async {
    final existing = await (select(categories)..limit(1)).get();
    if (existing.isNotEmpty) return; // already seeded

    // Helper to insert and return the new ID
    Future<int> addCat(String name, String icon, String color, {int? parentId}) async {
      return await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          icon: const Value('category'),
          colorHex: Value(color),
          isDefault: const Value(true),
          parentId: Value(parentId),
        ),
      );
    }

    // ── Top-level categories ──
    final food = await addCat('Food & Dining', 'restaurant', '#E53935');
    final transport = await addCat('Transport', 'directions_car', '#1E88E5');
    final shopping = await addCat('Shopping', 'shopping_bag', '#8E24AA');
    final bills = await addCat('Bills & Utilities', 'receipt_long', '#F4511E');
    final entertainment = await addCat('Entertainment', 'movie', '#43A047');
    final health = await addCat('Health', 'favorite', '#E91E63');
    final education = await addCat('Education', 'school', '#00897B');
    final savings = await addCat('Savings', 'savings', '#FFB300');
    final income = await addCat('Income', 'attach_money', '#43A047');
    await addCat('Other', 'more_horiz', '#757575');
    final transfer = await addCat('Transfer', 'swap_horiz', '#546E7A');

    // ── Food & Dining sub-categories ──
    await addCat('Groceries', 'local_grocery_store', '#E53935', parentId: food);
    await addCat('Restaurant', 'restaurant', '#E53935', parentId: food);
    await addCat('Cafe & Coffee', 'local_cafe', '#E53935', parentId: food);
    await addCat('Fast Food', 'fastfood', '#E53935', parentId: food);
    await addCat('Alcohol & Bar', 'local_bar', '#E53935', parentId: food);

    // ── Transport sub-categories ──
    await addCat('Fuel / Petrol', 'local_gas_station', '#1E88E5', parentId: transport);
    await addCat('Matatu / Bus', 'directions_bus', '#1E88E5', parentId: transport);
    await addCat('Taxi / Uber', 'local_taxi', '#1E88E5', parentId: transport);
    await addCat('Parking', 'local_parking', '#1E88E5', parentId: transport);
    await addCat('Vehicle Repair', 'build', '#1E88E5', parentId: transport);
    await addCat('Flight / Travel', 'flight', '#1E88E5', parentId: transport);

    // ── Shopping sub-categories ──
    await addCat('Clothing', 'checkroom', '#8E24AA', parentId: shopping);
    await addCat('Electronics', 'devices', '#8E24AA', parentId: shopping);
    await addCat('Home & Furniture', 'chair', '#8E24AA', parentId: shopping);
    await addCat('Cosmetics', 'face', '#8E24AA', parentId: shopping);
    await addCat('Online Shopping', 'shopping_cart', '#8E24AA', parentId: shopping);

    // ── Bills & Utilities sub-categories ──
    await addCat('Water Bill', 'water_drop', '#F4511E', parentId: bills);
    await addCat('KPLC / Electricity', 'bolt', '#F4511E', parentId: bills);
    await addCat('WiFi / Internet', 'wifi', '#F4511E', parentId: bills);
    await addCat('Rent', 'home', '#F4511E', parentId: bills);
    await addCat('TV / DSTV', 'tv', '#F4511E', parentId: bills);
    await addCat('Gas / Cooking Gas', 'local_fire_department', '#F4511E', parentId: bills);
    await addCat('Phone / Airtime', 'phone_android', '#F4511E', parentId: bills);
    await addCat('Insurance', 'security', '#F4511E', parentId: bills);

    // ── Entertainment sub-categories ──
    await addCat('Movies / Cinema', 'theaters', '#43A047', parentId: entertainment);
    await addCat('Sports', 'sports_soccer', '#43A047', parentId: entertainment);
    await addCat('Gaming', 'videogame_asset', '#43A047', parentId: entertainment);
    await addCat('Events / Concerts', 'event', '#43A047', parentId: entertainment);

    // ── Health sub-categories ──
    await addCat('Pharmacy / Medicine', 'medication', '#E91E63', parentId: health);
    await addCat('Doctor / Hospital', 'local_hospital', '#E91E63', parentId: health);
    await addCat('Gym / Fitness', 'fitness_center', '#E91E63', parentId: health);
    await addCat('Dental', 'face', '#E91E63', parentId: health);
    await addCat('Optical', 'visibility', '#E91E63', parentId: health);

    // ── Education sub-categories ──
    await addCat('School Fees', 'school', '#00897B', parentId: education);
    await addCat('Books & Stationery', 'menu_book', '#00897B', parentId: education);
    await addCat('Courses / Training', 'cast_for_education', '#00897B', parentId: education);

    // ── Savings sub-categories ──
    await addCat('Emergency Fund', 'shield', '#FFB300', parentId: savings);
    await addCat('Investment', 'trending_up', '#FFB300', parentId: savings);
    await addCat('Chama / SACCO', 'groups', '#FFB300', parentId: savings);

    // ── Income sub-categories ──
    await addCat('Salary', 'work', '#43A047', parentId: income);
    await addCat('Business Income', 'store', '#43A047', parentId: income);
    await addCat('Freelance', 'laptop', '#43A047', parentId: income);
    await addCat('Investment Returns', 'trending_up', '#43A047', parentId: income);
    await addCat('Gift / Transfer In', 'card_giftcard', '#43A047', parentId: income);

    // ── Transfer sub-categories ──
    await addCat('Send Money', 'send', '#546E7A', parentId: transfer);
    await addCat('Agent Deposit', 'account_balance', '#546E7A', parentId: transfer);
    await addCat('Fuliza Repayment', 'sync', '#546E7A', parentId: transfer);
  }
}
