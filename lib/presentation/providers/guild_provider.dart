import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../data/services/database_service.dart';
import 'game_provider.dart';

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
  final AppDatabase? _db;

  GuildStateNotifier([this._db]) : super(null) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    if (_db == null) return;
    try {
      final guilds = await _db!.select(_db!.guilds).get();
      if (guilds.isNotEmpty) {
        final g = guilds.first;
        final membersData = await (_db!.select(_db!.guildMembers)..where((tbl) => tbl.guildId.equals(g.id))).get();

        final membersList = membersData.map((m) {
          return GuildMemberModel(
            userId: m.userId,
            userName: 'Guild Member',
            rank: m.rank,
            joinedDate: m.joinedDate,
          );
        }).toList();

        state = GuildModel(
          id: g.id,
          name: g.name,
          tag: g.tag,
          masterUserId: g.masterUserId,
          treasuryBalance: g.treasuryBalance,
          announcement: g.announcement ?? 'Sovereign guild active.',
          members: membersList,
        );
      }
    } catch (_) {}
  }

  Future<void> createGuild({
    required String name,
    required String tag,
    required String masterUserId,
    required String masterName,
  }) async {
    final guildId = 'guild_${DateTime.now().millisecondsSinceEpoch}';
    final masterMember = GuildMemberModel(
      userId: masterUserId,
      userName: masterName,
      rank: 'Master',
      joinedDate: DateTime.now(),
    );

    final newGuild = GuildModel(
      id: guildId,
      name: name,
      tag: tag,
      masterUserId: masterUserId,
      treasuryBalance: 500,
      announcement: 'Welcome to [$tag] $name.',
      members: [masterMember],
      controlledSectorIds: ['sectors_neon_bastion_4'],
    );

    state = newGuild;

    if (_db != null) {
      try {
        await _db!.into(_db!.guilds).insertOnConflictUpdate(
          GuildsCompanion.insert(
            id: guildId,
            name: name,
            tag: tag,
            masterUserId: masterUserId,
            treasuryBalance: const Value(500),
            announcement: Value('Welcome to [$tag] $name.'),
            foundedDate: DateTime.now(),
          ),
        );

        await _db!.into(_db!.guildMembers).insertOnConflictUpdate(
          GuildMembersCompanion.insert(
            guildId: guildId,
            userId: masterUserId,
            rank: 'Master',
            joinedDate: DateTime.now(),
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> updateAnnouncement(String text) async {
    if (state != null) {
      state = state!.copyWith(announcement: text);
      if (_db != null) {
        try {
          await (_db!.update(_db!.guilds)..where((tbl) => tbl.id.equals(state!.id))).write(
            GuildsCompanion(announcement: Value(text)),
          );
        } catch (_) {}
      }
    }
  }

  Future<void> depositTreasury(int amount) async {
    if (state != null && amount > 0) {
      final newBalance = state!.treasuryBalance + amount;
      state = state!.copyWith(treasuryBalance: newBalance);
      if (_db != null) {
        try {
          await (_db!.update(_db!.guilds)..where((tbl) => tbl.id.equals(state!.id))).write(
            GuildsCompanion(treasuryBalance: Value(newBalance)),
          );
        } catch (_) {}
      }
    }
  }

  Future<void> addMember(String userId, String userName, String rank) async {
    if (state == null) return;
    final member = GuildMemberModel(
      userId: userId,
      userName: userName,
      rank: rank,
      joinedDate: DateTime.now(),
    );
    state = state!.copyWith(members: [...state!.members, member]);

    if (_db != null) {
      try {
        await _db!.into(_db!.guildMembers).insertOnConflictUpdate(
          GuildMembersCompanion.insert(
            guildId: state!.id,
            userId: userId,
            rank: rank,
            joinedDate: DateTime.now(),
          ),
        );
      } catch (_) {}
    }
  }
}

final guildProvider = StateNotifierProvider<GuildStateNotifier, GuildModel?>((ref) {
  final db = ref.watch(databaseProvider);
  return GuildStateNotifier(db);
});

class GovernanceStateNotifier extends StateNotifier<Map<String, SectorGovernanceModel>> {
  final AppDatabase? _db;

  GovernanceStateNotifier([this._db])
      : super({
          'sectors_neon_bastion_4': SectorGovernanceModel(
            sectorId: 'sectors_neon_bastion_4',
            governingGuildId: 'guild_alpha',
            taxRate: 0.05,
            sectorLawBody: 'Bastion Covenant: Energy transactions taxed at 5%. Vanguard members receive priority access.',
            lastElectionDate: DateTime.now(),
          ),
        }) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    if (_db == null) return;
    try {
      final rules = await _db!.select(_db!.governanceRules).get();
      if (rules.isNotEmpty) {
        final Map<String, SectorGovernanceModel> map = {};
        for (final r in rules) {
          map[r.sectorId] = SectorGovernanceModel(
            sectorId: r.sectorId,
            governingGuildId: r.governingGuildId,
            taxRate: r.taxRate,
            sectorLawBody: r.sectorLawBody,
            lastElectionDate: r.lastElectionDate,
          );
        }
        state = {...state, ...map};
      }
    } catch (_) {}
  }

  Future<void> updateGovernance({
    required String sectorId,
    required String governingGuildId,
    required double taxRate,
    required String laws,
  }) async {
    final current = state[sectorId] ?? SectorGovernanceModel(sectorId: sectorId, lastElectionDate: DateTime.now());
    final updated = current.copyWith(
      governingGuildId: governingGuildId,
      taxRate: taxRate.clamp(0.0, 0.15),
      sectorLawBody: laws,
      lastElectionDate: DateTime.now(),
    );
    state = {...state, sectorId: updated};

    if (_db != null) {
      try {
        await _db!.into(_db!.governanceRules).insertOnConflictUpdate(
          GovernanceRulesCompanion.insert(
            sectorId: sectorId,
            governingGuildId: Value(governingGuildId),
            taxRate: Value(taxRate.clamp(0.0, 0.15)),
            sectorLawBody: laws,
            lastElectionDate: DateTime.now(),
          ),
        );
      } catch (_) {}
    }
  }
}

final governanceProvider = StateNotifierProvider<GovernanceStateNotifier, Map<String, SectorGovernanceModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return GovernanceStateNotifier(db);
});
