import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:remainder_portal/services/roster_cache_service.dart';
import 'package:remainder_portal/services/auth_service.dart';
import 'package:remainder_portal/ui/components/global_feedback_overlay.dart';

// Mock SupabaseClient
class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('GlobalFeedbackOverlay Widget Tests', () {
    testWidgets('Renders child content and floating camera icon', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            supabaseClientProvider.overrideWithValue(FakeSupabaseClient()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: GlobalFeedbackOverlay(
                child: Text('Main Workspace Screen'),
              ),
            ),
          ),
        ),
      );

      // Verify page route content renders
      expect(find.text('Main Workspace Screen'), findsOneWidget);

      // Verify animated photo camera icon renders on the layout stack
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    });
  });
}
