// Zimma AI — Main Application Entry Point
//
// Agentic AI Service Orchestrator for the Informal Economy
// Challenge 2 — Google Antigravity Hackathon
//
// Owner: Mobile Engineer (04)
// Source: agents/skills/flutter-feature.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/request/request_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const RequestScreen(),
    );
  }
}
