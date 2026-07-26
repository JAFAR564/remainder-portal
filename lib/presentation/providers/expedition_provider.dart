import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/evaluate_cooperative_check.dart';

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

  ExpeditionNotifier() : super(null);

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

    state = ExpeditionModel(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      leaderId: leaderId,
      title: title,
      sectorId: sectorId,
      status: 0,
      members: [leader],
      squadLogs: ['[SYSTEM] Squad expedition "$title" initialized by $leaderName.'],
    );
  }

  bool addMember(ExpeditionMemberModel member) {
    if (state == null) return false;
    if (state!.members.length >= 5) return false; // Max 5 squad members

    final updated = [...state!.members, member];
    state = state!.copyWith(
      members: updated,
      squadLogs: [...state!.squadLogs, '[JOIN] ${member.userName} joined as ${member.assignedRole}.'],
    );
    return true;
  }

  void leaveExpedition(String userId) {
    if (state == null) return;
    final updated = state!.members.where((m) => m.userId != userId).toList();
    if (updated.isEmpty) {
      state = null;
    } else {
      state = state!.copyWith(members: updated);
    }
  }

  CooperativeCheckResult performSquadSkillCheck(String actionPrompt) {
    if (state == null) {
      throw StateError('No active expedition group.');
    }

    final checkInfos = state!.members.map((m) {
      return SquadMemberCheckInfo(
        name: m.userName,
        assignedRole: m.assignedRole,
        primaryStatValue: m.primaryStat,
        isSpecialistRole: m.isSpecialist,
        mutualTrustScore: m.trustScore,
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

    return result;
  }
}

final expeditionProvider = StateNotifierProvider<ExpeditionNotifier, ExpeditionModel?>((ref) {
  return ExpeditionNotifier();
});
