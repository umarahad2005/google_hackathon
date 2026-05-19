/// Decides the first screen: config error → setup hint, signed-out →
/// [AuthScreen], signed-in → the app. Rebuilds on every auth change.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/supabase_config.dart';
import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../providers/providers.dart';
import '../shell/home_shell.dart';
import 'auth_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.isConfigured) return const _ConfigNeeded();

    final user = ref.watch(currentUserProvider);
    return user == null ? const AuthScreen() : const HomeShell();
  }
}

class _ConfigNeeded extends StatelessWidget {
  const _ConfigNeeded();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: GlassPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.key_off_rounded,
                        size: 40, color: ZimmaTheme.warning),
                    const SizedBox(height: ZimmaTheme.space4),
                    Text(
                      'Supabase not configured',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ZimmaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: ZimmaTheme.space3),
                    Text(
                      'Run the app with the Supabase URL and anon key:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ZimmaTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: ZimmaTheme.space3),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius:
                            BorderRadius.circular(ZimmaTheme.radiusSm),
                      ),
                      child: SelectableText(
                        'flutter run \\\n'
                        '  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \\\n'
                        '  --dart-define=SUPABASE_ANON_KEY=eyJ...',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: ZimmaTheme.secondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
