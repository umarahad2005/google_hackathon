// Zimma AI — Main Application Entry Point
//
// Agentic AI Service Orchestrator for the Informal Economy
// Challenge 2 — Google Antigravity Hackathon
//
// Owner: Mobile Engineer (04)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_config.dart';
import 'core/theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const ProviderScope(child: ZimmaApp()));
}

class ZimmaApp extends StatelessWidget {
  const ZimmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zimma AI',
      debugShowCheckedModeBanner: false,
      theme: ZimmaTheme.darkTheme,
      home: const RootRouter(),
    );
  }
}

enum _Phase { splash, onboarding, app }

/// Splash → Onboarding (first launch only) → AuthGate, with smooth
/// cross-fades between phases.
class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  _Phase _phase = _Phase.splash;

  Future<void> _afterSplash() async {
    final done = await onboardingDone();
    if (!mounted) return;
    setState(() => _phase = done ? _Phase.app : _Phase.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (_phase) {
      _Phase.splash => SplashScreen(
          key: const ValueKey('splash'),
          onComplete: _afterSplash,
        ),
      _Phase.onboarding => OnboardingScreen(
          key: const ValueKey('onboarding'),
          onDone: () => setState(() => _phase = _Phase.app),
        ),
      _Phase.app => const AuthGate(key: ValueKey('app')),
    };

    return AnimatedSwitcher(
      duration: ZimmaTheme.motionSlow,
      switchInCurve: ZimmaTheme.easeEmphasized,
      switchOutCurve: ZimmaTheme.easeStandard,
      child: child,
    );
  }
}
