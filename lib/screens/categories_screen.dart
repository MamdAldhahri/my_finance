import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../services/derive.dart';
import '../services/sms_import.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Categories tab: define spending buckets from bank chats + shop names, and
/// see this month's spend per category.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

enum _Step { list, name, senders }

class _CategoriesScreenState extends State<CategoriesScreen> {
  _Step _step = _Step.list;

  /// How many months back from the most recent activity to show (0 = latest).
  int _monthOffset = 0;

  final _name = TextEditingController();
  int? _editingId;
  final Set<String> _senderIds = {};
  final Map<String, TextEditingController> _shopControllers = {};

  Future<List<SmsSender>>? _confirmedSenders;

  @override
  void dispose() {
    _name.dispose();
    for (final c in _shopControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startAdd() {
    _reset();
    setState(() => _step = _Step.name);
  }

  void _startEdit(Category c) {
    _reset();
    final rules = CategoryRules.of(c);
    _editingId = c.id;
    _name.text = c.name;
    _senderIds.addAll(rules.senderIds);
    for (final id in rules.senderIds) {
      _shopControllers[id] =
          TextEditingController(text: rules.shopNames[id] ?? '');
    }
    _confirmedSenders = _loadConfirmed();
    setState(() => _step = _Step.senders);
  }

  void _reset() {
    _editingId = null;
    _name.clear();
    _senderIds.clear();
    for (final c in _shopControllers.values) {
      c.dispose();
    }
    _shopControllers.clear();
  }

  void _cancel() {
    _reset();
    setState(() => _step = _Step.list);
  }

  Future<List<SmsSender>> _loadConfirmed() async {
    final ids = await db.getBankSenders();
    final inbox = await smsImport.inboxSenders();
    final byAddress = {for (final s in inbox) s.address: s};
    return [
      for (final id in ids)
        byAddress[id] ?? SmsSender(address: id, sample: '', count: 0),
    ];
  }

  Future<void> _saveCategory() async {
    final shopNames = <String, String>{
      for (final id in _senderIds) id: _shopControllers[id]?.text.trim() ?? '',
    };
    final (sendersJson, shopsJson) =
        CategoryRules.encode(_senderIds.toList(), shopNames);

    if (_editingId != null) {
      final existing =
          (await db.allCategories()).firstWhere((c) => c.id == _editingId);
      await db.updateCategory(existing.copyWith(
        name: _name.text.trim(),
        senderIds: sendersJson,
        shopNames: shopsJson,
      ));
    } else {
      final count = (await db.allCategories()).length;
      final color =
          '#${AppColors.paletteAt(count).toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      await db.addCategory(CategoriesCompanion.insert(
        name: _name.text.trim(),
        color: Value(color),
        senderIds: Value(sendersJson),
        shopNames: Value(shopsJson),
      ));
    }
    _cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: switch (_step) {
        _Step.list => _listView(),
        _Step.name => _nameStep(),
        _Step.senders => _sendersStep(),
      },
    );
  }

  // ---- List view ---------------------------------------------------------
  Widget _listView() {
    return StreamBuilder<List<Category>>(
      stream: db.watchCategories(),
      builder: (context, catSnap) {
        final categories = catSnap.data ?? const [];
        return StreamBuilder<List<Transaction>>(
          stream: db.watchTransactions(),
          builder: (context, txSnap) {
            final txns = txSnap.data ?? const [];
            return _CategoriesList(
              categories: categories,
              txns: txns,
              monthOffset: _monthOffset,
              onStepMonth: (delta) =>
                  setState(() => _monthOffset = (_monthOffset + delta).clamp(0, 120)),
              onAdd: _startAdd,
              onEdit: _startEdit,
            );
          },
        );
      },
    );
  }

  // ---- Name step ---------------------------------------------------------
  Widget _nameStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FlowHeader(title: 'New category', onBack: _cancel),
          const SizedBox(height: 22),
          const Text('Category name',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration('e.g. Groceries'),
            onSubmitted: (_) => _nameNext(),
          ),
          const SizedBox(height: 20),
          _GreenButton(label: 'Next', onTap: _nameNext),
        ],
      ),
    );
  }

  void _nameNext() {
    if (_name.text.trim().isEmpty) return;
    _confirmedSenders = _loadConfirmed();
    setState(() => _step = _Step.senders);
  }

  // ---- Senders step ------------------------------------------------------
  Widget _sendersStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FlowHeader(
            title: _name.text.trim().isEmpty ? 'Category' : _name.text.trim(),
            onBack: () {
              if (_editingId != null) {
                _cancel();
              } else {
                setState(() => _step = _Step.name);
              }
            },
          ),
          const SizedBox(height: 6),
          const Text('Pick from your confirmed bank chats.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 14),
          Expanded(
            child: FutureBuilder<List<SmsSender>>(
              future: _confirmedSenders,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final senders = snap.data ?? const [];
                if (senders.isEmpty) {
                  return const EmptyHint(
                    'No confirmed bank chats yet. Open the Transactions tab, '
                    'tap the gear, and pick your bank first.',
                  );
                }
                return ListView(
                  children: [
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < senders.length; i++)
                            _DraftSenderTile(
                              sender: senders[i],
                              checked: _senderIds.contains(senders[i].address),
                              controller:
                                  _shopControllers[senders[i].address],
                              showDivider: i != senders.length - 1,
                              onToggle: () => _toggleSender(senders[i].address),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GreenButton(label: 'Save', onTap: _saveCategory),
                    if (_editingId != null) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () async {
                          await db.deleteCategory(_editingId!);
                          _cancel();
                        },
                        child: const Text('Delete category',
                            style: TextStyle(color: AppColors.terracotta)),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSender(String id) {
    setState(() {
      if (_senderIds.contains(id)) {
        _senderIds.remove(id);
      } else {
        _senderIds.add(id);
        _shopControllers.putIfAbsent(id, () => TextEditingController());
      }
    });
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
    required this.txns,
    required this.monthOffset,
    required this.onStepMonth,
    required this.onAdd,
    required this.onEdit,
  });

  final List<Category> categories;
  final List<Transaction> txns;
  final int monthOffset;
  final ValueChanged<int> onStepMonth;
  final VoidCallback onAdd;
  final ValueChanged<Category> onEdit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Base the view on the most recent transaction month (so freshly imported
    // or assigned transactions are visible immediately), not always "now" —
    // imported SMS are often dated in earlier months. [monthOffset] steps back.
    DateTime base = DateTime(now.year, now.month);
    for (final t in txns) {
      final m = DateTime(t.date.year, t.date.month);
      if (m.isAfter(base)) base = m;
    }
    final period = DateTime(base.year, base.month - monthOffset);

    final spent = <int, double>{};
    for (final t in txns) {
      if (t.isCredit) continue;
      if (t.date.year != period.year || t.date.month != period.month) continue;
      final id = categoryIdFor(t, categories);
      if (id != null) spent[id] = (spent[id] ?? 0) + t.amount;
    }
    final total = spent.values.fold<double>(0, (s, v) => s + v);
    final periodLabel = period.year == now.year
        ? monthName(period)
        : '${monthName(period)} ${period.year}';

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
              Text('across ${categories.length} categories',
                  style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (categories.isEmpty)
          const EmptyHint(
            'No categories yet. Tap + to create one from your bank chats.',
          )
        else
          for (final c in categories) ...[
            _CategoryCard(
              category: c,
              spent: spent[c.id] ?? 0,
              sharePct: total <= 0 ? 0 : ((spent[c.id] ?? 0) / total * 100),
              onTap: () => onEdit(c),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.spent,
    required this.sharePct,
    required this.onTap,
  });

  final Category category;
  final double spent;
  final double sharePct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = hexColor(category.color);
    final rules = CategoryRules.of(category);
    final shops = rules.senderIds
        .map((id) => rules.shopNames[id] ?? '')
        .where((s) => s.trim().isNotEmpty)
        .join(', ');

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
                  shops.isEmpty ? 'No shops added yet' : shops,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const Text('Edit ›',
                  style: TextStyle(fontSize: 12, color: AppColors.faint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftSenderTile extends StatelessWidget {
  const _DraftSenderTile({
    required this.sender,
    required this.checked,
    required this.controller,
    required this.onToggle,
    required this.showDivider,
  });

  final SmsSender sender;
  final bool checked;
  final TextEditingController? controller;
  final VoidCallback onToggle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.cardBorder))
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sender.address,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink)),
                        if (sender.sample.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            sender.sample,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.muted,
                                height: 1.35),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: checked ? AppColors.green : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            checked ? AppColors.green : const Color(0x401E2E2A),
                        width: checked ? 1 : 1.5,
                      ),
                    ),
                    child: checked
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          if (checked)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shop name(s) from this chat',
                      style:
                          TextStyle(fontSize: 11.5, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'e.g. Al Fair Grocery, Karak & bites',
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.screen,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0x261E2E2A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0x261E2E2A)),
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
