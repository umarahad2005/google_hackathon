// Zimma AI — Widget Tests
//
// Smoke tests for the ZimmaApp widget tree.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_hackathon/main.dart';

void main() {
  testWidgets('ZimmaApp renders without crashing', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(child: ZimmaApp()),
    );

    // The app should render the RequestScreen
    // which contains the title 'Zimma AI'
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('ZimmaApp has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ZimmaApp()),
    );

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, equals('Zimma AI'));
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
