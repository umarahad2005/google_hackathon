/// Ambient depth backdrop.
///
/// A dark base gradient with two slow-drifting, heavily-blurred color
/// "blobs" (salmon + sage). This creates perceived depth and a focal
/// warmth without competing with foreground content (HCI: figure/ground —
/// the background stays low-contrast and non-distracting).

library;

import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: ZimmaTheme.darkGradient),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_c.value);
              return Stack(
                children: [
                  _blob(
                    color: ZimmaTheme.primary,
                    alignment: Alignment(-0.95 + t * 0.5, -0.85 + t * 0.3),
                    size: 360,
                    opacity: 0.28,
                  ),
                  _blob(
                    color: ZimmaTheme.secondary,
                    alignment: Alignment(0.95 - t * 0.4, 0.75 - t * 0.35),
                    size: 420,
                    opacity: 0.24,
                  ),
                  _blob(
                    color: ZimmaTheme.accent,
                    alignment: Alignment(0.7 - t * 0.3, -0.7 + t * 0.45),
                    size: 300,
                    opacity: 0.16,
                  ),
                ],
              );
            },
          ),
        ),
        // Soften everything behind the content into a smooth wash.
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _blob({
    required Color color,
    required Alignment alignment,
    required double size,
    required double opacity,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
