import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../services/derive.dart';
import '../services/sms_import.dart';
import '../theme.dart';
import '../widgets/transaction_row.dart';
import '../widgets/ui.dart';

enum _Filter { all, income, expense }

/// Transactions tab: month income/expense totals, filter chips, the unified
/// transaction list, the "which chat is your bank?" picker (gear) and manual
/// expense entry (+).
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _Filter _filter = _Filter.all;
  bool _scanning = false;

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _openSenderPicker() async {
    final granted = await smsImport.requestPermission();
    if (!granted) {
      _snack('SMS permission denied. Enable it in system settings to '
          'auto-import bank transactions.');
      return;
    }
    if (!mounted) return;
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SenderPickerSheet(),
    );
    if (selected == null) return;
    await db.setBankSenders(selected);
    if (selected.isEmpty) {
      await db.setSmsImportEnabled(false);
    } else {
      await db.setSmsImportEnabled(true);
      smsImport.startListening();
      setState(() => _scanning = true);
      final added = await smsImport.scanInbox();
      if (mounted) {
        setState(() => _scanning = false);
        _snack(added == 0
            ? 'No new bank messages found.'
            : 'Imported $added transaction${added == 1 ? '' : 's'}.');
      }
    }
  }

  Future<void> _openManualAdd() async {
    final categories = await db.allCategories();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualEntrySheet(categories: categories),
    );
  }

  Future<void> _openCategorySheet(Transaction txn) async {
    final categories = await db.allCategories();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignCategorySheet(txn: txn, categories: categories),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Category>>(
                stream: db.watchCategories(),
                builder: (context, catSnap) {
                  final categories = catSnap.data ?? const [];
                  return StreamBuilder<List<Transaction>>(
                    stream: db.watchTransactions(),
                    builder: (context, txSnap) {
                      final all = txSnap.data ?? const [];
                      return _content(all, categories);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        Row(
          children: [
            _IconBtn(
              icon: Icons.add,
              filled: true,
              onTap: _openManualAdd,
            ),
            const SizedBox(width: 8),
            _IconBtn(
              icon: Icons.settings_outlined,
              busy: _scanning,
              onTap: _scanning ? null : _openSenderPicker,
            ),
          ],
        ),
      ],
    );
  }

  Widget _content(List<Transaction> all, List<Category> categories) {
    final now = DateTime.now();
    bool thisMonth(Transaction t) =>
        t.date.year == now.year && t.date.month == now.month;
    final income = all
        .where((t) => t.isCredit && thisMonth(t))
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = all
        .where((t) => !t.isCredit && thisMonth(t))
        .fold<double>(0, (s, t) => s + t.amount);

    final filtered = switch (_filter) {
      _Filter.all => all,
      _Filter.income => all.where((t) => t.isCredit).toList(),
      _Filter.expense => all.where((t) => !t.isCredit).toList(),
    };

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Row(
          children: [
            Expanded(
              child: _MonthStat(
                label: 'Income · ${monthName(now)}',
                value: income,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MonthStat(
                label: 'Expenses · ${monthName(now)}',
                value: expense,
                color: AppColors.terracotta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _FilterChip(
              label: 'All',
              selected: _filter == _Filter.all,
              onTap: () => setState(() => _filter = _Filter.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Income',
              selected: _filter == _Filter.income,
              onTap: () => setState(() => _filter = _Filter.income),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Expenses',
              selected: _filter == _Filter.expense,
              onTap: () => setState(() => _filter = _Filter.expense),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Text(
                all.isEmpty
                    ? 'No transactions yet.\nTap the gear to pick your bank '
                        'chat, or + to add one manually.'
                    : 'Nothing in this filter.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.faint),
              ),
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < filtered.length; i++)
                  TransactionRow(
                    txn: filtered[i],
                    category: _resolve(filtered[i], categories),
                    showDivider: i != filtered.length - 1,
                    onTap: () => _openCategorySheet(filtered[i]),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Category? _resolve(Transaction t, List<Category> categories) {
    final id = categoryIdFor(t, categories);
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Small presentational pieces
// ---------------------------------------------------------------------------

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.busy = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.green : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: const Color(0x141E2E2A)),
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.ink),
              )
            : Icon(icon,
                size: 17, color: filled ? Colors.white : AppColors.ink),
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 5),
          SerifAmount(money(value), size: 19, color: color),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheets
// ---------------------------------------------------------------------------

/// Rounded sheet shell shared by the pickers below.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.child, this.maxHeightFactor = 0.82});

  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      decoration: const BoxDecoration(
        color: AppColors.screen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x401E2E2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// "Which chat is your bank?" — lists inbox senders with checkboxes.
class _SenderPickerSheet extends StatefulWidget {
  const _SenderPickerSheet();

  @override
  State<_SenderPickerSheet> createState() => _SenderPickerSheetState();
}

class _SenderPickerSheetState extends State<_SenderPickerSheet> {
  Future<List<SmsSender>>? _senders;
  final Set<String> _chosen = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _chosen.addAll(await db.getBankSenders());
    if (!mounted) return;
    setState(() {
      _senders = smsImport.inboxSenders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHeader(
            title: 'Which chat is your bank?',
            subtitle:
                'Pick every sender that texts you card alerts. Only these are '
                'read.',
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Flexible(
            child: FutureBuilder<List<SmsSender>>(
              future: _senders,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final senders = snap.data ?? const [];
                if (senders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'No SMS found. This works on Android with SMS permission '
                      'granted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.faint),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: senders.length,
                  itemBuilder: (context, i) {
                    final s = senders[i];
                    final checked = _chosen.contains(s.address);
                    return _SenderTile(
                      sender: s,
                      checked: checked,
                      onTap: () => setState(() {
                        checked
                            ? _chosen.remove(s.address)
                            : _chosen.add(s.address);
                      }),
                    );
                  },
                );
              },
            ),
          ),
          _SheetButton(
            label: 'Save',
            onTap: () => Navigator.pop(context, _chosen.toList()),
          ),
        ],
      ),
    );
  }
}

class _SenderTile extends StatelessWidget {
  const _SenderTile({
    required this.sender,
    required this.checked,
    required this.onTap,
  });

  final SmsSender sender;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              child: Text('${sender.count}',
                  style: const TextStyle(fontSize: 11, color: AppColors.faint)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender.address,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  if (sender.sample.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sender.sample,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.muted, height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _CheckBox(checked: checked),
          ],
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? AppColors.green : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? AppColors.green : const Color(0x401E2E2A),
          width: checked ? 1 : 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

/// Manual one-off expense/income entry.
class _ManualEntrySheet extends StatefulWidget {
  const _ManualEntrySheet({required this.categories});

  final List<Category> categories;

  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  bool _isCredit = false;
  DateTime _date = DateTime.now();
  int? _categoryId;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await db.addManualTransaction(
      description: _name.text.trim(),
      amount: double.parse(_amount.text),
      isCredit: _isCredit,
      date: _date,
      categoryId: _categoryId,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _Sheet(
        maxHeightFactor: 0.9,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add a transaction',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'A one-off entry that is not from a bank SMS.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                _field(_name, 'What was it?', capitalize: true),
                const SizedBox(height: 12),
                _field(
                  _amount,
                  'Amount (OMR)',
                  number: true,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n <= 0) ? 'Enter an amount' : null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _typeChip('Expense', !_isCredit,
                        () => setState(() => _isCredit = false)),
                    const SizedBox(width: 8),
                    _typeChip('Income', _isCredit,
                        () => setState(() => _isCredit = true)),
                  ],
                ),
                const SizedBox(height: 14),
                if (widget.categories.isNotEmpty) ...[
                  const Text('Category',
                      style:
                          TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int?>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration: _inputDecoration(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final c in widget.categories)
                        DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (v) => setState(() => _categoryId = v),
                  ),
                  const SizedBox(height: 14),
                ],
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('Date: ${shortDate(_date)}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: Color(0x261E2E2A)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                _SheetButton(label: 'Save', onTap: _save, inset: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool number = false,
    bool capitalize = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      keyboardType:
          number ? const TextInputType.numberWithOptions(decimal: true) : null,
      textCapitalization:
          capitalize ? TextCapitalization.sentences : TextCapitalization.none,
      decoration: _inputDecoration(label: label),
      validator: validator ??
          (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  Widget _typeChip(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x261E2E2A)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? label}) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x261E2E2A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x261E2E2A)),
      ),
    );

/// "Add to category" / delete sheet for a tapped transaction.
class _AssignCategorySheet extends StatelessWidget {
  const _AssignCategorySheet({required this.txn, required this.categories});

  final Transaction txn;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final title = txn.description.isEmpty ? 'this transaction' : txn.description;
    final byName = txn.source == TxSource.sms &&
        !{'', 'payment', 'deposit'}.contains(txn.description.trim().toLowerCase());
    final effective = categoryIdFor(txn, categories);
    return _Sheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            title: 'Add to category',
            subtitle: byName
                ? 'Filing every "$title" transaction into this category.'
                : 'File "$title" under a category.',
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Flexible(
            child: categories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No categories yet — create one in the Categories tab '
                      'first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.faint),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      final c = categories[i];
                      final selected = effective == c.id;
                      return InkWell(
                        onTap: () async {
                          await fileTransactionToCategory(
                              db, txn, c, categories);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: AppColors.cardBorder)),
                          ),
                          child: Row(
                            children: [
                              Dot(hexColor(c.color), size: 9),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check,
                                    size: 18, color: AppColors.green),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                if (effective != null)
                  Expanded(
                    child: _OutlineButton(
                      label: 'Remove from category',
                      onTap: () async {
                        await unfileTransactionFromCategory(
                            db, txn, categories);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                if (effective != null && txn.source == TxSource.manual)
                  const SizedBox(width: 10),
                if (txn.source == TxSource.manual)
                  Expanded(
                    child: _OutlineButton(
                      label: 'Delete',
                      danger: true,
                      onTap: () async {
                        await db.deleteTransaction(txn.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(top: false, child: const SizedBox(height: 8)),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.inset = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
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
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (!inset) return button;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: button,
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.terracotta : AppColors.ink;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0x261E2E2A)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
