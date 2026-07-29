import 'package:workmanager/workmanager.dart';
import 'package:remainder_portal/data/services/database_service.dart';
import 'package:remainder_portal/data/services/offline_queue_service.dart';
import 'package:remainder_portal/data/services/delta_sync_engine.dart';

const String backgroundSyncTaskKey = 'com.remainderportal.background_sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. Initialize self-contained SQLite DB with WAL journal mode enabled
    final db = AppDatabase();

    // 2. Instantiate isolate-specific sync engine and offline queue service
    final syncEngine = DeltaSyncEngine();
    final queueService = OfflineQueueService(db: db);

    try {
      // 3. Hydrate pending/un-synced ledger items from SQLite
      await queueService.loadFromDb();

      // 4. Process queue using DeltaSyncEngine conflict resolution logic
      await queueService.processQueue((item) async {
        final localDelta = DeltaEntity(
          entityId: item.id,
          entityType: item.messageType,
          data: item.payload,
          vectorClock: VectorClock({'node_local': item.retryCount + 1}),
          lastModified: item.createdAt,
        );

        final simulatedRemoteDelta = DeltaEntity(
          entityId: item.id,
          entityType: item.messageType,
          data: item.payload,
          vectorClock: VectorClock({'node_local': 1}),
          lastModified: item.createdAt,
        );

        final resolution = syncEngine.resolveConflict(localDelta, simulatedRemoteDelta);
        return resolution.winningEntity.entityId.isNotEmpty;
      });

      return true;
    } catch (e) {
      // Returning false signals WorkManager to retry task under backoff strategy
      return false;
    } finally {
      await db.close();
    }
  });
}

class BackgroundSyncWorker {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'periodic-sync-ledger',
      backgroundSyncTaskKey,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.exponential,
    );
  }

  static Future<void> triggerOneOffSync() async {
    await Workmanager().registerOneOffTask(
      'oneoff-sync-${DateTime.now().millisecondsSinceEpoch}',
      backgroundSyncTaskKey,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
