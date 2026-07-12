import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service implementing the mathematical gameplay equations and constraints
/// required by the RP Exclusive specifications.
class GameplayFormulasService {
  const GameplayFormulasService();

  /// 1. Character Initialization (Signup Clamping)
  /// 
  /// Allocates starting points dynamically, clamped logarithmically.
  /// Formula: S_k = Clamp(floor(3.5 * ln(L_signup_response)), 1, 5)
  int calculateSignupClamping(String signupResponse) {
    final length = signupResponse.trim().length;
    if (length <= 0) return 1;
    
    final logVal = log(length);
    final score = (3.5 * logVal).floor();
    
    // Clamp between 1 and 5
    return score.clamp(1, 5);
  }

  /// 2. XP Progression Formula
  /// 
  /// Experience gained maps to text length, item rarity, and danger tier.
  /// Formula: XP = floor(mu * ln(L_text) + sum(R_cost * Omega_tier) + Phi_event)
  int calculateXpProgression({
    required String actionText,
    double mu = 10.0,
    List<double> itemRarityCosts = const [],
    int dangerTier = 1,
    double eventModifier = 0.0,
  }) {
    final length = actionText.trim().length;
    if (length <= 0) return 0;

    final logText = log(length);
    
    double itemSum = 0.0;
    for (final cost in itemRarityCosts) {
      itemSum += cost * dangerTier;
    }

    final xp = (mu * logText + itemSum + eventModifier).floor();
    return xp < 0 ? 0 : xp;
  }

  /// 3. Anti-Godmoding Action Verification Index
  /// 
  /// Checks combat and movement actions against localized sector defenses.
  /// Formula: V_I = min(1.0, sum(A_i * delta_i) / Psi_sector_resilience)
  double verifyActionGodmoding({
    required List<double> actionIntents,
    required List<double> contextualWeights,
    required double sectorResilience,
  }) {
    if (sectorResilience <= 0.0) return 1.0;
    if (actionIntents.length != contextualWeights.length || actionIntents.isEmpty) {
      return 1.0;
    }

    double sum = 0.0;
    for (int i = 0; i < actionIntents.length; i++) {
      sum += actionIntents[i] * contextualWeights[i];
    }

    final index = sum / sectorResilience;
    return min(1.0, index);
  }

  /// 4. Lore Consensus Score (C_L)
  /// 
  /// Proposing changes to community-governed sectors requires C_L >= 0.75.
  /// Formula: C_L = alpha * (U_up / U_total) + beta * T_author - gamma * delta_G
  double calculateLoreConsensusScore({
    required int upvotes,
    required int totalVotes,
    required double authorStandingWeight,
    required double graphDeviationDelta,
    double alpha = 0.5,
    double beta = 0.3,
    double gamma = 0.2,
  }) {
    if (totalVotes <= 0) return 0.0;

    final voteRatio = upvotes / totalVotes;
    final score = (alpha * voteRatio) + (beta * authorStandingWeight) - (gamma * graphDeviationDelta);

    return score.clamp(0.0, 1.0);
  }
}

/// Provider exposing the GameplayFormulasService
final gameplayFormulasServiceProvider = Provider<GameplayFormulasService>((ref) {
  return const GameplayFormulasService();
});
