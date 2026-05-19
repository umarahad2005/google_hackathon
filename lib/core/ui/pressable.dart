/// Pressable — wraps any tappable surface with an immediate tactile
/// response: a subtle scale-down + haptic on press-down, springing back
/// on release. HCI: feedback must be immediate (<100ms) and perceptible,
/// so the user knows the tap registered before the async work returns.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (v == _down) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!.call();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: ZimmaTheme.motionFast,
        curve: ZimmaTheme.easeEmphasized,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.5,
          duration: ZimmaTheme.motionFast,
          child: widget.child,
        ),
      ),
    );
  }
}
