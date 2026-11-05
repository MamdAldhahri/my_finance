import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../services/income_plan.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Opens the plan setup screen, starting from [current] (null = first time).
Future<void> openPlanSetup(BuildContext context, IncomePlan? current) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlanSetupScreen(current: current)),
    );

/// Split the salary into the four buckets: preset chips, one slider per
/// bucket (they must add up to 100%), and a salary to plan with until the
/// salary SMS arrives.
class PlanSetupScreen extends StatefulWidget {
  const PlanSetupScreen({super.key, this.current});

  final IncomePlan? current;

  @override
  State<PlanSetupScreen> createState() => _PlanSetupScreenState();
}

class _PlanSetupScreenState extends State<PlanSetupScreen> {
  late PlanPreset _preset;
  late Map<Bucket, int> _pct;
  final _salary = TextEditingController();
  Transaction? _detected;

  @override
  void initState() {
    super.initState();
    final plan = widget.current ?? IncomePlan.fromPreset(PlanPreset.balanced);
    _preset = plan.preset;
    _pct = {...plan.percents};
    final expected = plan.expectedSalary;
    if (expected != null) _salary.text = expected.toStringAsFixed(3);
    db.allTransactions().then((txns) {
      if (mounted) setState(() => _detected = latestSalary(txns));
    });
  }

  @override
  void dispose() {
    _salary.dispose();
    super.dispose();
  }

  int get _total => _pct.values.fold(0, (s, v) => s + v);

  double? get _typedSalary {
    final v = double.tryParse(_salary.text.trim().replaceAll(',', ''));
    return v == null || v <= 0 ? null : v;
  }

  /// The salary the amounts on screen are worked out from.
  double get _base => _detected?.amount ?? _typedSalary ?? 0;

  void _pickPreset(PlanPreset p) {
    final split = p.split;
    setState(() {
      _preset = p;
      if (split != null) {
        _pct = {for (final b in Bucket.values) b: split[b.index]};
      }
    });
  }

  Future<void> _save() async {
    if (_total != 100) return;
    await saveIncomePlan(
      db,
      IncomePlan(percents: _pct, preset: _preset, expectedSalary: _typedSalary),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final left = 100 - _total;
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'Plan your salary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Every payday your salary is split into four parts. The app '
              'then compares what you actually spend and save against it.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _salaryCard(),
            const SizedBox(height: 20),
            const Text(
              'Start from',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final p in PlanPreset.values) _presetChip(p)],
            ),
            const SizedBox(height: 16),
            for (final b in Bucket.values) ...[
              _bucketSlider(b),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            Text(
              left == 0
                  ? 'Total 100%'
                  : left > 0
                  ? 'Total $_total% · $left% left to assign'
                  : 'Total $_total% · ${-left}% too much',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: left == 0 ? AppColors.green : AppColors.terracotta,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: left == 0 ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save plan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tip: keep Emergency & Savings and Investments in a separate '
              'bank account, so the money you planned to keep doesn\'t get '
              'spent by accident.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.faint,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _salaryCard() {
    final d = _detected;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your salary',
            style: TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          if (d != null) ...[
            SerifAmount(money(d.amount), size: 24),
            const SizedBox(height: 4),
            Text(
              'Last salary SMS: ${shortDate(d.date)}',
              style: const TextStyle(fontSize: 12, color: AppColors.faint),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _salary,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: d == null ? 'Monthly salary (OMR)' : 'Optional',
              labelText: d == null ? 'Monthly salary' : 'Backup salary',
              suffixText: currency,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x261E2E2A)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            d == null
                ? 'No salary SMS found yet. Once one arrives, the plan uses '
                      'the real amount each payday.'
                : 'Used when this month\'s salary SMS hasn\'t arrived yet. '
                      'If left empty, last payday\'s salary is used.',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.faint,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(PlanPreset p) {
    final selected = _preset == p;
    final split = p.split;
    return ChoiceChip(
      label: Text(split == null ? p.label : '${p.label} ${split.join('/')}'),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => _pickPreset(p),
      backgroundColor: Colors.white,
      selectedColor: AppColors.green,
      side: const BorderSide(color: Color(0x261E2E2A)),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppColors.ink,
      ),
    );
  }

  Widget _bucketSlider(Bucket b) {
    final pct = _pct[b] ?? 0;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Dot(b.color, size: 10),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  b.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  b.hint,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ),
              if (_base > 0)
                AmountText(
                  money(_base * pct / 100),
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
          Slider(
            value: pct.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: b.color,
            inactiveColor: AppColors.track,
            label: '$pct%',
            onChanged: (v) => setState(() {
              _pct[b] = v.round();
              _preset = PlanPreset.custom;
            }),
          ),
        ],
      ),
    );
  }
}
