import 'package:drift/drift.dart' show Value;

import '../database/database.dart';
import 'debt_matching.dart';

/// How far a transaction amount may differ from a fixed-amount rule — half a
/// baisa, rounding only (same as debts).
const categoryAmountTolerance = debtAmountTolerance;

/// Descriptions that name nobody in particular. A rule built from one would
/// match unrelated transactions, so such SMS are filed one by one instead.
const genericDescriptions = {'', 'payment', 'deposit'};

String _norm(String s) => s.trim().toLowerCase();

/// True when [t] has a merchant / recipient name a rule can be built from.
bool hasReusableName(Transaction t) =>
    t.source == TxSource.sms &&
    !genericDescriptions.contains(_norm(t.description));

/// True when [r] matches [t], ignoring exclusions and priority.
bool ruleMatches(CategoryRule r, Transaction t) {
  if (t.source != TxSource.sms) return false;
  if (r.sender.isNotEmpty && t.sender != r.sender) return false;
  if (r.isCredit != null && t.isCredit != r.isCredit) return false;
  final cp = _norm(r.counterparty);
  if (cp.isEmpty) return false;
  final desc = _norm(t.description);
  if (r.exact ? desc != cp : !desc.contains(cp)) return false;
  if (r.matchAmount &&
      (t.amount - r.amount).abs() > categoryAmountTolerance) {
    return false;
  }
  return true;
}

/// Higher wins: an amount-specific rule beats an any-amount one (so the same
/// recipient can feed different categories by amount), and an exact name
/// beats a "name contains" fragment.
int _rank(CategoryRule r) => (r.matchAmount ? 2 : 0) + (r.exact ? 1 : 0);

/// Decides which category each transaction is in. Order of precedence:
///
/// 1. filed by hand ([Transaction.categoryId]);
/// 2. an SMS confirmed as a debt payment is in no category — the debt owns
///    it (e.g. the fixed car transfer to a brother is not "House");
/// 3. the best-ranked matching rule whose category hasn't had this one
///    transaction removed; ties go to the older rule.
class CategoryResolver {
  CategoryResolver({
    required List<Category> categories,
    required List<CategoryRule> rules,
    required List<CategoryExclusion> exclusions,
    required List<DebtPayment> debtPayments,
  })  : _ids = {for (final c in categories) c.id},
        _debtTx = confirmedTransactionIds(debtPayments),
        _excluded = {
          for (final e in exclusions) (e.categoryId, e.transactionId),
        },
        _rules = [
          for (final r in rules)
            if (categories.any((c) => c.id == r.categoryId)) r,
        ]..sort((a, b) {
            final byRank = _rank(b).compareTo(_rank(a));
            return byRank != 0 ? byRank : a.id.compareTo(b.id);
          });

  final Set<int> _ids;
  final Set<int> _debtTx;
  final Set<(int, int)> _excluded;
  final List<CategoryRule> _rules;

  /// Loads everything the resolver needs from [db].
  static Future<CategoryResolver> load(AppDatabase db) async =>
      CategoryResolver(
        categories: await db.allCategories(),
        rules: await db.allCategoryRules(),
        exclusions: await db.allCategoryExclusions(),
        debtPayments: await db.allDebtPayments(),
      );

  bool isDebtPayment(Transaction t) => _debtTx.contains(t.id);

  bool isExcluded(int categoryId, Transaction t) =>
      _excluded.contains((categoryId, t.id));

  int? categoryIdFor(Transaction t) {
    final manual = t.categoryId;
    if (manual != null && _ids.contains(manual)) return manual;
    if (_debtTx.contains(t.id)) return null;
    for (final r in _rules) {
      if (_excluded.contains((r.categoryId, t.id))) continue;
      if (ruleMatches(r, t)) return r.categoryId;
    }
    return null;
  }
}

/// A rule copied from an example SMS: same bank, same merchant / recipient,
/// same direction. With [fixedAmount] only that exact amount matches.
CategoryRulesCompanion ruleFromTransaction(
  Transaction t, {
  bool fixedAmount = false,
}) =>
    CategoryRulesCompanion.insert(
      categoryId: 0, // set when saved
      sender: Value(t.sender),
      counterparty: t.description.trim(),
      exact: const Value(true),
      matchAmount: Value(fixedAmount),
      amount: Value(t.amount),
      isCredit: Value(t.isCredit),
    );

/// A typed shop name: any bank, money out, description contains [name].
CategoryRulesCompanion ruleFromShopName(String name) =>
    CategoryRulesCompanion.insert(
      categoryId: 0,
      counterparty: name.trim(),
      exact: const Value(false),
      isCredit: const Value(false),
    );

/// Files [t] (and, through a rule, every transaction like it) under [target]
/// from the Transactions tab. A generic SMS or a manual entry is filed alone.
/// For a named SMS an any-amount rule is added to [target], the same rule is
/// removed from other categories (a clean move) and any earlier removal of
/// [t] from [target] is undone. If a stronger rule elsewhere still wins, [t]
/// is pinned to [target] by hand so the tap always does what it says.
Future<void> fileTransactionToCategory(
  AppDatabase db,
  Transaction t,
  Category target,
) async {
  if (!hasReusableName(t)) {
    await db.setTransactionCategory(t.id, target.id);
    return;
  }
  final rule = ruleFromTransaction(t);
  final rules = await db.allCategoryRules();
  var present = false;
  for (final r in rules) {
    final same = r.sender == t.sender &&
        r.exact &&
        !r.matchAmount &&
        r.isCredit == t.isCredit &&
        _norm(r.counterparty) == _norm(t.description);
    if (!same) continue;
    if (r.categoryId == target.id) {
      present = true;
    } else {
      await db.deleteCategoryRule(r.id);
    }
  }
  if (!present) {
    await db.addCategoryRule(rule.copyWith(categoryId: Value(target.id)));
  }
  await db.restoreToCategory(target.id, t.id);
  if (t.categoryId != null) await db.setTransactionCategory(t.id, null);

  final fresh = (await db.transactionById(t.id))!;
  final resolver = await CategoryResolver.load(db);
  if (resolver.categoryIdFor(fresh) != target.id) {
    await db.setTransactionCategory(t.id, target.id);
  }
}

/// Takes just [t] out of categories from the Transactions tab: clears a
/// by-hand filing and records a removal for each category whose rule still
/// matches it, until it is uncategorised. The rules stay, so every other
/// matching transaction is unaffected.
Future<void> removeTransactionFromCategory(
  AppDatabase db,
  Transaction t,
) async {
  if (t.categoryId != null) await db.setTransactionCategory(t.id, null);
  final fresh = (await db.transactionById(t.id))!;
  final tried = <int>{};
  while (true) {
    final id = (await CategoryResolver.load(db)).categoryIdFor(fresh);
    if (id == null || !tried.add(id)) return;
    await db.excludeFromCategory(id, t.id);
  }
}
