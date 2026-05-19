/// DepthCard — the default raised surface for content blocks. Uses the
/// shared elevation model so every card on every screen sits in the same
/// "light" (HCI: consistency → predictability). Optionally tappable, in
/// which case it gets the [Pressable] tactile response and a glow.

library;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'pressable.dart';

class DepthCard extends StatelessWidget {
  const DepthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ZimmaTheme.space5),
    this.radius = ZimmaTheme.radiusLg,
    this.level = 2,
    this.gradient,
    this.color,
    this.glowColor,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final int level;
  final Gradient? gradient;
  final Color? color;
  final Color? glowColor;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    var decoration = ZimmaTheme.raised(
      radius: radius,
      gradient: gradient,
      color: color,
      level: level,
    );

    if (glowColor != null) {
      decoration = decoration.copyWith(
        boxShadow: [
          ...?decoration.boxShadow,
          ...ZimmaTheme.glow(glowColor!),
        ],
      );
    }
    if (borderColor != null) {
      decoration = decoration.copyWith(
        border: Border.all(color: borderColor!, width: 1),
      );
    }

    final card = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return card;
    return Pressable(onTap: onTap, child: card);
  }
}
