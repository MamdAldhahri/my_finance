import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../l10n/language.dart';
import '../theme.dart';
import 'transaction_row.dart';

/// Shows the original bank SMS behind [t] in a pop-up, so the user can see
/// exactly what the bank said (and why it landed where it did). Manual
/// entries, which have no SMS, show a short note instead.
///
/// With [onChangeCategory] the pop-up also offers a "Change category" button
/// (the Transactions tab), which closes it and runs the callback.
Future<void> showSmsBody(
  BuildContext context,
  Transaction t, {
  VoidCallback? onChangeCategory,
}) {
  final body = t.rawMessage.trim();
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        t.description.isEmpty ? tr.payment : t.description,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                shortDate(t.date),
                if (t.source == TxSource.sms) bankName(t.sender),
                '${t.isCredit ? '+' : ''}${money(t.amount)}',
              ].join(' · '),
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            SelectableText(
              body.isEmpty ? tr.addedByHandNoSms : body,
              // Arabic and English alerts both read correctly this way.
              textDirection: _isArabic(body) ? TextDirection.rtl : null,
              style: const TextStyle(
                  fontSize: 14, height: 1.4, color: AppColors.ink),
            ),
          ],
        ),
      ),
      actions: [
        if (onChangeCategory != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onChangeCategory();
            },
            child: Text(tr.changeCategory,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.green)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr.close,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.green)),
        ),
      ],
    ),
  );
}

bool _isArabic(String s) => RegExp(r'^[^A-Za-z]*[؀-ۿ]').hasMatch(s);
