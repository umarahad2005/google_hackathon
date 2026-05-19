/// Pressable — the one tappable primitive. Combines three feedback layers
/// so a tap is unmistakable (<100ms): a Material **InkWell ripple**, a
/// subtle scale-down, and a light haptic. HCI: feedback must be immediate
/// and perceptible before the async work returns.
///
/// Centralising this means every button/card in the app gets the same
/// ripple + spring without each call site wiring a GestureDetector/InkWell.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
    this.haptic = true,
    this.ripple = true,
    this.borderRadius = ZimmaTheme.radiusMd,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;

  /// Set false for full-bleed/irregular surfaces where a rectangular
  /// ripple would look wrong (keeps scale + haptic only).
  final bool ripple;

  /// Clips the ripple to this corner radius so it stays inside rounded
  /// cards/buttons instead of bleeding past them.
  final double borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (v == _down || !mounted) return;
    setState(() => _down = v);
  }

  void _fire() {
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;

    Widget content = AnimatedScale(
      scale: _down ? widget.scale : 1.0,
      duration: ZimmaTheme.motionFast,
      curve: ZimmaTheme.easeEmphasized,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.5,
        duration: ZimmaTheme.motionFast,
        child: widget.child,
      ),
    );

    if (!enabled) return content;

    if (widget.ripple) {
      final radius = BorderRadius.circular(widget.borderRadius);
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          splashColor: ZimmaTheme.primary.withValues(alpha: 0.12),
          highlightColor: ZimmaTheme.primary.withValues(alpha: 0.05),
          onHighlightChanged: _set,
          onTap: widget.onTap != null ? _fire : null,
          onLongPress: widget.onLongPress,
          child: content,
        ),
      );
    }

    // Ripple-free path (still a real GestureDetector + scale + haptic).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap != null ? _fire : null,
      onLongPress: widget.onLongPress,
      child: content,
    );
  }
}
