/// Glassmorphic panel — a frosted, translucent surface that floats above
/// the ambient background. Real backdrop blur + a lit top-left edge gives
/// a believable pane of glass. Keep content high-contrast on top of it.

library;

import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ZimmaTheme.space5),
    this.radius = ZimmaTheme.radiusLg,
    this.blur = 18,
    this.opacity = 0.06,
    this.tint = const Color(0xFFFFFFFF),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final double opacity;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: ZimmaTheme.glass(
            radius: radius,
            tint: tint,
            opacity: opacity,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
