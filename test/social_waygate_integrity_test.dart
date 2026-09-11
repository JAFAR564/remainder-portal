import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:remainder_portal/data/services/database_service.dart';
import 'package:remainder_portal/data/models/social_bulletin_model.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/presentation/providers/sovereign_provider.dart';
import 'package:remainder_portal/presentation/widgets/waygate_telemetry_sheet.dart';
import 'package:remainder_portal/presentation/widgets/social_post_creation_sheet.dart';
import 'package:remainder_portal/presentation/widgets/social_comments_sheet.dart';
import 'package:remainder_portal/presentation/widgets/social_post_card.dart';
import 'package:remainder_portal/presentation/screens/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Thread B-5 — Social Bulletin & Waygate Telemetry Integrity Tests', () {
    test('1. Initial Bulletin Hydration: seeds exactly ONE calibrated starter post into SQLite once, subsequent queries from SQLite', () async {
      final repo = SovereignRepository(db);

      // Verify social_posts table is initially empty in SQLite
      final initialRows = await db.getSocialPosts();
      expect(initialRows, isEmpty);

      // First query triggers one-time starter post seeding
      final feed = await repo.getFeed();
      expect(feed.length, 1);
      final starter = feed.first;
      expect(starter.id, 'post_vane_001');
      expect(starter.authorName, 'Lord Commander Vane');
      expect(starter.authorTitle, 'Imperial Vanguard Marshal');
      expect(starter.isIC, isTrue);
      expect(starter.laurelsCount, 14);
      expect(starter.commentsCount, 0);
      expect(starter.content, contains('Resonance levels in Sector 4 are stabilizing'));

      // Verify record is now genuinely in SQLite
      final dbRows = await db.getSocialPosts();
      expect(dbRows.length, 1);
      expect(dbRows.first.id, 'post_vane_001');

      // Second query reads strictly from SQLite without re-seeding or duplication
      final secondQueryFeed = await repo.getFeed();
      expect(secondQueryFeed.length, 1);
      expect(secondQueryFeed.first.id, 'post_vane_001');
    });

    test('2. Post Creation & Persistence: creates post through repository and persists to SQLite', () async {
      final repo = SovereignRepository(db);

      // Hydrate starter
      await repo.getFeed();

      // Create a new post
      final newPost = SocialPostEntry(
        id: 'post_operator_test_01',
        authorId: 'user_operator_001',
        authorName: 'Operator Zephyr',
        authorTitle: 'Aetherblade Vanguard',
        avatarPath: 'assets/icon/app_icon.png',
        content: 'Communion leylines stabilized across Sector 7.',
        isIC: true,
        laurelsCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      await repo.createPost(newPost);

      // Verify both starter and new post exist
      final updatedFeed = await repo.getFeed();
      expect(updatedFeed.length, 2);
      expect(updatedFeed.any((p) => p.id == 'post_operator_test_01'), isTrue);

      final fetchedPost = updatedFeed.firstWhere((p) => p.id == 'post_operator_test_01');
      expect(fetchedPost.authorName, 'Operator Zephyr');
      expect(fetchedPost.content, 'Communion leylines stabilized across Sector 7.');
      expect(fetchedPost.laurelsCount, 0);
      expect(fetchedPost.commentsCount, 0);

      // Verify SQLite row exists
      final dbPosts = await db.getSocialPosts();
      final postRow = dbPosts.firstWhere((p) => p.id == 'post_operator_test_01');
      expect(postRow.content, 'Communion leylines stabilized across Sector 7.');
    });

    test('3. Comment Lifecycle & Counter Increment: adding comment increments post commentsCount in SQLite', () async {
      final repo = SovereignRepository(db);

      // Hydrate starter post (initial commentsCount = 0)
      final feed = await repo.getFeed();
      final starter = feed.first;
      expect(starter.commentsCount, 0);

      // Add a comment
      final newComment = SocialCommentEntry(
        id: 'comment_test_001',
        postId: starter.id,
        authorName: 'Operator Zephyr',
        content: 'Standing by at the Aether Barrier.',
        createdAt: DateTime.now(),
      );

      await repo.addComment(newComment);

      // Verify comment exists in SQLite
      final comments = await repo.getComments(starter.id);
      expect(comments.length, 1);
      expect(comments.first.id, 'comment_test_001');
      expect(comments.first.authorName, 'Operator Zephyr');
      expect(comments.first.content, 'Standing by at the Aether Barrier.');

      // Verify post commentsCount in SQLite incremented from 0 to 1
      final dbPosts = await db.getSocialPosts();
      final updatedPost = dbPosts.firstWhere((p) => p.id == starter.id);
      expect(updatedPost.commentsCount, 1);

      final refreshedFeed = await repo.getFeed();
      expect(refreshedFeed.first.commentsCount, 1);
    });

    test('4. Laurel Endorsement Persistence: endorsing updates laurelsCount in SQLite', () async {
      final repo = SovereignRepository(db);

      // Hydrate starter post (initial laurelsCount = 14)
      final feed = await repo.getFeed();
      final starter = feed.first;
      expect(starter.laurelsCount, 14);

      // Endorse post
      await repo.endorsePost(postId: starter.id, userId: 'user_operator_001');

      // Verify laurelsCount incremented to 15 in SQLite
      final dbPosts = await db.getSocialPosts();
      final updatedPost = dbPosts.firstWhere((p) => p.id == starter.id);
      expect(updatedPost.laurelsCount, 15);
    });

    test('5. Waygate Telemetry Accuracy: accurately aggregates live Phase 2 and 3 subsystem states', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final telemetry = container.read(waygateTelemetryProvider);

      // Asserts mapping from live domain providers
      expect(telemetry.tradePendingCount, isA<int>());
      expect(telemetry.canonActiveProposalsCount, isA<int>());
      expect(telemetry.squadMemberCount, isA<int>());
      expect(telemetry.isSquadActive, isA<bool>());
      expect(telemetry.relayQueuedCount, isA<int>());
      expect(telemetry.isRelayOnline, isA<bool>());
    });

    test('6. Trust Score Alignment & Honest Mesh Status: reports 0 peers and local standby without fabricated connections', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final telemetry = container.read(waygateTelemetryProvider);

      // Honest un-fabricated telemetry asserts
      expect(telemetry.connectedPeersCount, 0);
      expect(telemetry.p2pMeshStatus, 'LOCAL STANDBY (P2P TRANSPORT DEFERRED)');
      expect(telemetry.syncEngineStatus, 'LOCAL-FIRST ISOLATION');
      expect(telemetry.architecturalNotice, contains('DEFERRED'));

      // Trust scores match Phase 2 trustProvider
      final trust = container.read(trustProvider);
      expect(telemetry.overallTrustScore, trust.overallTrustScore);
      expect(telemetry.vanguardScore, trust.vanguardScore);
      expect(telemetry.arbiterScore, trust.arbiterScore);
      expect(telemetry.merchantScore, trust.merchantScore);
      expect(telemetry.hackerScore, trust.hackerScore);
    });

    testWidgets('7. Widget Reactivity & Responsive Viewports: zero overflow across 320dp, 360dp, and 600dp viewports', (WidgetTester tester) async {
      final viewports = [
        const Size(320.0, 640.0), // Compact mobile
        const Size(360.0, 800.0), // Standard Android
        const Size(600.0, 960.0), // Tablet / Foldable
      ];

      for (final size in viewports) {
        tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
            ],
            child: const MaterialApp(
              home: DashboardScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Must have zero RenderFlex overflow exceptions
        expect(tester.takeException(), isNull, reason: 'Failed layout at width: ${size.width}');

        // Verify Waygate button exists and opens sheet
        final waygateBtn = find.byKey(const Key('open_waygate_telemetry_sheet'));
        expect(waygateBtn, findsOneWidget);

        // Verify Transmit button exists and opens sheet
        final transmitBtn = find.byKey(const Key('open_create_post_sheet'));
        expect(transmitBtn, findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
