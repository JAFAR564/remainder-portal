import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../data/services/database_service.dart';
import '../../data/repositories/okf_repository.dart';
import '../../data/services/litert_service.dart';
import '../../data/models/character_sheet.dart';

// SQLite database provider singleton
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// OKF Lore Repository provider
final okfRepositoryProvider = Provider<OkfRepository>((ref) {
  return OkfRepository();
});

// AI Service provider (with client hardware fallback routing)
final litertServiceProvider = Provider<LiteRtService>((ref) {
  return LiteRtService();
});

// Character state profile
class PlayerProfile {
  final String id;
  final String name;
  final String origin;
  final String activeSector;
  final CharacterSheet stats;

  PlayerProfile({
    required this.id,
    required this.name,
    required this.origin,
    required this.activeSector,
    required this.stats,
  });

  PlayerProfile copyWith({
    String? id,
    String? name,
    String? origin,
    String? activeSector,
    CharacterSheet? stats,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      activeSector: activeSector ?? this.activeSector,
      stats: stats ?? this.stats,
    );
  }
}

// Manages player profile state
class PlayerProfileNotifier extends StateNotifier<PlayerProfile?> {
  final AppDatabase _db;
  PlayerProfileNotifier(this._db) : super(null);

  Future<void> createProfile(String name, String origin) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final initialStats = CharacterSheet(
      computePower: origin == 'Amatsukrion Sync' ? 5 : 3,
      shieldIntegrity: origin == 'Wyrd-Born' ? 5 : 3,
      energyReserve: origin == 'Aether-Wake' ? 5 : 3,
    );

    final profile = PlayerProfile(
      id: newId,
      name: name,
      origin: origin,
      activeSector: 'sectors_neon_bastion_4',
      stats: initialStats,
    );

    // Save to Drift database offline cache
    await _db.into(_db.users).insert(
      UsersCompanion.insert(
        id: newId,
        displayName: name,
        email: '$name@remainder.net',
        origin: origin,
        activeSector: 'sectors_neon_bastion_4',
        reputationRanks: Value('{"Vanguard": 1}'),
        joinedDate: DateTime.now(),
        trustScore: 1.0,
      ),
    );

    state = profile;
  }

  void updateSector(String sectorId) {
    if (state != null) {
      state = state!.copyWith(activeSector: sectorId);
      _db.update(_db.users).write(
        UsersCompanion(activeSector: Value(sectorId)),
      );
    }
  }

  void addStat(String statName) {
    if (state == null) return;
    final current = state!.stats;
    CharacterSheet newStats;
    if (statName == 'compute') {
      newStats = current.copyWith(computePower: current.computePower + 1);
    } else if (statName == 'shield') {
      newStats = current.copyWith(shieldIntegrity: current.shieldIntegrity + 1);
    } else {
      newStats = current.copyWith(energyReserve: current.energyReserve + 1);
    }
    state = state!.copyWith(stats: newStats);
  }
}

final playerProfileProvider = StateNotifierProvider<PlayerProfileNotifier, PlayerProfile?>((ref) {
  final db = ref.watch(databaseProvider);
  return PlayerProfileNotifier(db);
});

// Chat message UI model
class MessageModel {
  final String sender;
  final String content;
  final DateTime timestamp;

  MessageModel({
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}

enum ConnectionStatus { online, offline }

final connectionStatusProvider = StateProvider<ConnectionStatus>((ref) => ConnectionStatus.online);

// Manages chat messages state
class ChatHistoryNotifier extends StateNotifier<List<MessageModel>> {
  final LiteRtService _aiService;
  final Ref _ref;

  ChatHistoryNotifier(this._aiService, this._ref) : super([
    MessageModel(
      sender: 'Game Master',
      content: 'Awakening portal active. Establish neural connection to begin.',
      timestamp: DateTime.now(),
    )
  ]);

  Future<void> sendPlayerAction(String actionText, String characterClass) async {
    final userMsg = MessageModel(
      sender: 'Player',
      content: actionText,
      timestamp: DateTime.now(),
    );

    state = [...state, userMsg];

    // Show typing placeholder
    final typingMsg = MessageModel(
      sender: 'Game Master',
      content: '...processing consensus rules...',
      timestamp: DateTime.now(),
    );
    state = [...state, typingMsg];

    // Fetch from AI endpoint with RAG context
    final gmResponse = await _aiService.generateStoryResponse(
      actionText,
      characterClass: characterClass,
    );

    // Update connection status based on whether it fell back to offline/network error
    if (gmResponse.contains('Offline or failed to reach') || gmResponse.contains('Network Error')) {
      _ref.read(connectionStatusProvider.notifier).state = ConnectionStatus.offline;
    } else {
      _ref.read(connectionStatusProvider.notifier).state = ConnectionStatus.online;
    }

    // Replace placeholder with response
    state = [
      ...state.sublist(0, state.length - 1),
      MessageModel(
        sender: 'Game Master',
        content: gmResponse,
        timestamp: DateTime.now(),
      )
    ];
  }
}

final chatHistoryProvider = StateNotifierProvider<ChatHistoryNotifier, List<MessageModel>>((ref) {
  final ai = ref.watch(litertServiceProvider);
  return ChatHistoryNotifier(ai, ref);
});
