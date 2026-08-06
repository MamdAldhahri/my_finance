import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Where a transaction came from.
///
/// [sms] rows are parsed from bank alerts and carry a [Transactions.sender],
/// [Transactions.card] and [Transactions.balanceAfter]. [manual] rows are
/// one-off entries the user typed; those three are empty/null for them.
enum TxSource { sms, manual }

/// A money movement — either auto-imported from a bank SMS or entered by hand.
///
/// [isCredit] is the direction: true = money in, false = money out. [amount]
/// is always positive. For SMS rows, [balanceAfter] is the "available balance"
/// the bank stated, and [smsId] (the Android inbox id) is kept unique so a
/// re-scan never imports the same alert twice. [categoryId] is a *manual*
/// category assignment that overrides the automatic shop-name matching.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  BoolColumn get isCredit => boolean()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  IntColumn get source => intEnum<TxSource>().withDefault(const Constant(0))();

  /// Bank sender id, e.g. "bank muscat" (SMS rows only).
  TextColumn get sender => text().withDefault(const Constant(''))();

  /// Last 4 digits of the account/card the alert is about (SMS rows only).
  TextColumn get card => text().withDefault(const Constant(''))();

  /// The "Avl Bal" the bank reported after this transaction (SMS rows only).
  RealColumn get balanceAfter => real().nullable()();

  /// Manual category assignment; overrides automatic shop-name matching.
  IntColumn get categoryId => integer().nullable()();

  TextColumn get rawMessage => text().withDefault(const Constant(''))();
  IntColumn get smsId => integer().nullable().unique()();
}

/// A spending category defined by which bank chats and shop names feed it.
///
/// [senderIds] is a JSON list of bank sender ids. [shopNames] is a JSON map of
/// senderId -> comma-separated shop-name fragments. A transaction is matched to
/// this category when its sender is in [senderIds] and its description contains
/// one of that sender's shop-name fragments (case-insensitive).
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get color => text().withDefault(const Constant('#3F6F63'))();
  TextColumn get senderIds => text().withDefault(const Constant('[]'))();
  TextColumn get shopNames => text().withDefault(const Constant('{}'))();
}

/// A savings target, e.g. "New car" – 3000 OMR, 750 already saved.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get targetAmount => real()();
  RealColumn get savedAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
}

/// Money you owe. [totalAmount] is the original debt, [paidAmount] what you
/// have already repaid. [creditor] is shown as the lender; [apr] and
/// [minPayment] mirror the design's debt cards.
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get creditor => text().withDefault(const Constant(''))();
  RealColumn get totalAmount => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  RealColumn get apr => real().withDefault(const Constant(0))();
  RealColumn get minPayment => real().withDefault(const Constant(0))();
  DateTimeColumn get dueDate => dateTime().nullable()();
}

/// Simple key/value store for app settings (SMS import flags).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Transactions, Categories, Goals, Debts, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Builds a database on a custom executor – used by tests with an
  /// in-memory connection.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 4) {
            // v4 rebuild: drop the retired manual-Expenses table and the old
            // bank_transactions table (its SMS rows are re-derived on the next
            // inbox scan), introduce the unified transactions + categories
            // tables, and extend debts with the design's fields.
            await m.deleteTable('expenses');
            await m.deleteTable('bank_transactions');
            await m.createTable(transactions);
            await m.createTable(categories);
            await m.addColumn(debts, debts.apr);
            await m.addColumn(debts, debts.minPayment);
          }
        },
      );

  // ---- Transactions ------------------------------------------------------
  Stream<List<Transaction>> watchTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<Transaction>> allTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  /// Inserts an SMS transaction, ignoring it when an alert with the same
  /// [smsId] was already imported. Returns the new row id, or null if skipped.
  Future<int?> addSmsTransaction(TransactionsCompanion entry) async {
    final smsIdValue = entry.smsId;
    if (smsIdValue.present && smsIdValue.value != null) {
      final existing = await (select(transactions)
            ..where((t) => t.smsId.equals(smsIdValue.value!))
            ..limit(1))
          .getSingleOrNull();
      if (existing != null) return null;
    }
    return into(transactions).insert(entry);
  }

  /// True when a transaction with this exact SMS body already exists. Used to
  /// dedupe live-received messages that arrive without a stable inbox id.
  Future<bool> transactionBodyExists(String rawMessage) async {
    final row = await (select(transactions)
          ..where((t) => t.rawMessage.equals(rawMessage))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  /// Records a hand-entered, off-book transaction (no sender/card/balance).
  Future<int> addManualTransaction({
    required String description,
    required double amount,
    required bool isCredit,
    required DateTime date,
    int? categoryId,
  }) =>
      into(transactions).insert(
        TransactionsCompanion.insert(
          amount: amount,
          isCredit: isCredit,
          date: date,
          description: Value(description),
          source: const Value(TxSource.manual),
          categoryId: Value(categoryId),
        ),
      );

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  /// Manually files a transaction under [categoryId] (null clears it).
  Future<void> setTransactionCategory(int id, int? categoryId) =>
      (update(transactions)..where((t) => t.id.equals(id)))
          .write(TransactionsCompanion(categoryId: Value(categoryId)));

  // ---- Categories --------------------------------------------------------
  Stream<List<Category>> watchCategories() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.id)])).watch();

  Future<List<Category>> allCategories() => select(categories).get();

  Future<int> addCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<bool> updateCategory(Category entry) =>
      update(categories).replace(entry);

  Future<int> deleteCategory(int id) async {
    // Un-file any transactions manually assigned to this category first.
    await (update(transactions)..where((t) => t.categoryId.equals(id)))
        .write(const TransactionsCompanion(categoryId: Value(null)));
    return (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  // ---- Goals -------------------------------------------------------------
  Stream<List<Goal>> watchGoals() =>
      (select(goals)..orderBy([(g) => OrderingTerm.asc(g.id)])).watch();

  Future<int> addGoal(GoalsCompanion entry) => into(goals).insert(entry);

  Future<bool> updateGoal(Goal entry) => update(goals).replace(entry);

  Future<int> deleteGoal(int id) =>
      (delete(goals)..where((g) => g.id.equals(id))).go();

  // ---- Debts -------------------------------------------------------------
  Stream<List<Debt>> watchDebts() =>
      (select(debts)..orderBy([(d) => OrderingTerm.asc(d.id)])).watch();

  Future<int> addDebt(DebtsCompanion entry) => into(debts).insert(entry);

  Future<bool> updateDebt(Debt entry) => update(debts).replace(entry);

  Future<int> deleteDebt(int id) =>
      (delete(debts)..where((d) => d.id.equals(id))).go();

  // ---- SMS settings ------------------------------------------------------
  Stream<bool> watchSmsImportEnabled() {
    final query = select(settings)..where((s) => s.key.equals(_smsEnabledKey));
    return query.watchSingleOrNull().map((row) => row?.value == 'true');
  }

  Future<bool> isSmsImportEnabled() async {
    final row = await (select(settings)
          ..where((s) => s.key.equals(_smsEnabledKey)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> setSmsImportEnabled(bool value) =>
      into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: _smsEnabledKey, value: value.toString()),
      );

  /// The SMS sender IDs the user has marked as their bank(s). Only messages
  /// from these senders are parsed. Empty until the user picks their bank(s).
  Stream<List<String>> watchBankSenders() {
    final query = select(settings)..where((s) => s.key.equals(_smsSendersKey));
    return query.watchSingleOrNull().map(_decodeSenders);
  }

  Future<List<String>> getBankSenders() async {
    final row = await (select(settings)
          ..where((s) => s.key.equals(_smsSendersKey)))
        .getSingleOrNull();
    return _decodeSenders(row);
  }

  Future<void> setBankSenders(List<String> senders) =>
      into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: _smsSendersKey,
          value: jsonEncode(senders),
        ),
      );

  List<String> _decodeSenders(Setting? row) {
    if (row == null || row.value.isEmpty) return const [];
    try {
      return (jsonDecode(row.value) as List).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  static const _smsEnabledKey = 'sms_import_enabled';
  static const _smsSendersKey = 'sms_bank_senders';
}

QueryExecutor _openConnection() => driftDatabase(name: 'finance_db');
