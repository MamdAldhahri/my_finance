import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'database/database.dart';
import 'l10n/language.dart';
import 'screens/categories_screen.dart';
import 'screens/debts_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/transactions_screen.dart';
import 'services/sms_import.dart';
import 'theme.dart';

late final AppDatabase db;
late final SmsImportService smsImport;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw behind a transparent status bar with dark icons, matching the warm
  // light UI — so no dark strip is ever painted above the content.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  db = AppDatabase();
  smsImport = SmsImportService(db);

  // Open in the language the user picked last time.
  await loadAppLanguage(db);

  // Bring names of already-imported SMS up to date with the current parser.
  await refreshSmsDescriptions(db);

  // If the user already enabled auto-import, resume it: start the live
  // listener and pull in anything received while the app was closed.
  if (await db.isSmsImportEnabled()) {
    smsImport.startListening();
    unawaited(smsImport.scanInbox());
  }

  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  @override
  void initState() {
    super.initState();
    appLanguage.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    appLanguage.removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// Strings are read through [tr], so a language switch rebuilds every
  /// widget (keeping their state, like the selected tab) to pick them up.
  void _onLanguageChanged() {
    setState(() {});
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (_) => tr.appTitle,
      theme: buildAppTheme(),
      locale: lang.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _screens = [
    OverviewScreen(),
    CategoriesScreen(),
    DebtsScreen(),
    GoalsScreen(),
    TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// The design's flat 5-item nav: coloured icon + label, no pill highlight.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home, tr.navOverview),
      (Icons.grid_view_outlined, Icons.grid_view, tr.navCategories),
      (Icons.credit_card_outlined, Icons.credit_card, tr.navDebt),
      (Icons.adjust_outlined, Icons.adjust, tr.navGoals),
      (Icons.swap_horiz, Icons.swap_horiz, tr.navTransactions),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.screen,
        border: Border(top: BorderSide(color: Color(0x121E2E2A))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavItem(
                  icon: index == i ? items[i].$2 : items[i].$1,
                  label: items[i].$3,
                  active: index == i,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ink : AppColors.inactive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
