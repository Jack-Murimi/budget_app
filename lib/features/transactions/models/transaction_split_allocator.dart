import 'transaction_model.dart';
import '../../../core/database/converters/cents_converter.dart';

/// Distributes an expense transaction's base amount + fees across its splits in
/// exact integer cents so budgets and charts never suffer rounding drift or
/// double-counting.
abstract final class TransactionSplitAllocator {
  static List<({int? categoryId, int cents})> allocateExpenseCents({
    required int? fallbackCategoryId,
    required int amountCents,
    required int feeCents,
    required List<({int categoryId, int amountCents})> splits,
  }) {
    if (splits.isEmpty) {
      return [(categoryId: fallbackCategoryId, cents: amountCents + feeCents)];
    }

    final totalSplitCents =
        splits.fold<int>(0, (sum, s) => sum + s.amountCents);
    if (totalSplitCents <= 0) {
      return [(categoryId: fallbackCategoryId, cents: amountCents + feeCents)];
    }

    if (feeCents <= 0) {
      return [
        for (final s in splits) (categoryId: s.categoryId, cents: s.amountCents),
      ];
    }

    // Proportional floor allocation of fees with largest-remainder distribution
    // so allocated fees sum exactly to [feeCents].
    final floors = <int>[];
    final remainders = <({int index, int rem, int amountCents})>[];
    var floorSum = 0;

    for (var i = 0; i < splits.length; i++) {
      final numer = feeCents * splits[i].amountCents;
      final floorVal = numer ~/ totalSplitCents;
      final rem = numer % totalSplitCents;
      floors.add(floorVal);
      floorSum += floorVal;
      remainders.add((index: i, rem: rem, amountCents: splits[i].amountCents));
    }

    var leftover = feeCents - floorSum;
    remainders.sort((a, b) {
      final rCmp = b.rem.compareTo(a.rem);
      if (rCmp != 0) return rCmp;
      final aCmp = b.amountCents.compareTo(a.amountCents);
      if (aCmp != 0) return aCmp;
      return a.index.compareTo(b.index);
    });

    for (var i = 0; i < leftover; i++) {
      floors[remainders[i].index] += 1;
    }

    return [
      for (var i = 0; i < splits.length; i++)
        (
          categoryId: splits[i].categoryId,
          cents: splits[i].amountCents + floors[i],
        ),
    ];
  }

  static List<({int? categoryId, int cents})> allocateForTransaction(
    TransactionModel txn,
  ) {
    final amountCents = CentsConverter.toCents(txn.amount);
    final feeCents = CentsConverter.toCents(txn.transactionCost) +
        CentsConverter.toCents(txn.fulizaFee);
    return allocateExpenseCents(
      fallbackCategoryId: txn.categoryId,
      amountCents: amountCents,
      feeCents: feeCents,
      splits: [
        for (final s in txn.splits)
          (categoryId: s.categoryId, amountCents: CentsConverter.toCents(s.amount)),
      ],
    );
  }
}
