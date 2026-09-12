import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_item_model.dart';
import '../../data/models/oracle_record.dart';
import '../../data/models/player_wallet.dart';
import '../../data/models/quest_decree_model.dart';
import '../../data/models/social_bulletin_model.dart';
import '../../data/repositories/sovereign_repository.dart';
import 'game_provider.dart';
import 'utrcs_provider.dart';
import 'economy_provider.dart';
import 'chrono_loom_provider.dart';
import 'expedition_provider.dart';
import 'guild_provider.dart';
import 'trust_provider.dart';
import '../../data/services/p2p_squad_relay_service.dart';

/// Sovereign Command Deck domain repository provider
final sovereignRepositoryProvider = Provider<SovereignRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SovereignRepository(db);
});

/// State for active temporal buffs and divination chronicle
class OracleBuffState {
  final List<ActiveBuff> activeBuffs;
  final List<OracleRecord> history;

  const OracleBuffState({
    this.activeBuffs = const [],
    this.history = const [],
  });

  OracleRecord? get latestRecord => history.isNotEmpty ? history.first : null;

  ActiveBuff? get primaryBuff => activeBuffs.isNotEmpty ? activeBuffs.first : null;

  OracleBuffState copyWith({
    List<ActiveBuff>? activeBuffs,
    List<OracleRecord>? history,
  }) {
    return OracleBuffState(
      activeBuffs: activeBuffs ?? this.activeBuffs,
      history: history ?? this.history,
    );
  }
}

/// Reactive StateNotifier managing Oracle divination chronicle and active temporal buffs
class OracleBuffNotifier extends StateNotifier<AsyncValue<OracleBuffState>> {
  final SovereignRepository _repo;
  final Ref _ref;
  final String _userId;

  OracleBuffNotifier(this._repo, this._ref, this._userId)
      : super(AsyncValue.data(OracleBuffState(
          history: [SovereignRepository.defaultStarterRoll(_userId)],
          activeBuffs: [
            if (SovereignRepository.defaultStarterRoll(_userId).activeBuff != null)
              SovereignRepository.defaultStarterRoll(_userId).activeBuff!
          ],
        ))) {
    loadOracleState();
  }

  Future<void> loadOracleState() async {
    try {
      final history = await _repo.getHistory(_userId, limit: 20);
      final activeBuffs = await _repo.getActiveBuffs(_userId);
      if (mounted) {
        state = AsyncValue.data(OracleBuffState(
          history: history,
          activeBuffs: activeBuffs,
        ));
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  /// Executes atomic divination communion with Essence debit, optional LLM synthesis, and roll persistence
  Future<OracleRecord> commune({
    int costEssence = 25,
    int? rollOverride,
    DateTime? timestamp,
    String? operatorClass,
    String? sector,
  }) async {
    final record = await _repo.communeWithOracle(
      userId: _userId,
      costEssence: costEssence,
      rollOverride: rollOverride,
      timestamp: timestamp,
      operatorClass: operatorClass,
      sector: sector,
    );

    // Refresh player wallet reactively so Essence deduction is reflected on Dashboard
    await _ref.read(playerWalletProvider(_userId).notifier).loadWallet();
    await loadOracleState();
    return record;
  }

  /// Direct roll recording for testing
  Future<void> logDivinationRoll({
    required String userId,
    required int d20Roll,
    required String outcomeTier,
    required String blessingText,
    String? buffGranted,
    BuffType? buffType,
    double multiplier = 1.0,
    Duration duration = const Duration(minutes: 15),
  }) async {
    final record = OracleRecord(
      id: 'oracle_roll_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      d20Roll: d20Roll,
      outcomeTier: outcomeTier,
      blessingText: blessingText,
      buffGranted: buffGranted,
      timestamp: DateTime.now(),
    );

    await _repo.recordRoll(record);
    await loadOracleState();
  }
}

/// Family provider for specific operator's Oracle & Buff state
final oracleBuffProvider = StateNotifierProvider.family<OracleBuffNotifier, AsyncValue<OracleBuffState>, String>((ref, userId) {
  final repo = ref.watch(sovereignRepositoryProvider);
  return OracleBuffNotifier(repo, ref, userId);
});

/// Reactive provider for the active operator's Oracle & Buff state
final activeOracleBuffProvider = Provider<AsyncValue<OracleBuffState>>((ref) {
  final character = ref.watch(utrcsCharacterProvider);
  final userId = character?.id ?? 'utrcs_default_player';
  return ref.watch(oracleBuffProvider(userId));
});

/// Manages player wallet and progression state reactively
class PlayerWalletNotifier extends StateNotifier<AsyncValue<PlayerWallet>> {
  final SovereignRepository _repo;
  final String _userId;

  PlayerWalletNotifier(this._repo, this._userId)
      : super(AsyncValue.data(PlayerWallet(
          userId: _userId,
          essenceBalance: 1000,
          laurelBalance: 150,
          experiencePoints: 765000,
          currentLevel: 88,
          unallocatedAttributePoints: 0,
          lastUpdated: DateTime(2026, 9, 11),
        ))) {
    loadWallet();
  }

  Future<void> loadWallet() async {
    try {
      final wallet = await _repo.getWallet(_userId);
      if (mounted) {
        state = AsyncValue.data(wallet);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> refresh() => loadWallet();
}

/// Family provider for specific operator wallet
final playerWalletProvider = StateNotifierProvider.family<PlayerWalletNotifier, AsyncValue<PlayerWallet>, String>((ref, userId) {
  final repo = ref.watch(sovereignRepositoryProvider);
  return PlayerWalletNotifier(repo, userId);
});

/// Reactive provider for the active operator's wallet
final activeWalletProvider = Provider<AsyncValue<PlayerWallet>>((ref) {
  final character = ref.watch(utrcsCharacterProvider);
  final userId = character?.id ?? 'utrcs_default_player';
  return ref.watch(playerWalletProvider(userId));
});

/// Represents the persistent state of the player's Imperial Relic Vault and equipped gear
class RelicVaultState {
  final List<EquipmentItemModel> items;

  const RelicVaultState({this.items = const []});

  List<EquipmentItemModel> get equippedItems => items.where((i) => i.isEquipped).toList();
  List<EquipmentItemModel> get vaultItems => items.where((i) => !i.isEquipped).toList();

  EquipmentItemModel? equippedForSlot(String slot) {
    try {
      return items.firstWhere((i) => i.isEquipped && i.slot.toUpperCase() == slot.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  List<EquipmentItemModel> vaultItemsForSlot(String slot) {
    return items.where((i) => !i.isEquipped && i.slot.toUpperCase() == slot.toUpperCase()).toList();
  }

  EquipmentItemModel? itemById(String id) {
    try {
      return items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Reactive StateNotifier for the Imperial Relic Vault & Equipment
class RelicVaultNotifier extends StateNotifier<AsyncValue<RelicVaultState>> {
  final SovereignRepository _repo;
  final Ref _ref;
  final String _userId;

  RelicVaultNotifier(this._repo, this._ref, this._userId)
      : super(AsyncValue.data(RelicVaultState(
          items: SovereignRepository.defaultStarterGear(_userId),
        ))) {
    loadVault();
  }

  Future<void> loadVault() async {
    try {
      final items = await _repo.getEquipment(_userId);
      if (mounted) {
        state = AsyncValue.data(RelicVaultState(items: items));
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> equipItem({required String itemId, required String slot}) async {
    await _repo.equipItem(userId: _userId, itemId: itemId, slot: slot);
    await loadVault();
  }

  Future<void> unequipItem({required String itemId}) async {
    await _repo.unequipItem(userId: _userId, itemId: itemId);
    await loadVault();
  }

  Future<EquipmentItemModel> upgradeItem({required String itemId, required int costEssence}) async {
    final updated = await _repo.upgradeItem(
      itemId: itemId,
      userId: _userId,
      costEssence: costEssence,
    );
    // Refresh the player wallet so the UI immediately reflects the debited Essence
    await _ref.read(playerWalletProvider(_userId).notifier).loadWallet();
    await loadVault();
    return updated;
  }
}

/// Family provider for specific operator's relic vault
final relicVaultProvider = StateNotifierProvider.family<RelicVaultNotifier, AsyncValue<RelicVaultState>, String>((ref, userId) {
  final repo = ref.watch(sovereignRepositoryProvider);
  return RelicVaultNotifier(repo, ref, userId);
});

/// Reactive provider for the active operator's relic vault
final activeRelicVaultProvider = Provider<AsyncValue<RelicVaultState>>((ref) {
  final character = ref.watch(utrcsCharacterProvider);
  final userId = character?.id ?? 'utrcs_default_player';
  return ref.watch(relicVaultProvider(userId));
});

/// State holding active decrees and optional tracked decree ID
class QuestDecreeState {
  final List<QuestDecreeModel> decrees;
  final String? selectedQuestId;
  final bool isWeaving;

  const QuestDecreeState({
    required this.decrees,
    this.selectedQuestId,
    this.isWeaving = false,
  });

  /// The active primary quest displayed on the dashboard.
  /// Precedence:
  /// 1. The explicitly selected quest, if present.
  /// 2. The first active, unclaimed quest (prioritizing completed/claimable, then urgent in-progress).
  /// 3. The first decree in the list, or null if empty.
  QuestDecreeModel? get primaryQuest {
    if (decrees.isEmpty) return null;
    if (selectedQuestId != null) {
      final selected = decrees.firstWhere(
        (q) => q.id == selectedQuestId,
        orElse: () => decrees.first,
      );
      return selected;
    }
    // Prefer unclaimed decrees: urgent in-progress first, then completed claimable, then any unclaimed
    final unclaimed = decrees.where((q) => !q.isClaimed).toList();
    if (unclaimed.isNotEmpty) {
      final urgent = unclaimed.where((q) => q.isUrgent && !q.isCompleted).toList();
      if (urgent.isNotEmpty) return urgent.first;
      final claimable = unclaimed.where((q) => q.isCompleted).toList();
      if (claimable.isNotEmpty) return claimable.first;
      return unclaimed.first;
    }
    return decrees.first;
  }

  QuestDecreeState copyWith({
    List<QuestDecreeModel>? decrees,
    String? selectedQuestId,
    bool? isWeaving,
  }) {
    return QuestDecreeState(
      decrees: decrees ?? this.decrees,
      selectedQuestId: selectedQuestId ?? this.selectedQuestId,
      isWeaving: isWeaving ?? this.isWeaving,
    );
  }
}

/// Reactive StateNotifier for World Arbiter Quest Decrees
class QuestDecreeNotifier extends StateNotifier<AsyncValue<QuestDecreeState>> {
  final SovereignRepository _repo;
  final Ref _ref;
  final String _userId;

  QuestDecreeNotifier(this._repo, this._ref, this._userId)
      : super(AsyncValue.data(QuestDecreeState(
          decrees: SovereignRepository.defaultStarterQuests(_userId),
        ))) {
    loadDecrees();
  }

  Future<void> loadDecrees() async {
    try {
      final decrees = await _repo.getQuests(_userId);
      if (mounted) {
        state = AsyncValue.data(QuestDecreeState(
          decrees: decrees,
          selectedQuestId: state.valueOrNull?.selectedQuestId,
          isWeaving: state.valueOrNull?.isWeaving ?? false,
        ));
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void selectQuest(String questId) {
    state = state.whenData((s) => s.copyWith(selectedQuestId: questId));
  }

  Future<void> updateProgress({required String questId, required double progress}) async {
    await _repo.updateQuestProgress(questId: questId, progress: progress);
    await loadDecrees();
  }

  Future<QuestClaimResult> claimReward({required String questId}) async {
    final result = await _repo.claimReward(questId: questId, userId: _userId);
    if (result.success) {
      // Reload wallet so live Essence & Laurels meters reactively reflect the reward
      await _ref.read(playerWalletProvider(_userId).notifier).loadWallet();
      await loadDecrees();
    }
    return result;
  }

  /// Triggers World Arbiter on-device LLM generation for a new quest decree.
  /// Sets isWeaving during inference and fails closed to deterministic calibrated fallback.
  Future<QuestDecreeModel> generateNewDecree({
    required String sectorId,
    required String sectorName,
    required String difficulty,
    String? operatorClass,
    bool isUrgent = false,
  }) async {
    state = state.whenData((s) => s.copyWith(isWeaving: true));
    try {
      final decree = await _repo.generateDynamicQuestDecree(
        userId: _userId,
        sectorId: sectorId,
        sectorName: sectorName,
        difficulty: difficulty,
        operatorClass: operatorClass,
        isUrgent: isUrgent,
      );
      await loadDecrees();
      return decree;
    } finally {
      if (mounted) {
        state = state.whenData((s) => s.copyWith(isWeaving: false));
      }
    }
  }
}

/// Family provider for specific operator's quest decrees
final questDecreeProvider = StateNotifierProvider.family<QuestDecreeNotifier, AsyncValue<QuestDecreeState>, String>((ref, userId) {
  final repo = ref.watch(sovereignRepositoryProvider);
  return QuestDecreeNotifier(repo, ref, userId);
});

/// Reactive provider for active operator's quest decrees
final activeQuestDecreeProvider = Provider<AsyncValue<QuestDecreeState>>((ref) {
  final character = ref.watch(utrcsCharacterProvider);
  final userId = character?.id ?? 'utrcs_default_player';
  return ref.watch(questDecreeProvider(userId));
});

// ==========================================
// Phase 5: Sanctuary Social Bulletin (Thread B-5)
// ==========================================

class SocialBulletinNotifier extends StateNotifier<AsyncValue<List<SocialPostEntry>>> {
  final SovereignRepository _repo;

  SocialBulletinNotifier(this._repo)
      : super(AsyncValue.data([SovereignRepository.defaultStarterPost()])) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    try {
      final posts = await _repo.getFeed();
      if (mounted) {
        state = AsyncValue.data(posts);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> createPost({
    required String authorId,
    required String authorName,
    required String authorTitle,
    required String content,
    bool isIC = true,
  }) async {
    final newPost = SocialPostEntry(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      authorName: authorName,
      authorTitle: authorTitle,
      avatarPath: 'assets/icon/app_icon.png',
      content: content,
      isIC: isIC,
      laurelsCount: 0,
      commentsCount: 0,
      createdAt: DateTime.now(),
    );
    await _repo.createPost(newPost);
    await loadFeed();
  }

  Future<void> endorsePost({required String postId, required String userId}) async {
    await _repo.endorsePost(postId: postId, userId: userId);
    await loadFeed();
  }

  Future<void> addComment({
    required String postId,
    required String authorName,
    required String content,
  }) async {
    final comment = SocialCommentEntry(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
    );
    await _repo.addComment(comment);
    await loadFeed();
  }

  Future<List<SocialCommentEntry>> getComments(String postId) async {
    return await _repo.getComments(postId);
  }
}

final socialBulletinProvider = StateNotifierProvider<SocialBulletinNotifier, AsyncValue<List<SocialPostEntry>>>((ref) {
  final repo = ref.watch(sovereignRepositoryProvider);
  return SocialBulletinNotifier(repo);
});

// ==========================================
// Phase 5: Waygate Telemetry Engine (Thread B-5)
// ==========================================

class WaygateTelemetryState {
  final int tradePendingCount;
  final int canonActiveProposalsCount;
  final int squadMemberCount;
  final bool isSquadActive;
  final String? guildTag;
  final int relayQueuedCount;
  final bool isRelayOnline;
  final double overallTrustScore;
  final double vanguardScore;
  final double arbiterScore;
  final double merchantScore;
  final double hackerScore;
  final String p2pMeshStatus;
  final int connectedPeersCount;
  final String syncEngineStatus;
  final String architecturalNotice;

  const WaygateTelemetryState({
    required this.tradePendingCount,
    required this.canonActiveProposalsCount,
    required this.squadMemberCount,
    required this.isSquadActive,
    this.guildTag,
    required this.relayQueuedCount,
    required this.isRelayOnline,
    required this.overallTrustScore,
    required this.vanguardScore,
    required this.arbiterScore,
    required this.merchantScore,
    required this.hackerScore,
    required this.p2pMeshStatus,
    required this.connectedPeersCount,
    required this.syncEngineStatus,
    required this.architecturalNotice,
  });
}

final tradeProvider = economyProvider;

final waygateTelemetryProvider = Provider<WaygateTelemetryState>((ref) {
  final tradeState = ref.watch(economyProvider);
  final chronoState = ref.watch(chronoLoomProvider);
  final expeditionState = ref.watch(expeditionProvider);
  final guildState = ref.watch(guildProvider);
  final relay = ref.watch(p2pSquadRelayProvider);
  final trust = ref.watch(trustProvider);

  final tradePending = tradeState.activeTrades.where((t) => t.status == TradeStatus.pending).length;
  final canonActive = chronoState.proposals.where((p) => p.status == 0).length;
  final squadCount = expeditionState?.members.length ?? 0;
  final hasSquad = expeditionState != null;

  return WaygateTelemetryState(
    tradePendingCount: tradePending,
    canonActiveProposalsCount: canonActive,
    squadMemberCount: squadCount,
    isSquadActive: hasSquad,
    guildTag: guildState?.tag,
    relayQueuedCount: relay.queuedEventCount,
    isRelayOnline: relay.isOnline,
    overallTrustScore: trust.overallTrustScore,
    vanguardScore: trust.vanguardScore,
    arbiterScore: trust.arbiterScore,
    merchantScore: trust.merchantScore,
    hackerScore: trust.hackerScore,
    p2pMeshStatus: 'LOCAL STANDBY (P2P TRANSPORT DEFERRED)',
    connectedPeersCount: 0,
    syncEngineStatus: 'LOCAL-FIRST ISOLATION',
    architecturalNotice: 'Multi-device P2P mesh discovery and physical peer transports are explicitly DEFERRED. Telemetry reflects authenticated local node state and verified Phase 2/3 domain providers.',
  );
});


