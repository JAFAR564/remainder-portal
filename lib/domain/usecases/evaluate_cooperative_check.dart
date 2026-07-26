import 'dart:math' as math;

class SquadMemberCheckInfo {
  final String name;
  final String assignedRole;
  final int primaryStatValue;
  final bool isSpecialistRole;
  final int equipmentBonus;
  final double mutualTrustScore; // 0.0 to 1.0

  SquadMemberCheckInfo({
    required this.name,
    required this.assignedRole,
    required this.primaryStatValue,
    required this.isSpecialistRole,
    this.equipmentBonus = 0,
    this.mutualTrustScore = 0.5,
  });
}

enum CooperativeOutcomeTier {
  criticalConsensus, // >= 22
  tacticalSuccess,   // 14 - 21
  partialSuccess,    // 8 - 13
  anomalyTriggered   // < 8
}

class CooperativeCheckResult {
  final int baseD20;
  final double totalStatContribution;
  final int totalEquipmentBonus;
  final int totalTrustBonus;
  final int finalScore;
  final CooperativeOutcomeTier outcomeTier;
  final String statusTitle;
  final String narrativeDescription;

  CooperativeCheckResult({
    required this.baseD20,
    required this.totalStatContribution,
    required this.totalEquipmentBonus,
    required this.totalTrustBonus,
    required this.finalScore,
    required this.outcomeTier,
    required this.statusTitle,
    required this.narrativeDescription,
  });
}

class EvaluateCooperativeCheck {
  CooperativeCheckResult evaluate({
    required String actionPrompt,
    required List<SquadMemberCheckInfo> members,
    int? customD20,
  }) {
    final random = math.Random();
    final d20 = customD20 ?? (random.nextInt(20) + 1);

    double statContrib = 0.0;
    int equipBonus = 0;
    int trustBonus = 0;

    for (final member in members) {
      final roleWeight = member.isSpecialistRole ? 0.5 : 0.25;
      statContrib += member.primaryStatValue * roleWeight;
      equipBonus += member.equipmentBonus;
      if (member.mutualTrustScore >= 0.8) {
        trustBonus += 1;
      }
    }

    final totalScore = (d20 + statContrib + equipBonus + trustBonus).round();

    CooperativeOutcomeTier tier;
    String title;
    String description;

    if (totalScore >= 22) {
      tier = CooperativeOutcomeTier.criticalConsensus;
      title = 'SQUAD CRITICAL CONSENSUS REACHED';
      description = 'Your combined squad action "$actionPrompt" achieved perfect operational harmony. Sector stability boosted +100%.';
    } else if (totalScore >= 14) {
      tier = CooperativeOutcomeTier.tacticalSuccess;
      title = 'SQUAD TACTICAL SUCCESS';
      description = 'The expedition squad successfully executed "$actionPrompt". Mission objectives updated.';
    } else if (totalScore >= 8) {
      tier = CooperativeOutcomeTier.partialSuccess;
      title = 'PARTIAL SQUAD CONSENSUS WITH STRAIN';
      description = 'Squad action "$actionPrompt" succeeded, but power fluctuations triggered minor shield/energy strain across members.';
    } else {
      tier = CooperativeOutcomeTier.anomalyTriggered;
      title = 'EXPEDITION ANOMALY TRIGGERED';
      description = 'Combined squad action "$actionPrompt" failed local consensus. Defense countermeasures engaged.';
    }

    return CooperativeCheckResult(
      baseD20: d20,
      totalStatContribution: statContrib,
      totalEquipmentBonus: equipBonus,
      totalTrustBonus: trustBonus,
      finalScore: totalScore,
      outcomeTier: tier,
      statusTitle: title,
      narrativeDescription: description,
    );
  }
}
