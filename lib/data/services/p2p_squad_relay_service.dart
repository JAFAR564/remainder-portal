import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SquadRelayEventType {
  squadCreated,
  memberJoined,
  memberLeft,
  squadAction,
  coopCheck,
  trustEndorsement,
}

class P2pSquadRelayEvent {
  final String id;
  final String expeditionId;
  final String senderId;
  final String senderName;
  final SquadRelayEventType eventType;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  P2pSquadRelayEvent({
    required this.id,
    required this.expeditionId,
    required this.senderId,
    required this.senderName,
    required this.eventType,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'expeditionId': expeditionId,
        'senderId': senderId,
        'senderName': senderName,
        'eventType': eventType.name,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };

  factory P2pSquadRelayEvent.fromJson(Map<String, dynamic> json) {
    return P2pSquadRelayEvent(
      id: json['id'] as String,
      expeditionId: json['expeditionId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      eventType: SquadRelayEventType.values.byName(json['eventType'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class P2pSquadRelayService {
  final _eventController = StreamController<P2pSquadRelayEvent>.broadcast();
  final Set<String> _processedEventIds = {};
  final List<P2pSquadRelayEvent> _offlineQueue = [];
  bool _isOnline = true;

  Stream<P2pSquadRelayEvent> get eventStream => _eventController.stream;
  bool get isOnline => _isOnline;
  int get queuedEventCount => _offlineQueue.length;

  void setOnlineStatus(bool online) {
    _isOnline = online;
    if (_isOnline && _offlineQueue.isNotEmpty) {
      flushOfflineQueue();
    }
  }

  bool broadcastEvent(P2pSquadRelayEvent event) {
    if (_processedEventIds.contains(event.id)) {
      return false; // Ignore duplicates
    }

    _processedEventIds.add(event.id);

    if (!_isOnline) {
      _offlineQueue.add(event);
      return false;
    }

    _eventController.add(event);
    return true;
  }

  void flushOfflineQueue() {
    final pending = List<P2pSquadRelayEvent>.from(_offlineQueue);
    _offlineQueue.clear();

    for (final event in pending) {
      _eventController.add(event);
    }
  }

  void clearDeduplicationCache() {
    _processedEventIds.clear();
  }

  void dispose() {
    _eventController.close();
  }
}

final p2pSquadRelayProvider = Provider<P2pSquadRelayService>((ref) {
  final service = P2pSquadRelayService();
  ref.onDispose(() => service.dispose());
  return service;
});
