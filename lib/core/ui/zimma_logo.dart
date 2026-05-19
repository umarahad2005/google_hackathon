/// Zimma AI — brand mark.
///
/// A crisp, fully vector logo (no bitmap): a soft squircle in the
/// sky-blue→coral brand gradient, carrying a geometric "Z" with an
/// agentic spark. Scales to any size; optional pulsing glow + wordmark.

library;

import 'package:flutter/material.dart';

import '../theme.dart';

class ZimmaLogo extends StatelessWidget {
  const ZimmaLogo({
    super.key,
    this.size = 72,
    this.glow = true,
    this.wordmark = false,
  });

  final double size;
  final bool glow;

  /// If true, renders the badge + "Zimma AI" gradient wordmark in a row.
  final bool wordmark;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: ZimmaTheme.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: glow
            ? ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.40)
            : null,
      ),
      child: CustomPaint(painter: _ZMarkPainter()),
    );

    if (!wordmark) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        SizedBox(width: size * 0.32),
        ShaderMask(
          shaderCallback: (r) =>
              ZimmaTheme.brandGradient.createShader(r),
          child: Text(
            'Zimma AI',
            style: TextStyle(
              fontSize: size * 0.46,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ZMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = w * 0.13;

    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Geometric "Z": top bar → diagonal → bottom bar, inset from edges.
    final l = w * 0.26;
    final r = w * 0.74;
    final t = h * 0.30;
    final b = h * 0.72;

    final z = Path()
      ..moveTo(l, t)
      ..lineTo(r, t)
      ..lineTo(l, b)
      ..lineTo(r, b);
    canvas.drawPath(z, p);

    // Agentic spark — a 4-point star near the top-right.
    final cx = w * 0.80;
    final cy = h * 0.22;
    final s = w * 0.085;
    final spark = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final star = Path()
      ..moveTo(cx, cy - s)
      ..quadraticBezierTo(cx, cy, cx + s, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + s)
      ..quadraticBezierTo(cx, cy, cx - s, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - s)
      ..close();
    canvas.drawPath(star, spark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
