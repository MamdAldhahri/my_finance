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
/// category assignment that overrides the automatic rule matching.
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

/// A spending category. Which transactions it holds is decided by its
/// [CategoryRules] (derived from example SMS the user picked), minus any
/// [CategoryExclusions], plus transactions filed into it by hand
/// ([Transactions.categoryId]).
///
/// [senderIds] / [shopNames] are the pre-v6 rule format (a JSON sender list
/// and a senderId -> comma-separated shop-fragment map). They are only read
/// by the v6 migration, which turns them into [CategoryRules] rows.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get color => text().withDefault(const Constant('#3F6F63'))();
  TextColumn get senderIds => text().withDefault(const Constant('[]'))();
  TextColumn get shopNames => text().withDefault(const Constant('{}'))();
}

/// One auto-matching rule of a category, usually copied from an SMS the user
/// picked: the bank [sender] ('' = any bank) and the merchant / masked
/// recipient [counterparty]. [exact] rules compare the whole description;
/// non-exact ones (typed shop names, migrated v5 fragments) match when the
/// description contains [counterparty]. With [matchAmount] only transactions
/// of [amount] (±half a baisa) match — this is what separates e.g. a fixed
/// monthly transfer to a person from other transfers to the same person.
/// [isCredit] limits the direction (null = both).
class CategoryRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer()();
  TextColumn get sender => text().withDefault(const Constant(''))();
  TextColumn get counterparty => text()();
  BoolColumn get exact => boolean().withDefault(const Constant(true))();
  BoolColumn get matchAmount => boolean().withDefault(const Constant(false))();
  RealColumn get amount => real().withDefault(const Constant(0))();
  BoolColumn get isCredit => boolean().nullable()();
}

/// "Not this category": a single transaction the user removed from a
/// category even though one of its rules matches. Only that one transaction
/// leaves; the rule keeps matching everything else.
class CategoryExclusions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer()();
  IntColumn get transactionId => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoryId, transactionId},
      ];
}

/// A savings target, e.g. "New car" – 3000 OMR, 750 already saved.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get targetAmount => real()();
  RealColumn get savedAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
}

/// Money you owe. [totalAmount] is the original debt. [paidAmount] is what was
/// repaid BEFORE tracking started (an opening figure); everything after that
/// is a [DebtPayments] row, so the real total paid is
/// `paidAmount + sum(confirmed payments)`. [creditor] is shown as the lender;
/// [apr] and [minPayment] mirror the design's debt cards.
///
/// A *fixed* debt ([isFixed]) is repaid by the same bank transfer every month.
/// Its matching rule — [fixedAmount] plus the bank [matchSender], the user's
/// own account [matchCard] and the (masked) recipient [matchCounterparty], all
/// copied from an SMS the user picked — lets new alerts be suggested as
/// payments automatically. Amount is the key: transfers to the same recipient
/// with a different amount are not this debt.
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get creditor => text().withDefault(const Constant(''))();
  RealColumn get totalAmount => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  RealColumn get apr => real().withDefault(const Constant(0))();
  RealColumn get minPayment => real().withDefault(const Constant(0))();
  DateTimeColumn get dueDate => dateTime().nullable()();

  BoolColumn get isFixed => boolean().withDefault(const Constant(false))();
  RealColumn get fixedAmount => real().withDefault(const Constant(0))();
  TextColumn get matchSender => text().withDefault(const Constant(''))();
  TextColumn get matchCard => text().withDefault(const Constant(''))();
  TextColumn get matchCounterparty => text().withDefault(const Constant(''))();
}

/// Lifecycle of a [DebtPayments] row. Only [confirmed] counts toward the debt.
/// [suggested] is an SMS the fixed-amount rule matched, waiting for the user;
/// [rejected] remembers a "not this debt" answer so it is never re-suggested.
enum PaymentStatus { confirmed, suggested, rejected }

/// One repayment toward a debt: either a linked SMS transaction
/// ([transactionId] set) or a payment the user entered by hand (null).
class DebtPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer()();
  IntColumn get transactionId => integer().nullable()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get status =>
      intEnum<PaymentStatus>().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {debtId, transactionId},
      ];
}

/// Simple key/value store for app settings (SMS import flags).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Transactions,
  Categories,
  CategoryRules,
  CategoryExclusions,
  Goals,
  Debts,
  DebtPayments,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Builds a database on a custom executor – used by tests with an
  /// in-memory connection.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

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
          if (from < 5) {
            // v5: debts can be linked to SMS payments.
            await m.addColumn(debts, debts.isFixed);
            await m.addColumn(debts, debts.fixedAmount);
            await m.addColumn(debts, debts.matchSender);
            await m.addColumn(debts, debts.matchCard);
            await m.addColumn(debts, debts.matchCounterparty);
            await m.createTable(debtPayments);
          }
          if (from < 6) {
            // v6: categories match by rules picked from SMS, with
            // per-transaction removals. Carry the old shop-name fragments
            // over as "name contains" rules so nothing changes on upgrade.
            await m.createTable(categoryRules);
            await m.createTable(categoryExclusions);
            await _migrateShopNames();
          }
        },
      );

  Future<void> _migrateShopNames() async {
    for (final c in await select(categories).get()) {
      List<String> senders = const [];
      Map<String, dynamic> shops = const {};
      try {
        senders = (jsonDecode(c.senderIds) as List).cast<String>();
      } catch (_) {}
      try {
        shops = jsonDecode(c.shopNames) as Map<String, dynamic>;
      } catch (_) {}
      for (final sender in senders) {
        final fragments = (shops[sender] ?? '')
            .toString()
            .split(',')
            .map((f) => f.trim())
            .where((f) => f.isNotEmpty);
        for (final f in fragments) {
          await into(categoryRules).insert(CategoryRulesCompanion.insert(
            categoryId: c.id,
            sender: Value(sender),
            counterparty: f,
            exact: const Value(false),
          ));
        }
      }
    }
  }

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

  /// Sets the merchant / recipient name of transaction [id].
  Future<void> setTransactionDescription(int id, String description) =>
      (update(transactions)..where((t) => t.id.equals(id)))
          .write(TransactionsCompanion(description: Value(description)));

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

  Future<Transaction?> transactionById(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> deleteTransaction(int id) async {
    // A deleted SMS can no longer count toward a debt.
    await (delete(debtPayments)..where((p) => p.transactionId.equals(id)))
        .go();
    await (delete(categoryExclusions)..where((e) => e.transactionId.equals(id)))
        .go();
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

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

  Future<Category?> categoryById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> deleteCategory(int id) async {
    // Un-file any transactions manually assigned to this category first.
    await (update(transactions)..where((t) => t.categoryId.equals(id)))
        .write(const TransactionsCompanion(categoryId: Value(null)));
    await (delete(categoryRules)..where((r) => r.categoryId.equals(id))).go();
    await (delete(categoryExclusions)..where((e) => e.categoryId.equals(id)))
        .go();
    return (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  // ---- Category rules & exclusions ---------------------------------------
  Stream<List<CategoryRule>> watchCategoryRules() =>
      (select(categoryRules)..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .watch();

  Future<List<CategoryRule>> allCategoryRules() =>
      (select(categoryRules)..orderBy([(r) => OrderingTerm.asc(r.id)])).get();

  Future<int> addCategoryRule(CategoryRulesCompanion entry) =>
      into(categoryRules).insert(entry);

  Future<int> deleteCategoryRule(int id) =>
      (delete(categoryRules)..where((r) => r.id.equals(id))).go();

  /// Replaces every rule of [categoryId] with [rules] in one transaction.
  Future<void> replaceCategoryRules(
    int categoryId,
    List<CategoryRulesCompanion> rules,
  ) =>
      transaction(() async {
        await (delete(categoryRules)
              ..where((r) => r.categoryId.equals(categoryId)))
            .go();
        for (final r in rules) {
          await into(categoryRules)
              .insert(r.copyWith(id: const Value.absent(), categoryId: Value(categoryId)));
        }
      });

  Stream<List<CategoryExclusion>> watchCategoryExclusions() =>
      select(categoryExclusions).watch();

  Future<List<CategoryExclusion>> allCategoryExclusions() =>
      select(categoryExclusions).get();

  /// Removes one transaction from [categoryId] without touching its rules.
  Future<void> excludeFromCategory(int categoryId, int transactionId) =>
      into(categoryExclusions).insert(
        CategoryExclusionsCompanion.insert(
          categoryId: categoryId,
          transactionId: transactionId,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  /// Lets a previously removed transaction back into [categoryId].
  Future<void> restoreToCategory(int categoryId, int transactionId) =>
      (delete(categoryExclusions)
            ..where((e) =>
                e.categoryId.equals(categoryId) &
                e.transactionId.equals(transactionId)))
          .go();

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

  Future<List<Debt>> allDebts() => select(debts).get();

  Future<Debt?> debtById(int id) =>
      (select(debts)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<int> deleteDebt(int id) async {
    await (delete(debtPayments)..where((p) => p.debtId.equals(id))).go();
    return (delete(debts)..where((d) => d.id.equals(id))).go();
  }

  // ---- Debt payments -----------------------------------------------------
  Stream<List<DebtPayment>> watchDebtPayments() => (select(debtPayments)
        ..orderBy([(p) => OrderingTerm.desc(p.date)]))
      .watch();

  Future<List<DebtPayment>> allDebtPayments() => select(debtPayments).get();

  /// Links an SMS transaction to [debtId] with [status]. If that pair already
  /// exists (e.g. a suggestion the user now confirms) its status is updated.
  Future<void> linkTransactionToDebt(
    int debtId,
    Transaction t, {
    PaymentStatus status = PaymentStatus.confirmed,
  }) async {
    final existing = await (select(debtPayments)
          ..where((p) => p.debtId.equals(debtId) & p.transactionId.equals(t.id)))
        .getSingleOrNull();
    if (existing != null) {
      await setPaymentStatus(existing.id, status);
      return;
    }
    await into(debtPayments).insert(DebtPaymentsCompanion.insert(
      debtId: debtId,
      transactionId: Value(t.id),
      amount: t.amount,
      date: t.date,
      note: Value(t.description),
      status: Value(status),
    ));
  }

  /// Records a payment made outside the tracked bank SMS (cash, another bank).
  Future<int> addManualDebtPayment({
    required int debtId,
    required double amount,
    required DateTime date,
    String note = '',
  }) =>
      into(debtPayments).insert(DebtPaymentsCompanion.insert(
        debtId: debtId,
        amount: amount,
        date: date,
        note: Value(note),
      ));

  Future<void> setPaymentStatus(int id, PaymentStatus status) =>
      (update(debtPayments)..where((p) => p.id.equals(id)))
          .write(DebtPaymentsCompanion(status: Value(status)));

  Future<int> deleteDebtPayment(int id) =>
      (delete(debtPayments)..where((p) => p.id.equals(id))).go();

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
