import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../models/profile.dart';
import 'auth_service.dart';
import 'profile_service.dart';

class ChatService {
  final SupabaseClient _client;

  ChatService(this._client);

  /// Fetches the list of chat rooms visible to the current authenticated user.
  /// (Supabase RLS automatically filters restricted rooms based on profile faction).
  Future<List<ChatRoom>> fetchAvailableRooms() async {
    try {
      final response = await _client.from('chat_rooms').select();
      return (response as List<dynamic>)
          .map((r) => ChatRoom.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching chat rooms: $e');
      rethrow;
    }
  }

  /// Fetches historical messages for a given room.
  Future<List<ChatMessage>> fetchMessages(String roomId) async {
    try {
      final response = await _client
          .from('chat_messages')
          .select('*, sender:profiles(*)')
          .eq('room_id', roomId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      rethrow;
    }
  }

  /// Sends a message to the specified room.
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
  }) async {
    try {
      final response = await _client
          .from('chat_messages')
          .insert({
            'room_id': roomId,
            'sender_id': senderId,
            'content': content,
          })
          .select('*, sender:profiles(*)')
          .single();

      return ChatMessage.fromJson(response);
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }
}

/// Provider exposing the ChatService.
final chatServiceProvider = Provider<ChatService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ChatService(client);
});

/// Provider exposing the list of visible rooms.
final chatRoomsProvider = FutureProvider<List<ChatRoom>>((ref) {
  return ref.watch(chatServiceProvider).fetchAvailableRooms();
});

/// Family notifier managing real-time messages in a specific chat room.
final chatMessagesProvider =
    AsyncNotifierProvider.family<RoomMessagesNotifier, List<ChatMessage>, String>((roomId) {
  return RoomMessagesNotifier(roomId);
});

class RoomMessagesNotifier extends AsyncNotifier<List<ChatMessage>> {
  final String _roomId;
  RealtimeChannel? _channel;
  final Map<String, Profile> _profileCache = {};

  RoomMessagesNotifier(this._roomId);

  @override
  Future<List<ChatMessage>> build() async {
    // 1. Fetch history
    final history = await ref.read(chatServiceProvider).fetchMessages(_roomId);

    // Cache historical profiles
    for (final msg in history) {
      if (msg.sender != null) {
        _profileCache[msg.senderId] = msg.sender!;
      }
    }

    // 2. Subscribe to real-time inserts
    _subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    return history;
  }

  void _subscribe() {
    final client = ref.read(supabaseClientProvider);
    _channel = client.channel('room_chats:$_roomId');
    
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_messages',
      callback: (payload) async {
        final record = payload.newRecord;
        final recordRoomId = record['room_id'] as String;
        if (recordRoomId != _roomId) return; // Client-side filter matching channel room ID

        final senderId = record['sender_id'] as String;

        // Try load sender profile from cache or database
        Profile? profile = _profileCache[senderId];
        if (profile == null) {
          try {
            profile = await ref.read(profileServiceProvider).getProfile(senderId);
            if (profile != null) {
              _profileCache[senderId] = profile;
            }
          } catch (_) {}
        }

        final newMessage = ChatMessage(
          id: record['id'] as String,
          roomId: record['room_id'] as String,
          senderId: senderId,
          content: record['content'] as String,
          createdAt: record['created_at'] as String,
          sender: profile,
        );

        final currentList = state.value ?? [];
        if (!currentList.any((m) => m.id == newMessage.id)) {
          state = AsyncValue.data([...currentList, newMessage]);
        }
      },
    ).subscribe();
  }

  Future<void> send(String content) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('User not authenticated');

    final sent = await ref.read(chatServiceProvider).sendMessage(
          roomId: _roomId,
          senderId: user.id,
          content: content,
        );

    final currentList = state.value ?? [];
    if (!currentList.any((m) => m.id == sent.id)) {
      state = AsyncValue.data([...currentList, sent]);
    }
  }
}

/// Notifier managing the currently selected chat room ID across screens.
class SelectedChatRoomIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectRoom(String? roomId) {
    state = roomId;
  }
}

/// Provider exposing the selected chat room ID state.
final selectedChatRoomIdProvider = NotifierProvider<SelectedChatRoomIdNotifier, String?>(() {
  return SelectedChatRoomIdNotifier();
});
