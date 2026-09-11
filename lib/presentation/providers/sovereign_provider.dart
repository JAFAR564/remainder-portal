import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_item_model.dart';
import '../../data/models/oracle_record.dart';
import '../../data/models/player_wallet.dart';
import '../../data/models/quest_decree_model.dart';
import '../../data/models/social_bulletin_model.dart';
import '../../data/repositories/sovereign_repository.dart';
import 'game_provider.dart';
import 'utrcs_provider.dart';

/// Sovereign Command Deck domain repository provider
final sovereignRepositoryProvider = Provider<SovereignRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SovereignRepository(db);
});

/// State for active temporal buffs granted by the Oracle
class OracleBuffState {
  final List<ActiveBuff> activeBuffs;
  final OracleRecord? latestRecord;

  const OracleBuffState({
    this.activeBuffs = const [],
    this.latestRecord,
  });

  OracleBuffState copyWith({
    List<ActiveBuff>? activeBuffs,
    OracleRecord? latestRecord,
  }) {
    return OracleBuffState(
      activeBuffs: activeBuffs ?? this.activeBuffs,
      latestRecord: latestRecord ?? this.latestRecord,
    );
  }
}

/// Manages active temporal Oracle buffs and divination chronicle history
class OracleBuffNotifier extends StateNotifier<OracleBuffState> {
  final SovereignRepository _repo;

  OracleBuffNotifier(this._repo) : super(const OracleBuffState());

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

    List<ActiveBuff> updatedBuffs = List.from(state.activeBuffs);
    if (buffGranted != null && buffType != null) {
      final now = DateTime.now();
      final newBuff = ActiveBuff(
        id: 'buff_${now.millisecondsSinceEpoch}',
        type: buffType,
        title: buffGranted,
        multiplier: multiplier,
        startedAt: now,
        expiresAt: now.add(duration),
      );
      // Clean expired buffs and add new buff
      updatedBuffs = updatedBuffs.where((b) => !b.isExpired).toList()..add(newBuff);
    }

    state = state.copyWith(
      activeBuffs: updatedBuffs,
      latestRecord: record,
    );
  }
}

final oracleBuffProvider = StateNotifierProvider<OracleBuffNotifier, OracleBuffState>((ref) {
  final repo = ref.watch(sovereignRepositoryProvider);
  return OracleBuffNotifier(repo);
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
