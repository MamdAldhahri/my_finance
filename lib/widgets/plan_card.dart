import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../l10n/language.dart';
import '../services/income_plan.dart';
import '../theme.dart';
import 'ui.dart';

/// Overview card for the running pay cycle: each bucket's actual against
/// its planned amount, days left and safe-to-spend per day. Without a plan
/// it invites the user to set one up.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onSetUp,
  });

  /// Null when no plan is saved yet.
  final CycleReport? report;
  final VoidCallback onTap;
  final VoidCallback onSetUp;

  @override
  Widget build(BuildContext context) {
    final r = report;
    if (r == null) return _SetUpPrompt(onTap: onSetUp);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr.thisCycle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${r.cycle.label(now: r.now)} · ${_daysLeftText(r)}',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            incomeLine(r),
            style: const TextStyle(fontSize: 12, color: AppColors.faint),
          ),
          const SizedBox(height: 14),
          if (r.income <= 0)
            Text(
              tr.noSalaryYetHint,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            )
          else ...[
            for (final b in Bucket.values) ...[
              BucketProgressRow(bucket: b, report: r),
              const SizedBox(height: 12),
            ],
            if (r.unknown > 0.0005) ...[
              _UnknownLine(amount: r.unknown),
              const SizedBox(height: 12),
            ],
            if (r.isRunning) _SafeToSpend(report: r),
          ],
        ],
      ),
    );
  }
}

String _daysLeftText(CycleReport r) {
  final d = r.daysLeft;
  if (!r.isRunning) return tr.cycleEnded;
  return tr.daysLeft(d);
}

/// "Salary 850.000 OMR" plus where the figure came from.
String incomeLine(CycleReport r) {
  final amount = money(r.income);
  return switch (r.incomeSource) {
    IncomeSource.detected => tr.incomeDetected(amount),
    IncomeSource.expected => tr.incomeExpected(amount),
    IncomeSource.lastCycle => tr.incomeLastCycle(amount),
    IncomeSource.none => tr.incomeNone,
  };
}

/// One bucket: name, "actual of planned", and a bar. Spending buckets turn
/// red when they go over; saving buckets fill up green.
class BucketProgressRow extends StatelessWidget {
  const BucketProgressRow({
    super.key,
    required this.bucket,
    required this.report,
    this.showPace = true,
  });

  final Bucket bucket;
  final CycleReport report;
  final bool showPace;

  @override
  Widget build(BuildContext context) {
    final planned = report.plannedFor(bucket);
    final actual = report.actualFor(bucket);
    final frac = planned <= 0 ? (actual > 0 ? 1.0 : 0.0) : actual / planned;
    final over = bucket.isSpending && actual > planned + 0.0005;
    // A spending bucket running ahead of the calendar is a warning.
    final ahead =
        bucket.isSpending &&
        report.isRunning &&
        showPace &&
        frac > report.elapsedFraction + 0.1;
    final barColor = over
        ? AppColors.terracotta
        : ahead
        ? AppColors.peach
        : bucket.color;

    final String status;
    if (bucket.isSpending) {
      status = over
          ? tr.amountOver(amountText(actual - planned))
          : tr.amountLeft(amountText(planned - actual));
    } else {
      status = actual >= planned - 0.0005
          ? tr.done
          : tr.amountToGo(amountText(planned - actual));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Dot(bucket.color, size: 8),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                bucket.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              '${amountText(actual)} / ${amountText(planned)}',
              // Numbers read "spent / planned" in Arabic too.
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(fraction: frac, color: barColor, height: 6),
        const SizedBox(height: 3),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: over ? AppColors.terracotta : AppColors.faint,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnknownLine extends StatelessWidget {
  const _UnknownLine({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, size: 15, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tr.unknownSpendingHint,
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          AmountText(
            money(amount),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeToSpend extends StatelessWidget {
  const _SafeToSpend({required this.report});

  final CycleReport report;

  @override
  Widget build(BuildContext context) {
    final left = report.spendingLeft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left <= 0
                  ? tr.spendingOverPlan
                  : tr.safeToSpendPerDay,
              style: const TextStyle(fontSize: 12.5, color: Colors.white70),
            ),
          ),
          AmountText(
            money(left <= 0 ? -left : report.safePerDay),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: left <= 0 ? AppColors.peach : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SetUpPrompt extends StatelessWidget {
  const _SetUpPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pie_chart_outline,
              size: 20,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.planYourSalary,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  tr.planYourSalaryHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.faint),
        ],
      ),
    );
  }
}
