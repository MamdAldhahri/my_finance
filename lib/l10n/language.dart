import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// The languages the app ships with.
enum AppLanguage {
  en(Locale('en')),
  ar(Locale('ar'));

  const AppLanguage(this.locale);

  final Locale locale;

  bool get isRtl => this == AppLanguage.ar;

  /// The other language: what the app-bar toggle switches to.
  AppLanguage get other => this == en ? ar : en;

  static AppLanguage fromCode(String? code) =>
      values.where((l) => l.name == code).firstOrNull ?? en;
}

/// The current app language. [FinanceApp] listens to this; the rest of the
/// app reads the strings through [tr].
final ValueNotifier<AppLanguage> appLanguage = ValueNotifier(AppLanguage.en);

/// Strings in the current language. Usable anywhere, even without a
/// [BuildContext] (services, formatters), because a language switch rebuilds
/// the whole widget tree.
AppLocalizations get tr => lookupAppLocalizations(appLanguage.value.locale);

/// The settings key the chosen language is saved under.
const languageSettingKey = 'language';

/// Restores the saved language (or, on first launch, picks Arabic when the
/// phone is set to Arabic) so the app opens in it.
Future<void> loadAppLanguage(AppDatabase db) async {
  await initializeDateFormatting('ar');
  final saved = await db.getSetting(languageSettingKey);
  final lang = saved != null
      ? AppLanguage.fromCode(saved)
      : PlatformDispatcher.instance.locale.languageCode == 'ar'
      ? AppLanguage.ar
      : AppLanguage.en;
  _apply(lang);
}

/// Switches the app to [lang] and remembers it for next time.
Future<void> setAppLanguage(AppDatabase db, AppLanguage lang) async {
  _apply(lang);
  await db.setSetting(languageSettingKey, lang.name);
}

void _apply(AppLanguage lang) => appLanguage.value = lang;

/// A [DateFormat] in the current language that keeps Western digits, so dates
/// match the amounts (which always use 0-9).
DateFormat appDateFormat(String pattern) => appLanguage.value == AppLanguage.ar
    ? (DateFormat(pattern, 'ar')..useNativeDigits = false)
    : DateFormat(pattern);
