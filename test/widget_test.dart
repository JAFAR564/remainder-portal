import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/screens/splash_screen.dart';
import 'package:remainder_portal/presentation/screens/auth_screen.dart';

void main() {
  testWidgets('SplashScreen and AuthScreen initialization render clean UI', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    // Verify that the title on SplashScreen renders properly.
    expect(find.text('THE REMAINDER PORTAL'), findsOneWidget);
    expect(find.text('SOVEREIGN SYSTEM ADMIN & ROLEPLAY NEXUS'), findsOneWidget);

    // Test AuthScreen directly
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    expect(find.text('SYSTEM ADMIN AUTHORIZATION'), findsOneWidget);
    expect(find.text('REGISTER OPERATOR'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
