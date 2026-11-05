import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance/database/database.dart';
import 'package:finance/services/category_matching.dart';
import 'package:finance/services/income_plan.dart';
import 'package:finance/services/pay_cycle.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  var nextSms = 1;
  Future<Transaction> sms(
    String desc,
    double amount,
    DateTime date, {
    bool credit = false,
    String raw = '',
  }) async {
    final id = await db.addSmsTransaction(
      TransactionsCompanion.insert(
        amount: amount,
        isCredit: credit,
        date: date,
        source: const Value(TxSource.sms),
        sender: const Value('bank muscat'),
        description: Value(desc),
        card: const Value('0001'),
        balanceAfter: const Value(100),
        rawMessage: Value(raw),
        smsId: Value(nextSms++),
      ),
    );
    return (await db.transactionById(id!))!;
  }

  Future<Category> category(
    String name, {
    Bucket bucket = Bucket.expenses,
  }) async {
    final id = await db.addCategory(
      CategoriesCompanion.insert(name: name, bucket: Value(bucket)),
    );
    return (await db.categoryById(id))!;
  }

  Future<CycleReport> report(IncomePlan plan, DateTime now) async {
    final txns = await db.allTransactions();
    final cycles = PayCycles.fromTransactions(txns, now: now);
    return buildCycleReport(
      cycle: cycles.current,
      cycles: cycles,
      txns: txns,
      resolver: await CategoryResolver.load(db),
      categories: await db.allCategories(),
      debts: await db.allDebts(),
      debtPayments: await db.allDebtPayments(),
      plan: plan,
      now: now,
    );
  }

  final balanced = IncomePlan.fromPreset(PlanPreset.balanced);

  test('plan round-trips through settings and rejects bad totals', () async {
    expect(IncomePlan.decode(null), isNull);
    final plan = IncomePlan(
      percents: {
        Bucket.expenses: 55,
        Bucket.extras: 15,
        Bucket.savings: 10,
        Bucket.investments: 20,
      },
      preset: PlanPreset.custom,
      expectedSalary: 900,
    );
    await saveIncomePlan(db, plan);
    final back = await watchIncomePlan(db).first;
    expect(back!.percentOf(Bucket.expenses), 55);
    expect(back.preset, PlanPreset.custom);
    expect(back.expectedSalary, 900);
    expect(IncomePlan.decode('{"expenses":50,"extras":10}'), isNull);
    expect(IncomePlan.fromPreset(PlanPreset.balanced).isValid, isTrue);
    expect(IncomePlan.fromPreset(PlanPreset.emergencyFirst).isValid, isTrue);
    expect(IncomePlan.fromPreset(PlanPreset.aggressive).isValid, isTrue);
  });

  test('categories are listed bucket by bucket', () async {
    await category('Invest', bucket: Bucket.investments);
    await category('Rent');
    await category('Cafe', bucket: Bucket.extras);
    await category('Fuel');
    final all = await db.allCategories();
    expect(categoriesByBucket(all).map((c) => c.name), [
      'Rent',
      'Fuel',
      'Cafe',
      'Invest',
    ]);
    expect(categoriesIn(Bucket.savings, all), isEmpty);
    // New categories default to Expenses.
    final id = await db.addCategory(CategoriesCompanion.insert(name: 'X'));
    expect((await db.categoryById(id))!.bucket, Bucket.expenses);
  });

  test(
    'spending is planned against the salary and sorted into buckets',
    () async {
      final food = await category('Food', bucket: Bucket.expenses);
      final rest = await category('Restaurants', bucket: Bucket.extras);
      final saving = await category('Savings transfer', bucket: Bucket.savings);

      await sms(
        'SALARY',
        1000,
        DateTime(2026, 10, 15),
        credit: true,
        raw: 'Salary credited',
      );
      final lulu = await sms('LULU', 40, DateTime(2026, 10, 18));
      final kfc = await sms('KFC', 10, DateTime(2026, 10, 19));
      final save = await sms('OWN SAVINGS', 100, DateTime(2026, 10, 20));
      await sms('UNKNOWN SHOP', 5, DateTime(2026, 10, 21));
      // Before the cycle: not counted.
      await sms('LULU', 99, DateTime(2026, 10, 10));
      await fileTransactionToCategory(db, lulu, food);
      await fileTransactionToCategory(db, kfc, rest);
      await fileTransactionToCategory(db, save, saving);

      final r = await report(balanced, DateTime(2026, 10, 25));
      expect(r.income, 1000);
      expect(r.incomeSource, IncomeSource.detected);
      expect(r.plannedFor(Bucket.expenses), 500);
      expect(r.plannedFor(Bucket.investments), 200);
      expect(r.actualFor(Bucket.expenses), 40);
      expect(r.actualFor(Bucket.extras), 10);
      expect(r.actualFor(Bucket.savings), 100);
      expect(r.unknown, 5);
      // 700 planned spending - 50 spent - 5 unknown.
      expect(r.spendingLeft, closeTo(645, 1e-9));
      expect(r.isRunning, isTrue);
      expect(r.safePerDay, closeTo(645 / r.daysLeft, 1e-9));
    },
  );

  test(
    'debt payments: regular part is Expenses, extra is Investments',
    () async {
      await sms(
        'SALARY',
        1000,
        DateTime(2026, 10, 15),
        credit: true,
        raw: 'salary',
      );
      final debtId = await db.addDebt(
        DebtsCompanion.insert(
          name: 'Car',
          totalAmount: 5000,
          minPayment: const Value(150),
        ),
      );
      final pay = await sms('BROTHER', 250, DateTime(2026, 10, 16));
      final debt = (await db.debtById(debtId))!;
      await db.linkTransactionToDebt(debt.id, pay);
      // A suggestion that wasn't confirmed doesn't count.
      final maybe = await sms('BROTHER', 150, DateTime(2026, 10, 17));
      await db.linkTransactionToDebt(
        debt.id,
        maybe,
        status: PaymentStatus.suggested,
      );

      final r = await report(balanced, DateTime(2026, 10, 25));
      expect(r.actualFor(Bucket.expenses), 150);
      expect(r.actualFor(Bucket.investments), 100);
      // The unconfirmed one is ordinary uncategorized spending.
      expect(r.unknown, 150);
    },
  );

  test(
    'before the salary SMS, plans on typed salary, else last cycle',
    () async {
      await sms(
        'SALARY',
        800,
        DateTime(2026, 9, 15),
        credit: true,
        raw: 'salary',
      );
      // 16 Oct, salary window still open: still September's cycle, which
      // has a salary. Jump to a date with no salary in its cycle instead.
      final now = DateTime(2026, 10, 25);
      final last = await report(balanced, now);
      expect(last.incomeSource, IncomeSource.lastCycle);
      expect(last.income, 800);

      final typed = IncomePlan.fromPreset(
        PlanPreset.balanced,
        expectedSalary: 900,
      );
      final r = await report(typed, now);
      expect(r.incomeSource, IncomeSource.expected);
      expect(r.income, 900);
    },
  );

  test('upgrading from v8 turns subcategories into categories', () async {
    final dir = await Directory.systemTemp.createTemp('finance_v8');
    final file = File('${dir.path}/db.sqlite');
    // Build a v8 database: categories with parent_id and a nullable bucket.
    var old = AppDatabase.forTesting(NativeDatabase(file));
    await old.allCategories(); // opens and creates today's tables
    await old.customStatement('DROP TABLE categories');
    await old.customStatement('''
      CREATE TABLE categories (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT NOT NULL DEFAULT '#3F6F63',
        sender_ids TEXT NOT NULL DEFAULT '[]',
        shop_names TEXT NOT NULL DEFAULT '{}',
        parent_id INTEGER NULL,
        bucket INTEGER NULL)
    ''');
    await old.customStatement('''
      INSERT INTO categories (id, name, parent_id, bucket) VALUES
        (1, 'Food', NULL, 0),
        (2, 'Restaurants', 1, 1),
        (3, 'Market', 1, NULL),
        (4, 'Misc', NULL, NULL),
        (5, 'Broker', NULL, 3)
    ''');
    await old.customStatement('PRAGMA user_version = 8');
    await old.close();

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
    final byName = {
      for (final c in await upgraded.allCategories()) c.name: c.bucket,
    };
    expect(byName, {
      'Food': Bucket.expenses,
      'Restaurants': Bucket.extras, // keeps its own bucket
      'Market': Bucket.expenses, // takes its parent's
      'Misc': Bucket.expenses, // default
      'Broker': Bucket.investments,
    });
    final cols = await upgraded
        .customSelect('PRAGMA table_info(categories)')
        .get();
    expect(cols.map((c) => c.read<String>('name')), isNot(contains('parent_id')));
    await upgraded.close();
    await dir.delete(recursive: true);
  });
}
