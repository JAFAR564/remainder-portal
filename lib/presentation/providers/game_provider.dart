import 'package:flutter/material.dart';
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

  Future<void> createProfile({
    required String name,
    required String origin,
    required int compute,
    required int shield,
    required int energy,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final initialStats = CharacterSheet(
      computePower: compute,
      shieldIntegrity: shield,
      energyReserve: energy,
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
  final bool isIC;

  MessageModel({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isIC = true,
  });
}

enum ChatFilter { all, icOnly, oocOnly }

final chatFilterProvider = StateProvider<ChatFilter>((ref) => ChatFilter.all);

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
      isIC: true,
    )
  ]);

  Future<void> sendPlayerAction(String actionText, String characterClass, {bool isIC = true}) async {
    final userMsg = MessageModel(
      sender: 'Player',
      content: actionText,
      timestamp: DateTime.now(),
      isIC: isIC,
    );

    state = [...state, userMsg];

    // Show typing placeholder
    final typingMsg = MessageModel(
      sender: 'Game Master',
      content: '...processing consensus rules...',
      timestamp: DateTime.now(),
      isIC: isIC,
    );
    state = [...state, typingMsg];

    // Fetch from AI endpoint with RAG context
    final gmResponse = await _aiService.generateStoryResponse(
      actionText,
      characterClass: characterClass,
    );

    // Update connection status based on whether it fell back to offline/network error
    if (gmResponse.contains('[OFFLINE RULE ENGINE]') ||
        gmResponse.contains('Offline or failed to reach') ||
        gmResponse.contains('Network Error')) {
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
        isIC: isIC,
      )
    ];
  }
}

final chatHistoryProvider = StateNotifierProvider<ChatHistoryNotifier, List<MessageModel>>((ref) {
  final ai = ref.watch(litertServiceProvider);
  return ChatHistoryNotifier(ai, ref);
});

// Equipment Models & Providers
enum EquipmentRarity { common, rare, celestial, sovereign }

class EquippedGearItem {
  final String id;
  final String slot;
  final String name;
  final EquipmentRarity rarity;
  final String statBonus;
  final String description;
  final IconData icon;

  const EquippedGearItem({
    required this.id,
    required this.slot,
    required this.name,
    required this.rarity,
    required this.statBonus,
    required this.description,
    required this.icon,
  });
}

class EquippedGearNotifier extends StateNotifier<List<EquippedGearItem>> {
  EquippedGearNotifier()
      : super(const [
          EquippedGearItem(
            id: 'gear_wep_1',
            slot: 'WEAPON',
            name: 'Shadow Dagger',
            rarity: EquipmentRarity.celestial,
            statBonus: '+15 Physical ATK, +8 Shadow Resonance',
            description: 'Forged in the abyss beneath Sanctuary 4. Strikes weave ethereal shadows that bypass arcane wards.',
            icon: Icons.colorize,
          ),
          EquippedGearItem(
            id: 'gear_arm_1',
            slot: 'ARMOR',
            name: 'Aegis Cuirass',
            rarity: EquipmentRarity.sovereign,
            statBonus: '+20 Shield Integrity, +10 Vitality',
            description: 'Masterwork armor inscribed with Cardinal protection runes. Reduces dimensional anomaly shock by 25%.',
            icon: Icons.shield,
          ),
          EquippedGearItem(
            id: 'gear_rel_1',
            slot: 'RELIC',
            name: 'Astrolabe Core',
            rarity: EquipmentRarity.celestial,
            statBonus: '+14 Compute Power, +12 Aether Reserve',
            description: 'A spinning celestial mechanism synchronizing soul vessel pulse directly with World Arbiter decrees.',
            icon: Icons.auto_awesome,
          ),
          EquippedGearItem(
            id: 'gear_chm_1',
            slot: 'CHARM',
            name: 'Ionic Crystal',
            rarity: EquipmentRarity.rare,
            statBonus: '+6 Aether Regeneration per Round',
            description: 'Condensed starlight harvested from ancient sky temples. Radiates soothing celestial warmth.',
            icon: Icons.diamond_outlined,
          ),
        ]);

  void unequipItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final equippedGearProvider = StateNotifierProvider<EquippedGearNotifier, List<EquippedGearItem>>((ref) {
  return EquippedGearNotifier();
});

// Active Quest Decree Model & Provider
class ActiveQuestModel {
  final String id;
  final String title;
  final String sectorId;
  final String sectorName;
  final String decreeText;
  final int rewardEssence;
  final int rewardLaurels;
  final double progress;
  final bool isUrgent;
  final String difficulty;

  const ActiveQuestModel({
    required this.id,
    required this.title,
    required this.sectorId,
    required this.sectorName,
    required this.decreeText,
    required this.rewardEssence,
    required this.rewardLaurels,
    this.progress = 0.65,
    this.isUrgent = true,
    this.difficulty = 'S-RANK',
  });
}

final activeQuestProvider = StateProvider<ActiveQuestModel>((ref) {
  return const ActiveQuestModel(
    id: 'quest_sanctuary_4',
    title: 'Clear Anomaly Wave in Sanctuary 4 (Aether Spire)',
    sectorId: 'sectors_neon_bastion_4',
    sectorName: 'Sanctuary 4 (Aether Spire)',
    decreeText: 'The World Arbiter (Cardinal) has detected dimensional chaos. Assemble squad matrix or engage solo descent.',
    rewardEssence: 750,
    rewardLaurels: 50,
    progress: 0.65,
    isUrgent: true,
    difficulty: 'S-RANK',
  );
});

// Social Feed Model & Provider
class SocialPostModel {
  final String id;
  final String authorName;
  final String authorTitle;
  final String avatarPath;
  final String timeAgo;
  final String content;
  final bool isIC;
  final int laurels;
  final int comments;
  final bool hasLaureled;

  const SocialPostModel({
    required this.id,
    required this.authorName,
    required this.authorTitle,
    required this.avatarPath,
    required this.timeAgo,
    required this.content,
    required this.isIC,
    required this.laurels,
    required this.comments,
    this.hasLaureled = false,
  });

  SocialPostModel copyWith({
    int? laurels,
    int? comments,
    bool? hasLaureled,
  }) {
    return SocialPostModel(
      id: id,
      authorName: authorName,
      authorTitle: authorTitle,
      avatarPath: avatarPath,
      timeAgo: timeAgo,
      content: content,
      isIC: isIC,
      laurels: laurels ?? this.laurels,
      comments: comments ?? this.comments,
      hasLaureled: hasLaureled ?? this.hasLaureled,
    );
  }
}

class SocialFeedNotifier extends StateNotifier<List<SocialPostModel>> {
  SocialFeedNotifier()
      : super(const [
          SocialPostModel(
            id: 'post_1',
            authorName: 'Aegis Commander Kaelen',
            authorTitle: 'High Guardian | Guild: Covenant of Aegis',
            avatarPath: 'assets/icon/app_icon.png',
            timeAgo: '12m ago',
            content: 'Barrier wards holding strong at Sanctuary 4. Looking for two high-Aether sorcerers to join our raid party against the Shadow Serpent wave tonight!',
            isIC: true,
            laurels: 24,
            comments: 7,
          ),
          SocialPostModel(
            id: 'post_2',
            authorName: 'Archmage Nyx',
            authorTitle: 'Master Sorcerer | Guild: Spellweavers',
            avatarPath: 'assets/icon/app_icon.png',
            timeAgo: '45m ago',
            content: 'OOC: Just finished designing the new lore proposal for the Ancient Aether Spire in the Chrono-Loom! Please check out the proposal thread and cast your vote!',
            isIC: false,
            laurels: 41,
            comments: 12,
          ),
        ]);

  void toggleLaurel(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        final newHasLaureled = !post.hasLaureled;
        final newLaurels = newHasLaureled ? post.laurels + 1 : post.laurels - 1;
        return post.copyWith(
          laurels: newLaurels,
          hasLaureled: newHasLaureled,
        );
      }
      return post;
    }).toList();
  }

  Future<void> refreshFeed() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Keeps live state intact with fresh timestamp simulation
  }
}

final socialFeedProvider = StateNotifierProvider<SocialFeedNotifier, List<SocialPostModel>>((ref) {
  return SocialFeedNotifier();
});

