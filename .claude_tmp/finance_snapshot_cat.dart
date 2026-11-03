import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../services/category_matching.dart';
import '../services/pay_cycle.dart';
import '../theme.dart';
import '../widgets/category_resolver_builder.dart';
import '../widgets/ui.dart';

/// Categories tab: spending buckets filled automatically by rules picked from
/// example SMS (like fixed debts), with this month's spend per category.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

/// An editable copy of a [CategoryRule] while the editor is open.
class _DraftRule {
  _DraftRule({
    required this.sender,
    required this.counterparty,
    required this.exact,
    required this.matchAmount,
    required this.amount,
    required this.isCredit,
  });

  factory _DraftRule.of(CategoryRule r) => _DraftRule(
        sender: r.sender,
        counterparty: r.counterparty,
        exact: r.exact,
        matchAmount: r.matchAmount,
        amount: r.amount,
        isCredit: r.isCredit,
      );

  factory _DraftRule.fromCompanion(CategoryRulesCompanion c) => _DraftRule(
        sender: c.sender.present ? c.sender.value : '',
        counterparty: c.counterparty.value,
        exact: c.exact.present ? c.exact.value : true,
        matchAmount: c.matchAmount.present ? c.matchAmount.value : false,
        amount: c.amount.present ? c.amount.value : 0,
        isCredit: c.isCredit.present ? c.isCredit.value : null,
      );

  final String sender;
  final String counterparty;
  final bool exact;
  bool matchAmount;
  final double amount;
  final bool? isCredit;

  /// Rules with the same key are duplicates (across categories, a clean move).
  String get key => [
        sender,
        counterparty.trim().toLowerCase(),
        exact,
        matchAmount,
        if (matchAmount) amount.toStringAsFixed(3),
        isCredit,
      ].join('|');

  bool get canFixAmount => exact && amount > 0;

  CategoryRule asRule(int id, int categoryId) => CategoryRule(
        id: id,
        categoryId: categoryId,
        sender: sender,
        counterparty: counterparty,
        exact: exact,
        matchAmount: matchAmount,
        amount: amount,
        isCredit: isCredit,
      );

  CategoryRulesCompanion toCompanion(int categoryId) =>
      CategoryRulesCompanion.insert(
        categoryId: categoryId,
        sender: Value(sender),
        counterparty: counterparty,
        exact: Value(exact),
        matchAmount: Value(matchAmount),
        amount: Value(amount),
        isCredit: Value(isCredit),
      );
}

/// Stand-in id for a category that isn't saved yet (preview only).
const _newCategoryId = -1;

/// Draft rules sort after every saved rule on ties, as they will once saved.
const _draftRuleIdBase = 1 << 40;

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _editing = false;

  /// How many months back from the most recent activity to show (0 = latest).
  int _monthOffset = 0;

  final _name = TextEditingController();
  final _shopName = TextEditingController();
  Category? _existing;
  final List<_DraftRule> _rules = [];

  /// Transactions removed from this category (one at a time).
  final Set<int> _removed = {};

  /// SMS without a reusable name (e.g. "Payment") picked as examples: these
  /// are filed into the category one by one on save.
  final Set<int> _pinned = {};

  // Created once so typing in the editor doesn't resubscribe (and flash).
  final _categoryStream = db.watchCategories();
  final _ruleStream = db.watchCategoryRules();
  final _exclusionStream = db.watchCategoryExclusions();
  final _paymentStream = db.watchDebtPayments();
  final _txStream = db.watchTransactions();

  @override
  void dispose() {
    _name.dispose();
    _shopName.dispose();
    super.dispose();
  }

  int get _draftId => _existing?.id ?? _newCategoryId;

  Future<void> _startAdd() async {
    _reset();
    setState(() => _editing = true);
  }

  Future<void> _startEdit(Category c) async {
    _reset();
    final rules = await db.allCategoryRules();
    final exclusions = await db.allCategoryExclusions();
    if (!mounted) return;
    setState(() {
      _existing = c;
      _name.text = c.name;
      _rules.addAll(
          rules.where((r) => r.categoryId == c.id).map(_DraftRule.of));
      _removed.addAll(exclusions
          .where((e) => e.categoryId == c.id)
          .map((e) => e.transactionId));
      _editing = true;
    });
  }

  void _reset() {
    _existing = null;
    _name.clear();
    _shopName.clear();
    _rules.clear();
    _removed.clear();
    _pinned.clear();
  }

  void _cancel() {
    _reset();
    setState(() => _editing = false);
  }

  void _toast(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pickSms() async {
    final picked = await showModalBottomSheet<List<Transaction>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.screen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: const _CategorySmsPicker(),
      ),
    );
    if (picked == null || picked.isEmpty) return;
    setState(() {
      for (final t in picked) {
        _removed.remove(t.id);
        if (!hasReusableName(t)) {
          _pinned.add(t.id);
          continue;
        }
        final rule = _DraftRule.fromCompanion(ruleFromTransaction(t));
        if (_rules.every((r) => r.key != rule.key)) _rules.add(rule);
      }
    });
  }

  void _addShopName() {
    final name = _shopName.text.trim();
    if (name.isEmpty) return;
    final rule = _DraftRule.fromCompanion(ruleFromShopName(name));
    setState(() {
      if (_rules.every((r) => r.key != rule.key)) _rules.add(rule);
      _shopName.clear();
    });
  }

  Future<void> _saveCategory() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _toast('Give the category a name first.');
      return;
    }
    final int id;
    final existing = _existing;
    if (existing != null) {
      id = existing.id;
      await db.updateCategory(existing.copyWith(name: name));
    } else {
      final count = (await db.allCategories()).length;
      final color =
          '#${AppColors.paletteAt(count).toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      id = await db.addCategory(CategoriesCompanion.insert(
        name: name,
        color: Value(color),
      ));
    }

    // A rule lives in one category: picking the same SMS rule here moves it.
    final keys = {for (final r in _rules) r.key};
    for (final r in await db.allCategoryRules()) {
      if (r.categoryId != id && keys.contains(_DraftRule.of(r).key)) {
        await db.deleteCategoryRule(r.id);
      }
    }
    await db.replaceCategoryRules(
        id, [for (final r in _rules) r.toCompanion(id)]);

    final before = {
      for (final e in await db.allCategoryExclusions())
        if (e.categoryId == id) e.transactionId,
    };
    for (final txId in _removed.difference(before)) {
      await db.excludeFromCategory(id, txId);
    }
    for (final txId in before.difference(_removed)) {
      await db.restoreToCategory(id, txId);
    }
    for (final txId in _pinned) {
      await db.setTransactionCategory(txId, id);
    }
    for (final txId in _removed) {
      final t = await db.transactionById(txId);
      if (t != null && t.categoryId == id) {
        await db.setTransactionCategory(txId, null);
      }
    }
    _cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: _editing ? _editor() : _listView(),
    );
  }

  // ---- List view ---------------------------------------------------------
  Widget _listView() {
    return CategoryResolverBuilder(
      builder: (context, categories, resolver) {
        return StreamBuilder<List<CategoryRule>>(
          stream: _ruleStream,
          builder: (context, ruleSnap) {
            return StreamBuilder<List<Transaction>>(
              stream: _txStream,
              builder: (context, txSnap) {
                final txns = txSnap.data ?? const [];
                return _CategoriesList(
                  categories: categories,
                  rules: ruleSnap.data ?? const [],
                  resolver: resolver,
                  txns: txns,
                  monthOffset: _monthOffset,
                  onStepMonth: (delta) => setState(() =>
                      _monthOffset = (_monthOffset + delta).clamp(0, 120)),
                  onAdd: _startAdd,
                  onEdit: _startEdit,
                );
              },
            );
          },
        );
      },
    );
  }

  // ---- Editor ------------------------------------------------------------
  Widget _editor() {
    return StreamBuilder<List<CategoryRule>>(
      stream: _ruleStream,
      builder: (context, ruleSnap) => StreamBuilder<List<CategoryExclusion>>(
        stream: _exclusionStream,
        builder: (context, exclSnap) => StreamBuilder<List<Category>>(
          stream: _categoryStream,
          builder: (context, catSnap) => StreamBuilder<List<DebtPayment>>(
            stream: _paymentStream,
            builder: (context, paySnap) => StreamBuilder<List<Transaction>>(
              stream: _txStream,
              builder: (context, txSnap) => _editorBody(
                categories: catSnap.data ?? const [],
                rules: ruleSnap.data ?? const [],
                exclusions: exclSnap.data ?? const [],
                payments: paySnap.data ?? const [],
                txns: txSnap.data ?? const [],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editorBody({
    required List<Category> categories,
    required List<CategoryRule> rules,
    required List<CategoryExclusion> exclusions,
    required List<DebtPayment> payments,
    required List<Transaction> txns,
  }) {
    final draftId = _draftId;
    // Preview with the draft in place of this category's saved state.
    final resolver = CategoryResolver(
      categories: [
        ...categories.where((c) => c.id != draftId),
        Category(
          id: draftId,
          name: _name.text,
          color: '#000000',
          senderIds: '[]',
          shopNames: '{}',
        ),
      ],
      rules: [
        ...rules.where((r) => r.categoryId != draftId),
        for (var i = 0; i < _rules.length; i++)
          _rules[i].asRule(_draftRuleIdBase + i, draftId),
      ],
      exclusions: [
        ...exclusions.where((e) => e.categoryId != draftId),
        for (final txId in _removed)
          CategoryExclusion(id: 0, categoryId: draftId, transactionId: txId),
      ],
      debtPayments: payments,
    );
    final matched = <Transaction>[];
    final removed = <Transaction>[];
    for (final t in txns) {
      if (_removed.contains(t.id)) {
        removed.add(t);
      } else if (_pinned.contains(t.id) ||
          resolver.categoryIdFor(t) == draftId) {
        matched.add(t);
      }
    }
    const shown = 60;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _FlowHeader(
          title: _existing == null ? 'New category' : 'Edit category',
          onBack: _cancel,
        ),
        const SizedBox(height: 18),
        const Text('Category name',
            style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          autofocus: _existing == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: _decoration('e.g. Groceries'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        const Text('Matching SMS',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
        const SizedBox(height: 4),
        const Text(
          'Pick example SMS. Every past and future SMS to the same shop or '
          'person files here automatically. Turn on "Only this amount" when '
          'the same person gets money for different things.',
          style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 12),
        if (_rules.isNotEmpty)
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _rules.length; i++)
                  _RuleRow(
                    rule: _rules[i],
                    showDivider: i != _rules.length - 1,
                    onToggleAmount: () => setState(
                        () => _rules[i].matchAmount = !_rules[i].matchAmount),
                    onDelete: () => setState(() => _rules.removeAt(i)),
                  ),
              ],
            ),
          ),
        if (_rules.isNotEmpty) const SizedBox(height: 10),
        _OutlineAction(
          icon: Icons.sms_outlined,
          label: 'Pick example SMS',
          onTap: _pickSms,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _shopName,
                decoration: _decoration('Or type a shop name'),
                onSubmitted: (_) => _addShopName(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addShopName,
              style: IconButton.styleFrom(backgroundColor: AppColors.green),
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('In this category (${matched.length})',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
        const SizedBox(height: 4),
        const Text(
          'Tap ✕ to take out just that one transaction. SMS counted as a debt '
          'payment stay with the debt.',
          style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 10),
        if (matched.isEmpty)
          const EmptyHint('Nothing matches yet.')
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < matched.length && i < shown; i++)
                  _TxPreviewRow(
                    txn: matched[i],
                    showDivider: i != matched.length - 1 && i != shown - 1,
                    actionIcon: Icons.close,
                    actionTooltip: 'Remove from this category',
                    onAction: () => setState(() {
                      _pinned.remove(matched[i].id);
                      _removed.add(matched[i].id);
                    }),
                  ),
                if (matched.length > shown)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('and ${matched.length - shown} more',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.faint)),
                  ),
              ],
            ),
          ),
        if (removed.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Removed (${removed.length})',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < removed.length; i++)
                  _TxPreviewRow(
                    txn: removed[i],
                    showDivider: i != removed.length - 1,
                    actionIcon: Icons.undo,
                    actionTooltip: 'Put back',
                    onAction: () =>
                        setState(() => _removed.remove(removed[i].id)),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        _GreenButton(label: 'Save', onTap: _saveCategory),
        if (_existing != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              await db.deleteCategory(_existing!.id);
              _cancel();
            },
            child: const Text('Delete category',
                style: TextStyle(color: AppColors.terracotta)),
          ),
        ],
      ],
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x261E2E2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x261E2E2A)),
        ),
      );
}

// ---------------------------------------------------------------------------

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({
    required this.categories,
    required this.rules,
    required this.resolver,
    required this.txns,
    required this.monthOffset,
    required this.onStepMonth,
    required this.onAdd,
    required this.onEdit,
  });

  final List<Category> categories;
  final List<CategoryRule> rules;
  final CategoryResolver resolver;
  final List<Transaction> txns;
  final int monthOffset;
  final ValueChanged<int> onStepMonth;
  final VoidCallback onAdd;
  final ValueChanged<Category> onEdit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Months run salary to salary (see PayCycles). Base the view on the
    // current cycle, or a later one if a transaction is dated after it.
    // [monthOffset] steps back one cycle at a time.
    final cycles = PayCycles.fromTransactions(txns);
    var base = cycles.current;
    for (final t in txns) {
      if (!t.date.isBefore(base.end)) base = cycles.cycleFor(t.date);
    }
    final period = cycles.shift(base, -monthOffset);

    // Every expense this month lands in exactly one bucket: a category, the
    // debts (confirmed debt payments), or Unknown (everything else).
    final spent = <int, double>{};
    final unknown = <Transaction>[];
    var unknownTotal = 0.0;
    var debtTotal = 0.0;
    var income = 0.0;
    for (final t in txns) {
      if (!period.contains(t.date)) continue;
      if (t.isCredit) {
        income += t.amount;
        continue;
      }
      final id = resolver.categoryIdFor(t);
      if (id != null) {
        spent[id] = (spent[id] ?? 0) + t.amount;
      } else if (resolver.isDebtPayment(t)) {
        debtTotal += t.amount;
      } else {
        unknown.add(t);
        unknownTotal += t.amount;
      }
    }
    final total = spent.values.fold<double>(0, (s, v) => s + v) +
        unknownTotal +
        debtTotal;
    final remaining = income - total;

    final slices = <_PieSlice>[
      for (final c in categories)
        if ((spent[c.id] ?? 0) > 0)
          _PieSlice(c.name, spent[c.id]!, hexColor(c.color)),
      if (unknownTotal > 0)
        _PieSlice(_unknownName, unknownTotal, _unknownColor),
      if (debtTotal > 0)
        _PieSlice('Debt payments', debtTotal, AppColors.peach),
      if (remaining > 0)
        _PieSlice('Remaining income', remaining, AppColors.mint),
    ];
    final periodLabel = period.start.year == now.year
        ? period.label(now: now)
        : '${period.label(now: now)} ${period.start.year}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Categories',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DarkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MutedCaps('Spent · $periodLabel', color: Colors.white54),
                  Row(
                    children: [
                      _StepArrow(
                        icon: Icons.chevron_left,
                        onTap: () => onStepMonth(1), // older
                      ),
                      const SizedBox(width: 4),
                      _StepArrow(
                        icon: Icons.chevron_right,
                        // Can't go newer than the latest activity month.
                        onTap: monthOffset == 0 ? null : () => onStepMonth(-1),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SerifAmount(money(total),
                  size: 32, color: Colors.white, weight: FontWeight.w500),
              const SizedBox(height: 8),
              Text(
                  'Income ${money(income)} · '
                  '${remaining >= 0 ? 'left ${money(remaining)}' : 'over by ${money(-remaining)}'}',
                  style: const TextStyle(fontSize: 12, color: Colors.white54)),
              if (slices.isNotEmpty) ...[
                const SizedBox(height: 18),
                _SpendingPie(
                  slices: slices,
                  // Out of income, or out of spending when spending is more.
                  whole: math.max(income, total),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final c in categories) ...[
          _CategoryCard(
            category: c,
            rules: [
              for (final r in rules)
                if (r.categoryId == c.id) r,
            ],
            spent: spent[c.id] ?? 0,
            sharePct: total <= 0 ? 0 : ((spent[c.id] ?? 0) / total * 100),
            onTap: () => onEdit(c),
          ),
          const SizedBox(height: 12),
        ],
        _CategoryCard(
          category: const Category(
            id: _unknownCategoryId,
            name: _unknownName,
            color: '#B7C0BA',
            senderIds: '[]',
            shopNames: '{}',
          ),
          rules: const [],
          spent: unknownTotal,
          sharePct: total <= 0 ? 0 : (unknownTotal / total * 100),
          subtitle: unknown.isEmpty
              ? 'Every expense has a category'
              : '${unknown.length} expenses without a category',
          actionLabel: 'View ›',
          onTap: () => _showUnknown(context, unknown, periodLabel),
        ),
        if (categories.isEmpty)
          const EmptyHint(
            'Tap + and pick example SMS to create your first category.',
          ),
      ],
    );
  }

  void _showUnknown(
      BuildContext context, List<Transaction> txns, String periodLabel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.screen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: _UnknownSheet(
          txns: txns,
          categories: categories,
          periodLabel: periodLabel,
        ),
      ),
    );
  }
}

/// The Unknown list: each expense can be given a category from here. Filing
/// a named SMS adds a rule, so others like it leave Unknown too.
class _UnknownSheet extends StatefulWidget {
  const _UnknownSheet({
    required this.txns,
    required this.categories,
    required this.periodLabel,
  });

  final List<Transaction> txns;
  final List<Category> categories;
  final String periodLabel;

  @override
  State<_UnknownSheet> createState() => _UnknownSheetState();
}

class _UnknownSheetState extends State<_UnknownSheet> {
  late List<Transaction> _txns = [...widget.txns]
    ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> _assign(Transaction t) async {
    final picked = await showModalBottomSheet<Category>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.screen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CategoryChoiceSheet(
        txn: t,
        categories: widget.categories,
      ),
    );
    if (picked == null) return;
    await fileTransactionToCategory(db, t, picked);

    // Drop everything that now has a home (the new rule may catch others).
    final resolver = await CategoryResolver.load(db);
    final fresh = {for (final x in await db.allTransactions()) x.id: x};
    if (!mounted) return;
    final before = _txns.length;
    setState(() {
      _txns = [
        for (final x in _txns)
          if (fresh[x.id] != null &&
              resolver.categoryIdFor(fresh[x.id]!) == null)
            fresh[x.id]!,
      ];
    });
    final moved = before - _txns.length;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(moved > 1
            ? 'Moved $moved expenses to ${picked.name}.'
            : 'Moved to ${picked.name}.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$_unknownName · ${widget.periodLabel}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text(
            'Expenses no category picked up. Tap Assign to give one a '
            'category; others from the same shop or person move with it.',
            style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: _txns.isEmpty
                ? const EmptyHint('Nothing left here this month.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _txns.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.cardBorder),
                    itemBuilder: (context, i) {
                      final t = _txns[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.description.isEmpty
                                        ? 'Payment'
                                        : t.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink),
                                  ),
                                  Text(
                                    [
                                      shortDate(t.date),
                                      if (t.card.isNotEmpty) '••••${t.card}',
                                      money(t.amount),
                                    ].join(' · '),
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _assign(t),
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: const Color(0x261E2E2A)),
                                ),
                                child: const Text('Assign',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.green)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Pick a category for one Unknown expense. Pops with the chosen category.
class _CategoryChoiceSheet extends StatelessWidget {
  const _CategoryChoiceSheet({required this.txn, required this.categories});

  final Transaction txn;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final title = txn.description.isEmpty ? 'Payment' : txn.description;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assign "$title"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(
            hasReusableName(txn)
                ? 'Every "$title" expense will go to this category.'
                : 'Only this one expense moves.',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          if (categories.isEmpty)
            const EmptyHint(
                'No categories yet. Close this and tap + to create one.')
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in categories)
                    InkWell(
                      onTap: () => Navigator.pop(context, c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.cardBorder)),
                        ),
                        child: Row(
                          children: [
                            Dot(hexColor(c.color), size: 9),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(c.name,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The built-in catch-all bucket: every expense that no category, and no
/// debt, claims. It isn't stored; it's worked out each time.
const _unknownName = 'Unknown';
const _unknownCategoryId = -2;
const _unknownColor = AppColors.inactive;

class _PieSlice {
  const _PieSlice(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

/// Donut of where this month's money went, with a legend beside it.
class _SpendingPie extends StatelessWidget {
  const _SpendingPie({required this.slices, required this.whole});

  final List<_PieSlice> slices;

  /// What 100% means (income, or spending if spending is larger).
  final double whole;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: CustomPaint(painter: _DonutPainter(slices)),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in slices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Dot(s.color, size: 8),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ),
                      Text(
                          whole <= 0
                              ? ''
                              : '${(s.value / whole * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices);

  final List<_PieSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (s, x) => s + x.value);
    if (total <= 0) return;
    const stroke = 16.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: math.min(size.width, size.height) / 2 - stroke / 2,
    );
    // A hairline gap between slices so neighbours stay distinct.
    final gap = slices.length > 1 ? 0.03 : 0.0;
    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = s.value / total * 2 * math.pi;
      if (sweep > gap) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep - gap,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = s.color,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.slices != slices;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.rules,
    required this.spent,
    required this.sharePct,
    required this.onTap,
    this.subtitle,
    this.actionLabel = 'Edit ›',
  });

  final Category category;
  final List<CategoryRule> rules;
  final double spent;

  /// This category's share of all spending this month, 0–100. The bar shows it.
  final double sharePct;
  final VoidCallback onTap;

  /// Replaces the list of shops under the bar.
  final String? subtitle;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final color = hexColor(category.color);
    final shops = {for (final r in rules) r.counterparty.trim()}.join(', ');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Dot(color),
                  const SizedBox(width: 10),
                  Text(category.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                ],
              ),
              SerifAmount(money(spent), size: 17),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(fraction: sharePct / 100, color: color),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subtitle ?? (shops.isEmpty ? 'No SMS picked yet' : shops),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              Text('${sharePct.round()}% of spending · $actionLabel',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.faint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowHeader extends StatelessWidget {
  const _FlowHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.ink),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}

/// A small circular ‹ / › month-stepper button used on the Categories hero.
class _StepArrow extends StatelessWidget {
  const _StepArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.12 : 0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 18,
            color: Colors.white.withValues(alpha: enabled ? 0.85 : 0.3)),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  const _GreenButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small centred hint used for empty states inside the Categories flow.
class EmptyHint extends StatelessWidget {
  const EmptyHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: AppColors.faint),
      ),
    );
  }
}

/// One rule in the editor: who it matches, and the "any amount" toggle.
class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.rule,
    required this.showDivider,
    required this.onToggleAmount,
    required this.onDelete,
  });

  final _DraftRule rule;
  final bool showDivider;
  final VoidCallback onToggleAmount;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final details = [
      rule.sender.isEmpty ? 'Any bank' : rule.sender,
      if (rule.isCredit == true) 'money in',
      if (rule.isCredit == false) 'money out',
      if (!rule.exact) 'name contains',
    ].join(' · ');
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.cardBorder))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.counterparty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(details,
                    style:
                        const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                if (rule.canFixAmount) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onToggleAmount,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: rule.matchAmount
                            ? AppColors.green
                            : AppColors.screen,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: rule.matchAmount
                                ? AppColors.green
                                : const Color(0x261E2E2A)),
                      ),
                      child: Text(
                        rule.matchAmount
                            ? 'Only ${money(rule.amount)}'
                            : 'Any amount · tap for only ${money(rule.amount)}',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: rule.matchAmount
                                ? Colors.white
                                : AppColors.ink),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete rule',
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 18, color: AppColors.faint),
          ),
        ],
      ),
    );
  }
}

/// A transaction in the editor's preview, with one action (remove / undo).
class _TxPreviewRow extends StatelessWidget {
  const _TxPreviewRow({
    required this.txn,
    required this.showDivider,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onAction,
  });

  final Transaction txn;
  final bool showDivider;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.cardBorder))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description.isEmpty ? 'Payment' : txn.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink),
                ),
                Text(
                  [
                    shortDate(txn.date),
                    if (txn.card.isNotEmpty) '••••${txn.card}',
                  ].join(' · '),
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text('${txn.isCredit ? '+' : ''}${money(txn.amount)}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          IconButton(
            tooltip: actionTooltip,
            onPressed: onAction,
            icon: Icon(actionIcon, size: 18, color: AppColors.faint),
          ),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0x261E2E2A)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

/// Lets the user tick example bank SMS for a category, newest first. SMS
/// already counted as a debt payment are left out (the debt owns them).
class _CategorySmsPicker extends StatefulWidget {
  const _CategorySmsPicker();

  @override
  State<_CategorySmsPicker> createState() => _CategorySmsPickerState();
}

class _CategorySmsPickerState extends State<_CategorySmsPicker> {
  final Set<int> _selected = {};
  String _query = '';
  List<Transaction>? _txns;

  @override
  void initState() {
    super.initState();
    () async {
      final all = await db.allTransactions();
      final resolver = await CategoryResolver.load(db);
      if (!mounted) return;
      setState(() {
        _txns = all
            .where((t) => t.source == TxSource.sms)
            .where((t) => !resolver.isDebtPayment(t))
            .toList();
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final visible = (_txns ?? const <Transaction>[])
        .where((t) =>
            q.isEmpty ||
            t.description.toLowerCase().contains(q) ||
            amountText(t.amount).contains(q))
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pick example SMS',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text(
              'One per shop or person is enough; the rest are found for you.',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search name or amount',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0x261E2E2A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0x261E2E2A)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: _txns == null
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                    ? const EmptyHint('No matching bank SMS.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: visible.length,
                        itemBuilder: (context, i) {
                          final t = visible[i];
                          return CheckboxListTile(
                            value: _selected.contains(t.id),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.green,
                            onChanged: (v) => setState(() {
                              v == true
                                  ? _selected.add(t.id)
                                  : _selected.remove(t.id);
                            }),
                            title: Text(
                              t.description.isEmpty ? 'Payment' : t.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              [
                                shortDate(t.date),
                                if (t.card.isNotEmpty) '••••${t.card}',
                              ].join(' · '),
                              style: const TextStyle(fontSize: 11),
                            ),
                            secondary: Text(
                                '${t.isCredit ? '+' : ''}${money(t.amount)}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 12),
          _GreenButton(
            label: _selected.isEmpty ? 'Done' : 'Use ${_selected.length} SMS',
            onTap: () {
              final all = _txns ?? const <Transaction>[];
              Navigator.pop(
                context,
                all.where((t) => _selected.contains(t.id)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
