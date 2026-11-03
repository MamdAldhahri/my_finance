import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../database/database.dart';

/// Day of the month the salary normally lands on. Used as the fallback cycle
/// start when no salary SMS is found for a month.
const defaultPayDay = 15;

/// How many days before or after [defaultPayDay] a salary may land and still
/// start that month's cycle (weekends, holidays, the 15th/16th drift).
const payDayTolerance = 3;

final _salaryWords = RegExp(r'salary|راتب', caseSensitive: false);

/// True when [t] is a salary credit: money in, from an SMS (or entry) that
/// mentions salary in English or Arabic.
bool isSalary(Transaction t) =>
    t.isCredit &&
    (_salaryWords.hasMatch(t.rawMessage) ||
        _salaryWords.hasMatch(t.description));

/// One budgeting "month": from one payday up to (not including) the next.
class PayCycle {
  const PayCycle(this.start, this.end);

  /// First day of the cycle (midnight), inclusive.
  final DateTime start;

  /// First day of the next cycle (midnight), exclusive.
  final DateTime end;

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  /// The calendar month this cycle is anchored to (the month its payday is
  /// in), e.g. the cycle that starts 16 Oct is "October's".
  DateTime get anchorMonth => DateTime(start.year, start.month);

  /// "Since 16 Oct" for a cycle that is still running, otherwise
  /// "16 Sep – 15 Oct" (last day inclusive).
  String label({DateTime? now}) {
    final f = DateFormat('d MMM');
    if (end.isAfter(now ?? DateTime.now())) return 'Since ${f.format(start)}';
    final last = DateTime(end.year, end.month, end.day - 1);
    return '${f.format(start)} – ${f.format(last)}';
  }

  @override
  bool operator ==(Object other) =>
      other is PayCycle && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'PayCycle($start → $end)';
}

/// Splits time into salary-to-salary cycles.
///
/// Each calendar month has a pay window of [payDay] ± [tolerance] days. The
/// cycle for that month starts on the day the salary SMS arrived inside the
/// window. If there is none:
///   * while the window is still open (salary not here yet), the new cycle
///     hasn't started, so today still belongs to the previous cycle;
///   * once the window has passed, it falls back to [payDay].
class PayCycles {
  PayCycles(
    Iterable<DateTime> salaryDates, {
    this.payDay = defaultPayDay,
    this.tolerance = payDayTolerance,
    DateTime? now,
  })  : now = now ?? DateTime.now(),
        _salary = salaryDates.map(_dayOf).toList()..sort();

  /// Cycles built from the salary credits among [txns].
  factory PayCycles.fromTransactions(
    List<Transaction> txns, {
    int payDay = defaultPayDay,
    int tolerance = payDayTolerance,
    DateTime? now,
  }) =>
      PayCycles(
        txns.where(isSalary).map((t) => t.date),
        payDay: payDay,
        tolerance: tolerance,
        now: now,
      );

  final int payDay;
  final int tolerance;
  final DateTime now;
  final List<DateTime> _salary;

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Start of the cycle anchored to calendar month [month] (any day in it).
  DateTime _startOf(DateTime month) {
    final y = month.year, m = month.month;
    final lastDay = DateTime(y, m + 1, 0).day;
    final nominal = DateTime(y, m, math.min(payDay, lastDay));
    final from = DateTime(y, m, nominal.day - tolerance);
    final to = DateTime(y, m, nominal.day + tolerance);
    for (final s in _salary) {
      if (!s.isBefore(from) && !s.isAfter(to)) return s; // earliest wins
    }
    // Salary not detected. If the window is still open, the cycle starts no
    // earlier than the day after it closes; otherwise use the usual pay day.
    if (!to.isBefore(_dayOf(now))) return DateTime(y, m, to.day + 1);
    return nominal;
  }

  PayCycle _anchoredAt(DateTime month) => PayCycle(
        _startOf(month),
        _startOf(DateTime(month.year, month.month + 1)),
      );

  /// The cycle [date] falls in.
  PayCycle cycleFor(DateTime date) {
    final day = _dayOf(date);
    final here = DateTime(day.year, day.month);
    if (day.isBefore(_startOf(here))) {
      return _anchoredAt(DateTime(day.year, day.month - 1));
    }
    return _anchoredAt(here);
  }

  /// The cycle running today.
  PayCycle get current => cycleFor(now);

  /// The cycle [n] cycles after [c] (negative goes back).
  PayCycle shift(PayCycle c, int n) => _anchoredAt(
      DateTime(c.anchorMonth.year, c.anchorMonth.month + n));
}
