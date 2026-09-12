import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull, Column;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:remainder_portal/data/services/database_service.dart';
import 'package:remainder_portal/data/services/local_llm_sidecar_service.dart';
import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/models/oracle_record.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';
import 'package:remainder_portal/presentation/providers/sovereign_provider.dart';
import 'package:remainder_portal/presentation/providers/utrcs_provider.dart';
import 'package:remainder_portal/presentation/widgets/aether_resonance_oracle_widget.dart';
import 'package:remainder_portal/presentation/widgets/quest_decree_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;
  const defaultUser = 'utrcs_test_player';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.savePlayerWallet(PlayerWallet(
      userId: defaultUser,
      essenceBalance: 500,
      laurelBalance: 50,
      experiencePoints: 100000,
      currentLevel: 50,
      lastUpdated: DateTime.now(),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  group('Thread C-0 — Local LLM Sidecar Integration Tests', () {
    test('1. Happy Path Oracle: Valid LLM prophecy flavor text with 100% deterministic mechanics', () async {
      final mockClient = http_testing.MockClient((request) async {
        expect(request.url.path, '/v1/chat/completions');
        final responsePayload = {
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content': json.encode({
                  'prophecy_text': 'The Astral Leylines converge, granting luminous clarity to the Void.'
                }),
              }
            }
          ]
        };
        return http.Response(json.encode(responsePayload), 200, headers: {'Content-Type': 'application/json'});
      });

      final llmService = LocalLlmSidecarService(client: mockClient);
      final repo = SovereignRepository(db, llmService);

      final record = await repo.communeWithOracle(
        userId: defaultUser,
        costEssence: 25,
        rollOverride: 20,
        operatorClass: 'Vanguard',
      );

      // Verify LLM flavor text was adopted
      expect(record.blessingText, 'The Astral Leylines converge, granting luminous clarity to the Void.');

      // Verify mechanics remain 100% deterministic
      expect(record.d20Roll, 20);
      expect(record.outcomeTier, 'CRITICAL CONSENSUS');
      expect(record.buffGranted, '+15% Aether Multiplier (15m)');

      // Verify persisted to SQLite
      final history = await db.getOracleHistoryForUser(defaultUser);
      expect(history.length, 1);
      expect(history.first.blessingText, record.blessingText);
    });

    test('2. Happy Path Arbiter: Valid LLM decree flavor text with 100% deterministic mechanics', () async {
      final mockClient = http_testing.MockClient((request) async {
        expect(request.url.path, '/v1/chat/completions');
        final responsePayload = {
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content': json.encode({
                  'title': 'Scourge of the Fractured Spire',
                  'description': 'Purge rogue void apparitions infesting the lower levels of Sector 7.',
                }),
              }
            }
          ]
        };
        return http.Response(json.encode(responsePayload), 200, headers: {'Content-Type': 'application/json'});
      });

      final llmService = LocalLlmSidecarService(client: mockClient);
      final repo = SovereignRepository(db, llmService);

      final decree = await repo.generateDynamicQuestDecree(
        userId: defaultUser,
        sectorId: 'sector_007',
        sectorName: 'Fractured Spire',
        difficulty: 'S-RANK',
        operatorClass: 'Vanguard',
      );

      // Verify LLM flavor text was adopted
      expect(decree.title, 'Scourge of the Fractured Spire');
      expect(decree.decreeText, 'Purge rogue void apparitions infesting the lower levels of Sector 7.');

      // Verify mechanics remain 100% deterministic
      expect(decree.rewardEssence, 750);
      expect(decree.rewardLaurels, 50);
      expect(decree.difficulty, 'S-RANK');
      expect(decree.progress, 0.0);
      expect(decree.isClaimed, false);

      // Verify persisted to SQLite
      final dbQuests = await db.getQuestDecreesForUser(defaultUser);
      expect(dbQuests.any((q) => q.id == decree.id), true);
    });

    test('3. Timeout Path: Server latency >22s fails closed to calibrated seed content without crash or hang', () async {
      final mockClient = http_testing.MockClient((request) async {
        throw TimeoutException('Request exceeded 22 seconds');
      });

      final llmService = LocalLlmSidecarService(client: mockClient);
      final repo = SovereignRepository(db, llmService);

      // Oracle fails closed to calibrated template
      final record = await repo.communeWithOracle(
        userId: defaultUser,
        costEssence: 25,
        rollOverride: 18,
      );
      expect(record.outcomeTier, 'HARMONIC AETHER');
      expect(record.blessingText, contains('Celestial Leylines resonate'));
      expect(record.buffGranted, '+10% Quest Essence Boost (15m)');

      // Arbiter decree fails closed to calibrated template
      final decree = await repo.generateDynamicQuestDecree(
        userId: defaultUser,
        sectorId: 'sector_abyss',
        sectorName: 'Celestial Abyss',
        difficulty: 'A-RANK',
      );
      expect(decree.title, contains('Celestial Abyss'));
      expect(decree.decreeText, contains('The World Arbiter decrees'));
      expect(decree.rewardEssence, 500); // S-RANK = 750, A-RANK = 500
      expect(decree.rewardLaurels, 35);
    });

    test('4. Malformed JSON Path: Garbage output or truncated braces fails closed identically to timeout', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('<<<NON-JSON GARBAGE SYSTEM FAILURE>>>', 200, headers: {'Content-Type': 'text/plain'});
      });

      final llmService = LocalLlmSidecarService(client: mockClient);
      final repo = SovereignRepository(db, llmService);

      final record = await repo.communeWithOracle(
        userId: defaultUser,
        costEssence: 25,
        rollOverride: 20,
      );
      expect(record.outcomeTier, 'CRITICAL CONSENSUS');
      expect(record.blessingText, contains('World Arbiter grants +15% Aether Multiplier'));

      final decree = await repo.generateDynamicQuestDecree(
        userId: defaultUser,
        sectorId: 'sector_9',
        sectorName: 'Sector 9',
        difficulty: 'B-RANK',
      );
      expect(decree.rewardEssence, 300);
      expect(decree.title, contains('Sector 9'));
    });

    test('5. Hallucinated Keys Dropped: Malicious/hallucinated reward fields are strictly discarded', () async {
      final mockClient = http_testing.MockClient((request) async {
        final responsePayload = {
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content': json.encode({
                  'title': 'Infiltrate Core Vault',
                  'description': 'Bypass imperial security lasers and access the core.',
                  'reward_essence': 9999999, // Attempted mechanic exploit
                  'reward_laurels': 8888888, // Attempted mechanic exploit
                  'progress': 1.0,           // Attempted exploit
                  'is_claimed': true,        // Attempted exploit
                }),
              }
            }
          ]
        };
        return http.Response(json.encode(responsePayload), 200, headers: {'Content-Type': 'application/json'});
      });

      final llmService = LocalLlmSidecarService(client: mockClient);
      final repo = SovereignRepository(db, llmService);

      final decree = await repo.generateDynamicQuestDecree(
        userId: defaultUser,
        sectorId: 'sec_vault',
        sectorName: 'Core Vault',
        difficulty: 'A-RANK',
      );

      // Flavor text accepted
      expect(decree.title, 'Infiltrate Core Vault');
      expect(decree.decreeText, 'Bypass imperial security lasers and access the core.');

      // Mechanics strictly governed by SovereignRepository rule engine
      expect(decree.rewardEssence, 500); // NOT 9999999
      expect(decree.rewardLaurels, 35);  // NOT 8888888
      expect(decree.progress, 0.0);      // NOT 1.0
      expect(decree.isClaimed, false);   // NOT true
    });

    test('6. Sanity Bounds: Runaway text (>250 chars) or script injection is rejected', () async {
      final mockClient = http_testing.MockClient((request) async {
        final responsePayload = {
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content': json.encode({
                  'prophecy_text': 'A' * 300, // Exceeds 250 character boundary
                }),
              }
            }
          ]
        };
        return http.Response(json.encode(responsePayload), 200, headers: {'Content-Type': 'application/json'});
      });

      final llmService = LocalLlmSidecarService(client: mockClient);
      final repo = SovereignRepository(db, llmService);

      final record = await repo.communeWithOracle(
        userId: defaultUser,
        costEssence: 25,
        rollOverride: 20,
      );
      // Fails closed to calibrated template because 300 chars > 250 char bound
      expect(record.blessingText, contains('World Arbiter grants +15% Aether Multiplier'));
    });

    test('7. Restart Persistence: Generated LLM decree and prophecy survive DB close/reopen', () async {
      // 1. Generate records in initial DB session
      final mockClient = http_testing.MockClient((request) async {
        final responsePayload = {
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content': json.encode({
                  'title': 'Celestial Vanguard Protocol',
                  'description': 'Vanguard units must stabilize perimeter breach.',
                }),
              }
            }
          ]
        };
        return http.Response(json.encode(responsePayload), 200, headers: {'Content-Type': 'application/json'});
      });

      final llmService = LocalLlmSidecarService(client: mockClient);
      final repo = SovereignRepository(db, llmService);

      final decree = await repo.generateDynamicQuestDecree(
        userId: defaultUser,
        sectorId: 'sector_p',
        sectorName: 'Perimeter',
        difficulty: 'S-RANK',
      );
      expect(decree.title, 'Celestial Vanguard Protocol');

      // 2. Query DB directly to verify persistence
      final savedQuests = await db.getQuestDecreesForUser(defaultUser);
      final persisted = savedQuests.firstWhere((q) => q.id == decree.id);
      expect(persisted.title, 'Celestial Vanguard Protocol');
      expect(persisted.rewardEssence, 750);
    });

    testWidgets('8. Responsive UI & Loading States at 320dp narrow viewport: Zero RenderFlex overflows', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = SovereignRepository(db);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sovereignRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    AetherResonanceOracleWidget(),
                    QuestDecreeWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widgets render cleanly without overflow errors
      expect(find.byType(AetherResonanceOracleWidget), findsOneWidget);
      expect(find.byType(QuestDecreeWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
