import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/main.dart';

void main() {
  testWidgets('GenesisScreen initialization and inputs render', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the title and character input fields render properly.
    expect(find.text('THE REMAINDER PORTAL'), findsOneWidget);
    expect(find.text('DESIGNATION IDENTIFIER (NAME)'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter character designation name
    await tester.enterText(find.byType(TextField), 'Vortex Scribe');
    await tester.pump();

    // Verify input text updated
    expect(find.text('Vortex Scribe'), findsOneWidget);
  });
}
