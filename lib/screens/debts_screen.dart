import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Debt tab: total remaining hero + per-debt cards with lender, APR and
/// minimum payment. Debts are entered by hand (they aren't in SMS).
class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<Debt>>(
        stream: db.watchDebts(),
        builder: (context, snapshot) {
          final debts = snapshot.data ?? const [];
          final total = debts.fold<double>(0, (s, d) => s + d.totalAmount);
          final paid = debts.fold<double>(0, (s, d) => s + d.paidAmount);
          final remaining = total - paid;
          final paidPct = total <= 0 ? 0 : (paid / total * 100);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Debt',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                  _AddButton(onTap: () => _openEditor(context)),
                ],
              ),
              const SizedBox(height: 16),
              DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MutedCaps('Total remaining', color: Colors.white54),
                    const SizedBox(height: 6),
                    SerifAmount(money(remaining),
                        size: 32, color: Colors.white, weight: FontWeight.w500),
                    const SizedBox(height: 14),
                    ProgressBar(
                      fraction: paidPct / 100,
                      color: AppColors.peach,
                      track: Colors.white24,
                    ),
                    const SizedBox(height: 8),
                    Text('${paidPct.toStringAsFixed(0)}% paid off overall',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (debts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'No debts tracked.\nTap + to add one and plan your payoff.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.faint),
                  ),
                )
              else
                for (final d in debts) ...[
                  _DebtCard(debt: d),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt});

  final Debt debt;

  @override
  Widget build(BuildContext context) {
    final remaining = debt.totalAmount - debt.paidAmount;
    final pct =
        debt.totalAmount <= 0 ? 0 : (debt.paidAmount / debt.totalAmount * 100);
    final sub = [
      if (debt.creditor.isNotEmpty) debt.creditor,
      if (debt.apr > 0) '${_trim(debt.apr)}% APR',
    ].join(' · ');

    return AppCard(
      onTap: () => _openEditor(context, debt),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debt.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(sub,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.faint)),
                    ],
                  ],
                ),
              ),
              SerifAmount(money(remaining), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(fraction: pct / 100, color: AppColors.brown),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                debt.minPayment > 0
                    ? 'Min payment ${money(debt.minPayment)}/mo'
                    : (debt.dueDate != null
                        ? 'Due ${shortDate(debt.dueDate!)}'
                        : 'Tap to update'),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              Text('${pct.toStringAsFixed(0)}% paid',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brown)),
            ],
          ),
        ],
      ),
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

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
          color: AppColors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add, size: 18, color: Colors.white),
      ),
    );
  }
}

Future<void> _openEditor(BuildContext context, [Debt? existing]) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.screen,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _DebtEditor(existing: existing),
    ),
  );
}

class _DebtEditor extends StatefulWidget {
  const _DebtEditor({this.existing});

  final Debt? existing;

  @override
  State<_DebtEditor> createState() => _DebtEditorState();
}

class _DebtEditorState extends State<_DebtEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _creditor;
  late final TextEditingController _total;
  late final TextEditingController _paid;
  late final TextEditingController _apr;
  late final TextEditingController _minPayment;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _name = TextEditingController(text: d?.name ?? '');
    _creditor = TextEditingController(text: d?.creditor ?? '');
    _total = TextEditingController(
        text: d == null ? '' : d.totalAmount.toStringAsFixed(3));
    _paid = TextEditingController(
        text: d == null ? '' : d.paidAmount.toStringAsFixed(3));
    _apr = TextEditingController(
        text: d == null || d.apr == 0 ? '' : _trim(d.apr));
    _minPayment = TextEditingController(
        text: d == null || d.minPayment == 0
            ? ''
            : d.minPayment.toStringAsFixed(3));
    _dueDate = d?.dueDate;
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _name.dispose();
    _creditor.dispose();
    _total.dispose();
    _paid.dispose();
    _apr.dispose();
    _minPayment.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final total = double.parse(_total.text);
    final paid = double.tryParse(_paid.text) ?? 0;
    final apr = double.tryParse(_apr.text) ?? 0;
    final minPay = double.tryParse(_minPayment.text) ?? 0;
    final d = widget.existing;
    if (d == null) {
      await db.addDebt(DebtsCompanion.insert(
        name: _name.text.trim(),
        creditor: Value(_creditor.text.trim()),
        totalAmount: total,
        paidAmount: Value(paid),
        apr: Value(apr),
        minPayment: Value(minPay),
        dueDate: Value(_dueDate),
      ));
    } else {
      await db.updateDebt(d.copyWith(
        name: _name.text.trim(),
        creditor: _creditor.text.trim(),
        totalAmount: total,
        paidAmount: paid,
        apr: apr,
        minPayment: minPay,
        dueDate: Value(_dueDate),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existing == null ? 'Add debt' : 'Edit debt',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
                if (widget.existing != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.terracotta),
                    onPressed: () async {
                      await db.deleteDebt(widget.existing!.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _tf(_name, 'Debt name', capitalize: true, required: true),
            const SizedBox(height: 12),
            _tf(_creditor, 'Lender (optional)', capitalize: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _tf(_total, 'Total (OMR)',
                        number: true, required: true)),
                const SizedBox(width: 12),
                Expanded(child: _tf(_paid, 'Paid (OMR)', number: true)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _tf(_apr, 'APR %', number: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _tf(_minPayment, 'Min / mo (OMR)', number: true)),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(_dueDate == null
                  ? 'Due date (optional)'
                  : 'Due: ${shortDate(_dueDate!)}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: Color(0x261E2E2A)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(
    TextEditingController c,
    String label, {
    bool number = false,
    bool capitalize = false,
    bool required = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType:
          number ? const TextInputType.numberWithOptions(decimal: true) : null,
      textCapitalization:
          capitalize ? TextCapitalization.words : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
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
      validator: required
          ? (v) {
              if (number) {
                final n = double.tryParse(v ?? '');
                return (n == null || n <= 0) ? 'Invalid' : null;
              }
              return (v == null || v.trim().isEmpty) ? 'Required' : null;
            }
          : null,
    );
  }
}
