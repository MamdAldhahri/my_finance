import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../database/database.dart';
import '../l10n/language.dart';
import '../theme.dart';
import 'category_matching.dart';
import 'pay_cycle.dart';

/// Display names, short explanations and colours for the plan buckets.
extension BucketInfo on Bucket {
  String get label => switch (this) {
    Bucket.expenses => tr.bucketExpenses,
    Bucket.extras => tr.bucketExtras,
    Bucket.savings => tr.bucketSavings,
    Bucket.investments => tr.bucketInvestments,
  };

  String get hint => switch (this) {
    Bucket.expenses => tr.bucketExpensesHint,
    Bucket.extras => tr.bucketExtrasHint,
    Bucket.savings => tr.bucketSavingsHint,
    Bucket.investments => tr.bucketInvestmentsHint,
  };

  Color get color => switch (this) {
    Bucket.expenses => AppColors.blue,
    Bucket.extras => AppColors.peach,
    Bucket.savings => AppColors.green,
    Bucket.investments => AppColors.brown,
  };

  /// Spending buckets are limits (going over is bad); the other two are
  /// targets (going over is good).
  bool get isSpending => this == Bucket.expenses || this == Bucket.extras;
}

/// A ready-made split the user can start from.
enum PlanPreset { balanced, emergencyFirst, aggressive, custom }

extension PlanPresetInfo on PlanPreset {
  String get label => switch (this) {
    PlanPreset.balanced => tr.presetBalanced,
    PlanPreset.emergencyFirst => tr.presetEmergencyFirst,
    PlanPreset.aggressive => tr.presetAggressive,
    PlanPreset.custom => tr.presetCustom,
  };

  /// Percentages in [Bucket] order, or null for [PlanPreset.custom].
  List<int>? get split => switch (this) {
    PlanPreset.balanced => const [50, 20, 10, 20],
    PlanPreset.emergencyFirst => const [50, 15, 25, 10],
    PlanPreset.aggressive => const [45, 10, 15, 30],
    PlanPreset.custom => null,
  };
}

/// How the salary is split, plus a salary to plan with when no salary SMS
/// is found for the cycle.
class IncomePlan {
  IncomePlan({
    required Map<Bucket, int> percents,
    this.preset = PlanPreset.balanced,
    this.expectedSalary,
  }) : percents = Map.unmodifiable(percents);

  factory IncomePlan.fromPreset(PlanPreset preset, {double? expectedSalary}) {
    final split = preset.split ?? PlanPreset.balanced.split!;
    return IncomePlan(
      percents: {for (final b in Bucket.values) b: split[b.index]},
      preset: preset,
      expectedSalary: expectedSalary,
    );
  }

  /// Settings key the plan is stored under.
  static const settingsKey = 'income_plan';

  final Map<Bucket, int> percents;
  final PlanPreset preset;

  /// Typed by the user; used when the cycle's salary SMS isn't found.
  final double? expectedSalary;

  int percentOf(Bucket b) => percents[b] ?? 0;

  int get total => percents.values.fold(0, (s, v) => s + v);

  bool get isValid => total == 100;

  String encode() => jsonEncode({
    for (final b in Bucket.values) b.name: percentOf(b),
    'preset': preset.name,
    if (expectedSalary != null) 'salary': expectedSalary,
  });

  /// Parses a stored plan; null when nothing (or nothing usable) is stored.
  static IncomePlan? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final percents = {
        for (final b in Bucket.values) b: (m[b.name] as num? ?? 0).round(),
      };
      final preset =
          PlanPreset.values.where((p) => p.name == m['preset']).firstOrNull ??
          PlanPreset.custom;
      final salary = (m['salary'] as num?)?.toDouble();
      final plan = IncomePlan(
        percents: percents,
        preset: preset,
        expectedSalary: salary,
      );
      return plan.isValid ? plan : null;
    } catch (_) {
      return null;
    }
  }
}

Stream<IncomePlan?> watchIncomePlan(AppDatabase db) =>
    db.watchSetting(IncomePlan.settingsKey).map(IncomePlan.decode);

Future<void> saveIncomePlan(AppDatabase db, IncomePlan plan) =>
    db.setSetting(IncomePlan.settingsKey, plan.encode());

/// [categories] in [bucket], oldest first.
List<Category> categoriesIn(Bucket bucket, List<Category> categories) => [
      for (final c in categories)
        if (c.bucket == bucket) c,
    ]..sort((a, b) => a.id.compareTo(b.id));

/// Every category, grouped by bucket in plan order, oldest first within one.
List<Category> categoriesByBucket(List<Category> categories) => [
      for (final b in Bucket.values) ...categoriesIn(b, categories),
    ];

/// The regular monthly payment of [d]: its fixed transfer, else its
/// minimum payment (0 = unknown, so every payment counts as regular).
double regularPaymentOf(Debt d) =>
    d.isFixed && d.fixedAmount > 0 ? d.fixedAmount : d.minPayment;

/// Where the money that went out in a period went, by bucket.
///
/// * A confirmed debt payment counts toward Expenses up to the debt's
///   regular payment; anything above it counts as Investments. It is never
///   also counted under a category.
/// * Every other money-out transaction counts toward its category, and so
///   its category's bucket. With no category it is Unknown.
class BucketSpend {
  BucketSpend._(
    this.perCategory,
    this.debtExpenses,
    this.debtInvestments,
    this.unknown,
    this._bucketOf,
  );

  factory BucketSpend.of({
    required Iterable<Transaction> txns,
    required bool Function(DateTime) inPeriod,
    required CategoryResolver resolver,
    required List<Category> categories,
    required List<Debt> debts,
    required List<DebtPayment> debtPayments,
  }) {
    final bucketOf = {for (final c in categories) c.id: c.bucket};

    final debtById = {for (final d in debts) d.id: d};
    final paidPerDebt = <int, double>{};
    for (final p in debtPayments) {
      if (p.status != PaymentStatus.confirmed || !inPeriod(p.date)) continue;
      paidPerDebt[p.debtId] = (paidPerDebt[p.debtId] ?? 0) + p.amount;
    }
    var debtExpenses = 0.0, debtInvestments = 0.0;
    paidPerDebt.forEach((debtId, paid) {
      final d = debtById[debtId];
      final regular = d == null ? 0.0 : regularPaymentOf(d);
      final expensePart = regular > 0 ? math.min(paid, regular) : paid;
      debtExpenses += expensePart;
      debtInvestments += paid - expensePart;
    });

    final perCategory = <int, double>{};
    final unknown = <Transaction>[];
    for (final t in txns) {
      if (t.isCredit || !inPeriod(t.date)) continue;
      if (resolver.isDebtPayment(t)) continue; // counted above
      final id = resolver.categoryIdFor(t);
      if (id == null || !bucketOf.containsKey(id)) {
        unknown.add(t);
      } else {
        perCategory[id] = (perCategory[id] ?? 0) + t.amount;
      }
    }
    return BucketSpend._(
        perCategory, debtExpenses, debtInvestments, unknown, bucketOf);
  }

  /// Spent per category id.
  final Map<int, double> perCategory;

  /// Regular debt payments (part of Expenses).
  final double debtExpenses;

  /// Debt paid above the regular payment (part of Investments).
  final double debtInvestments;

  /// Money out with no category.
  final List<Transaction> unknown;

  final Map<int, Bucket> _bucketOf;

  double get unknownTotal => unknown.fold(0.0, (s, t) => s + t.amount);

  double get debtTotal => debtExpenses + debtInvestments;

  double spentIn(int categoryId) => perCategory[categoryId] ?? 0;

  /// Debt payments counted in [b].
  double debtIn(Bucket b) => switch (b) {
        Bucket.expenses => debtExpenses,
        Bucket.investments => debtInvestments,
        _ => 0,
      };

  /// Everything counted in [b]: its categories plus its share of debt.
  double totalIn(Bucket b) {
    var sum = debtIn(b);
    perCategory.forEach((id, v) {
      if (_bucketOf[id] == b) sum += v;
    });
    return sum;
  }

  /// All money out in the period.
  double get total =>
      perCategory.values.fold(0.0, (s, v) => s + v) + debtTotal + unknownTotal;
}

/// Where the cycle's planned income figure came from.
enum IncomeSource {
  /// Salary SMS found in this cycle.
  detected,

  /// No salary SMS yet; using the salary the user typed in the plan.
  expected,

  /// No salary SMS yet; using last cycle's salary.
  lastCycle,

  /// Nothing to plan with.
  none,
}

/// Plan vs actual for one pay cycle.
class CycleReport {
  CycleReport({
    required this.cycle,
    required this.income,
    required this.incomeSource,
    required this.planned,
    required this.spend,
    required this.now,
  });

  final PayCycle cycle;
  final double income;
  final IncomeSource incomeSource;
  final Map<Bucket, double> planned;
  final BucketSpend spend;
  final DateTime now;

  double plannedFor(Bucket b) => planned[b] ?? 0;
  double actualFor(Bucket b) => spend.totalIn(b);

  /// Money out with no category yet.
  double get unknown => spend.unknownTotal;

  bool get isRunning => cycle.contains(now);

  /// Share of the cycle's days already gone, 0..1.
  double get elapsedFraction {
    final total = cycle.end.difference(cycle.start).inMinutes;
    if (total <= 0) return 1;
    final gone = now.difference(cycle.start).inMinutes;
    return (gone / total).clamp(0.0, 1.0);
  }

  /// Whole days left, counting today. 0 once the cycle is over.
  int get daysLeft {
    if (!isRunning) return 0;
    final today = DateTime(now.year, now.month, now.day);
    return math.max(1, cycle.end.difference(today).inDays);
  }

  /// What's left of Expenses + Extras, minus Unknown spending (that money
  /// came out of the same pocket).
  double get spendingLeft =>
      plannedFor(Bucket.expenses) +
      plannedFor(Bucket.extras) -
      actualFor(Bucket.expenses) -
      actualFor(Bucket.extras) -
      unknown;

  /// How much can still be spent per day without breaking the plan.
  double get safePerDay =>
      daysLeft == 0 ? 0 : math.max(0.0, spendingLeft) / daysLeft;
}

/// Builds the plan-vs-actual report for [cycle]. Income is the salary
/// credits in the cycle; with none yet it falls back to the plan's expected
/// salary, then to last cycle's salary. Spending is split as [BucketSpend].
CycleReport buildCycleReport({
  required PayCycle cycle,
  required PayCycles cycles,
  required List<Transaction> txns,
  required CategoryResolver resolver,
  required List<Category> categories,
  required List<Debt> debts,
  required List<DebtPayment> debtPayments,
  required IncomePlan plan,
  DateTime? now,
}) {
  double salaryIn(PayCycle c) => txns
      .where((t) => isSalary(t) && c.contains(t.date))
      .fold(0.0, (s, t) => s + t.amount);

  var income = salaryIn(cycle);
  var source = IncomeSource.detected;
  if (income <= 0) {
    final expected = plan.expectedSalary;
    final last = salaryIn(cycles.shift(cycle, -1));
    if (expected != null && expected > 0) {
      income = expected;
      source = IncomeSource.expected;
    } else if (last > 0) {
      income = last;
      source = IncomeSource.lastCycle;
    } else {
      income = 0;
      source = IncomeSource.none;
    }
  }

  return CycleReport(
    cycle: cycle,
    income: income,
    incomeSource: source,
    planned: {
      for (final b in Bucket.values) b: income * plan.percentOf(b) / 100,
    },
    spend: BucketSpend.of(
      txns: txns,
      inPeriod: cycle.contains,
      resolver: resolver,
      categories: categories,
      debts: debts,
      debtPayments: debtPayments,
    ),
    now: now ?? cycles.now,
  );
}

/// The most recent salary credit, if any (for the plan setup screen).
Transaction? latestSalary(List<Transaction> txns) {
  Transaction? best;
  for (final t in txns) {
    if (!isSalary(t)) continue;
    if (best == null || t.date.isAfter(best.date)) best = t;
  }
  return best;
}
