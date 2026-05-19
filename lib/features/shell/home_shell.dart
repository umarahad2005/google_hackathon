/// The signed-in app shell: a persistent premium bottom nav over four
/// state-preserving tabs (Home · New · History · Profile). The request
/// funnel (trace → recommendation → booking → follow-up) pushes as full
/// routes over the shell and returns here.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import '../request/request_screen.dart';
import '../settings/settings_screen.dart';

/// Selected tab — also lets other screens (e.g. Dashboard CTA) jump tabs.
final homeTabProvider = StateProvider<int>((ref) => 0);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  Future<void> _onPop(
      bool didPop, BuildContext context, WidgetRef ref) async {
    if (didPop) return;
    final index = ref.read(homeTabProvider);
    // A back-swipe / back-button on a sub-tab returns Home — it must NOT
    // silently kill the app (bad gesture UX).
    if (index != 0) {
      ref.read(homeTabProvider.notifier).state = 0;
      return;
    }
    // On Home, confirm before exiting instead of closing on a stray swipe.
    final exit = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: ZimmaTheme.raised(radius: ZimmaTheme.radiusLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded,
                  color: ZimmaTheme.primary, size: 34),
              const SizedBox(height: 12),
              Text(
                'Exit Zimma AI?',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ZimmaTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You can come right back where you left off.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ZimmaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Pressable(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ZimmaTheme.surfaceLight,
                          borderRadius:
                              BorderRadius.circular(ZimmaTheme.radiusMd),
                        ),
                        child: Text(
                          'Stay',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ZimmaTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Pressable(
                      onTap: () => Navigator.of(ctx).pop(true),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: ZimmaTheme.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(ZimmaTheme.radiusMd),
                        ),
                        child: Text(
                          'Exit',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (exit == true) {
      await SystemNavigator.pop(); // graceful, intentional exit only
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPop(didPop, context, ref),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: index,
          children: const [
            DashboardScreen(),
            RequestScreen(),
            HistoryScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: ZimmaBottomNav(
          currentIndex: index,
          onTap: (i) => ref.read(homeTabProvider.notifier).state = i,
          items: const [
            ZimmaNavItem(
                Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
            ZimmaNavItem(
                Icons.add_circle_outline, Icons.add_circle_rounded, 'New'),
            ZimmaNavItem(
                Icons.history_rounded, Icons.history_rounded, 'History'),
            ZimmaNavItem(
                Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }
}
