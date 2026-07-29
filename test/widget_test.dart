// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tomato/main.dart';

void main() {
  testWidgets('Splash Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TomatoApp());

    // Verify that the title 'Tomato' exists on splash screen.
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Skip the Queue, Not the Food.'), findsOneWidget);
    
    // Drain pending routing timers to avoid leaks
    await tester.pump(const Duration(seconds: 5));
  });
}
