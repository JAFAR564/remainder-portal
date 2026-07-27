import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../domain/usecases/evaluate_consensus.dart';
import '../../data/services/database_service.dart';
import 'game_provider.dart';

class LoreProposalModel {
  final String id;
  final String sectorId;
  final String authorId;
  final String authorName;
  final String title;
  final String proposedContent;
  final int status; // 0: Draft, 1: Voting, 2: Canonized, 3: Rejected
  final int yesVotes;
  final int noVotes;
  final List<VoterInfo> voterLog;
  final DateTime votingEndsAt;

  LoreProposalModel({
    required this.id,
    required this.sectorId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.proposedContent,
    required this.status,
    this.yesVotes = 0,
    this.noVotes = 0,
    this.voterLog = const [],
    required this.votingEndsAt,
  });

  LoreProposalModel copyWith({
    int? status,
    int? yesVotes,
    int? noVotes,
    List<VoterInfo>? voterLog,
  }) {
    return LoreProposalModel(
      id: id,
      sectorId: sectorId,
      authorId: authorId,
      authorName: authorName,
      title: title,
      proposedContent: proposedContent,
      status: status ?? this.status,
      yesVotes: yesVotes ?? this.yesVotes,
      noVotes: noVotes ?? this.noVotes,
      voterLog: voterLog ?? this.voterLog,
      votingEndsAt: votingEndsAt,
    );
  }
}

class LoreHistoryModel {
  final String id;
  final String sectorId;
  final String proposalId;
  final int version;
  final String title;
  final String markdownContent;
  final DateTime canonizedAt;

  LoreHistoryModel({
    required this.id,
    required this.sectorId,
    required this.proposalId,
    required this.version,
    required this.title,
    required this.markdownContent,
    required this.canonizedAt,
  });
}

class ChronoLoomState {
  final List<LoreProposalModel> proposals;
  final List<LoreHistoryModel> canonizedHistory;

  ChronoLoomState({
    required this.proposals,
    required this.canonizedHistory,
  });

  ChronoLoomState copyWith({
    List<LoreProposalModel>? proposals,
    List<LoreHistoryModel>? canonizedHistory,
  }) {
    return ChronoLoomState(
      proposals: proposals ?? this.proposals,
      canonizedHistory: canonizedHistory ?? this.canonizedHistory,
    );
  }
}

class ChronoLoomNotifier extends StateNotifier<ChronoLoomState> {
  final EvaluateConsensus _consensusEvaluator = EvaluateConsensus();
  final AppDatabase? _db;

  ChronoLoomNotifier([this._db])
      : super(ChronoLoomState(
          proposals: [
            LoreProposalModel(
              id: 'prop_101',
              sectorId: 'sectors_neon_bastion_4',
              authorId: 'user_scribe',
              authorName: 'Vanguard Scribe',
              title: 'Covenant of the Bastion Gate',
              proposedContent:
                  'Establish an autonomous AI energy conduit at Sector Bastion 4, granting +15% shield recharge to all registered expedition squads.',
              status: 1, // Voting
              yesVotes: 12,
              noVotes: 2,
              votingEndsAt: DateTime.now().add(const Duration(days: 2)),
            )
          ],
          canonizedHistory: [
            LoreHistoryModel(
              id: 'hist_001',
              sectorId: 'sectors_neon_bastion_4',
              proposalId: 'prop_000',
              version: 1,
              title: 'The Great Awakening Event',
              markdownContent: 'Sector Neon Bastion 4 was declared an open consensus node by the first Vanguard fleet.',
              canonizedAt: DateTime.now().subtract(const Duration(days: 30)),
            )
          ],
        )) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    if (_db == null) return;
    try {
      final dbProposals = await _db!.select(_db!.loreProposals).get();
      final dbHistory = await _db!.select(_db!.loreHistory).get();

      final proposalsList = dbProposals.map((p) {
        return LoreProposalModel(
          id: p.id,
          sectorId: p.sectorId,
          authorId: p.authorUserId,
          authorName: 'Author',
          title: p.title,
          proposedContent: p.proposedContent,
          status: p.status,
          yesVotes: p.yesVotes,
          noVotes: p.noVotes,
          votingEndsAt: p.votingEndsAt,
        );
      }).toList();

      final historyList = dbHistory.map((h) {
        return LoreHistoryModel(
          id: h.id,
          sectorId: h.sectorId,
          proposalId: h.proposalId,
          version: h.version,
          title: 'Canon Lore #${h.version}',
          markdownContent: h.markdownContent,
          canonizedAt: h.canonizedAt,
        );
      }).toList();

      if (proposalsList.isNotEmpty || historyList.isNotEmpty) {
        state = state.copyWith(
          proposals: proposalsList.isNotEmpty ? proposalsList : state.proposals,
          canonizedHistory: historyList.isNotEmpty ? historyList : state.canonizedHistory,
        );
      }
    } catch (_) {}
  }

  Future<void> submitProposal({
    required String sectorId,
    required String authorId,
    required String authorName,
    required String title,
    required String proposedContent,
  }) async {
    final propId = 'prop_${DateTime.now().millisecondsSinceEpoch}';
    final votingEnds = DateTime.now().add(const Duration(days: 3));

    final newProp = LoreProposalModel(
      id: propId,
      sectorId: sectorId,
      authorId: authorId,
      authorName: authorName,
      title: title,
      proposedContent: proposedContent,
      status: 1, // Active voting
      votingEndsAt: votingEnds,
    );

    state = state.copyWith(
      proposals: [newProp, ...state.proposals],
    );

    if (_db != null) {
      try {
        await _db!.into(_db!.loreProposals).insertOnConflictUpdate(
          LoreProposalsCompanion.insert(
            id: propId,
            sectorId: sectorId,
            authorUserId: authorId,
            title: title,
            proposedContent: proposedContent,
            status: 1,
            yesVotes: const Value(0),
            noVotes: const Value(0),
            votingEndsAt: votingEnds,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> castVote({
    required String proposalId,
    required bool isYes,
    required double trustScore,
    required int reputationRank,
  }) async {
    final index = state.proposals.indexWhere((p) => p.id == proposalId);
    if (index == -1) return;

    final target = state.proposals[index];
    if (target.status != 1) return;

    final voter = VoterInfo(
      vote: isYes,
      trustScore: trustScore,
      reputationRank: reputationRank,
    );

    final updatedVoters = [...target.voterLog, voter];
    final updatedYes = isYes ? target.yesVotes + 1 : target.yesVotes;
    final updatedNo = !isYes ? target.noVotes + 1 : target.noVotes;

    final updatedProp = target.copyWith(
      yesVotes: updatedYes,
      noVotes: updatedNo,
      voterLog: updatedVoters,
    );

    bool approved = _consensusEvaluator.isApproved(updatedVoters);
    int newStatus = target.status;
    List<LoreHistoryModel> newHistory = state.canonizedHistory;
    LoreHistoryModel? newHistoryEntry;

    if (updatedVoters.length >= 5 && approved) {
      newStatus = 2; // Canonized
      newHistoryEntry = LoreHistoryModel(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        sectorId: target.sectorId,
        proposalId: target.id,
        version: state.canonizedHistory.length + 1,
        title: target.title,
        markdownContent: target.proposedContent,
        canonizedAt: DateTime.now(),
      );
      newHistory = [newHistoryEntry, ...newHistory];
    } else if (updatedVoters.length >= 5 && !approved) {
      newStatus = 3; // Rejected
    }

    final finalProp = updatedProp.copyWith(status: newStatus);

    final updatedProposals = [...state.proposals];
    updatedProposals[index] = finalProp;

    state = state.copyWith(
      proposals: updatedProposals,
      canonizedHistory: newHistory,
    );

    if (_db != null) {
      try {
        await (_db!.update(_db!.loreProposals)..where((tbl) => tbl.id.equals(target.id))).write(
          LoreProposalsCompanion(
            status: Value(newStatus),
            yesVotes: Value(updatedYes),
            noVotes: Value(updatedNo),
          ),
        );

        if (newHistoryEntry != null) {
          await _db!.into(_db!.loreHistory).insertOnConflictUpdate(
            LoreHistoryCompanion.insert(
              id: newHistoryEntry.id,
              sectorId: newHistoryEntry.sectorId,
              proposalId: newHistoryEntry.proposalId,
              version: newHistoryEntry.version,
              markdownContent: newHistoryEntry.markdownContent,
              canonizedAt: newHistoryEntry.canonizedAt,
            ),
          );
        }
      } catch (_) {}
    }
  }
}

final chronoLoomProvider = StateNotifierProvider<ChronoLoomNotifier, ChronoLoomState>((ref) {
  final db = ref.watch(databaseProvider);
  return ChronoLoomNotifier(db);
});
