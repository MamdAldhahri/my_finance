import 'package:flutter/material.dart';

import '../database/database.dart';
import '../theme.dart';
import 'pay_cycle.dart';

/// A bank account inferred from SMS: one per distinct account/card number,
/// carrying the balance from that number's most recent alert.
class Account {
  Account({
    required this.card,
    required this.sender,
    required this.balance,
    required this.color,
  });

  /// Last 4 digits of the account/card number.
  final String card;

  /// Bank sender the alerts came from, e.g. "bank muscat".
  final String sender;

  /// Balance from the most recent SMS for this account.
  final double balance;
  final Color color;

  /// Human label like "Bank Muscat ••••0001".
  String get label {
    final bank = _titleCase(sender);
    return card.isEmpty ? bank : '$bank ••••$card';
  }
}

/// Derives per-account balances from [txns].
///
/// Each distinct card (last 4) becomes one account, its balance taken from the
/// most recent SMS transaction that reported one. [txns] may be in any order.
List<Account> deriveAccounts(List<Transaction> txns) {
  final latest = <String, Transaction>{};
  for (final t in txns) {
    if (t.source != TxSource.sms) continue;
    if (t.card.isEmpty || t.balanceAfter == null) continue;
    final current = latest[t.card];
    if (current == null || _isNewer(t, current)) latest[t.card] = t;
  }

  final cards = latest.keys.toList()..sort();
  return [
    for (var i = 0; i < cards.length; i++)
      Account(
        card: cards[i],
        sender: latest[cards[i]]!.sender,
        balance: latest[cards[i]]!.balanceAfter!,
        color: AppColors.paletteAt(i),
      ),
  ];
}

/// Total across all derived accounts.
double totalBalance(List<Transaction> txns) =>
    deriveAccounts(txns).fold(0.0, (s, a) => s + a.balance);

/// Percentage change in total balance versus the end of the last salary
/// cycle (the day before payday), or null when there isn't enough history
/// (no transactions before this cycle) to compute a meaningful figure.
double? balanceDeltaPct(List<Transaction> txns) {
  final cycleStart = PayCycles.fromTransactions(txns).current.start;
  final prior = txns.where((t) => t.date.isBefore(cycleStart)).toList();
  if (prior.isEmpty) return null;
  final prev = totalBalance(prior);
  if (prev <= 0) return null;
  return (totalBalance(txns) - prev) / prev * 100;
}

bool _isNewer(Transaction a, Transaction b) {
  final byDate = a.date.compareTo(b.date);
  if (byDate != 0) return byDate > 0;
  return a.id > b.id; // same instant: later-inserted row wins
}

String _titleCase(String s) => s
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');
