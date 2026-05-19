// Basic smoke test: verifies the app's root widget builds.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_hack/main.dart';

void main() {
  testWidgets('ZimmaApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZimmaApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
