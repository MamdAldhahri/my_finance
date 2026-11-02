import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance/database/database.dart';
import 'package:finance/services/debt_matching.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  var nextSms = 1;
  Future<Transaction> transfer(
    double amount,
    DateTime date, {
    String to = 'BRAHXXXXXXXXXXXXXOHAM',
    String card = '0017',
    bool credit = false,
  }) async {
    final id = await db.addSmsTransaction(TransactionsCompanion.insert(
      amount: amount,
      isCredit: credit,
      date: date,
      source: const Value(TxSource.sms),
      sender: const Value('BankMuscat'),
      description: Value(to),
      card: Value(card),
      balanceAfter: const Value(500),
      smsId: Value(nextSms++),
    ));
    return (await db.transactionById(id!))!;
  }

  Future<Debt> carDebt({double paidBefore = 0}) async {
    final id = await db.addDebt(DebtsCompanion.insert(
      name: 'Car',
      totalAmount: 6000,
      paidAmount: Value(paidBefore),
      isFixed: const Value(true),
      fixedAmount: const Value(84.053),
      matchSender: const Value('BankMuscat'),
      matchCard: const Value('0017'),
      matchCounterparty: const Value('BRAHXXXXXXXXXXXXXOHAM'),
    ));
    return (await db.debtById(id))!;
  }

  test('only same account + same amount matches; ration transfers do not',
      () async {
    final debt = await carDebt();
    final car = await transfer(84.053, DateTime(2026, 9, 1));
    final ration = await transfer(30, DateTime(2026, 9, 5));
    final otherPerson = await transfer(84.053, DateTime(2026, 9, 6), to: 'SHU****LAH');
    final otherCard = await transfer(84.053, DateTime(2026, 9, 7), card: '0001');
    final incoming = await transfer(84.053, DateTime(2026, 9, 8), credit: true);

    expect(matchesFixedDebt(debt, car), isTrue);
    expect(matchesFixedDebt(debt, ration), isFalse);
    expect(matchesFixedDebt(debt, otherPerson), isFalse);
    expect(matchesFixedDebt(debt, otherCard), isFalse);
    expect(matchesFixedDebt(debt, incoming), isFalse);
  });

  test('scanning past SMS queues suggestions that count once confirmed',
      () async {
    await transfer(84.053, DateTime(2026, 8, 1));
    await transfer(84.053, DateTime(2026, 9, 1));
    await transfer(25, DateTime(2026, 9, 10)); // ration, ignored
    final debt = await carDebt(paidBefore: 1000);

    expect(await suggestDebtMatches(db, debt), 2);
    var p = progressOf(debt, await db.allDebtPayments());
    expect(p.pending, hasLength(2));
    expect(p.paid, 1000); // suggestions don't count yet

    for (final s in p.pending) {
      await db.setPaymentStatus(s.id, PaymentStatus.confirmed);
    }
    p = progressOf(debt, await db.allDebtPayments());
    expect(p.paid, closeTo(1168.106, 1e-9));
    expect(p.remaining, closeTo(4831.894, 1e-9));
    expect(p.monthsLeft, 58); // 4831.894 / 84.053 = 57.49 → 58

    // Re-scanning adds nothing new.
    expect(await suggestDebtMatches(db, debt), 0);
  });

  test('a new SMS is suggested on import; a rejected one is not re-suggested',
      () async {
    final debt = await carDebt();
    final t = await transfer(84.053, DateTime(2026, 10, 1));
    await suggestDebtMatchesForTransaction(db, t);
    final pending = progressOf(debt, await db.allDebtPayments()).pending;
    expect(pending, hasLength(1));

    await db.setPaymentStatus(pending.single.id, PaymentStatus.rejected);
    expect(await suggestDebtMatches(db, debt), 0);
    expect(progressOf(debt, await db.allDebtPayments()).pending, isEmpty);
  });

  test('manual payments count and the full car loan is 72 months', () async {
    final debt = await carDebt();
    expect(progressOf(debt, const []).monthsLeft, 72); // 6000 / 84.053 = 71.4

    await db.addManualDebtPayment(
        debtId: debt.id, amount: 200, date: DateTime(2026, 10, 15));
    final p = progressOf(debt, await db.allDebtPayments());
    expect(p.paid, 200);
    expect(p.remaining, 5800);
  });

  test('deleting a debt removes its payments', () async {
    final debt = await carDebt();
    await db.addManualDebtPayment(
        debtId: debt.id, amount: 50, date: DateTime(2026, 10, 1));
    await db.deleteDebt(debt.id);
    expect(await db.allDebtPayments(), isEmpty);
  });
}
