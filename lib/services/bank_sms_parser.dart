/// Turns a raw bank SMS body into a structured transaction.
///
/// Omani banks (Bank Muscat, NBO, Bank Dhofar, Sohar International, OAB, …)
/// each phrase their alerts a little differently, but they almost always
/// contain:
///   * a currency + amount   e.g. "OMR 12.500", "RO 12.500", "12.500 OMR"
///   * a direction keyword    e.g. "debited" / "credited" / "purchase"
///   * (usually) a date and a merchant / counterparty
///
/// The parser requires BOTH a currency amount AND a direction keyword before
/// it treats a message as a transaction — that keeps random texts that merely
/// mention money from being imported. If you find a message that parses
/// wrongly, adjust the keyword lists or [_amountPattern] below; everything the
/// rest of the app relies on flows from this one function.
library;

/// The result of parsing a single SMS. `null` from [parseBankSms] means the
/// message was not recognised as a bank transaction.
class ParsedTransaction {
  const ParsedTransaction({
    required this.amount,
    required this.isCredit,
    required this.description,
    required this.date,
    required this.card,
    required this.balanceAfter,
  });

  /// Always positive. Direction is carried by [isCredit].
  final double amount;

  /// true  = money came IN  (credited / deposit / salary / refund)
  /// false = money went OUT (debited / purchase / withdrawal / payment)
  final bool isCredit;

  /// Merchant or counterparty when we can find one, else a short fallback.
  final String description;

  /// Transaction date parsed from the body, or null to fall back to the SMS
  /// timestamp (handled by the caller).
  final DateTime? date;

  /// The card / account this transaction belongs to, as the last 4 digits
  /// (e.g. "1234"), or empty when the SMS names no card. Lets the app keep
  /// several cards apart.
  final String card;

  /// The available balance the bank stated after this transaction
  /// ("Avl Bal OMR 474.352" / "New available balance OMR 900.000"), or null
  /// when the SMS reports none. Drives the account balances on Overview.
  final double? balanceAfter;
}

/// Words that mean money LEFT the account.
const _debitWords = [
  'debited',
  'debit',
  'purchase',
  'purchased',
  'spent',
  'used for', // "Card ... used for OMR X at MERCHANT"
  'used at',
  'withdrawn',
  'withdrawal',
  'paid',
  'payment',
  'deducted',
  'pos',
  'transfer to',
  'transferred to',
  'sent to',
  'you have sent',
  'تم خصم',
  'بإستخدام بطاقة الخصم المباشر',
  'لقد قمت بإرسال',
  'من حسابك',
];

/// Phrases that mark a message as marketing / promotional rather than a real
/// transaction. Banks send these from the same sender, so we drop any message
/// containing one of these even if it also mentions an amount. Kept
/// deliberately narrow (things a genuine debit/credit alert never says) so we
/// don't discard real transactions — add to this list as you spot new promos.
const _marketingWords = [
  // NOTE: do NOT add "dear customer" / "عزيزي الزبون" here — this bank opens
  // BOTH promos and real transaction alerts with that greeting, so it would
  // reject genuine transactions.
  // Confirmed by the user for their bank: a real alert never contains these.
  'prize',
  'offer',
  'pay bills',
  'draw',
  // General promo giveaways.
  'cashback',
  'discount',
  'voucher',
  'coupon',
  'promo',
  'congratulation',
  'apply now',
  'apply for',
  'click here',
  'click below',
  'http://',
  'https://',
  'www.',
  'unsubscribe',
  'reward point',
  // NOTE: do NOT add "installment" / "instalment" / "EMI" here — real loan
  // installment alerts use those words and must be imported.
  '% off',
  '% cashback',
  'limited time',
  'hurry',
  'exclusive',
  'eligible for',
  'win',
  'winner',
  'you won',
  'giveaway',
  't&c',
  'terms apply',
  'terms and conditions',
  'transfer your salary',
  'enter the draw',
];

/// Words that mean money ENTERED the account.
const _creditWords = [
  'is credited to your', // user-confirmed credit signature
  'credited',
  'credit',
  'deposited',
  'deposit',
  'received',
  'salary',
  'refund',
  'refunded',
  'added',
  'transfer from',
  'transferred from',
  'تم قيد راتبك',
  'تم إيداع',
  'لقد استلمت',
];

/// Matches a currency + amount in either order:
///   OMR 12.500 · RO 12.5 · R.O. 12.500 · 12.500 OMR · 12.500 RO
/// Group `pre` is the amount when the currency comes first, `post` when it
/// comes after. Thousands separators (commas) are tolerated.
final _amountPattern = RegExp(
  r'(?:(?:omr|rials?|ro|r\.o\.?)\s*(?<pre>[\d,]+(?:\.\d{1,3})?))'
  r'|(?:(?<post>[\d,]+(?:\.\d{1,3})?)\s*(?:omr|rials?|ro|r\.o\.?))',
  caseSensitive: false,
);

/// Finds the card / account token after a keyword, e.g. "card ending 1234",
/// "card no XXXX1234", "a/c 0616XXXXXXXX0001", "****1234". The full token
/// (digits + mask characters) is captured; [_extractCard] then takes its last
/// 4 digits, which is the part that actually identifies the card.
final _cardPattern = RegExp(
  r'\b(?:card|a/?c|acct|account|ending)\b'
  r'[^0-9Xx*]{0,12}?([0-9Xx*]{4,})',
  caseSensitive: false,
);

/// Arabic counterpart: the account/card token after حساب ("account") or
/// بطاقة ("card"), e.g. "من حسابك 0304XXXXXXXX0017".
final _cardArPattern = RegExp(
  r'(?:حساب|بطاقة)[^0-9Xx*]{0,12}?([0-9Xx*]{4,})',
  caseSensitive: false,
  unicode: true,
);

/// Common date shapes: 05/08/2026, 5-8-26, 05.08.2026, 2026-08-05.
final _datePattern = RegExp(
  r'(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})'
  r'|(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})',
);

/// Merchant after `at NAME` or counterparty after `to`/`from NAME`,
/// stopping at the next clause (date, "on", balance, punctuation).
final _merchantPattern = RegExp(
  r'\b(?:at|to|from)\s+([A-Za-z0-9][A-Za-z0-9 &._\-]{1,40}?)'
  r'(?=\s+(?:on|dated|avail|available|bal|ref|from|to|using|via|txn|'
  r'a/?c|acct|account)\b'
  r'|[.,;\n]|\s+\d|\s+\S*\d{4,}|$)',
  caseSensitive: false,
);

/// Arabic counterpart: the recipient/merchant after إلى ("to") or لدى ("at"),
/// e.g. "إلى SHU****LAH من حسابك …" → "SHU****LAH". Stops at the next Arabic
/// clause word (من "from", باستخدام "using", رقم "number", رصيد "balance", …)
/// or punctuation.
final _merchantArPattern = RegExp(
  r'(?:إلى|لدى)\s+(\S.{0,40}?)'
  r'(?=\s+(?:من|في|باستخدام|بإستخدام|رقم|رصيد|بتاريخ|عبر|حساب)'
  r'|[.,;\n]|$)',
  caseSensitive: false,
  unicode: true,
);

/// Arabic card-purchase alerts name the shop after في ("at"), prefixed by a
/// terminal id, e.g. "… الخصم المباشر في 451840-ThawaniPay APP بتاريخ …" →
/// "ThawaniPay APP". Stops at the date / balance clause or punctuation.
final _merchantArAtPattern = RegExp(
  r'(?:^|\s)في\s+(\S.{0,40}?)'
  r'(?=\s+(?:بتاريخ|رصيد|من|عبر|رقم)|[.,;\n]|$)',
  caseSensitive: false,
  unicode: true,
);

/// A leading terminal / merchant id glued to the shop name ("451840-").
final _terminalIdPrefix = RegExp(r'^\d+\s*-\s*');

/// Words that follow "from"/"to" in a sentence but are not a name — "withdrawn
/// from your a/c …", "transferred from your account …". Taking them as the
/// name would give every such alert the same name, so filing one ATM
/// withdrawal would drag every transfer along with it.
const _notANameWords = {'your', 'you', 'my', 'the', 'a', 'an'};

/// ATM cash withdrawals ("through ATM11353226", "at ATM", "ATM on …").
final _atmPattern = RegExp(r'\batm', caseSensitive: false);

/// Parses [body]; returns null when it is not a recognisable bank alert.
ParsedTransaction? parseBankSms(String body) {
  final text = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (text.isEmpty) return null;
  final lower = text.toLowerCase();

  // Marketing from the bank's own number: skip it even if it mentions money.
  if (_looksLikeMarketing(lower)) return null;

  final isCredit = _matchesAny(lower, _creditWords);
  final isDebit = _matchesAny(lower, _debitWords);
  // Need exactly one clear direction. If a message somehow contains both, we
  // treat "debit" as the safer default only when a debit word appears; a pure
  // credit with no debit word is a credit.
  if (!isCredit && !isDebit) return null;

  final amount = _extractAmount(text);
  if (amount == null) return null;

  final credit = isCredit && !isDebit;

  return ParsedTransaction(
    amount: amount,
    isCredit: credit,
    description: _extractMerchant(text) ?? (credit ? 'Deposit' : 'Payment'),
    date: _extractDate(text),
    card: _extractCard(text),
    balanceAfter: _extractBalance(text),
  );
}

/// Extracts the available-balance figure — the amount that IS preceded by a
/// balance word ("Avl Bal", "available balance", "bal"). The complement of
/// [_extractAmount], which deliberately skips it. Returns the last such figure
/// (banks put the balance at the end), or null when none is present.
double? _extractBalance(String text) {
  double? balance;
  for (final m in _amountPattern.allMatches(text)) {
    final raw = m.namedGroup('pre') ?? m.namedGroup('post');
    if (raw == null) continue;
    final value = double.tryParse(raw.replaceAll(',', ''));
    if (value == null || value < 0) continue;
    final start = m.start < 20 ? 0 : m.start - 20;
    final before = text.substring(start, m.start).toLowerCase();
    if (before.contains('bal') ||
        before.contains('available') ||
        before.contains('رصيد')) {
      balance = value;
    }
  }
  return balance;
}

String _extractCard(String text) {
  final token =
      (_cardPattern.firstMatch(text) ?? _cardArPattern.firstMatch(text))?.group(
        1,
      );
  if (token == null) return '';
  // Keep only real digits (drop the X / * mask characters), then the last 4 —
  // that is the part that tells one card apart from another.
  final digits = token.replaceAll(RegExp('[^0-9]'), '');
  if (digits.length < 4) return '';
  return digits.substring(digits.length - 4);
}

bool _matchesAny(String lower, List<String> words) =>
    words.any((w) => lower.contains(w));

/// True when [lower] looks like a marketing message. Purely alphabetic phrases
/// (e.g. "draw", "offer") are matched as whole words so they don't fire inside
/// unrelated words — "draw" must not match "withdrawn". Phrases containing
/// symbols/spaces (URLs, "% off") are matched as plain substrings.
bool _looksLikeMarketing(String lower) {
  for (final raw in _marketingWords) {
    // Lowercase defensively so a capitalised list entry still matches the
    // (already lowercased) message instead of silently never firing.
    final w = raw.toLowerCase();
    // "wordish" = letters and single interior spaces only (no leading/trailing
    // space, no symbols) — those are safe to anchor with word boundaries.
    final wordish = RegExp(r'^[a-z]+( [a-z]+)*$').hasMatch(w);
    if (wordish) {
      if (RegExp('\\b${RegExp.escape(w)}\\b').hasMatch(lower)) return true;
    } else if (lower.contains(w)) {
      return true;
    }
  }
  return false;
}

/// Picks the transaction amount, skipping any amount that is actually the
/// balance line ("avail bal OMR …"). Returns the first non-balance amount.
double? _extractAmount(String text) {
  double? firstAny;
  for (final m in _amountPattern.allMatches(text)) {
    final raw = m.namedGroup('pre') ?? m.namedGroup('post');
    if (raw == null) continue;
    final value = double.tryParse(raw.replaceAll(',', ''));
    if (value == null || value <= 0) continue;
    firstAny ??= value;

    // Look at the ~14 characters before this match: if they mention a balance,
    // this is the balance figure, not the transaction — skip it.
    final start = m.start < 14 ? 0 : m.start - 14;
    final before = text.substring(start, m.start).toLowerCase();
    if (before.contains('bal') ||
        before.contains('available') ||
        before.contains('رصيد')) {
      continue;
    }
    return value;
  }
  // Everything looked like a balance? Fall back to the first amount so we still
  // capture the transaction rather than dropping it.
  return firstAny;
}

DateTime? _extractDate(String text) {
  final m = _datePattern.firstMatch(text);
  if (m == null) return null;
  try {
    if (m.group(1) != null) {
      // yyyy-mm-dd
      return DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    }
    // dd-mm-yy(yy)
    var year = int.parse(m.group(6)!);
    if (year < 100) year += 2000;
    final day = int.parse(m.group(4)!);
    final month = int.parse(m.group(5)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}

String? _extractMerchant(String text) {
  String? name;
  for (final m in _merchantPattern.allMatches(text)) {
    final candidate = m.group(1)!.trim();
    final first = candidate.split(' ').first.toLowerCase();
    if (_notANameWords.contains(first)) continue;
    name = candidate;
    break;
  }
  name ??= _merchantArPattern.firstMatch(text)?.group(1)?.trim();
  if (name == null) {
    final at = _merchantArAtPattern.firstMatch(text)?.group(1)?.trim();
    final shop = at?.replaceFirst(_terminalIdPrefix, '').trim();
    // Must contain a letter, so "في 2026/10/31" is never taken as a shop.
    if (shop != null && RegExp(r'[^\d\s/:.\-]').hasMatch(shop)) name = shop;
  }
  if (name == null && _atmPattern.hasMatch(text)) name = 'ATM';
  if (name == null || name.isEmpty) return null;
  return name.replaceAll(RegExp(r'\s{2,}'), ' ');
}
