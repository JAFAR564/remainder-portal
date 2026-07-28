import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:remainder_portal/data/services/database_service.dart';

enum QueueItemStatus { pending, inFlight, synced, failed }

class QueueItemModel {
  final String id;
  final String idempotencyKey;
  final String messageType;
  final Map<String, dynamic> payload;
  final String? dependencyId;
  final int retryCount;
  final QueueItemStatus status;
  final String? conflictMetadata;
  final DateTime createdAt;

  QueueItemModel({
    required this.id,
    required this.idempotencyKey,
    required this.messageType,
    required this.payload,
    this.dependencyId,
    this.retryCount = 0,
    this.status = QueueItemStatus.pending,
    this.conflictMetadata,
    required this.createdAt,
  });

  QueueItemModel copyWith({
    int? retryCount,
    QueueItemStatus? status,
    String? conflictMetadata,
  }) {
    return QueueItemModel(
      id: id,
      idempotencyKey: idempotencyKey,
      messageType: messageType,
      payload: payload,
      dependencyId: dependencyId,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      conflictMetadata: conflictMetadata ?? this.conflictMetadata,
      createdAt: createdAt,
    );
  }
}

class OfflineQueueService {
  final AppDatabase? db;
  final List<QueueItemModel> _memoryQueue = [];

  OfflineQueueService({this.db});

  List<QueueItemModel> get pendingItems =>
      _memoryQueue.where((item) => item.status == QueueItemStatus.pending).toList();

  List<QueueItemModel> get allItems => List.unmodifiable(_memoryQueue);

  int get pendingCount => pendingItems.length;

  Future<void> loadFromDb() async {
    if (db == null) return;

    // Fetch ONLY un-synced items from SQLite to prevent memory bloat and historical re-processing
    final dbItems = await (db!.select(db!.offlineQueue)
          ..where((tbl) => tbl.status.equals(QueueItemStatus.synced.index).not()))
        .get();

    _memoryQueue.clear();
    for (final row in dbItems) {
      final safeStatusIndex = (row.status >= 0 && row.status < QueueItemStatus.values.length)
          ? row.status
          : QueueItemStatus.pending.index;

      _memoryQueue.add(QueueItemModel(
        id: row.id,
        idempotencyKey: row.idempotencyKey,
        messageType: row.messageType,
        payload: json.decode(row.payload) as Map<String, dynamic>,
        dependencyId: row.dependencyId,
        retryCount: row.retryCount,
        status: QueueItemStatus.values[safeStatusIndex],
        conflictMetadata: row.conflictMetadata,
        createdAt: row.createdAt,
      ));
    }
  }

  static String generateIdempotencyKey(String sender, String messageType, Map<String, dynamic> payload, DateTime time) {
    final raw = '$sender:$messageType:${json.encode(payload)}:${time.millisecondsSinceEpoch}';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  QueueItemModel enqueue({
    required String senderId,
    required String messageType,
    required Map<String, dynamic> payload,
    String? dependencyId,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final key = generateIdempotencyKey(senderId, messageType, payload, now);

    // Idempotency check: prevent duplicate enqueue
    final existingIndex = _memoryQueue.indexWhere((item) => item.idempotencyKey == key);
    if (existingIndex != -1) {
      return _memoryQueue[existingIndex];
    }

    final item = QueueItemModel(
      id: 'q_${now.millisecondsSinceEpoch}_${_memoryQueue.length}',
      idempotencyKey: key,
      messageType: messageType,
      payload: payload,
      dependencyId: dependencyId,
      retryCount: 0,
      status: QueueItemStatus.pending,
      createdAt: now,
    );

    _memoryQueue.add(item);

    // Asynchronously persist to SQLite if DB is connected
    if (db != null) {
      db!.into(db!.offlineQueue).insertOnConflictUpdate(
        OfflineQueueCompanion.insert(
          id: item.id,
          idempotencyKey: item.idempotencyKey,
          messageType: item.messageType,
          payload: json.encode(item.payload),
          dependencyId: Value(item.dependencyId),
          retryCount: Value(item.retryCount),
          status: Value(item.status.index),
          conflictMetadata: Value(item.conflictMetadata),
          createdAt: item.createdAt,
        ),
      );
    }

    return item;
  }

  Future<int> processQueue(Future<bool> Function(QueueItemModel item) syncHandler) async {
    int syncedCount = 0;
    final toProcess = List<QueueItemModel>.from(pendingItems);

    for (final item in toProcess) {
      final index = _memoryQueue.indexWhere((i) => i.id == item.id);
      if (index == -1) continue;

      _memoryQueue[index] = _memoryQueue[index].copyWith(status: QueueItemStatus.inFlight);
      await _updateDbItem(_memoryQueue[index]);

      try {
        final success = await syncHandler(_memoryQueue[index]);
        if (success) {
          _memoryQueue[index] = _memoryQueue[index].copyWith(status: QueueItemStatus.synced);
          syncedCount++;
        } else {
          final newRetry = _memoryQueue[index].retryCount + 1;
          final newStatus = newRetry >= 5 ? QueueItemStatus.failed : QueueItemStatus.pending;
          _memoryQueue[index] = _memoryQueue[index].copyWith(
            retryCount: newRetry,
            status: newStatus,
          );
        }
      } catch (e) {
        final newRetry = _memoryQueue[index].retryCount + 1;
        final newStatus = newRetry >= 5 ? QueueItemStatus.failed : QueueItemStatus.pending;
        _memoryQueue[index] = _memoryQueue[index].copyWith(
          retryCount: newRetry,
          status: newStatus,
          conflictMetadata: e.toString(),
        );
      }

      await _updateDbItem(_memoryQueue[index]);
    }
    return syncedCount;
  }

  Future<void> _updateDbItem(QueueItemModel item) async {
    if (db == null) return;
    await (db!.update(db!.offlineQueue)..where((t) => t.id.equals(item.id))).write(
      OfflineQueueCompanion(
        retryCount: Value(item.retryCount),
        status: Value(item.status.index),
        conflictMetadata: Value(item.conflictMetadata),
      ),
    );
  }

  void clearSynced() {
    _memoryQueue.removeWhere((item) => item.status == QueueItemStatus.synced);
  }
}

