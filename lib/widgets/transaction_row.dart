import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../theme.dart';
import 'ui.dart';

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
    this.showInitial = true,
    this.showUnknown = false,
  });

  final Transaction txn;
  final Category? category;
  final VoidCallback? onTap;
  final bool showDivider;

  /// The coloured first-letter tile at the start of the row.
  final bool showInitial;

  /// Shows an "Unknown" tag when [category] is null (an uncategorised SMS).
  final bool showUnknown;

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
            if (showInitial) ...[
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
            ],
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
                  ] else if (showUnknown) ...[
                    const SizedBox(height: 5),
                    const _UnknownTag(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AmountText(
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
        : bankName(txn.sender);
    return '$source · ${dayLabel(txn.date)}';
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

/// The bank's name for an SMS [sender] id, e.g. "BankMuscat" → "Bank Muscat",
/// "bank dhofar" → "Bank Dhofar". Shown instead of the card's last 4 digits.
String bankName(String sender) {
  final spaced = sender
      .replaceAll(RegExp(r'[-_]+'), ' ')
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  final words = spaced.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return 'Bank';
  return words.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

/// The grey tag for an SMS no category has claimed (it sits in Unknown).
class _UnknownTag extends StatelessWidget {
  const _UnknownTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.inactive.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Unknown',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
