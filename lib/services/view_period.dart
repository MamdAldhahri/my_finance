import 'package:intl/intl.dart';

import 'pay_cycle.dart';

/// How long a stretch of time the Categories screen summarises.
enum PeriodKind { daily, monthly, yearly }

extension PeriodKindLabel on PeriodKind {
  String get label => switch (this) {
        PeriodKind.daily => 'Daily',
        PeriodKind.monthly => 'Monthly',
        PeriodKind.yearly => 'Yearly',
      };

  /// How far back the arrows may step.
  int get maxOffset => switch (this) {
        PeriodKind.daily => 3650,
        PeriodKind.monthly => 120,
        PeriodKind.yearly => 10,
      };
}

/// A span of time: [start] inclusive, [end] exclusive, with a display label.
class ViewPeriod {
  const ViewPeriod(this.start, this.end, this.label);

  final DateTime start;
  final DateTime end;
  final String label;

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);
}

DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// The period of [kind] that is [offset] steps before the latest one.
///
/// The latest one holds today, or the newest transaction if any is dated
/// later ([latestActivity]).
///   * Daily: calendar days.
///   * Monthly: salary-to-salary pay cycles (see [PayCycles]).
///   * Yearly: the twelve pay cycles anchored to January..December, so a
///     year is exactly the sum of its months.
ViewPeriod viewPeriod(
  PeriodKind kind,
  int offset, {
  required PayCycles cycles,
  DateTime? latestActivity,
}) {
  final now = cycles.now;
  final latest = latestActivity != null && latestActivity.isAfter(now)
      ? latestActivity
      : now;

  switch (kind) {
    case PeriodKind.daily:
      final today = _dayOf(now);
      final top = _dayOf(latest);
      final day = DateTime(top.year, top.month, top.day - offset);
      final end = DateTime(day.year, day.month, day.day + 1);
      final String label;
      if (day == today) {
        label = 'Today';
      } else if (day == DateTime(today.year, today.month, today.day - 1)) {
        label = 'Yesterday';
      } else {
        label = DateFormat(day.year == now.year ? 'EEE d MMM' : 'EEE d MMM y')
            .format(day);
      }
      return ViewPeriod(day, end, label);

    case PeriodKind.monthly:
      final period = cycles.shift(cycles.cycleFor(latest), -offset);
      final label = period.start.year == now.year
          ? period.label(now: now)
          : '${period.label(now: now)} ${period.start.year}';
      return ViewPeriod(period.start, period.end, label);

    case PeriodKind.yearly:
      final year = cycles.cycleFor(latest).anchorMonth.year - offset;
      final first = cycles.cycleFor(DateTime(year, 1, 28));
      final last = cycles.cycleFor(DateTime(year, 12, 28));
      final f = DateFormat('d MMM');
      final String range;
      if (last.end.isAfter(now)) {
        range = 'since ${f.format(first.start)}';
      } else {
        final lastDay =
            DateTime(last.end.year, last.end.month, last.end.day - 1);
        range = '${f.format(first.start)} – ${f.format(lastDay)}';
      }
      return ViewPeriod(first.start, last.end, '$year · $range');
  }
}
