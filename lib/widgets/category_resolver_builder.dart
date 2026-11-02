import 'package:flutter/material.dart';

import '../database/database.dart';
import '../main.dart';
import '../services/category_matching.dart';

/// Rebuilds [builder] with a fresh [CategoryResolver] whenever categories,
/// their rules, removals or debt payments change.
class CategoryResolverBuilder extends StatefulWidget {
  const CategoryResolverBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    List<Category> categories,
    CategoryResolver resolver,
  ) builder;

  @override
  State<CategoryResolverBuilder> createState() =>
      _CategoryResolverBuilderState();
}

class _CategoryResolverBuilderState extends State<CategoryResolverBuilder> {
  // Created once so parent rebuilds don't resubscribe (and flash empty).
  final _categories = db.watchCategories();
  final _rules = db.watchCategoryRules();
  final _exclusions = db.watchCategoryExclusions();
  final _payments = db.watchDebtPayments();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: _categories,
      builder: (context, cats) => StreamBuilder<List<CategoryRule>>(
        stream: _rules,
        builder: (context, rules) => StreamBuilder<List<CategoryExclusion>>(
          stream: _exclusions,
          builder: (context, excl) => StreamBuilder<List<DebtPayment>>(
            stream: _payments,
            builder: (context, pays) {
              final categories = cats.data ?? const <Category>[];
              return widget.builder(
                context,
                categories,
                CategoryResolver(
                  categories: categories,
                  rules: rules.data ?? const [],
                  exclusions: excl.data ?? const [],
                  debtPayments: pays.data ?? const [],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
