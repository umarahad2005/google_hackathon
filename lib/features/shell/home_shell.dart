/// The signed-in app shell: a persistent premium bottom nav over four
/// state-preserving tabs (Home · New · History · Profile). The request
/// funnel (trace → recommendation → booking → follow-up) pushes as full
/// routes over the shell and returns here.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/ui.dart';
import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import '../request/request_screen.dart';
import '../settings/settings_screen.dart';

/// Selected tab — also lets other screens (e.g. Dashboard CTA) jump tabs.
final homeTabProvider = StateProvider<int>((ref) => 0);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabProvider);

    return Scaffold(
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
          ZimmaNavItem(Icons.history_rounded, Icons.history_rounded, 'History'),
          ZimmaNavItem(
              Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }
}
