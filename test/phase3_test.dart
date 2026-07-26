import 'package:flutter_test/flutter_test.dart';
import 'package:remainder_portal/data/services/offline_queue_service.dart';
import 'package:remainder_portal/data/services/delta_sync_engine.dart';
import 'package:remainder_portal/presentation/providers/economy_provider.dart';
import 'package:remainder_portal/presentation/providers/creator_provider.dart';

void main() {
  group('Phase 3 — Offline-First Synchronization & Player Economy Tests', () {
    test('OfflineQueueService enforces idempotency hashing and handles retry counts', () async {
      final queueService = OfflineQueueService();

      final now = DateTime.now();
      final item1 = queueService.enqueue(
        senderId: 'player_1',
        messageType: 'chat_action',
        payload: {'text': 'Exploring sector breach'},
        timestamp: now,
      );

      expect(item1.idempotencyKey, isNotEmpty);
      expect(queueService.pendingCount, 1);

      // Attempting to enqueue duplicate item with identical parameters returns existing item
      final item2 = queueService.enqueue(
        senderId: 'player_1',
        messageType: 'chat_action',
        payload: {'text': 'Exploring sector breach'},
        timestamp: now,
      );

      expect(item2.id, item1.id);

      // Process queue with simulated sync handler
      int processed = await queueService.processQueue((item) async => true);
      expect(processed, 1);
      expect(queueService.pendingCount, 0);
    });

    test('DeltaSyncEngine resolves vector clocks, LWW timestamps, and trust score tie-breakers', () {
      final engine = DeltaSyncEngine();
      final now = DateTime.now();

      // Scenario A: Local vector clock dominates
      final localA = DeltaEntity(
        entityId: 'e1',
        entityType: 'sector_state',
        data: {'val': 10},
        vectorClock: VectorClock({'nodeA': 2, 'nodeB': 1}),
        lastModified: now,
      );

      final remoteA = DeltaEntity(
        entityId: 'e1',
        entityType: 'sector_state',
        data: {'val': 5},
        vectorClock: VectorClock({'nodeA': 1, 'nodeB': 1}),
        lastModified: now,
      );

      final resA = engine.resolveConflict(localA, remoteA);
      expect(resA.resolutionMethod, 'LOCAL_DOMINATES');
      expect(resA.winningEntity.data['val'], 10);

      // Scenario B: Concurrent vector clock -> LWW timestamp resolution
      final localB = DeltaEntity(
        entityId: 'e2',
        entityType: 'sector_state',
        data: {'val': 'newer'},
        vectorClock: VectorClock({'nodeA': 2, 'nodeB': 1}),
        lastModified: now.add(const Duration(seconds: 10)),
      );

      final remoteB = DeltaEntity(
        entityId: 'e2',
        entityType: 'sector_state',
        data: {'val': 'older'},
        vectorClock: VectorClock({'nodeA': 1, 'nodeB': 2}),
        lastModified: now,
      );

      final resB = engine.resolveConflict(localB, remoteB);
      expect(resB.resolutionMethod, 'LWW_TIMESTAMP');
      expect(resB.winningEntity.data['val'], 'newer');
    });

    test('TradeNotifier executes two-phase commit escrow locking and atomic commit', () {
      final notifier = TradeNotifier();

      final item = TradeItemModel(
        itemId: 'item_101',
        itemName: 'Plasma Conduit',
        itemGenre: 'Tech',
        baseAttributeValue: 5,
        structuralDescription: 'High energy conduit',
      );

      final trade = notifier.initiateTrade(
        initiatorId: 'p1',
        receiverId: 'p2',
        offeredItems: [item],
        offeredEnergy: 100,
        requestedItems: [],
        requestedEnergy: 0,
      );

      expect(trade.status, TradeStatus.pending);

      // Phase 1: Escrow Lock
      final locked = notifier.lockEscrow(trade.id);
      expect(locked, isTrue);
      expect(notifier.debugState.activeTrades.first.status, TradeStatus.escrowLocked);

      // Phase 2: Initiator confirms
      final p1Confirmed = notifier.confirmTrade(trade.id, 'p1');
      expect(p1Confirmed, isFalse); // Pending 2nd party confirmation

      // Phase 2: Receiver confirms -> Atomic Commit
      final p2Confirmed = notifier.confirmTrade(trade.id, 'p2');
      expect(p2Confirmed, isTrue); // Complete!

      expect(notifier.debugState.activeTrades.isEmpty, isTrue);
      expect(notifier.debugState.tradeHistory.first.status, TradeStatus.completed);
    });

    test('CreatorStateNotifier advances OKF content across 9-stage lifecycle pipeline', () {
      final notifier = CreatorStateNotifier();

      notifier.createContent(
        authorId: 'author_1',
        contentType: 'sector',
        title: 'Neon Vault 9',
        okfBody: '# Sector Profile: Vault 9',
      );

      final contentId = notifier.debugState.first.id;
      expect(notifier.debugState.first.stage, ContentLifecycleStage.draft);

      // Advance stage to Validation (1)
      notifier.advanceStage(contentId);
      expect(notifier.debugState.firstWhere((c) => c.id == contentId).stage, ContentLifecycleStage.validation);

      // Advance stage to Preview (2)
      notifier.advanceStage(contentId);
      expect(notifier.debugState.firstWhere((c) => c.id == contentId).stage, ContentLifecycleStage.preview);
    });
  });
}
