import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database/database.dart';
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

  // If the user already enabled auto-import, resume it: start the live
  // listener and pull in anything received while the app was closed.
  if (await db.isSmsImportEnabled()) {
    smsImport.startListening();
    unawaited(smsImport.scanInbox());
  }

  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Finance',
      theme: buildAppTheme(),
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
    TransactionsScreen(),
    CategoriesScreen(),
    DebtsScreen(),
    GoalsScreen(),
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

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Overview'),
    (Icons.swap_horiz, Icons.swap_horiz, 'Transactions'),
    (Icons.grid_view_outlined, Icons.grid_view, 'Categories'),
    (Icons.credit_card_outlined, Icons.credit_card, 'Debt'),
    (Icons.adjust_outlined, Icons.adjust, 'Goals'),
  ];

  @override
  Widget build(BuildContext context) {
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
              for (var i = 0; i < _items.length; i++)
                _NavItem(
                  icon: index == i ? _items[i].$2 : _items[i].$1,
                  label: _items[i].$3,
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
