/// Animated splash — the brand moment shown while the app boots and
/// Supabase finishes initializing. HCI: perceived performance + a calm,
/// confident first impression. Motion via flutter_animate (the Flutter
/// equivalent of Framer Motion / GSAP timelines).

library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Minimum brand dwell; main() already finished Supabase.initialize.
    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ZimmaLogo(size: 112)
                  .animate()
                  .scale(
                    begin: const Offset(0.55, 0.55),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 500.ms)
                  .then()
                  .shimmer(duration: 1100.ms, color: Colors.white)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -8, duration: 1600.ms),
              const SizedBox(height: ZimmaTheme.space5),
              ShaderMask(
                shaderCallback: (r) =>
                    ZimmaTheme.brandGradient.createShader(r),
                child: Text(
                  'Zimma AI',
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 600.ms)
                  .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: ZimmaTheme.space2),
              Text(
                'ذمہ — I take charge of it',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZimmaTheme.textSecondary,
                ),
              ).animate().fadeIn(delay: 650.ms, duration: 600.ms),
              const SizedBox(height: ZimmaTheme.space6),
              SizedBox(
                width: 132,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor:
                        ZimmaTheme.primary.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(
                      ZimmaTheme.primary,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
