import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/database.dart';
import '../theme.dart';

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

/// Percentage change in total balance versus the end of last month, or null
/// when there isn't enough history (no transactions before this month) to
/// compute a meaningful figure.
double? balanceDeltaPct(List<Transaction> txns) {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final prior = txns.where((t) => t.date.isBefore(monthStart)).toList();
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

/// A category's matching rules, decoded from its stored JSON fields.
class CategoryRules {
  CategoryRules(this.senderIds, this.shopNames);

  /// Bank sender ids this category draws from.
  final List<String> senderIds;

  /// senderId -> comma-separated shop-name fragments.
  final Map<String, String> shopNames;

  factory CategoryRules.of(Category c) {
    List<String> senders = const [];
    Map<String, String> shops = const {};
    try {
      senders = (jsonDecode(c.senderIds) as List).cast<String>();
    } catch (_) {}
    try {
      shops = (jsonDecode(c.shopNames) as Map)
          .map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {}
    return CategoryRules(senders, shops);
  }

  /// Encodes rules back into the two JSON strings the table stores.
  static (String, String) encode(
    List<String> senderIds,
    Map<String, String> shopNames,
  ) =>
      (jsonEncode(senderIds), jsonEncode(shopNames));

  /// True when [t] belongs to this category by the auto-matching rule:
  /// its sender is listed AND one of that sender's shop-name fragments appears
  /// in the transaction description.
  bool matches(Transaction t) {
    if (t.sender.isEmpty || !senderIds.contains(t.sender)) return false;
    final desc = t.description.toLowerCase();
    final fragments = (shopNames[t.sender] ?? '')
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty);
    return fragments.any((f) => desc.contains(f));
  }
}

/// Resolves the category a transaction belongs to: a manual assignment wins,
/// otherwise the first category whose auto-matching rule fits. Returns null
/// when nothing matches.
int? categoryIdFor(Transaction t, List<Category> categories) {
  if (t.categoryId != null) return t.categoryId;
  if (t.source != TxSource.sms) return null;
  for (final c in categories) {
    if (CategoryRules.of(c).matches(t)) return c.id;
  }
  return null;
}

const _genericNames = {'', 'payment', 'deposit'};

List<String> _fragments(String? csv) => (csv ?? '')
    .split(',')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

/// Files [t] under [target] by the merchant name, so EVERY transaction with
/// the same name (past and future) falls into the category — e.g. tapping one
/// "TALABAT" into Food captures all TALABAT charges.
///
/// For SMS transactions this adds the merchant as a shop-name rule on the
/// category (and removes it from any other category, a clean move). Manual
/// entries or generic descriptions ("Payment"/"Deposit") have no reusable
/// name, so they fall back to a single-row assignment.
Future<void> fileTransactionToCategory(
  AppDatabase db,
  Transaction t,
  Category target,
  List<Category> all,
) async {
  final merchant = t.description.trim();
  if (t.sender.isEmpty || _genericNames.contains(merchant.toLowerCase())) {
    await db.setTransactionCategory(t.id, target.id);
    return;
  }
  final ml = merchant.toLowerCase();

  for (final c in all) {
    final rules = CategoryRules.of(c);
    final isTarget = c.id == target.id;
    final relevant = rules.senderIds.contains(t.sender) || isTarget;
    if (!relevant) continue;

    final frags = _fragments(rules.shopNames[t.sender]);
    final kept = frags.where((f) => f.toLowerCase() != ml).toList();

    if (isTarget) {
      final senders = [...rules.senderIds];
      if (!senders.contains(t.sender)) senders.add(t.sender);
      kept.add(merchant); // ensure present exactly once
      final shops = {...rules.shopNames, t.sender: kept.join(', ')};
      final (sj, shj) = CategoryRules.encode(senders, shops);
      await db.updateCategory(c.copyWith(senderIds: sj, shopNames: shj));
    } else if (kept.length != frags.length) {
      final shops = {...rules.shopNames, t.sender: kept.join(', ')};
      final (sj, shj) = CategoryRules.encode(rules.senderIds, shops);
      await db.updateCategory(c.copyWith(senderIds: sj, shopNames: shj));
    }
  }

  // A stale manual override would shadow the new rule; clear it.
  if (t.categoryId != null) await db.setTransactionCategory(t.id, null);
}

/// Removes [t] from whatever category holds it: clears a manual assignment and
/// drops the merchant's shop-name rule (so all same-named transactions leave).
Future<void> unfileTransactionFromCategory(
  AppDatabase db,
  Transaction t,
  List<Category> all,
) async {
  if (t.categoryId != null) await db.setTransactionCategory(t.id, null);
  final merchant = t.description.trim();
  if (t.sender.isEmpty || merchant.isEmpty) return;
  final ml = merchant.toLowerCase();

  for (final c in all) {
    final rules = CategoryRules.of(c);
    if (!rules.senderIds.contains(t.sender)) continue;
    final frags = _fragments(rules.shopNames[t.sender]);
    final kept = frags.where((f) => f.toLowerCase() != ml).toList();
    if (kept.length != frags.length) {
      final shops = {...rules.shopNames, t.sender: kept.join(', ')};
      final (sj, shj) = CategoryRules.encode(rules.senderIds, shops);
      await db.updateCategory(c.copyWith(senderIds: sj, shopNames: shj));
    }
  }
}

String _titleCase(String s) => s
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');
