import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance/database/database.dart';
import 'package:finance/services/derive.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addTalabat(int n) => db.addSmsTransaction(
        TransactionsCompanion.insert(
          amount: 5,
          isCredit: false,
          date: DateTime(2026, 8, n),
          source: const Value(TxSource.sms),
          sender: const Value('bank muscat'),
          description: const Value('TALABAT'),
          card: const Value('0001'),
          balanceAfter: const Value(100),
          smsId: Value(n),
        ),
      );

  test('filing one merchant categorises all same-named transactions',
      () async {
    await db.addCategory(CategoriesCompanion.insert(name: 'Food'));
    await addTalabat(1);
    await addTalabat(2);
    await addTalabat(3);

    var txns = await db.allTransactions();
    var cats = await db.allCategories();
    expect(txns.where((t) => categoryIdFor(t, cats) != null), isEmpty);

    // Tap ONE TALABAT into Food.
    await fileTransactionToCategory(db, txns.first, cats.single, cats);

    cats = await db.allCategories();
    txns = await db.allTransactions();
    final food = cats.single.id;
    expect(
      txns.where((t) => categoryIdFor(t, cats) == food).length,
      3,
      reason: 'all TALABAT transactions should now be in Food',
    );
  });

  test('a future same-named transaction auto-joins the category', () async {
    await db.addCategory(CategoriesCompanion.insert(name: 'Food'));
    await addTalabat(1);
    var cats = await db.allCategories();
    await fileTransactionToCategory(
        db, (await db.allTransactions()).first, cats.single, cats);

    // A new TALABAT arrives later.
    await addTalabat(9);
    cats = await db.allCategories();
    final food = cats.single.id;
    final newest = (await db.allTransactions())
        .firstWhere((t) => t.smsId == 9);
    expect(categoryIdFor(newest, cats), food);
  });

  test('removing a merchant clears all its transactions', () async {
    await db.addCategory(CategoriesCompanion.insert(name: 'Food'));
    await addTalabat(1);
    await addTalabat(2);
    var cats = await db.allCategories();
    await fileTransactionToCategory(
        db, (await db.allTransactions()).first, cats.single, cats);

    cats = await db.allCategories();
    await unfileTransactionFromCategory(
        db, (await db.allTransactions()).first, cats);

    cats = await db.allCategories();
    final txns = await db.allTransactions();
    expect(txns.where((t) => categoryIdFor(t, cats) != null), isEmpty);
  });

  test('moving a merchant to another category removes it from the first',
      () async {
    await db.addCategory(CategoriesCompanion.insert(name: 'Food'));
    await db.addCategory(CategoriesCompanion.insert(name: 'Delivery'));
    await addTalabat(1);

    var cats = await db.allCategories();
    final food = cats.firstWhere((c) => c.name == 'Food');
    final delivery = cats.firstWhere((c) => c.name == 'Delivery');

    await fileTransactionToCategory(
        db, (await db.allTransactions()).first, food, cats);
    cats = await db.allCategories();
    await fileTransactionToCategory(
        db, (await db.allTransactions()).first, delivery, cats);

    cats = await db.allCategories();
    final t = (await db.allTransactions()).first;
    expect(categoryIdFor(t, cats), delivery.id);
  });
}
