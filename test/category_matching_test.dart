import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance/database/database.dart';
import 'package:finance/services/category_matching.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  var nextSms = 1;
  Future<Transaction> sms(
    String to,
    double amount, {
    int day = 1,
    bool credit = false,
    String sender = 'bank muscat',
  }) async {
    final id = await db.addSmsTransaction(TransactionsCompanion.insert(
      amount: amount,
      isCredit: credit,
      date: DateTime(2026, 8, day),
      source: const Value(TxSource.sms),
      sender: Value(sender),
      description: Value(to),
      card: const Value('0001'),
      balanceAfter: const Value(100),
      smsId: Value(nextSms++),
    ));
    return (await db.transactionById(id!))!;
  }

  Future<Category> category(String name) async {
    final id = await db.addCategory(CategoriesCompanion.insert(name: name));
    return (await db.categoryById(id))!;
  }

  Future<int?> catOf(Transaction t) async =>
      (await CategoryResolver.load(db))
          .categoryIdFor((await db.transactionById(t.id))!);

  test('a rule from one example SMS files all past and future ones',
      () async {
    final food = await category('Food');
    final a = await sms('TALABAT', 5, day: 1);
    final b = await sms('TALABAT', 7, day: 2);
    final other = await sms('LULU', 7, day: 2);
    await db.replaceCategoryRules(food.id, [ruleFromTransaction(a)]);

    expect(await catOf(a), food.id);
    expect(await catOf(b), food.id);
    expect(await catOf(other), isNull);
    final later = await sms('TALABAT', 3, day: 20);
    expect(await catOf(later), food.id);
  });

  test('removing one transaction leaves the rest in the category', () async {
    final food = await category('Food');
    final a = await sms('TALABAT', 5, day: 1);
    final b = await sms('TALABAT', 7, day: 2);
    await db.replaceCategoryRules(food.id, [ruleFromTransaction(a)]);

    await removeTransactionFromCategory(db, a);
    expect(await catOf(a), isNull);
    expect(await catOf(b), food.id);

    // Filing it back from the Transactions tab undoes the removal.
    await fileTransactionToCategory(db, a, food);
    expect(await catOf(a), food.id);
  });

  test('same person: fixed-amount rule beats any-amount rule', () async {
    final house = await category('House');
    final school = await category('School fees');
    final rations = await sms('BRAHXXXXOHAM', 23.4, day: 3);
    final fees = await sms('BRAHXXXXOHAM', 50, day: 4);
    await db.replaceCategoryRules(house.id, [ruleFromTransaction(rations)]);
    await db.replaceCategoryRules(
        school.id, [ruleFromTransaction(fees, fixedAmount: true)]);

    expect(await catOf(rations), house.id);
    expect(await catOf(fees), school.id);
    expect(await catOf(await sms('BRAHXXXXOHAM', 50, day: 30)), school.id);
    expect(await catOf(await sms('BRAHXXXXOHAM', 11, day: 30)), house.id);
  });

  test('an SMS confirmed as a debt payment is in no category', () async {
    final house = await category('House');
    final rations = await sms('BRAHXXXXOHAM', 23.4, day: 3);
    final car = await sms('BRAHXXXXOHAM', 84.053, day: 5);
    await db.replaceCategoryRules(house.id, [ruleFromTransaction(rations)]);
    final debtId = await db.addDebt(
        DebtsCompanion.insert(name: 'Car', totalAmount: 6000));
    await db.linkTransactionToDebt(debtId, car);

    expect(await catOf(rations), house.id);
    expect(await catOf(car), isNull);
  });

  test('filing a generic "Payment" SMS files only that one', () async {
    final misc = await category('Misc');
    final a = await sms('Payment', 4);
    final b = await sms('Payment', 6);
    await fileTransactionToCategory(db, a, misc);
    expect(await catOf(a), misc.id);
    expect(await catOf(b), isNull);
    expect(await db.allCategoryRules(), isEmpty);
  });

  test('moving a merchant to another category removes it from the first',
      () async {
    final food = await category('Food');
    final delivery = await category('Delivery');
    final t = await sms('TALABAT', 5);
    await fileTransactionToCategory(db, t, food);
    await fileTransactionToCategory(db, t, delivery);
    expect(await catOf(t), delivery.id);
    expect((await db.allCategoryRules()).map((r) => r.categoryId),
        [delivery.id]);
  });

  test('typed shop names match by "contains", money out only', () async {
    final food = await category('Food');
    await db.replaceCategoryRules(food.id, [ruleFromShopName('lulu')]);
    expect(await catOf(await sms('LULU HYPERMARKET', 9)), food.id);
    expect(await catOf(await sms('LULU HYPERMARKET', 9, credit: true)),
        isNull);
  });

  test('deleting a category removes its rules and removals', () async {
    final food = await category('Food');
    final t = await sms('TALABAT', 5);
    await db.replaceCategoryRules(food.id, [ruleFromTransaction(t)]);
    await db.excludeFromCategory(food.id, t.id);
    await db.deleteCategory(food.id);
    expect(await db.allCategoryRules(), isEmpty);
    expect(await db.allCategoryExclusions(), isEmpty);
  });
}
