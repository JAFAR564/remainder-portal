import 'dart:convert';
import 'package:crypto/crypto.dart';

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
  final List<QueueItemModel> _memoryQueue = [];

  List<QueueItemModel> get pendingItems =>
      _memoryQueue.where((item) => item.status == QueueItemStatus.pending).toList();

  int get pendingCount => pendingItems.length;

  static String generateIdempotencyKey(String sender, String messageType, Map<String, dynamic> payload, DateTime time) {
    final raw = '$sender:$messageType:${json.encode(payload)}:${time.millisecondsSinceEpoch}';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  QueueItemModel enqueue({
    required String senderId,
    required String messageType,
    required Map<String, dynamic> payload,
    String? dependencyId,
  }) {
    final now = DateTime.now();
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
    return item;
  }

  Future<int> processQueue(Future<bool> Function(QueueItemModel item) syncHandler) async {
    int syncedCount = 0;
    final toProcess = List<QueueItemModel>.from(pendingItems);

    for (final item in toProcess) {
      final index = _memoryQueue.indexWhere((i) => i.id == item.id);
      if (index == -1) continue;

      _memoryQueue[index] = _memoryQueue[index].copyWith(status: QueueItemStatus.inFlight);

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
    }
    return syncedCount;
  }

  void clearSynced() {
    _memoryQueue.removeWhere((item) => item.status == QueueItemStatus.synced);
  }
}
