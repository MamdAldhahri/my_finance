import 'package:flutter/material.dart';

import '../theme.dart';

/// A white rounded card with the design's hairline border. The default padding
/// and radius match the mockup's list/stat cards.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
    if (onTap == null) return decorated;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: decorated,
    );
  }
}

/// The dark forest-green hero card used for balances and totals.
class DarkCard extends StatelessWidget {
  const DarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// A thin rounded progress bar. [fraction] is clamped to 0..1.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 6,
    this.track = AppColors.track,
  });

  final double fraction;
  final Color color;
  final double height;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: track),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(height: height, color: color),
          ),
        ],
      ),
    );
  }
}

/// A small coloured dot used beside account/category/goal names.
class Dot extends StatelessWidget {
  const Dot(this.color, {super.key, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Serif (Newsreader) currency text — the design uses it for every amount.
class SerifAmount extends StatelessWidget {
  const SerifAmount(
    this.text, {
    super.key,
    this.size = 20,
    this.color = AppColors.ink,
    this.weight = FontWeight.w500,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Newsreader',
          fontSize: size,
          color: color,
          fontWeight: weight,
          letterSpacing: -0.3,
        ),
      );
}

/// Uppercase section label ("YOUR ACCOUNTS") used inside dark cards.
class MutedCaps extends StatelessWidget {
  const MutedCaps(this.text, {super.key, this.color, this.size = 12});

  final String text;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: color ?? AppColors.muted,
        ),
      );
}
