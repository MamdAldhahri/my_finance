import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../theme.dart';

/// One transaction line, shared by Overview's "Recent activity" and the
/// Transactions list. [category] is the already-resolved category (auto or
/// manual), or null when uncategorised.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.txn,
    required this.category,
    this.onTap,
    this.showDivider = true,
  });

  final Transaction txn;
  final Category? category;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final credit = txn.isCredit;
    final accent = credit ? AppColors.incomeColor : AppColors.expenseColor;
    final title = txn.description.isEmpty
        ? (credit ? 'Deposit' : 'Payment')
        : txn.description;
    final initial = title.characters.first.toUpperCase();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.cardBorder))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _subtitle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.faint),
                  ),
                  if (category != null) ...[
                    const SizedBox(height: 5),
                    _CategoryTag(category!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${credit ? '+' : '-'}${money(txn.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final source = txn.source == TxSource.manual
        ? 'Cash'
        : _bank(txn.sender) + (txn.card.isEmpty ? '' : ' ••••${txn.card}');
    return '$source · ${dayLabel(txn.date)}';
  }

  static String _bank(String sender) {
    if (sender.isEmpty) return 'Bank';
    return sender
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag(this.category);

  final Category category;

  @override
  Widget build(BuildContext context) {
    final color = hexColor(category.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
