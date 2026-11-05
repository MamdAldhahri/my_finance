import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finance/database/database.dart';
import 'package:finance/main.dart';
import 'package:finance/screens/overview_screen.dart';
import 'package:finance/screens/plan_setup_screen.dart';
import 'package:finance/services/income_plan.dart';
import 'package:finance/theme.dart';
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

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  /// Drift closes stream queries on a short timer; let it fire.
  Future<void> settleStreams(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('overview invites to plan, then shows the cycle card', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final now = DateTime.now();
      await db.addManualTransaction(
        description: 'Salary',
        amount: 1000,
        isCredit: true,
        date: now.subtract(const Duration(days: 1)),
      );
      final food = await db.addCategory(
        CategoriesCompanion.insert(
          name: 'Groceries',
          bucket: const Value(Bucket.expenses),
        ),
      );
      await db.addManualTransaction(
        description: 'LULU',
        amount: 120,
        isCredit: false,
        date: now,
        categoryId: food,
      );
      await db.addManualTransaction(
        description: 'Shop',
        amount: 7,
        isCredit: false,
        date: now,
      );
    });
    await pump(tester, const OverviewScreen());
    expect(find.text('Plan your salary'), findsOneWidget);

    await tester.runAsync(
      () => saveIncomePlan(db, IncomePlan.fromPreset(PlanPreset.balanced)),
    );
    await pump(tester, const OverviewScreen());
    expect(find.text('This cycle'), findsOneWidget);
    expect(find.text('Emergency & Savings'), findsOneWidget);
    expect(find.textContaining('120.000 / 500.000'), findsOneWidget);
    expect(find.text('Safe to spend per day'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('This cycle'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Income plan'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await settleStreams(tester);
  });

  testWidgets('setup screen only saves when the split adds up to 100', (
    tester,
  ) async {
    await pump(tester, const PlanSetupScreen());
    await tester.tap(find.text('Aggressive saver 45/10/15/30'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Total 100%'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Total 100%'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await settleStreams(tester);
  });
}
