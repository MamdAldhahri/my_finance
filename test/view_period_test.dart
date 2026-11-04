import 'package:flutter_test/flutter_test.dart';

import 'package:finance/services/pay_cycle.dart';
import 'package:finance/services/view_period.dart';

void main() {
  DateTime d(int m, int day, [int y = 2026]) => DateTime(y, m, day);

  final cycles = PayCycles(
    [d(1, 15), d(10, 16), d(11, 15)],
    now: d(11, 4).add(const Duration(hours: 10)),
  );

  test('daily steps back one calendar day at a time', () {
    final today = viewPeriod(PeriodKind.daily, 0, cycles: cycles);
    expect(today.start, d(11, 4));
    expect(today.end, d(11, 5));
    expect(today.label, 'Today');
    final yesterday = viewPeriod(PeriodKind.daily, 1, cycles: cycles);
    expect(yesterday.start, d(11, 3));
    expect(yesterday.label, 'Yesterday');
    expect(viewPeriod(PeriodKind.daily, 4, cycles: cycles).start, d(10, 31));
  });

  test('monthly is the running pay cycle', () {
    final p = viewPeriod(PeriodKind.monthly, 0, cycles: cycles);
    expect(p.start, d(10, 16));
    expect(p.end, d(11, 15));
    final prev = viewPeriod(PeriodKind.monthly, 1, cycles: cycles);
    expect(prev.end, d(10, 16));
  });

  test('yearly spans January to December pay cycles', () {
    final y = viewPeriod(PeriodKind.yearly, 0, cycles: cycles);
    expect(y.start, d(1, 15));
    // Next January's salary isn't in yet, so the end is the latest it
    // could start (window close + 1), as for any running cycle.
    expect(y.end, d(1, 19, 2027));
    expect(y.label, startsWith('2026'));
    final last = viewPeriod(PeriodKind.yearly, 1, cycles: cycles);
    expect(last.end, d(1, 15));
    expect(last.label, startsWith('2025'));
  });

  test('a transaction dated after today moves the latest period forward', () {
    final p = viewPeriod(PeriodKind.daily, 0,
        cycles: cycles, latestActivity: d(11, 6));
    expect(p.start, d(11, 6));
  });
}
