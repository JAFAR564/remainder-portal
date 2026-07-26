import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildMemberModel {
  final String userId;
  final String userName;
  final String rank; // 'Master', 'Marshal', 'Scribe', 'Initiate'
  final DateTime joinedDate;

  GuildMemberModel({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.joinedDate,
  });
}

class GuildModel {
  final String id;
  final String name;
  final String tag;
  final String masterUserId;
  final int treasuryBalance;
  final String announcement;
  final List<GuildMemberModel> members;
  final List<String> controlledSectorIds;

  GuildModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.masterUserId,
    this.treasuryBalance = 500,
    this.announcement = 'Sovereign guild established. Honor the consensus.',
    required this.members,
    this.controlledSectorIds = const [],
  });

  GuildModel copyWith({
    int? treasuryBalance,
    String? announcement,
    List<GuildMemberModel>? members,
    List<String>? controlledSectorIds,
  }) {
    return GuildModel(
      id: id,
      name: name,
      tag: tag,
      masterUserId: masterUserId,
      treasuryBalance: treasuryBalance ?? this.treasuryBalance,
      announcement: announcement ?? this.announcement,
      members: members ?? this.members,
      controlledSectorIds: controlledSectorIds ?? this.controlledSectorIds,
    );
  }
}

class SectorGovernanceModel {
  final String sectorId;
  final String? governingGuildId;
  final double taxRate; // 0.0 to 0.15
  final String sectorLawBody;
  final DateTime lastElectionDate;

  SectorGovernanceModel({
    required this.sectorId,
    this.governingGuildId,
    this.taxRate = 0.05,
    this.sectorLawBody = 'Standard sector protocol active. All transactions subject to 5% guild tariff.',
    required this.lastElectionDate,
  });

  SectorGovernanceModel copyWith({
    String? governingGuildId,
    double? taxRate,
    String? sectorLawBody,
    DateTime? lastElectionDate,
  }) {
    return SectorGovernanceModel(
      sectorId: sectorId,
      governingGuildId: governingGuildId ?? this.governingGuildId,
      taxRate: taxRate ?? this.taxRate,
      sectorLawBody: sectorLawBody ?? this.sectorLawBody,
      lastElectionDate: lastElectionDate ?? this.lastElectionDate,
    );
  }
}

class GuildStateNotifier extends StateNotifier<GuildModel?> {
  GuildStateNotifier() : super(null);

  void createGuild({
    required String name,
    required String tag,
    required String masterUserId,
    required String masterName,
  }) {
    final masterMember = GuildMemberModel(
      userId: masterUserId,
      userName: masterName,
      rank: 'Master',
      joinedDate: DateTime.now(),
    );

    state = GuildModel(
      id: 'guild_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      tag: tag,
      masterUserId: masterUserId,
      treasuryBalance: 500,
      announcement: 'Welcome to [$tag] $name.',
      members: [masterMember],
      controlledSectorIds: ['sectors_neon_bastion_4'],
    );
  }

  void updateAnnouncement(String text) {
    if (state != null) {
      state = state!.copyWith(announcement: text);
    }
  }

  void depositTreasury(int amount) {
    if (state != null && amount > 0) {
      state = state!.copyWith(treasuryBalance: state!.treasuryBalance + amount);
    }
  }

  void addMember(String userId, String userName, String rank) {
    if (state == null) return;
    final member = GuildMemberModel(
      userId: userId,
      userName: userName,
      rank: rank,
      joinedDate: DateTime.now(),
    );
    state = state!.copyWith(members: [...state!.members, member]);
  }
}

final guildProvider = StateNotifierProvider<GuildStateNotifier, GuildModel?>((ref) {
  return GuildStateNotifier();
});

class GovernanceStateNotifier extends StateNotifier<Map<String, SectorGovernanceModel>> {
  GovernanceStateNotifier()
      : super({
          'sectors_neon_bastion_4': SectorGovernanceModel(
            sectorId: 'sectors_neon_bastion_4',
            governingGuildId: 'guild_alpha',
            taxRate: 0.05,
            sectorLawBody: 'Bastion Covenant: Energy transactions taxed at 5%. Vanguard members receive priority access.',
            lastElectionDate: DateTime.now(),
          ),
        });

  void updateGovernance({
    required String sectorId,
    required String governingGuildId,
    required double taxRate,
    required String laws,
  }) {
    final current = state[sectorId] ?? SectorGovernanceModel(sectorId: sectorId, lastElectionDate: DateTime.now());
    final updated = current.copyWith(
      governingGuildId: governingGuildId,
      taxRate: taxRate.clamp(0.0, 0.15),
      sectorLawBody: laws,
      lastElectionDate: DateTime.now(),
    );
    state = {...state, sectorId: updated};
  }
}

final governanceProvider = StateNotifierProvider<GovernanceStateNotifier, Map<String, SectorGovernanceModel>>((ref) {
  return GovernanceStateNotifier();
});
