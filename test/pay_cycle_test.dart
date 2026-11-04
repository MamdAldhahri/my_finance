import 'package:flutter_test/flutter_test.dart';

import 'package:finance/services/pay_cycle.dart';

void main() {
  DateTime d(int m, int day, [int y = 2026]) => DateTime(y, m, day);

  test('cycle starts on the day the salary actually landed', () {
    final c = PayCycles([d(9, 15), d(10, 16), d(11, 15)], now: d(11, 20));
    expect(c.cycleFor(d(10, 15)), PayCycle(d(9, 15), d(10, 16)));
    expect(c.cycleFor(d(10, 16)), PayCycle(d(10, 16), d(11, 15)));
    expect(c.current, PayCycle(d(11, 15), d(12, 19)));
  });

  test('before this month\'s salary arrives, today is still last cycle', () {
    // Salary usually on the 15th; it's the 16th and nothing has landed yet.
    final c = PayCycles([d(10, 15)], now: d(11, 16, 2026).add(
        const Duration(hours: 9)));
    expect(c.current.start, d(10, 15));
    expect(c.current.contains(d(11, 16)), isTrue);
  });

  test('falls back to the pay day once the window passes with no salary', () {
    final c = PayCycles(const [], now: d(11, 25));
    expect(c.current, PayCycle(d(11, 15), d(12, 19)));
    expect(c.cycleFor(d(11, 14)).start, d(10, 15));
  });

  test('early salary (before a weekend) still starts the cycle', () {
    final c = PayCycles([d(11, 13)], now: d(11, 20));
    expect(c.current.start, d(11, 13));
    expect(c.cycleFor(d(11, 12)).end, d(11, 13));
  });

  test('shift steps whole cycles, across the year boundary', () {
    final c = PayCycles([d(12, 16, 2025), d(1, 15), d(2, 16)], now: d(2, 20));
    final jan = c.shift(c.current, -1);
    expect(jan, PayCycle(d(1, 15), d(2, 16)));
    expect(c.shift(jan, -1), PayCycle(d(12, 16, 2025), d(1, 15)));
  });

  test('labels', () {
    final c = PayCycles([d(10, 16), d(11, 15)], now: d(11, 20));
    expect(c.current.label(now: d(11, 20)), 'Since 15 Nov');
    expect(c.shift(c.current, -1).label(now: d(11, 20)), '16 Oct – 14 Nov');
  });
}
