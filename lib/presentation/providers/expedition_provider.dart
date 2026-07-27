import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/evaluate_cooperative_check.dart';
import '../../data/services/p2p_squad_relay_service.dart';
import 'trust_provider.dart';

class ExpeditionMemberModel {
  final String userId;
  final String userName;
  final String assignedRole;
  final int primaryStat;
  final bool isSpecialist;
  final double trustScore;

  ExpeditionMemberModel({
    required this.userId,
    required this.userName,
    required this.assignedRole,
    this.primaryStat = 10,
    this.isSpecialist = true,
    this.trustScore = 0.85,
  });

  ExpeditionMemberModel copyWith({
    String? userId,
    String? userName,
    String? assignedRole,
    int? primaryStat,
    bool? isSpecialist,
    double? trustScore,
  }) {
    return ExpeditionMemberModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      assignedRole: assignedRole ?? this.assignedRole,
      primaryStat: primaryStat ?? this.primaryStat,
      isSpecialist: isSpecialist ?? this.isSpecialist,
      trustScore: trustScore ?? this.trustScore,
    );
  }
}

class ExpeditionModel {
  final String id;
  final String leaderId;
  final String title;
  final String sectorId;
  final int status; // 0: Recruiting, 1: Active, 2: Completed
  final List<ExpeditionMemberModel> members;
  final List<String> squadLogs;

  ExpeditionModel({
    required this.id,
    required this.leaderId,
    required this.title,
    required this.sectorId,
    required this.status,
    required this.members,
    this.squadLogs = const [],
  });

  ExpeditionModel copyWith({
    int? status,
    List<ExpeditionMemberModel>? members,
    List<String>? squadLogs,
  }) {
    return ExpeditionModel(
      id: id,
      leaderId: leaderId,
      title: title,
      sectorId: sectorId,
      status: status ?? this.status,
      members: members ?? this.members,
      squadLogs: squadLogs ?? this.squadLogs,
    );
  }
}

class ExpeditionNotifier extends StateNotifier<ExpeditionModel?> {
  final EvaluateCooperativeCheck _checkEvaluator = EvaluateCooperativeCheck();
  final P2pSquadRelayService? _relayService;
  final Ref? _ref;
  StreamSubscription<P2pSquadRelayEvent>? _relaySubscription;

  ExpeditionNotifier([this._relayService, this._ref]) : super(null) {
    if (_relayService != null) {
      _relaySubscription = _relayService!.eventStream.listen(_handleIncomingRelayEvent);
    }
  }

  @override
  void dispose() {
    _relaySubscription?.cancel();
    super.dispose();
  }

  void _handleIncomingRelayEvent(P2pSquadRelayEvent event) {
    if (state != null && event.expeditionId != state!.id) {
      return; // Ignore events for different expeditions
    }

    switch (event.eventType) {
      case SquadRelayEventType.squadCreated:
        if (state == null) {
          final leaderName = event.payload['leaderName'] as String? ?? 'Leader';
          state = ExpeditionModel(
            id: event.expeditionId,
            leaderId: event.senderId,
            title: event.payload['title'] as String? ?? 'Remote Expedition',
            sectorId: event.payload['sectorId'] as String? ?? 'sector_1',
            status: 0,
            members: [
              ExpeditionMemberModel(
                userId: event.senderId,
                userName: leaderName,
                assignedRole: 'Squad Leader',
                primaryStat: 14,
                trustScore: 0.9,
              )
            ],
            squadLogs: ['[SYSTEM] Squad expedition "${event.payload['title']}" initialized by $leaderName.'],
          );
        }
        break;

      case SquadRelayEventType.memberJoined:
        if (state != null) {
          final userId = event.payload['userId'] as String;
          if (!state!.members.any((m) => m.userId == userId)) {
            final member = ExpeditionMemberModel(
              userId: userId,
              userName: event.payload['userName'] as String? ?? 'Ally',
              assignedRole: event.payload['assignedRole'] as String? ?? 'Specialist',
              primaryStat: event.payload['primaryStat'] as int? ?? 10,
              trustScore: (event.payload['trustScore'] as num?)?.toDouble() ?? 0.85,
            );
            state = state!.copyWith(
              members: [...state!.members, member],
              squadLogs: [...state!.squadLogs, '[JOIN] ${member.userName} joined as ${member.assignedRole}.'],
            );
          }
        }
        break;

      case SquadRelayEventType.memberLeft:
        if (state != null) {
          final userId = event.payload['userId'] as String;
          leaveExpedition(userId, isRemote: true);
        }
        break;

      case SquadRelayEventType.squadAction:
      case SquadRelayEventType.coopCheck:
        if (state != null) {
          final logMsg = event.payload['logMessage'] as String? ?? '';
          if (logMsg.isNotEmpty && !state!.squadLogs.contains(logMsg)) {
            state = state!.copyWith(squadLogs: [...state!.squadLogs, logMsg]);
          }
        }
        break;

      case SquadRelayEventType.trustEndorsement:
        if (state != null) {
          final targetUserId = event.payload['targetUserId'] as String;
          final newTrust = (event.payload['newTrust'] as num).toDouble();
          updateMemberTrust(targetUserId, newTrust, isRemote: true);
        }
        break;
    }
  }

  void createExpedition({
    required String title,
    required String leaderId,
    required String leaderName,
    required String sectorId,
  }) {
    final leader = ExpeditionMemberModel(
      userId: leaderId,
      userName: leaderName,
      assignedRole: 'Squad Leader',
      primaryStat: 14,
      isSpecialist: true,
      trustScore: 0.9,
    );

    final expId = 'exp_${DateTime.now().millisecondsSinceEpoch}';
    state = ExpeditionModel(
      id: expId,
      leaderId: leaderId,
      title: title,
      sectorId: sectorId,
      status: 0,
      members: [leader],
      squadLogs: ['[SYSTEM] Squad expedition "$title" initialized by $leaderName.'],
    );

    _relayService?.broadcastEvent(P2pSquadRelayEvent(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}_created',
      expeditionId: expId,
      senderId: leaderId,
      senderName: leaderName,
      eventType: SquadRelayEventType.squadCreated,
      payload: {
        'title': title,
        'leaderName': leaderName,
        'sectorId': sectorId,
      },
    ));
  }

  bool addMember(ExpeditionMemberModel member, {bool isRemote = false}) {
    if (state == null) return false;
    if (state!.members.length >= 5) return false;

    final updated = [...state!.members, member];
    state = state!.copyWith(
      members: updated,
      squadLogs: [...state!.squadLogs, '[JOIN] ${member.userName} joined as ${member.assignedRole}.'],
    );

    if (!isRemote) {
      _relayService?.broadcastEvent(P2pSquadRelayEvent(
        id: 'evt_${DateTime.now().millisecondsSinceEpoch}_join_${member.userId}',
        expeditionId: state!.id,
        senderId: member.userId,
        senderName: member.userName,
        eventType: SquadRelayEventType.memberJoined,
        payload: {
          'userId': member.userId,
          'userName': member.userName,
          'assignedRole': member.assignedRole,
          'primaryStat': member.primaryStat,
          'trustScore': member.trustScore,
        },
      ));
    }
    return true;
  }

  void leaveExpedition(String userId, {bool isRemote = false}) {
    if (state == null) return;
    final leavingMember = state!.members.firstWhere((m) => m.userId == userId, orElse: () => ExpeditionMemberModel(userId: userId, userName: 'Member', assignedRole: ''));
    final updated = state!.members.where((m) => m.userId != userId).toList();

    if (!isRemote && state != null) {
      _relayService?.broadcastEvent(P2pSquadRelayEvent(
        id: 'evt_${DateTime.now().millisecondsSinceEpoch}_leave_$userId',
        expeditionId: state!.id,
        senderId: userId,
        senderName: leavingMember.userName,
        eventType: SquadRelayEventType.memberLeft,
        payload: {'userId': userId},
      ));
    }

    if (updated.isEmpty) {
      state = null;
    } else {
      state = state!.copyWith(
        members: updated,
        squadLogs: [...state!.squadLogs, '[LEFT] ${leavingMember.userName} left the squad.'],
      );
    }
  }

  void updateMemberTrust(String targetUserId, double newTrustScore, {bool isRemote = false}) {
    if (state == null) return;
    final updatedMembers = state!.members.map((m) {
      if (m.userId == targetUserId) {
        return m.copyWith(trustScore: newTrustScore.clamp(0.0, 1.0));
      }
      return m;
    }).toList();

    state = state!.copyWith(members: updatedMembers);

    if (!isRemote) {
      _relayService?.broadcastEvent(P2pSquadRelayEvent(
        id: 'evt_${DateTime.now().millisecondsSinceEpoch}_trust_$targetUserId',
        expeditionId: state!.id,
        senderId: targetUserId,
        senderName: 'System',
        eventType: SquadRelayEventType.trustEndorsement,
        payload: {
          'targetUserId': targetUserId,
          'newTrust': newTrustScore,
        },
      ));
    }
  }

  CooperativeCheckResult performSquadSkillCheck(String actionPrompt) {
    if (state == null) {
      throw StateError('No active expedition group.');
    }

    // Dynamic trust sync with trustProvider if available
    double overallTrustBonus = 0.0;
    if (_ref != null) {
      final trustState = _ref!.read(trustProvider);
      overallTrustBonus = trustState.overallTrustScore;
    }

    final checkInfos = state!.members.map((m) {
      final effectiveTrust = _ref != null ? ((m.trustScore + overallTrustBonus) / 2.0).clamp(0.0, 1.0) : m.trustScore;
      return SquadMemberCheckInfo(
        name: m.userName,
        assignedRole: m.assignedRole,
        primaryStatValue: m.primaryStat,
        isSpecialistRole: m.isSpecialist,
        mutualTrustScore: effectiveTrust,
      );
    }).toList();

    final result = _checkEvaluator.evaluate(
      actionPrompt: actionPrompt,
      members: checkInfos,
    );

    final logEntry = '[COOP CHECK] ${result.statusTitle}\nScore: ${result.finalScore} (D20: ${result.baseD20})\n${result.narrativeDescription}';
    state = state!.copyWith(
      squadLogs: [...state!.squadLogs, logEntry],
    );

    _relayService?.broadcastEvent(P2pSquadRelayEvent(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}_coop',
      expeditionId: state!.id,
      senderId: state!.leaderId,
      senderName: 'Squad Leader',
      eventType: SquadRelayEventType.coopCheck,
      payload: {'logMessage': logEntry},
    ));

    return result;
  }
}

final expeditionProvider = StateNotifierProvider<ExpeditionNotifier, ExpeditionModel?>((ref) {
  final relay = ref.watch(p2pSquadRelayProvider);
  return ExpeditionNotifier(relay, ref);
});
