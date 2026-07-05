import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remainder_portal/models/application.dart';
import 'package:remainder_portal/models/okf_models.dart';
import 'package:remainder_portal/models/roster_member.dart';
import 'package:remainder_portal/services/roster_cache_service.dart';
import 'package:remainder_portal/ui/components/glass_card.dart';
import 'package:remainder_portal/ui/components/iridescent_overlay.dart';

void main() {
  group('GlassCard Widget Tests', () {
    testWidgets('Renders child content successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlassCard(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('Respects custom padding configuration', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(16.0);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlassCard(
                padding: customPadding,
                child: Text('Padding Test'),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      final container = tester.widget<Container>(containerFinder.last);
      expect(container.padding, customPadding);
    });

    testWidgets('Applies custom background color', (WidgetTester tester) async {
      const customColor = Colors.red;
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlassCard(
                backgroundColor: customColor,
                child: Text('Color Test'),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      final container = tester.widget<Container>(containerFinder.last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('Hides border when hasBorder is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlassCard(
                hasBorder: false,
                child: Text('No Border Test'),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      final container = tester.widget<Container>(containerFinder.last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNull);
    });
  });

  group('IridescentOverlay Widget Tests', () {
    testWidgets('Renders child widget successfully as fallback', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IridescentOverlay(
                child: Text('Overlay Child Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Overlay Child Content'), findsOneWidget);
    });
  });

  group('Roster Caching & Serialization Tests', () {
    test('Loads seeded list when cache is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final cacheService = container.read(rosterCacheServiceProvider);
      expect(cacheService.loadRoster(), hasLength(2));
    });

    test('Saves and loads roster correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final cacheService = container.read(rosterCacheServiceProvider);
      const member = RosterMember(
        id: '99',
        characterName: 'Test Char',
        playerName: 'Test Player',
        faction: 'Test Faction',
        faceclaimName: 'Test FC',
        faceclaimImgUrl: 'https://example.com/test.png',
        status: 'Active',
        joinedDate: '2026-07-02',
      );

      await cacheService.saveRoster([member]);
      final loaded = cacheService.loadRoster();

      expect(loaded, hasLength(1));
      expect(loaded.first.characterName, 'Test Char');
      expect(loaded.first.playerName, 'Test Player');
    });
  });

  group('Application Serialization Tests', () {
    test('Converts Application to/from JSON correctly', () {
      final json = {
        'id': 'app-101',
        'submitted_at': '2026-07-02T12:00:00Z',
        'applicant_email': 'applicant@example.com',
        'character_name': 'Eldritch Scholar',
        'faction': 'Chronicles',
        'answers': ['Answer 1', 'Answer 2'],
        'status': 'Pending',
      };

      final app = Application.fromJson(json);
      expect(app.id, 'app-101');
      expect(app.characterName, 'Eldritch Scholar');
      expect(app.answers, hasLength(2));

      final serialized = app.toJson();
      expect(serialized['id'], 'app-101');
      expect(serialized['character_name'], 'Eldritch Scholar');
    });
  });

  group('OKF Models Serialization Tests', () {
    test('Converts LoreChunk to/from JSON correctly', () {
      final json = {
        'id': 'chunk-001',
        'title': 'The Great Rift Lore',
        'content': 'Historical records detail the collapse...',
        'relevance_score': 0.95,
        'metadata': {'author': 'Archivist'},
      };

      final chunk = LoreChunk.fromJson(json);
      expect(chunk.id, 'chunk-001');
      expect(chunk.relevanceScore, 0.95);

      final serialized = chunk.toJson();
      expect(serialized['id'], 'chunk-001');
    });

    test('Converts OKFQueryResult to/from JSON correctly', () {
      final json = {
        'chunks': [
          {
            'id': 'chunk-001',
            'title': 'The Great Rift Lore',
            'content': 'Historical records detail the collapse...',
            'relevance_score': 0.95,
            'metadata': {'author': 'Archivist'},
          }
        ],
        'relevance_score': 0.98,
        'citation_sources': ['Chronicles of Vance'],
      };

      final result = OKFQueryResult.fromJson(json);
      expect(result.relevanceScore, 0.98);
      expect(result.chunks, hasLength(1));
      expect(result.citationSources.first, 'Chronicles of Vance');
    });
  });
}
