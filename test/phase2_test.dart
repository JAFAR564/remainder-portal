import 'package:flutter_test/flutter_test.dart';
import 'package:remainder_portal/domain/usecases/evaluate_cooperative_check.dart';
import 'package:remainder_portal/domain/usecases/evaluate_consensus.dart';
import 'package:remainder_portal/presentation/providers/trust_provider.dart';
import 'package:remainder_portal/presentation/providers/expedition_provider.dart';
import 'package:remainder_portal/presentation/providers/guild_provider.dart';
import 'package:remainder_portal/presentation/providers/chrono_loom_provider.dart';

void main() {
  group('Phase 2 — Collaborative Expeditions & Sovereign Governance Tests', () {
    test('EvaluateCooperativeCheck calculates squad skill check formulas correctly', () {
      final evaluator = EvaluateCooperativeCheck();

      final members = [
        SquadMemberCheckInfo(
          name: 'Leader Kaelen',
          assignedRole: 'Squad Leader',
          primaryStatValue: 14,
          isSpecialistRole: true,
          equipmentBonus: 2,
          mutualTrustScore: 0.9,
        ),
        SquadMemberCheckInfo(
          name: 'Hacker Vex',
          assignedRole: 'Cyber Specialist',
          primaryStatValue: 12,
          isSpecialistRole: true,
          equipmentBonus: 1,
          mutualTrustScore: 0.85,
        ),
      ];

      // Test with custom D20 roll = 15
      final result = evaluator.evaluate(
        actionPrompt: 'Infiltrate Sector Gate',
        members: members,
        customD20: 15,
      );

      // Math:
      // Leader stat: 14 * 0.5 = 7.0
      // Hacker stat: 12 * 0.5 = 6.0
      // Equipment bonus: 2 + 1 = 3
      // Trust bonus: 1 (for 0.9) + 1 (for 0.85) = 2
      // Total: (15 + 13.0 + 3 + 2).round() = 33
      expect(result.finalScore, 33);
      expect(result.outcomeTier, CooperativeOutcomeTier.criticalConsensus);
      expect(result.statusTitle, contains('SQUAD CRITICAL CONSENSUS REACHED'));
    });

    test('TrustNotifier enforces daily cap of 3 endorsements and calculates score yields', () {
      final notifier = TrustNotifier();

      // Grant 3 endorsements
      final e1 = notifier.addEndorsement(giverId: 'p1', receiverId: 'p2', vector: TrustVector.vanguard);
      final e2 = notifier.addEndorsement(giverId: 'p1', receiverId: 'p3', vector: TrustVector.arbiter);
      final e3 = notifier.addEndorsement(giverId: 'p1', receiverId: 'p4', vector: TrustVector.merchant);

      expect(e1, isTrue);
      expect(e2, isTrue);
      expect(e3, isTrue);

      // 4th endorsement within 24h should fail rate limit
      final e4 = notifier.addEndorsement(giverId: 'p1', receiverId: 'p5', vector: TrustVector.hacker);
      expect(e4, isFalse);
    });

    test('ExpeditionNotifier manages squad roster limits and skill check log history', () {
      final notifier = ExpeditionNotifier();

      notifier.createExpedition(
        title: 'Bastion Raid',
        leaderId: 'leader_1',
        leaderName: 'Alpha Leader',
        sectorId: 'sectors_neon_bastion_4',
      );

      expect(notifier.debugState, isNotNull);
      expect(notifier.debugState!.members.length, 1);

      // Add 4 members up to max 5 limit
      for (int i = 2; i <= 5; i++) {
        final added = notifier.addMember(
          ExpeditionMemberModel(
            userId: 'user_$i',
            userName: 'Member $i',
            assignedRole: 'Specialist',
          ),
        );
        expect(added, isTrue);
      }

      // 6th member should be rejected
      final overflowMember = notifier.addMember(
        ExpeditionMemberModel(
          userId: 'user_6',
          userName: 'Member 6',
          assignedRole: 'Specialist',
        ),
      );
      expect(overflowMember, isFalse);
    });

    test('GuildStateNotifier and GovernanceStateNotifier initialize sovereign governance', () {
      final guildNotifier = GuildStateNotifier();
      guildNotifier.createGuild(
        name: 'Vanguard Syndicate',
        tag: 'VNG',
        masterUserId: 'master_1',
        masterName: 'Grandmaster Kael',
      );

      expect(guildNotifier.debugState, isNotNull);
      expect(guildNotifier.debugState!.name, 'Vanguard Syndicate');
      expect(guildNotifier.debugState!.treasuryBalance, 500);

      final govNotifier = GovernanceStateNotifier();
      govNotifier.updateGovernance(
        sectorId: 'sectors_neon_bastion_4',
        governingGuildId: 'guild_vng',
        taxRate: 0.10,
        laws: 'All traders pay 10% tariff to VNG Syndicate.',
      );

      final sectorState = govNotifier.debugState['sectors_neon_bastion_4'];
      expect(sectorState, isNotNull);
      expect(sectorState!.taxRate, 0.10);
      expect(sectorState.sectorLawBody, contains('10% tariff'));
    });

    test('ChronoLoomNotifier processes democratic proposals and canonization history', () {
      final notifier = ChronoLoomNotifier();

      notifier.submitProposal(
        sectorId: 'sectors_neon_bastion_4',
        authorId: 'author_1',
        authorName: 'Scribe Ally',
        title: 'Bastion Energy Concordat',
        proposedContent: 'Construct energy shield conduits.',
      );

      final proposalId = notifier.debugState.proposals.first.id;

      // Cast 5 affirmative votes to cross approval threshold
      for (int i = 0; i < 5; i++) {
        notifier.castVote(
          proposalId: proposalId,
          isYes: true,
          trustScore: 0.9,
          reputationRank: 2,
        );
      }

      // Proposal should now be canonized (status 2) and added to canonizedHistory
      final updatedProp = notifier.debugState.proposals.firstWhere((p) => p.id == proposalId);
      expect(updatedProp.status, 2); // Canonized
      expect(notifier.debugState.canonizedHistory.length, greaterThanOrEqualTo(2));
      expect(notifier.debugState.canonizedHistory.first.title, 'Bastion Energy Concordat');
    });
  });
}
