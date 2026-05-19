/// Entrance — a one-shot fade + slide-up used to introduce content. A
/// small per-item [delay] produces a staggered cascade that guides the
/// eye top-to-bottom in reading order (HCI: visual flow & orientation).
///
/// Self-contained (TweenAnimationBuilder), so it needs no controller and
/// is safe to sprinkle anywhere without lifecycle bookkeeping.

library;

import 'package:flutter/material.dart';

import '../theme.dart';

class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;

  /// Initial downward offset in logical px before settling.
  final double offset;

  @override
  Widget build(BuildContext context) {
    // Fold the delay into a single tween: a flat leading [Interval]
    // section reproduces a stagger without a controller.
    final total = delay + ZimmaTheme.motionSlow;
    final start = total.inMicroseconds == 0
        ? 0.0
        : delay.inMicroseconds / total.inMicroseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        start,
        1,
        curve: ZimmaTheme.easeEmphasized,
      ),
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * offset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Convenience: wraps each child in a staggered [Entrance].
class EntranceList extends StatelessWidget {
  const EntranceList({
    super.key,
    required this.children,
    this.step = const Duration(milliseconds: 70),
  });

  final List<Widget> children;
  final Duration step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          Entrance(delay: step * i, child: children[i]),
      ],
    );
  }
}
