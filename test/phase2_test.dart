import 'package:flutter_test/flutter_test.dart';
import 'package:remainder_portal/domain/usecases/evaluate_cooperative_check.dart';
import 'package:remainder_portal/data/services/p2p_squad_relay_service.dart';
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

    test('P2pSquadRelayService broadcasts events, handles deduplication and offline queueing', () async {
      final relay = P2pSquadRelayService();
      final eventsReceived = <P2pSquadRelayEvent>[];

      final sub = relay.eventStream.listen((event) {
        eventsReceived.add(event);
      });

      final event1 = P2pSquadRelayEvent(
        id: 'evt_001',
        expeditionId: 'exp_100',
        senderId: 'user_1',
        senderName: 'Alpha',
        eventType: SquadRelayEventType.squadAction,
        payload: {'action': 'scout'},
      );

      final success1 = relay.broadcastEvent(event1);
      expect(success1, isTrue);

      // Duplicate broadcast with same ID should be ignored
      final successDuplicate = relay.broadcastEvent(event1);
      expect(successDuplicate, isFalse);

      // Test offline queueing
      relay.setOnlineStatus(false);
      final event2 = P2pSquadRelayEvent(
        id: 'evt_002',
        expeditionId: 'exp_100',
        senderId: 'user_2',
        senderName: 'Bravo',
        eventType: SquadRelayEventType.coopCheck,
        payload: {'action': 'hack'},
      );

      final success2 = relay.broadcastEvent(event2);
      expect(success2, isFalse); // Queued offline
      expect(relay.queuedEventCount, 1);

      // Reconnect and flush queue
      relay.setOnlineStatus(true);
      await pumpEventQueue();

      expect(eventsReceived.length, 2);
      expect(eventsReceived.last.id, 'evt_002');

      await sub.cancel();
      relay.dispose();
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

    test('ExpeditionNotifier manages squad roster limits, relay sync, and skill check log history', () {
      final relay = P2pSquadRelayService();
      final notifier = ExpeditionNotifier(relay);

      notifier.createExpedition(
        title: 'Bastion Raid',
        leaderId: 'leader_1',
        leaderName: 'Alpha Leader',
        sectorId: 'sectors_neon_bastion_4',
      );

      expect(notifier.state, isNotNull);
      expect(notifier.state!.members.length, 1);

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

      notifier.dispose();
      relay.dispose();
    });

    test('GuildStateNotifier and GovernanceStateNotifier initialize sovereign governance', () {
      final guildNotifier = GuildStateNotifier();
      guildNotifier.createGuild(
        name: 'Vanguard Syndicate',
        tag: 'VNG',
        masterUserId: 'master_1',
        masterName: 'Grandmaster Kael',
      );

      expect(guildNotifier.state, isNotNull);
      expect(guildNotifier.state!.name, 'Vanguard Syndicate');
      expect(guildNotifier.state!.treasuryBalance, 500);

      final govNotifier = GovernanceStateNotifier();
      govNotifier.updateGovernance(
        sectorId: 'sectors_neon_bastion_4',
        governingGuildId: 'guild_vng',
        taxRate: 0.10,
        laws: 'All traders pay 10% tariff to VNG Syndicate.',
      );

      final sectorState = govNotifier.state['sectors_neon_bastion_4'];
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

      final proposalId = notifier.state.proposals.first.id;

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
      final updatedProp = notifier.state.proposals.firstWhere((p) => p.id == proposalId);
      expect(updatedProp.status, 2); // Canonized
      expect(notifier.state.canonizedHistory.length, greaterThanOrEqualTo(2));
      expect(notifier.state.canonizedHistory.first.title, 'Bastion Energy Concordat');
    });
  });
}
