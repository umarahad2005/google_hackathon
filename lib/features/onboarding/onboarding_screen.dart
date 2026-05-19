/// Onboarding tour — a 5-page progressive-disclosure intro shown once on
/// first launch. HCI: recognition over recall, clear progress, an always-
/// available Skip, one primary action per screen. Motion via
/// flutter_animate with a parallax tied to the page scroll.

library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';

const _kOnboardingDoneKey = 'onboarding_done';

Future<bool> onboardingDone() async {
  try {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kOnboardingDoneKey) ?? false;
  } catch (_) {
    return false; // storage unavailable → show it (safe default)
  }
}

class _Page {
  const _Page(this.icon, this.color, this.title, this.body);
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

const _pages = <_Page>[
  _Page(
    Icons.auto_awesome_rounded,
    ZimmaTheme.primary,
    'Meet Zimma AI',
    'Trusted local help — AC techs, electricians, plumbers, tutors and '
        'more — found and booked for you by an AI agent team.',
  ),
  _Page(
    Icons.record_voice_over_rounded,
    ZimmaTheme.secondary,
    'Just say it, your way',
    'Type or speak in Urdu, Roman Urdu, or English. Zimma understands '
        '“Mujhe kal subah G-13 mein AC technician chahiye”.',
  ),
  _Page(
    Icons.hub_rounded,
    ZimmaTheme.primary,
    'Watch the AI think',
    'A live agent trace shows every step — intent, discovery, ranking, '
        'reasoning — in real time. No black box.',
  ),
  _Page(
    Icons.phone_in_talk_rounded,
    ZimmaTheme.accent,
    'We confirm the vendor',
    'Zimma places a confirmation call to the chosen provider and only '
        'books once they accept. Declined? It re-ranks instantly.',
  ),
  _Page(
    Icons.verified_rounded,
    ZimmaTheme.success,
    'Tracked to completion',
    'Reminders, en-route and progress updates, completion and a rating '
        'request — the whole lifecycle, automated.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kOnboardingDoneKey, true);
    } catch (_) {/* non-fatal */}
    widget.onDone();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: ZimmaTheme.motionBase,
        curve: ZimmaTheme.easeEmphasized,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                  child: Pressable(
                    onTap: _finish,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ZimmaTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _OnboardPage(
                    page: _pages[i],
                    active: i == _index,
                  ),
                ),
              ),
              _Dots(count: _pages.length, index: _index),
              const SizedBox(height: ZimmaTheme.space5),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Pressable(
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: ZimmaTheme.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(ZimmaTheme.radiusMd),
                      boxShadow: ZimmaTheme.glow(ZimmaTheme.primary,
                          strength: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? 'Get started' : 'Next',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLast
                              ? Icons.rocket_launch_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.page, required this.active});

  final _Page page;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.color.withValues(alpha: 0.22),
                  page.color.withValues(alpha: 0.08),
                ],
              ),
              boxShadow: ZimmaTheme.glow(page.color, strength: 0.22),
            ),
            child: Icon(page.icon, size: 76, color: page.color),
          )
              .animate(target: active ? 1 : 0)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
                duration: 520.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 380.ms),
          const SizedBox(height: ZimmaTheme.space6),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: ZimmaTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(delay: 120.ms, duration: 420.ms)
              .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: ZimmaTheme.space3),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: ZimmaTheme.textSecondary,
            ),
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(delay: 220.ms, duration: 460.ms)
              .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: ZimmaTheme.motionBase,
            curve: ZimmaTheme.easeEmphasized,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 26 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index
                  ? ZimmaTheme.primary
                  : ZimmaTheme.primary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}
