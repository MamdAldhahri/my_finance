import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance/database/database.dart';
import 'package:finance/services/category_matching.dart';
import 'package:finance/services/category_tree.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  var nextSms = 1;
  Future<Transaction> sms(String to, double amount) async {
    final id = await db.addSmsTransaction(
      TransactionsCompanion.insert(
        amount: amount,
        isCredit: false,
        date: DateTime(2026, 8, 1),
        source: const Value(TxSource.sms),
        sender: const Value('bank muscat'),
        description: Value(to),
        card: const Value('0001'),
        balanceAfter: const Value(100),
        smsId: Value(nextSms++),
      ),
    );
    return (await db.transactionById(id!))!;
  }

  Future<Category> category(String name, {int? parent}) async {
    final id = await db.addCategory(
      CategoriesCompanion.insert(name: name, parentId: Value(parent)),
    );
    return (await db.categoryById(id))!;
  }

  test('subcategory spending rolls up into its parent', () async {
    final food = await category('Food');
    final cafe = await category('Cafe', parent: food.id);
    final rest = await category('Restaurants', parent: food.id);
    final car = await category('Car');
    final tree = CategoryTree(await db.allCategories());

    expect(tree.roots.map((c) => c.name), ['Food', 'Car']);
    expect(tree.childrenOf(food.id).map((c) => c.name), [
      'Cafe',
      'Restaurants',
    ]);
    expect(tree.ordered.map((c) => c.name), [
      'Food',
      'Cafe',
      'Restaurants',
      'Car',
    ]);
    expect(tree.pathName(cafe), 'Food › Cafe');
    expect(tree.rootIdOf(rest.id), food.id);
    expect(tree.rootIdOf(car.id), car.id);
    expect(tree.rollUp({cafe.id: 3, rest.id: 7, food.id: 1, car.id: 20}), {
      food.id: 11,
      car.id: 20,
    });
  });

  test('a subcategory whose parent is gone counts as top level', () async {
    final orphan = await category('Orphan', parent: 999);
    final tree = CategoryTree(await db.allCategories());
    expect(tree.roots.single.id, orphan.id);
    expect(tree.rootIdOf(orphan.id), orphan.id);
    expect(tree.pathName(orphan), 'Orphan');
  });

  test('transactions can be filed into a subcategory by rule', () async {
    final food = await category('Food');
    final cafe = await category('Cafe', parent: food.id);
    final a = await sms('STARBUCKS', 2);
    final b = await sms('STARBUCKS', 3);
    await fileTransactionToCategory(db, a, cafe);

    final resolver = await CategoryResolver.load(db);
    expect(resolver.categoryIdFor((await db.transactionById(b.id))!), cafe.id);
  });

  test('deleting a parent deletes its subcategories', () async {
    final food = await category('Food');
    final cafe = await category('Cafe', parent: food.id);
    final t = await sms('STARBUCKS', 2);
    await fileTransactionToCategory(db, t, cafe);
    await db.deleteCategory(food.id);

    expect(await db.allCategories(), isEmpty);
    expect(await db.allCategoryRules(), isEmpty);
    final resolver = await CategoryResolver.load(db);
    expect(resolver.categoryIdFor((await db.transactionById(t.id))!), isNull);
  });

  test('deleting a subcategory keeps the parent', () async {
    final food = await category('Food');
    final cafe = await category('Cafe', parent: food.id);
    await db.deleteCategory(cafe.id);
    expect((await db.allCategories()).single.id, food.id);
  });

  test(
    'upgrading from v6 adds subcategory support and keeps categories',
    () async {
      final dir = await Directory.systemTemp.createTemp('finance_v6');
      final file = File('${dir.path}/db.sqlite');
      // Build a v6 database: today's schema minus parent_id.
      var old = AppDatabase.forTesting(NativeDatabase(file));
      await old.addCategory(CategoriesCompanion.insert(name: 'Food'));
      await old.customStatement('ALTER TABLE categories DROP COLUMN parent_id');
      await old.customStatement('PRAGMA user_version = 6');
      await old.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      final food = (await upgraded.allCategories()).single;
      expect(food.name, 'Food');
      expect(food.parentId, isNull);
      await upgraded.addCategory(
        CategoriesCompanion.insert(name: 'Cafe', parentId: Value(food.id)),
      );
      expect((await upgraded.allCategories()).last.parentId, food.id);
      await upgraded.close();
      await dir.delete(recursive: true);
    },
  );
}
