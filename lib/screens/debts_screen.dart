import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../services/debt_matching.dart';
import '../services/pay_cycle.dart';
import '../theme.dart';
import '../widgets/transaction_row.dart';
import '../widgets/ui.dart';

/// Debt tab: total remaining hero + per-debt cards. A debt can be linked to
/// the bank SMS that repay it; fixed monthly debts pick up new matching SMS
/// automatically as suggestions to confirm.
class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<Debt>>(
        stream: db.watchDebts(),
        builder: (context, debtSnap) {
          return StreamBuilder<List<DebtPayment>>(
            stream: db.watchDebtPayments(),
            builder: (context, paySnap) {
              final debts = debtSnap.data ?? const [];
              final payments = paySnap.data ?? const [];
              final progress = {
                for (final d in debts) d.id: progressOf(d, payments),
              };
              final total = debts.fold<double>(0, (s, d) => s + d.totalAmount);
              final paid = debts.fold<double>(
                  0, (s, d) => s + progress[d.id]!.paid.clamp(0.0, d.totalAmount));
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
                        const MutedCaps('Total remaining',
                            color: Colors.white54),
                        const SizedBox(height: 6),
                        SerifAmount(money(remaining),
                            size: 32,
                            color: Colors.white,
                            weight: FontWeight.w500),
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
                      _DebtCard(debt: d, progress: progress[d.id]!),
                      const SizedBox(height: 12),
                    ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// "72 months left" / "Paid off" label shared by the card and the detail.
String? _monthsLeftText(DebtProgress p) {
  if (p.remaining <= debtAmountTolerance) return 'Paid off';
  final m = p.monthsLeft;
  if (m == null) return null;
  return m == 1 ? '1 month left' : '$m months left';
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt, required this.progress});

  final Debt debt;
  final DebtProgress progress;

  @override
  Widget build(BuildContext context) {
    final pct = progress.fractionPaid(debt) * 100;
    final sub = [
      if (debt.creditor.isNotEmpty) debt.creditor,
      if (debt.apr > 0) '${_trim(debt.apr)}% APR',
    ].join(' · ');

    final monthsText = _monthsLeftText(progress);
    final String footer;
    if (debt.isFixed && debt.fixedAmount > 0) {
      footer = [
        '${money(debt.fixedAmount)}/mo',
        ?monthsText,
      ].join(' · ');
    } else if (debt.minPayment > 0) {
      footer = [
        'Min payment ${money(debt.minPayment)}/mo',
        ?monthsText,
      ].join(' · ');
    } else if (debt.dueDate != null) {
      footer = 'Due ${shortDate(debt.dueDate!)}';
    } else {
      footer = 'Tap to see payments';
    }

    return AppCard(
      onTap: () => _openDetail(context, debt.id),
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
              SerifAmount(money(progress.remaining), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(fraction: pct / 100, color: AppColors.brown),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  footer,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              Text('${pct.toStringAsFixed(0)}% paid',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brown)),
            ],
          ),
          if (progress.pending.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _Pill(
                progress.pending.length == 1
                    ? '1 matched SMS to confirm'
                    : '${progress.pending.length} matched SMS to confirm',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.peach.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.terracotta)),
    );
  }
}

String _trim(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

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

Future<T?> _sheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.screen,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: child,
      ),
    ),
  );
}

Future<void> _openEditor(BuildContext context, [Debt? existing]) =>
    _sheet<void>(context, _DebtEditor(existing: existing));

Future<void> _openDetail(BuildContext context, int debtId) =>
    _sheet<void>(context, _DebtDetail(debtId: debtId));

/// Lets the user tick the bank SMS that belong to a debt. Only money-out SMS
/// are listed, newest first; [exclude] hides ones already counted elsewhere.
Future<List<Transaction>?> _pickSms(
  BuildContext context, {
  Set<int> exclude = const {},
  Set<int> initial = const {},
}) =>
    _sheet<List<Transaction>>(
      context,
      _SmsPicker(exclude: exclude, initial: initial),
    );

// ---------------------------------------------------------------------------
// Detail: remaining, months left, suggestions to confirm, payment history.
// ---------------------------------------------------------------------------

class _DebtDetail extends StatelessWidget {
  const _DebtDetail({required this.debtId});

  final int debtId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Debt>>(
      stream: db.watchDebts(),
      builder: (context, debtSnap) {
        return StreamBuilder<List<DebtPayment>>(
          stream: db.watchDebtPayments(),
          builder: (context, paySnap) {
            return StreamBuilder<List<Transaction>>(
              stream: db.watchTransactions(),
              builder: (context, txSnap) {
                final debt = (debtSnap.data ?? const <Debt>[])
                    .where((d) => d.id == debtId)
                    .firstOrNull;
                if (debt == null) {
                  return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()));
                }
                final all = paySnap.data ?? const <DebtPayment>[];
                final p = progressOf(debt, all);
                return _DetailBody(
                  debt: debt,
                  progress: p,
                  allPayments: all,
                  cycles: PayCycles.fromTransactions(
                      txSnap.data ?? const <Transaction>[]),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.debt,
    required this.progress,
    required this.allPayments,
    required this.cycles,
  });

  final Debt debt;
  final DebtProgress progress;
  final List<DebtPayment> allPayments;
  final PayCycles cycles;

  Future<void> _linkSms(BuildContext context) async {
    final taken = confirmedTransactionIds(allPayments);
    final picked = await _pickSms(context, exclude: taken);
    if (picked == null) return;
    for (final t in picked) {
      await db.linkTransactionToDebt(debt.id, t);
    }
  }

  Future<void> _removePayment(DebtPayment pay) async {
    if (pay.transactionId == null) {
      await db.deleteDebtPayment(pay.id);
    } else {
      // Keep the row as "rejected" so the rule never suggests this SMS again.
      await db.setPaymentStatus(pay.id, PaymentStatus.rejected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final monthsText = _monthsLeftText(p);
    final payoff = p.payoffMonth(cycles: cycles);
    final ruleParts = [
      if (debt.isFixed && debt.fixedAmount > 0)
        '${money(debt.fixedAmount)} every month',
      if (debt.isFixed && debt.matchCard.isNotEmpty) 'from ••••${debt.matchCard}',
      if (debt.isFixed && debt.matchCounterparty.isNotEmpty)
        'to ${debt.matchCounterparty}',
    ];

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(debt.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
            ),
            IconButton(
              tooltip: 'Edit debt',
              icon: const Icon(Icons.edit_outlined, color: AppColors.ink),
              onPressed: () {
                Navigator.pop(context);
                _openEditor(context, debt);
              },
            ),
          ],
        ),
        if (ruleParts.isNotEmpty)
          Text(ruleParts.join(' · '),
              style: const TextStyle(fontSize: 12, color: AppColors.faint)),
        const SizedBox(height: 14),
        DarkCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MutedCaps('Remaining', color: Colors.white54),
              const SizedBox(height: 4),
              SerifAmount(money(p.remaining), size: 28, color: Colors.white),
              const SizedBox(height: 12),
              ProgressBar(
                fraction: p.fractionPaid(debt),
                color: AppColors.peach,
                track: Colors.white24,
              ),
              const SizedBox(height: 10),
              Text(
                [
                  'Paid ${money(p.paid)} of ${money(debt.totalAmount)}',
                  ?monthsText,
                  if (payoff != null) 'last payment ${monthYear(payoff)}',
                ].join(' · '),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        if (p.pending.isNotEmpty) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text('Matched SMS to confirm (${p.pending.length})',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
              ),
              TextButton(
                onPressed: () async {
                  for (final s in p.pending) {
                    await db.setPaymentStatus(s.id, PaymentStatus.confirmed);
                  }
                },
                child: const Text('Confirm all'),
              ),
            ],
          ),
          const Text(
            'Same account and same amount as this debt. Confirm the ones that '
            'are real payments of it.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final s in p.pending)
                  _PaymentRow(
                    payment: s,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Not this debt',
                          icon: const Icon(Icons.close,
                              color: AppColors.terracotta),
                          onPressed: () => db.setPaymentStatus(
                              s.id, PaymentStatus.rejected),
                        ),
                        IconButton(
                          tooltip: 'Confirm payment',
                          icon: const Icon(Icons.check, color: AppColors.green),
                          onPressed: () => db.setPaymentStatus(
                              s.id, PaymentStatus.confirmed),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        const Text('Payments',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _linkSms(context),
                icon: const Icon(Icons.sms_outlined, size: 16),
                label: const Text('Link SMS'),
                style: _outlineStyle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _sheet<void>(context, _ManualPayment(debt: debt)),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add payment'),
                style: _outlineStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (debt.paidAmount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Includes ${money(debt.paidAmount)} paid before tracking.',
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ),
        if (p.payments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No payments linked yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.faint)),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final pay in p.payments)
                  _PaymentRow(
                    payment: pay,
                    trailing: IconButton(
                      tooltip: 'Remove from this debt',
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColors.faint, size: 20),
                      onPressed: () => _removePayment(pay),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

final _outlineStyle = OutlinedButton.styleFrom(
  foregroundColor: AppColors.ink,
  side: const BorderSide(color: Color(0x261E2E2A)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.trailing});

  final DebtPayment payment;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final fromSms = payment.transactionId != null;
    final title = payment.note.isNotEmpty
        ? payment.note
        : (fromSms ? 'Bank SMS' : 'Manual payment');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Icon(fromSms ? Icons.sms_outlined : Icons.edit_note,
              size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                Text(shortDate(payment.date),
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.faint)),
              ],
            ),
          ),
          Text(money(payment.amount),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          trailing,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Manual (non-SMS) payment.
// ---------------------------------------------------------------------------

class _ManualPayment extends StatefulWidget {
  const _ManualPayment({required this.debt});

  final Debt debt;

  @override
  State<_ManualPayment> createState() => _ManualPaymentState();
}

class _ManualPaymentState extends State<_ManualPayment> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await db.addManualDebtPayment(
      debtId: widget.debt.id,
      amount: double.parse(_amount.text),
      date: _date,
      note: _note.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add payment to ${widget.debt.name}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
            const SizedBox(height: 12),
            _field(_amount, 'Amount (OMR)', number: true, required: true),
            const SizedBox(height: 12),
            _field(_note, 'Note (optional)', capitalize: true),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text('Paid on ${shortDate(_date)}'),
              style: _outlineStyle,
            ),
            const SizedBox(height: 20),
            _SaveButton(onPressed: _save),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SMS picker.
// ---------------------------------------------------------------------------

class _SmsPicker extends StatefulWidget {
  const _SmsPicker({required this.exclude, required this.initial});

  final Set<int> exclude;
  final Set<int> initial;

  @override
  State<_SmsPicker> createState() => _SmsPickerState();
}

class _SmsPickerState extends State<_SmsPicker> {
  late final Set<int> _selected = {...widget.initial};
  String _query = '';
  List<Transaction>? _txns;

  @override
  void initState() {
    super.initState();
    db.allTransactions().then((all) {
      if (!mounted) return;
      setState(() {
        _txns = all
            .where(canBeDebtPayment)
            .where((t) => !widget.exclude.contains(t.id))
            .toList();
      });
    });
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select related SMS',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text('Money-out bank SMS from the last 6 months.',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: _inputDecoration('Search name or amount')
                .copyWith(prefixIcon: const Icon(Icons.search, size: 18)),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: _txns == null
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('No matching bank SMS.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13, color: AppColors.faint)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: visible.length,
                        itemBuilder: (context, i) {
                          final t = visible[i];
                          final on = _selected.contains(t.id);
                          return CheckboxListTile(
                            value: on,
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
                                if (t.source == TxSource.sms) bankName(t.sender),
                              ].join(' · '),
                              style: const TextStyle(fontSize: 11),
                            ),
                            secondary: Text(money(t.amount),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 12),
          _SaveButton(
            label: _selected.isEmpty
                ? 'Done'
                : 'Use ${_selected.length} SMS',
            onPressed: () {
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

// ---------------------------------------------------------------------------
// Add / edit.
// ---------------------------------------------------------------------------

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
  late final TextEditingController _fixedAmount;
  DateTime? _dueDate;
  late bool _isFixed;

  /// SMS the user ticked in this editing session (linked on save).
  List<Transaction> _selected = const [];

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _name = TextEditingController(text: d?.name ?? '');
    _creditor = TextEditingController(text: d?.creditor ?? '');
    _total = TextEditingController(
        text: d == null ? '' : d.totalAmount.toStringAsFixed(3));
    _paid = TextEditingController(
        text: d == null || d.paidAmount == 0
            ? ''
            : d.paidAmount.toStringAsFixed(3));
    _apr = TextEditingController(
        text: d == null || d.apr == 0 ? '' : _trim(d.apr));
    _minPayment = TextEditingController(
        text: d == null || d.minPayment == 0
            ? ''
            : d.minPayment.toStringAsFixed(3));
    _fixedAmount = TextEditingController(
        text: d == null || d.fixedAmount == 0
            ? ''
            : d.fixedAmount.toStringAsFixed(3));
    _dueDate = d?.dueDate;
    _isFixed = d?.isFixed ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _creditor.dispose();
    _total.dispose();
    _paid.dispose();
    _apr.dispose();
    _minPayment.dispose();
    _fixedAmount.dispose();
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

  Future<void> _selectSms() async {
    final payments = await db.allDebtPayments();
    // Hide SMS already counted toward another debt (or already on this one).
    final exclude = {
      for (final p in payments)
        if (p.transactionId != null &&
            p.status == PaymentStatus.confirmed)
          p.transactionId!,
    };
    if (!mounted) return;
    final picked = await _pickSms(
      context,
      exclude: exclude,
      initial: {for (final t in _selected) t.id},
    );
    if (picked == null) return;
    setState(() {
      _selected = picked;
      if (_isFixed && _fixedAmount.text.isEmpty && picked.isNotEmpty) {
        _fixedAmount.text = picked.first.amount.toStringAsFixed(3);
      }
    });
  }

  /// The SMS whose bank/account/recipient become the fixed rule: the first
  /// selected one with the fixed amount, else the first selected.
  Transaction? _ruleSource(double fixed) {
    if (_selected.isEmpty) return null;
    return _selected
            .where((t) => (t.amount - fixed).abs() <= debtAmountTolerance)
            .firstOrNull ??
        _selected.first;
  }

  void _toast(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final total = double.parse(_total.text);
    final paid = double.tryParse(_paid.text) ?? 0;
    final apr = double.tryParse(_apr.text) ?? 0;
    final minPay = double.tryParse(_minPayment.text) ?? 0;
    final fixed = _isFixed ? (double.tryParse(_fixedAmount.text) ?? 0) : 0.0;
    final d = widget.existing;

    final source = _isFixed ? _ruleSource(fixed) : null;
    final hasRule = source != null ||
        (d != null && (d.matchCounterparty.isNotEmpty || d.matchCard.isNotEmpty));
    if (_isFixed && !hasRule) {
      _toast('Select at least one SMS of this payment so the app knows '
          'which account it goes to.');
      return;
    }

    final sender = source?.sender ?? d?.matchSender ?? '';
    final card = source?.card ?? d?.matchCard ?? '';
    final counterparty = source?.description ?? d?.matchCounterparty ?? '';

    final int id;
    if (d == null) {
      id = await db.addDebt(DebtsCompanion.insert(
        name: _name.text.trim(),
        creditor: Value(_creditor.text.trim()),
        totalAmount: total,
        paidAmount: Value(paid),
        apr: Value(apr),
        minPayment: Value(minPay),
        dueDate: Value(_dueDate),
        isFixed: Value(_isFixed),
        fixedAmount: Value(fixed),
        matchSender: Value(sender),
        matchCard: Value(card),
        matchCounterparty: Value(counterparty),
      ));
    } else {
      id = d.id;
      await db.updateDebt(d.copyWith(
        name: _name.text.trim(),
        creditor: _creditor.text.trim(),
        totalAmount: total,
        paidAmount: paid,
        apr: apr,
        minPayment: minPay,
        dueDate: Value(_dueDate),
        isFixed: _isFixed,
        fixedAmount: fixed,
        matchSender: sender,
        matchCard: card,
        matchCounterparty: counterparty,
      ));
    }

    for (final t in _selected) {
      await db.linkTransactionToDebt(id, t);
    }

    var found = 0;
    if (_isFixed) {
      final saved = await db.debtById(id);
      if (saved != null) found = await suggestDebtMatches(db, saved);
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    if (found > 0) {
      messenger.showSnackBar(SnackBar(
        content: Text(found == 1
            ? 'Found 1 more matching SMS. Open the debt to confirm it.'
            : 'Found $found more matching SMS. Open the debt to confirm them.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            _field(_name, 'Debt name', capitalize: true, required: true),
            const SizedBox(height: 12),
            _field(_creditor, 'Lender (optional)', capitalize: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _field(_total, 'Total (OMR)',
                        number: true, required: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_paid, 'Paid before (OMR)', number: true)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Paid before = anything repaid before the SMS you link below.',
              style: TextStyle(fontSize: 11, color: AppColors.faint),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _selectSms,
              icon: const Icon(Icons.sms_outlined, size: 16),
              label: Text(_selected.isEmpty
                  ? 'Select related SMS'
                  : '${_selected.length} SMS selected'),
              style: _outlineStyle,
            ),
            if (_selected.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final t in _selected.take(3))
                Text(
                  '${shortDate(t.date)} · ${t.description} · ${money(t.amount)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              if (_selected.length > 3)
                Text('and ${_selected.length - 3} more',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.green,
              title: const Text('Fixed monthly payment?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text(
                'New SMS to the same account with the same amount will be '
                'suggested as payments.',
                style: TextStyle(fontSize: 12),
              ),
              value: _isFixed,
              onChanged: (v) => setState(() {
                _isFixed = v;
                if (v && _fixedAmount.text.isEmpty && _selected.isNotEmpty) {
                  _fixedAmount.text = _selected.first.amount.toStringAsFixed(3);
                }
              }),
            ),
            if (_isFixed) ...[
              const SizedBox(height: 4),
              _field(_fixedAmount, 'Monthly amount (OMR)',
                  number: true, required: true),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(_apr, 'APR %', number: true)),
                if (!_isFixed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(_minPayment, 'Min / mo (OMR)',
                          number: true)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(_dueDate == null
                  ? 'Due date (optional)'
                  : 'Due: ${shortDate(_dueDate!)}'),
              style: _outlineStyle,
            ),
            const SizedBox(height: 20),
            _SaveButton(onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed, this.label = 'Save'});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) => InputDecoration(
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
    );

Widget _field(
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
    decoration: _inputDecoration(label),
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
