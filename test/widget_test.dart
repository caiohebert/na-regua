// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:na_regua/screens/welcome_screen.dart';
import 'package:na_regua/app_theme.dart';

void main() {
  testWidgets('Welcome screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.theme,
          home: const WelcomeScreen(),
        ),
      ),
    );

    // Verify that the welcome screen displays the app name
    expect(find.text('Na Régua'), findsOneWidget);
    expect(find.text('Seu estilo, sua agenda'), findsOneWidget);
    
    // Verify that login and register buttons are present
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar Conta'), findsOneWidget);
  });
}
