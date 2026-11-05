import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../services/category_matching.dart';
import '../services/income_plan.dart';
import '../services/pay_cycle.dart';
import '../theme.dart';
import '../widgets/plan_card.dart';
import '../widgets/ui.dart';
import 'plan_setup_screen.dart';

/// Everything a plan report is worked out from, captured from the Overview.
class PlanInputs {
  PlanInputs({
    required this.txns,
    required this.resolver,
    required this.categories,
    required this.debts,
    required this.debtPayments,
  }) : cycles = PayCycles.fromTransactions(txns);

  final List<Transaction> txns;
  final CategoryResolver resolver;
  final List<Category> categories;
  final List<Debt> debts;
  final List<DebtPayment> debtPayments;
  final PayCycles cycles;

  CycleReport report(PayCycle cycle, IncomePlan plan) => buildCycleReport(
    cycle: cycle,
    cycles: cycles,
    txns: txns,
    resolver: resolver,
    categories: categories,
    debts: debts,
    debtPayments: debtPayments,
    plan: plan,
  );
}

/// The running cycle in full, plus how the previous cycles went.
class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key, required this.inputs});

  final PlanInputs inputs;

  static const _history = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: StreamBuilder<IncomePlan?>(
          stream: watchIncomePlan(db),
          builder: (context, snap) {
            final plan = snap.data;
            final cycles = inputs.cycles;
            final current = cycles.current;
            final earliest = inputs.txns.isEmpty
                ? null
                : inputs.txns
                      .map((t) => t.date)
                      .reduce((a, b) => a.isBefore(b) ? a : b);
            final past = <CycleReport>[];
            if (plan != null && earliest != null) {
              for (var i = 1; i <= _history; i++) {
                final c = cycles.shift(current, -i);
                if (c.end.isBefore(earliest)) break;
                past.add(inputs.report(c, plan));
              }
            }
            return ListView(
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
                    const Expanded(
                      child: Text(
                        'Income plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => openPlanSetup(context, plan),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.green,
                      ),
                      child: const Text('Edit plan'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (plan == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      'No plan yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.faint),
                    ),
                  )
                else ...[
                  _SplitSummary(plan: plan),
                  const SizedBox(height: 14),
                  PlanCard(
                    report: inputs.report(current, plan),
                    onTap: () {},
                    onSetUp: () => openPlanSetup(context, plan),
                  ),
                  if (past.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Previous cycles',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Measured against your current split.',
                      style: TextStyle(fontSize: 12, color: AppColors.faint),
                    ),
                    const SizedBox(height: 10),
                    for (final r in past) ...[
                      _PastCycle(report: r),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplitSummary extends StatelessWidget {
  const _SplitSummary({required this.plan});

  final IncomePlan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              for (final b in Bucket.values)
                if (plan.percentOf(b) > 0)
                  Expanded(
                    flex: plan.percentOf(b),
                    child: Container(height: 10, color: b.color),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final b in Bucket.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Dot(b.color, size: 7),
                  const SizedBox(width: 5),
                  Text(
                    '${b.label} ${plan.percentOf(b)}%',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _PastCycle extends StatelessWidget {
  const _PastCycle({required this.report});

  final CycleReport report;

  @override
  Widget build(BuildContext context) {
    final r = report;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.cycle.label(now: r.now),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              AmountText(
                money(r.income),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (r.income <= 0)
            const Text(
              'No salary found for this cycle.',
              style: TextStyle(fontSize: 12, color: AppColors.faint),
            )
          else ...[
            for (final b in Bucket.values) ...[
              BucketProgressRow(bucket: b, report: r, showPace: false),
              const SizedBox(height: 8),
            ],
            if (r.unknown > 0.0005)
              Text(
                '${money(r.unknown)} in Unknown (no category)',
                style: const TextStyle(fontSize: 11.5, color: AppColors.faint),
              ),
          ],
        ],
      ),
    );
  }
}
