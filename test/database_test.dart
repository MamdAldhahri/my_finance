import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('manual transactions are stored and streamed', () async {
    await db.addManualTransaction(
      description: 'Cash lunch',
      amount: 3.5,
      isCredit: false,
      date: DateTime(2026, 8, 2),
    );
    final txns = await db.watchTransactions().first;
    expect(txns, hasLength(1));
    expect(txns.single.source, TxSource.manual);
    expect(txns.single.description, 'Cash lunch');
  });

  test('SMS transactions dedupe on smsId', () async {
    Future<int?> insert() => db.addSmsTransaction(
          TransactionsCompanion.insert(
            amount: 10,
            isCredit: false,
            date: DateTime(2026, 8, 1),
            source: const Value(TxSource.sms),
            sender: const Value('bank muscat'),
            card: const Value('0001'),
            balanceAfter: const Value(490),
            smsId: const Value(42),
          ),
        );
    expect(await insert(), isNotNull); // first insert
    expect(await insert(), isNull); // same smsId ignored
    expect(await db.watchTransactions().first, hasLength(1));
  });

  test('category assignment can be set and cleared', () async {
    final catId = await db.addCategory(
      CategoriesCompanion.insert(name: 'Food'),
    );
    final txId = await db.addManualTransaction(
      description: 'Al Fair',
      amount: 5,
      isCredit: false,
      date: DateTime(2026, 8, 3),
    );
    await db.setTransactionCategory(txId, catId);
    expect((await db.watchTransactions().first).single.categoryId, catId);

    // Deleting the category un-files its transactions.
    await db.deleteCategory(catId);
    expect((await db.watchTransactions().first).single.categoryId, isNull);
  });

  test('goal saved amount can grow', () async {
    final id = await db.addGoal(
      GoalsCompanion.insert(name: 'Car', targetAmount: 3000),
    );
    final goal = (await db.watchGoals().first).single;
    expect(goal.id, id);
    await db.updateGoal(goal.copyWith(savedAmount: 750));
    expect((await db.watchGoals().first).single.savedAmount, 750);
  });

  test('debt payment reduces the remaining balance', () async {
    await db.addDebt(
      DebtsCompanion.insert(name: 'Loan', totalAmount: 500),
    );
    final debt = (await db.watchDebts().first).single;
    await db.updateDebt(debt.copyWith(paidAmount: 120));
    final updated = (await db.watchDebts().first).single;
    expect(updated.totalAmount - updated.paidAmount, 380);
  });
}
