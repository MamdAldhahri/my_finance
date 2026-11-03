import 'dart:math' as math;

import '../database/database.dart';
import 'pay_cycle.dart';

/// How far an SMS amount may differ from a debt's fixed amount and still
/// match — half a baisa, to absorb rounding only. The amount is the key that
/// separates the monthly debt transfer from other transfers to the same
/// recipient, so this stays tight on purpose.
const debtAmountTolerance = 0.0005;

/// Only money that LEFT the account via a bank SMS can be a debt payment.
bool canBeDebtPayment(Transaction t) =>
    t.source == TxSource.sms && !t.isCredit;

String _norm(String s) => s.trim().toLowerCase();

/// True when [t] fits [d]'s fixed-payment rule: same bank, same own account,
/// same recipient, and the same amount (within [debtAmountTolerance]).
bool matchesFixedDebt(Debt d, Transaction t) {
  if (!d.isFixed || d.fixedAmount <= 0) return false;
  if (!canBeDebtPayment(t)) return false;
  if (d.matchSender.isNotEmpty && t.sender != d.matchSender) return false;
  if (d.matchCard.isNotEmpty && t.card != d.matchCard) return false;
  if (d.matchCounterparty.isNotEmpty &&
      _norm(t.description) != _norm(d.matchCounterparty)) {
    return false;
  }
  return (t.amount - d.fixedAmount).abs() <= debtAmountTolerance;
}

/// A debt's progress, combining the opening "paid before tracking" figure
/// with its confirmed payments.
class DebtProgress {
  const DebtProgress({
    required this.paid,
    required this.remaining,
    required this.monthlyAmount,
    required this.monthsLeft,
    required this.pending,
    required this.payments,
  });

  final double paid;
  final double remaining;

  /// The fixed amount, or the minimum payment for non-fixed debts; 0 if none.
  final double monthlyAmount;

  /// Payments still needed at [monthlyAmount], or null when there is no
  /// monthly amount to project with.
  final int? monthsLeft;

  /// Suggested SMS matches waiting for the user to confirm or reject.
  final List<DebtPayment> pending;

  /// Confirmed payments, newest first.
  final List<DebtPayment> payments;

  double fractionPaid(Debt d) =>
      d.totalAmount <= 0 ? 0 : (paid / d.totalAmount).clamp(0.0, 1.0);

  /// The budget month (salary cycle) the last payment is expected in.
  ///
  /// Counts one payment per salary cycle starting with the current one, or
  /// with the next one when this cycle's payment is already confirmed, so a
  /// payment made right after payday doesn't make the payoff look a month
  /// early.
  DateTime? payoffMonth({PayCycles? cycles}) {
    if (monthsLeft == null || monthsLeft == 0) return null;
    final c = (cycles ?? PayCycles(const [])).current;
    final paidThisCycle = payments.any((p) => c.contains(p.date));
    final a = c.anchorMonth;
    return DateTime(
        a.year, a.month + monthsLeft! - 1 + (paidThisCycle ? 1 : 0), 1);
  }
}

DebtProgress progressOf(Debt d, List<DebtPayment> all) {
  final mine = all.where((p) => p.debtId == d.id).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  final confirmed =
      mine.where((p) => p.status == PaymentStatus.confirmed).toList();
  final pending =
      mine.where((p) => p.status == PaymentStatus.suggested).toList();
  final paid = d.paidAmount + confirmed.fold<double>(0, (s, p) => s + p.amount);
  final remaining = math.max(0.0, d.totalAmount - paid);
  final monthly = d.isFixed && d.fixedAmount > 0 ? d.fixedAmount : d.minPayment;
  int? months;
  if (monthly > 0) {
    // Tiny epsilon so 84.053 × 3 = 252.159 left reads as 3, not 4.
    months = remaining <= debtAmountTolerance
        ? 0
        : (remaining / monthly - 1e-9).ceil();
  }
  return DebtProgress(
    paid: paid,
    remaining: remaining,
    monthlyAmount: monthly,
    monthsLeft: months,
    pending: pending,
    payments: confirmed,
  );
}

/// Ids of transactions already confirmed as a payment of some debt. A
/// transaction never counts toward two debts.
Set<int> confirmedTransactionIds(List<DebtPayment> all) => {
      for (final p in all)
        if (p.status == PaymentStatus.confirmed && p.transactionId != null)
          p.transactionId!,
    };

/// Scans every stored transaction for matches to [d]'s fixed rule and queues
/// the new ones as suggestions. Returns how many were added. Run when a fixed
/// debt is created or its rule changes, so past months are back-filled.
Future<int> suggestDebtMatches(AppDatabase db, Debt d) async {
  if (!d.isFixed) return 0;
  final payments = await db.allDebtPayments();
  final taken = confirmedTransactionIds(payments);
  final known = {
    for (final p in payments)
      if (p.debtId == d.id && p.transactionId != null) p.transactionId!,
  };
  var added = 0;
  for (final t in await db.allTransactions()) {
    if (taken.contains(t.id) || known.contains(t.id)) continue;
    if (!matchesFixedDebt(d, t)) continue;
    await db.linkTransactionToDebt(d.id, t, status: PaymentStatus.suggested);
    added++;
  }
  return added;
}

/// Checks one newly imported transaction against every fixed debt and queues
/// it as a suggestion where it matches. Called from the SMS import pipeline.
Future<void> suggestDebtMatchesForTransaction(
  AppDatabase db,
  Transaction t,
) async {
  if (!canBeDebtPayment(t)) return;
  for (final d in await db.allDebts()) {
    if (matchesFixedDebt(d, t)) {
      await db.linkTransactionToDebt(d.id, t, status: PaymentStatus.suggested);
    }
  }
}
