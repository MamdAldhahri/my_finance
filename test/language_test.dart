import 'package:drift/native.dart';
import 'package:finance/database/database.dart';
import 'package:finance/format.dart';
import 'package:finance/l10n/language.dart';
import 'package:finance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Real fonts, so text widths (and overflows) match the device.
    Future<void> load(String family, List<String> files) async {
      final loader = FontLoader(family);
      for (final f in files) {
        loader.addFont(rootBundle.load('assets/fonts/$f'));
      }
      await loader.load();
    }

    await load('Manrope', ['Manrope-VariableFont_wght.ttf']);
    await load('Newsreader', ['Newsreader-VariableFont_opsz,wght.ttf']);
  });

  setUp(() => appLanguage.value = AppLanguage.en);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  testWidgets('the Overview toggle switches to Arabic, right to left, and '
      'saves the choice', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FinanceApp());
    await settle(tester);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('ع'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Overview'))),
      TextDirection.ltr,
    );

    await tester.tap(find.byKey(const ValueKey('language-toggle')));
    await settle(tester);

    expect(appLanguage.value, AppLanguage.ar);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الديون'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('الرئيسية'))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);

    final saved = await tester.runAsync(
      () => db.getSetting(languageSettingKey),
    );
    expect(saved, 'ar');

    // Back to English.
    await tester.tap(find.byKey(const ValueKey('language-toggle')));
    await settle(tester);
    expect(find.text('Overview'), findsOneWidget);
    expect(appLanguage.value, AppLanguage.en);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  test('the saved language is restored on the next launch', () async {
    await db.setSetting(languageSettingKey, 'ar');
    appLanguage.value = AppLanguage.en;
    await loadAppLanguage(db);
    expect(appLanguage.value, AppLanguage.ar);
    expect(currency, 'ر.ع.');
    expect(money(1850), '1,850.000 ر.ع.');

    await db.setSetting(languageSettingKey, 'en');
    await loadAppLanguage(db);
    expect(appLanguage.value, AppLanguage.en);
    expect(money(1850), '1,850.000 OMR');
  });

  test('Arabic dates keep Western digits', () async {
    await loadAppLanguage(db);
    appLanguage.value = AppLanguage.ar;
    expect(shortDate(DateTime(2026, 11, 5)), contains('2026'));
    expect(shortDate(DateTime(2026, 11, 5)), contains('نوفمبر'));
  });
}
