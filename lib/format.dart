import 'package:intl/intl.dart';

/// App-wide currency formatting. Omani Rial uses 3 decimal places and the
/// design groups thousands (e.g. "1,850.000").
final NumberFormat _amount = NumberFormat('#,##0.000');

/// The numeric part of an amount, grouped with 3 decimals: "1,850.000".
/// Always non-negative — carry the sign separately where needed.
String amountText(double value) => _amount.format(value.abs());

/// Full money label with the currency prefix: "OMR 1,850.000".
String money(double value) => 'OMR ${amountText(value)}';

/// Short date, e.g. "20 Jul 2026".
String shortDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

/// Compact day label used in transaction rows, e.g. "Aug 2".
String dayLabel(DateTime date) => DateFormat('MMM d').format(date);

/// Full month name, e.g. "August".
String monthName(DateTime date) => DateFormat('MMMM').format(date);

/// Month + year for goal/debt due dates, e.g. "Dec 2026".
String monthYear(DateTime date) => DateFormat('MMM yyyy').format(date);
