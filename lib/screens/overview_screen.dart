import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../l10n/language.dart';
import '../main.dart';
import '../services/category_matching.dart';
import '../services/debt_matching.dart';
import '../services/derive.dart';
import '../services/income_plan.dart';
import '../services/pay_cycle.dart';
import '../theme.dart';
import '../widgets/category_resolver_builder.dart';
import '../widgets/plan_card.dart';
import '../widgets/sms_body_dialog.dart';
import '../widgets/transaction_row.dart';
import '../widgets/ui.dart';
import 'plan_detail_screen.dart';
import 'plan_setup_screen.dart';

/// Created once so rebuilds don't resubscribe (and flash the set-up prompt).
final Stream<IncomePlan?> _planStream = watchIncomePlan(db);

/// Home tab: total balance (from SMS), per-account breakdown, debt & goals
/// summaries, and recent activity.
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<Transaction>>(
        stream: db.watchTransactions(),
        builder: (context, txSnap) {
          final txns = txSnap.data ?? const [];
          return CategoryResolverBuilder(
            builder: (context, categories, resolver) {
              return StreamBuilder<List<Debt>>(
                stream: db.watchDebts(),
                builder: (context, debtSnap) {
                  return StreamBuilder<List<DebtPayment>>(
                    stream: db.watchDebtPayments(),
                    builder: (context, paySnap) {
                      return StreamBuilder<List<Goal>>(
                        stream: db.watchGoals(),
                        builder: (context, goalSnap) {
                          return StreamBuilder<IncomePlan?>(
                            stream: _planStream,
                            builder: (context, planSnap) {
                              return _Body(
                                txns: txns,
                                categories: categories,
                                resolver: resolver,
                                debts: debtSnap.data ?? const [],
                                debtPayments: paySnap.data ?? const [],
                                goals: goalSnap.data ?? const [],
                                plan: planSnap.data,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.txns,
    required this.categories,
    required this.resolver,
    required this.debts,
    required this.debtPayments,
    required this.goals,
    required this.plan,
  });

  final List<Transaction> txns;
  final List<Category> categories;
  final CategoryResolver resolver;
  final List<Debt> debts;
  final List<DebtPayment> debtPayments;
  final List<Goal> goals;
  final IncomePlan? plan;

  @override
  Widget build(BuildContext context) {
    final accounts = deriveAccounts(txns);
    final total = accounts.fold(0.0, (s, a) => s + a.balance);
    final delta = balanceDeltaPct(txns);

    final debtTotal = debts.fold<double>(0, (s, d) => s + d.totalAmount);
    final debtPaid = debts.fold<double>(
        0,
        (s, d) =>
            s + progressOf(d, debtPayments).paid.clamp(0.0, d.totalAmount));
    final debtLeft = debtTotal - debtPaid;
    final debtPaidFrac = debtTotal <= 0 ? 0.0 : debtPaid / debtTotal;

    final goalsSaved = goals.fold<double>(0, (s, g) => s + g.savedAmount);
    final goalsTarget = goals.fold<double>(0, (s, g) => s + g.targetAmount);
    final goalsFrac = goalsTarget <= 0 ? 0.0 : goalsSaved / goalsTarget;

    final recent = txns.take(4).toList();

    final inputs = PlanInputs(
      txns: txns,
      resolver: resolver,
      categories: categories,
      debts: debts,
      debtPayments: debtPayments,
    );
    final plan = this.plan;
    final cycle = PayCycles.fromTransactions(txns).current;
    final report = plan == null ? null : inputs.report(cycle, plan);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _Header(),
        const SizedBox(height: 18),
        _BalanceCard(accounts: accounts, total: total, deltaPct: delta),
        const SizedBox(height: 16),
        PlanCard(
          report: report,
          onSetUp: () => openPlanSetup(context, plan),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PlanDetailScreen(inputs: inputs),
          )),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: tr.debtLeft,
                value: debtLeft,
                fraction: debtPaidFrac,
                color: AppColors.terracotta,
                icon: Icons.trending_flat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: tr.goalsSaved,
                value: goalsSaved,
                fraction: goalsFrac,
                color: AppColors.green,
                icon: Icons.adjust,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          tr.recentActivity,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                tr.noTransactionsYet,
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
                for (var i = 0; i < recent.length; i++)
                  TransactionRow(
                    txn: recent[i],
                    category: _categoryOf(recent[i]),
                    showDivider: i != recent.length - 1,
                    showInitial: false,
                    showUnknown: recent[i].source == TxSource.sms &&
                        !recent[i].isCredit &&
                        !resolver.isDebtPayment(recent[i]),
                    onTap: () => showSmsBody(context, recent[i]),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Category? _categoryOf(Transaction t) {
    final id = resolver.categoryIdFor(t);
    if (id == null) return null;
    return categories.where((c) => c.id == id).firstOrNull;
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? tr.goodMorning
        : hour < 18
            ? tr.goodAfternoon
            : tr.goodEvening;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            Text(
              tr.appTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _LanguageToggle(),
            const SizedBox(width: 10),
            _Avatar(),
          ],
        ),
      ],
    );
  }
}

/// App-bar pill that flips between English and Arabic. Shows the language it
/// switches to ("ع" while in English, "EN" while in Arabic); the choice is
/// saved so the app opens in it next time.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tr.switchLanguage,
      child: Material(
        color: AppColors.green.withValues(alpha: 0.10),
        shape: const StadiumBorder(),
        child: InkWell(
          key: const ValueKey('language-toggle'),
          customBorder: const StadiumBorder(),
          onTap: () => setAppLanguage(db, appLanguage.value.other),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate, size: 16, color: AppColors.green),
                const SizedBox(width: 6),
                Text(
                  tr.languageToggleLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.green,
        shape: BoxShape.circle,
      ),
      child: const Text(
        'M',
        style: TextStyle(
          fontFamily: 'Newsreader',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.accounts,
    required this.total,
    required this.deltaPct,
  });

  final List<Account> accounts;
  final double total;
  final double? deltaPct;

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MutedCaps(tr.totalBalance, color: Colors.white60),
          const SizedBox(height: 6),
          SerifAmount(money(total),
              size: 38, color: Colors.white, weight: FontWeight.w500),
          if (deltaPct != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${deltaPct! >= 0 ? '+' : ''}${deltaPct!.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mint,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tr.vsBeforePayday,
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ],
          if (accounts.isNotEmpty) ...[
            const SizedBox(height: 20),
            MutedCaps(tr.yourAccounts, color: Colors.white54, size: 11),
            const SizedBox(height: 8),
            for (final a in accounts) ...[
              _AccountRow(account: a),
              if (a != accounts.last) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Dot(account.color, size: 8),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              account.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          AmountText(
            money(account.balance),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final double fraction;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 10),
          SerifAmount(money(value), size: 20),
          const SizedBox(height: 10),
          ProgressBar(fraction: fraction, color: color, height: 5),
        ],
      ),
    );
  }
}
