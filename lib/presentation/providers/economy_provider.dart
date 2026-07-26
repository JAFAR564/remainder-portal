import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradeItemModel {
  final String itemId;
  final String itemName;
  final String itemGenre;
  final int baseAttributeValue;
  final String structuralDescription;

  TradeItemModel({
    required this.itemId,
    required this.itemName,
    required this.itemGenre,
    required this.baseAttributeValue,
    required this.structuralDescription,
  });
}

enum TradeStatus { pending, escrowLocked, completed, cancelled }

class PlayerTradeModel {
  final String id;
  final String initiatorId;
  final String receiverId;
  final TradeStatus status;
  final List<TradeItemModel> offeredItems;
  final int offeredEnergy;
  final List<TradeItemModel> requestedItems;
  final int requestedEnergy;
  final bool initiatorConfirmed;
  final bool receiverConfirmed;
  final DateTime createdAt;

  PlayerTradeModel({
    required this.id,
    required this.initiatorId,
    required this.receiverId,
    this.status = TradeStatus.pending,
    required this.offeredItems,
    this.offeredEnergy = 0,
    required this.requestedItems,
    this.requestedEnergy = 0,
    this.initiatorConfirmed = false,
    this.receiverConfirmed = false,
    required this.createdAt,
  });

  PlayerTradeModel copyWith({
    TradeStatus? status,
    bool? initiatorConfirmed,
    bool? receiverConfirmed,
  }) {
    return PlayerTradeModel(
      id: id,
      initiatorId: initiatorId,
      receiverId: receiverId,
      status: status ?? this.status,
      offeredItems: offeredItems,
      offeredEnergy: offeredEnergy,
      requestedItems: requestedItems,
      requestedEnergy: requestedEnergy,
      initiatorConfirmed: initiatorConfirmed ?? this.initiatorConfirmed,
      receiverConfirmed: receiverConfirmed ?? this.receiverConfirmed,
      createdAt: createdAt,
    );
  }
}

class TradeState {
  final List<PlayerTradeModel> activeTrades;
  final List<PlayerTradeModel> tradeHistory;

  TradeState({
    this.activeTrades = const [],
    this.tradeHistory = const [],
  });

  TradeState copyWith({
    List<PlayerTradeModel>? activeTrades,
    List<PlayerTradeModel>? tradeHistory,
  }) {
    return TradeState(
      activeTrades: activeTrades ?? this.activeTrades,
      tradeHistory: tradeHistory ?? this.tradeHistory,
    );
  }
}

class TradeNotifier extends StateNotifier<TradeState> {
  TradeNotifier() : super(TradeState());

  PlayerTradeModel initiateTrade({
    required String initiatorId,
    required String receiverId,
    required List<TradeItemModel> offeredItems,
    required int offeredEnergy,
    required List<TradeItemModel> requestedItems,
    required int requestedEnergy,
  }) {
    final trade = PlayerTradeModel(
      id: 'trade_${DateTime.now().millisecondsSinceEpoch}',
      initiatorId: initiatorId,
      receiverId: receiverId,
      status: TradeStatus.pending,
      offeredItems: offeredItems,
      offeredEnergy: offeredEnergy,
      requestedItems: requestedItems,
      requestedEnergy: requestedEnergy,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      activeTrades: [...state.activeTrades, trade],
    );
    return trade;
  }

  /// Two-Phase Commit Phase 1: Escrow Lock
  bool lockEscrow(String tradeId) {
    final index = state.activeTrades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    final target = state.activeTrades[index];
    if (target.status != TradeStatus.pending) return false;

    final lockedTrade = target.copyWith(status: TradeStatus.escrowLocked);
    final updated = [...state.activeTrades];
    updated[index] = lockedTrade;

    state = state.copyWith(activeTrades: updated);
    return true;
  }

  /// Two-Phase Commit Phase 2: Atomic Transfer Commit
  bool confirmTrade(String tradeId, String userId) {
    final index = state.activeTrades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    final target = state.activeTrades[index];
    if (target.status != TradeStatus.escrowLocked) return false;

    bool initConf = target.initiatorConfirmed;
    bool recvConf = target.receiverConfirmed;

    if (userId == target.initiatorId) initConf = true;
    if (userId == target.receiverId) recvConf = true;

    final updatedTrade = target.copyWith(
      initiatorConfirmed: initConf,
      receiverConfirmed: recvConf,
    );

    if (initConf && recvConf) {
      final completedTrade = updatedTrade.copyWith(status: TradeStatus.completed);
      final remainingActive = state.activeTrades.where((t) => t.id != tradeId).toList();
      state = state.copyWith(
        activeTrades: remainingActive,
        tradeHistory: [completedTrade, ...state.tradeHistory],
      );
      return true;
    } else {
      final updatedList = [...state.activeTrades];
      updatedList[index] = updatedTrade;
      state = state.copyWith(activeTrades: updatedList);
      return false;
    }
  }

  void cancelTrade(String tradeId) {
    final index = state.activeTrades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return;

    final target = state.activeTrades[index];
    final cancelledTrade = target.copyWith(status: TradeStatus.cancelled);
    final remainingActive = state.activeTrades.where((t) => t.id != tradeId).toList();

    state = state.copyWith(
      activeTrades: remainingActive,
      tradeHistory: [cancelledTrade, ...state.tradeHistory],
    );
  }
}

final economyProvider = StateNotifierProvider<TradeNotifier, TradeState>((ref) {
  return TradeNotifier();
});
