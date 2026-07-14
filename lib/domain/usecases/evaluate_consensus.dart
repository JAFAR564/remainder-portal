class VoterInfo {
  final bool vote; // true for approval, false for rejection
  final double trustScore; // User trust coefficient (0.0 to 1.0)
  final int reputationRank; // Reputation score in faction

  VoterInfo({
    required this.vote,
    required this.trustScore,
    required this.reputationRank,
  });
}

class EvaluateConsensus {
  // Evaluates community proposal consensus scores weighted by voter trust and reputation
  double calculateConsensusScore(List<VoterInfo> voters) {
    if (voters.isEmpty) return 0.0;

    double weightedAffirmative = 0.0;
    double totalWeight = 0.0;

    for (final voter in voters) {
      // Weight = trustScore * (1 + reputationRank / 10)
      final double weight = voter.trustScore * (1.0 + (voter.reputationRank / 10.0));
      
      if (voter.vote) {
        weightedAffirmative += weight;
      }
      totalWeight += weight;
    }

    if (totalWeight == 0.0) return 0.0;
    return weightedAffirmative / totalWeight;
  }

  // A proposal requires > 65% consensus to pass and edit the OKF master graph
  bool isApproved(List<VoterInfo> voters, {double threshold = 0.65}) {
    final score = calculateConsensusScore(voters);
    return score >= threshold;
  }
}
