import 'package:another_telephony/telephony.dart' hide Value;
import 'package:drift/drift.dart' show Value;

import '../database/database.dart';
import 'bank_sms_parser.dart';

/// One SMS sender, summarised for the "which chat is your bank?" picker.
class SmsSender {
  const SmsSender({
    required this.address,
    required this.sample,
    required this.count,
  });

  /// The sender id as it appears in the inbox, e.g. "BankMuscat", "NBO".
  final String address;

  /// The most recent message body from this sender, shown as a preview.
  final String sample;

  /// How many messages this sender has sent (helps spot the busy ones).
  final int count;
}

/// Reads bank SMS and turns each recognised alert into a [Transaction].
///
/// The user first tells the app WHICH sender(s) are their bank (stored via
/// [AppDatabase.setBankSenders]); only messages from those senders are ever
/// parsed. Two entry points feed the same [_ingest] pipeline:
///   * [scanInbox]     – walks the existing inbox (app start / "Scan now").
///   * [startListening] – imports new alerts live while the app is open.
///
/// SMS is an Android-only capability. On every other platform the plugin calls
/// throw, so all of them are guarded and turn into a no-op.
class SmsImportService {
  SmsImportService(this._db);

  final AppDatabase _db;
  final Telephony _telephony = Telephony.instance;
  bool _listening = false;

  /// Asks the OS for SMS read/receive permission. Returns true if granted.
  Future<bool> requestPermission() async {
    try {
      return await _telephony.requestSmsPermissions ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Lists the distinct senders in the inbox, most-recent first, so the user
  /// can point at their bank. Returns an empty list off Android / without
  /// permission.
  Future<List<SmsSender>> inboxSenders() async {
    final messages = await _readInbox();
    // Preserve inbox order (newest first) while collapsing by sender.
    final byAddress = <String, ({String sample, int count})>{};
    for (final sms in messages) {
      final address = sms.address ?? '';
      if (address.isEmpty) continue;
      final existing = byAddress[address];
      byAddress[address] = (
        // Keep the first (newest) body we saw as the preview.
        sample: existing?.sample ?? (sms.body ?? ''),
        count: (existing?.count ?? 0) + 1,
      );
    }
    return [
      for (final e in byAddress.entries)
        SmsSender(address: e.key, sample: e.value.sample, count: e.value.count),
    ];
  }

  /// Imports every recognised bank alert from the selected senders. Returns the
  /// number of NEW transactions added (duplicates are skipped).
  ///
  /// Queries each bank sender directly (filtered by address AND date in the
  /// content provider), so the phone only ever hands us the bank's recent
  /// messages — not the whole inbox — which keeps the scan fast.
  Future<int> scanInbox() async {
    final senders = await _db.getBankSenders();
    if (senders.isEmpty) return 0; // nothing selected yet

    var added = 0;
    for (final sender in senders) {
      for (final sms in await _readInboxFrom(sender)) {
        if (await _ingest(sms)) added++;
      }
    }
    return added;
  }

  /// Starts importing new messages as they arrive (foreground only — the app
  /// must be open). Idempotent: calling twice does not double-register.
  void startListening() {
    if (_listening) return;
    _listening = true;
    try {
      _telephony.listenIncomingSms(
        onNewMessage: (SmsMessage sms) async {
          final senders = (await _db.getBankSenders()).toSet();
          if (senders.contains(sms.address)) await _ingest(sms);
        },
        listenInBackground: false,
      );
    } catch (_) {
      _listening = false;
    }
  }

  /// Start of the import window: the current month plus the previous two.
  /// Messages older than that are ignored, so scans stay fast even on phones
  /// holding years of SMS.
  int get _cutoffMillis {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 2, 1).millisecondsSinceEpoch;
  }

  static const _cols = [
    SmsColumn.ID,
    SmsColumn.ADDRESS,
    SmsColumn.BODY,
    SmsColumn.DATE,
  ];

  /// Reads recent inbox messages across all senders (used only by the bank
  /// picker), newest first, within the one-month window.
  Future<List<SmsMessage>> _readInbox() async {
    try {
      return await _telephony.getInboxSms(
        columns: _cols,
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThanOrEqualTo(_cutoffMillis.toString()),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );
    } catch (_) {
      // Not Android, permission missing, or query failed.
      return const [];
    }
  }

  /// Reads recent messages from a single [sender] within the one-month window.
  /// Filtering by address in the query means the whole inbox is never scanned.
  Future<List<SmsMessage>> _readInboxFrom(String sender) async {
    try {
      return await _telephony.getInboxSms(
        columns: _cols,
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThanOrEqualTo(_cutoffMillis.toString())
            .and(SmsColumn.ADDRESS)
            .equals(sender),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );
    } catch (_) {
      return const [];
    }
  }

  /// Parses one SMS and stores it if it is a new bank transaction.
  /// Returns true when a row was inserted.
  Future<bool> _ingest(SmsMessage sms) async {
    final body = sms.body;
    if (body == null || body.isEmpty) return false;

    final parsed = parseBankSms(body);
    if (parsed == null) return false;

    // Use the bank-stated day for correct monthly grouping, but keep the SMS
    // receipt time-of-day so same-day transactions order correctly (which
    // decides each account's latest balance). Fall back to receipt / now.
    final receipt = sms.date != null
        ? DateTime.fromMillisecondsSinceEpoch(sms.date!)
        : null;
    final DateTime date;
    if (parsed.date != null) {
      final d = parsed.date!;
      date = receipt != null
          ? DateTime(d.year, d.month, d.day, receipt.hour, receipt.minute,
              receipt.second)
          : d;
    } else {
      date = receipt ?? DateTime.now();
    }

    // Messages received live can arrive without a stable inbox id; dedupe
    // those by body so the follow-up inbox scan does not re-add them.
    if (sms.id == null && await _db.transactionBodyExists(body)) {
      return false;
    }

    final rowId = await _db.addSmsTransaction(
      TransactionsCompanion.insert(
        amount: parsed.amount,
        isCredit: parsed.isCredit,
        date: date,
        description: Value(parsed.description),
        source: const Value(TxSource.sms),
        sender: Value(sms.address ?? ''),
        card: Value(parsed.card),
        balanceAfter: Value(parsed.balanceAfter),
        rawMessage: Value(body),
        smsId: Value(sms.id),
      ),
    );
    return rowId != null;
  }
}
