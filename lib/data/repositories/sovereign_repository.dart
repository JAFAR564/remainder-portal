import 'dart:math';
import '../models/equipment_item_model.dart';
import '../models/oracle_record.dart';
import '../models/player_wallet.dart';
import '../models/quest_decree_model.dart';
import '../models/social_bulletin_model.dart';
import '../services/database_service.dart' hide PlayerWallet;
import '../services/local_llm_sidecar_service.dart';

/// Repository coordinating persistent domain state for the Sovereign Command Deck.
class SovereignRepository {
  final AppDatabase _db;
  final LocalLlmSidecarService _llmService;

  SovereignRepository(this._db, [LocalLlmSidecarService? llmService])
      : _llmService = llmService ?? LocalLlmSidecarService();

  // ==========================================
  // 1. Player Wallet & Currency Engine
  // ==========================================

  Future<PlayerWallet> getWallet(String userId) async {
    final existing = await _db.getPlayerWallet(userId);
    if (existing != null) return existing;

    final defaultWallet = PlayerWallet(
      userId: userId,
      essenceBalance: 1000,
      laurelBalance: 150,
      experiencePoints: 765000,
      currentLevel: 88,
      unallocatedAttributePoints: 0,
      lastUpdated: DateTime.now(),
    );
    await _db.savePlayerWallet(defaultWallet);
    return defaultWallet;
  }

  Future<PlayerWallet> adjustBalance({
    required String userId,
    int essenceDelta = 0,
    int laurelDelta = 0,
    int xpDelta = 0,
    int pointsDelta = 0,
  }) async {
    return await _db.adjustWalletBalance(
      userId: userId,
      essenceDelta: essenceDelta,
      laurelDelta: laurelDelta,
      xpDelta: xpDelta,
      pointsDelta: pointsDelta,
    );
  }

  // ==========================================
  // 2. Imperial Relic Vault & Equipment
  // ==========================================

  static List<EquipmentItemModel> defaultStarterGear(String userId, [DateTime? baseTime]) {
    final now = baseTime ?? DateTime.now();
    return [
      EquipmentItemModel(
        id: 'relic_weapon_shadow_dagger',
        userId: userId,
        slot: 'WEAPON',
        name: 'Shadow Dagger',
        rarity: EquipmentRarity.celestial,
        statBonus: '+15 Physical ATK, +8 Shadow Resonance',
        description: 'Forged in the abyss beneath Sanctuary 4. Strikes weave ethereal shadows that bypass arcane wards.',
        iconName: 'colorize',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: now,
      ),
      EquipmentItemModel(
        id: 'relic_armor_aegis_cuirass',
        userId: userId,
        slot: 'ARMOR',
        name: 'Aegis Cuirass',
        rarity: EquipmentRarity.sovereign,
        statBonus: '+20 Shield Integrity, +10 Vitality',
        description: 'Masterwork armor inscribed with Cardinal protection runes. Reduces dimensional anomaly shock by 25%.',
        iconName: 'shield',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: now.add(const Duration(seconds: 1)),
      ),
      EquipmentItemModel(
        id: 'relic_relic_astrolabe_core',
        userId: userId,
        slot: 'RELIC',
        name: 'Astrolabe Core',
        rarity: EquipmentRarity.celestial,
        statBonus: '+14 Compute Power, +12 Aether Reserve',
        description: 'A spinning celestial mechanism synchronizing soul vessel pulse directly with World Arbiter decrees.',
        iconName: 'auto_awesome',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: now.add(const Duration(seconds: 2)),
      ),
      EquipmentItemModel(
        id: 'relic_charm_ionic_crystal',
        userId: userId,
        slot: 'CHARM',
        name: 'Ionic Crystal',
        rarity: EquipmentRarity.rare,
        statBonus: '+6 Aether Regeneration per Round',
        description: 'Condensed starlight harvested from ancient sky temples. Radiates soothing celestial warmth.',
        iconName: 'diamond_outlined',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: now.add(const Duration(seconds: 3)),
      ),
      // Vault items available for swapping
      EquipmentItemModel(
        id: 'relic_weapon_obsidian_edge',
        userId: userId,
        slot: 'WEAPON',
        name: 'Obsidian Edge',
        rarity: EquipmentRarity.rare,
        statBonus: '+28 ATK',
        description: 'Honed volcanic crystal shard with sharp piercing frequency.',
        iconName: 'colorize',
        upgradeLevel: 0,
        isEquipped: false,
        acquiredAt: now.add(const Duration(seconds: 4)),
      ),
      EquipmentItemModel(
        id: 'relic_armor_ironclad_aegis',
        userId: userId,
        slot: 'ARMOR',
        name: 'Ironclad Aegis',
        rarity: EquipmentRarity.common,
        statBonus: '+18 DEF',
        description: 'Heavy reinforced plating from old frontier dreadnoughts.',
        iconName: 'shield',
        upgradeLevel: 0,
        isEquipped: false,
        acquiredAt: now.add(const Duration(seconds: 5)),
      ),
    ];
  }

  Future<List<EquipmentItemModel>> getEquipment(String userId) async {
    final items = await _db.getEquipmentForUser(userId);
    if (items.isNotEmpty) return items;

    // Seed default starter gear and vault items
    final starterGear = defaultStarterGear(userId);

    for (final item in starterGear) {
      await _db.upsertEquipment(item);
    }
    return await _db.getEquipmentForUser(userId);
  }

  Future<void> equipItem({
    required String userId,
    required String itemId,
    required String slot,
  }) async {
    await _db.equipItem(userId: userId, itemId: itemId, slot: slot);
  }

  Future<void> unequipItem({
    required String userId,
    required String itemId,
  }) async {
    await _db.unequipItem(userId: userId, itemId: itemId);
  }

  Future<EquipmentItemModel> upgradeItem({
    required String itemId,
    required String userId,
    required int costEssence,
  }) async {
    return await _db.upgradeEquipment(
      itemId: itemId,
      userId: userId,
      costEssence: costEssence,
    );
  }

  // ==========================================
  // 3. World Arbiter Quest Decrees
  // ==========================================

  static List<QuestDecreeModel> defaultStarterQuests(String userId, [DateTime? baseTime]) {
    final now = baseTime ?? DateTime.now();
    return [
      QuestDecreeModel(
        id: 'quest_sanctuary_outpost',
        userId: userId,
        title: 'Clear Anomaly Wave in Sanctuary 4',
        sectorId: 'sectors_neon_bastion_4',
        sectorName: 'Sanctuary 4 (Aether Spire)',
        decreeText: 'The World Arbiter (Cardinal) has detected dimensional chaos. Assemble squad matrix or engage solo descent.',
        rewardEssence: 750,
        rewardLaurels: 50,
        progress: 0.65,
        isUrgent: true,
        isClaimed: false,
        difficulty: 'S-RANK',
        createdAt: now,
      ),
      QuestDecreeModel(
        id: 'quest_aether_conduit',
        userId: userId,
        title: 'Restore Imperial Aether Conduit',
        sectorId: 'sectors_citadel_9',
        sectorName: 'Imperial Citadel - Core',
        decreeText: 'Purge anomalous data residue from primary power conductors and realign flow.',
        rewardEssence: 500,
        rewardLaurels: 35,
        progress: 1.0,
        isUrgent: false,
        isClaimed: false,
        difficulty: 'A-RANK',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Future<List<QuestDecreeModel>> getQuests(String userId) async {
    final quests = await _db.getQuestDecreesForUser(userId);
    if (quests.isNotEmpty) return quests;

    // Seed default initial decrees into SQLite once
    final initialQuests = defaultStarterQuests(userId);
    for (final q in initialQuests) {
      await _db.upsertQuestDecree(q);
    }
    // Return exclusively from authoritative SQLite query
    return await _db.getQuestDecreesForUser(userId);
  }

  Future<void> updateQuestProgress({
    required String questId,
    required double progress,
  }) async {
    await _db.updateQuestProgress(questId: questId, progress: progress);
  }

  Future<bool> claimReward({
    required String questId,
    required String userId,
  }) async {
    return await _db.claimQuestReward(questId: questId, userId: userId);
  }

  /// Generates a dynamic World Arbiter quest decree with validated LLM flavor text.
  /// Mechanical variables (rewardEssence, rewardLaurels, difficulty, progress, isClaimed)
  /// remain strictly deterministic and governed exclusively by Sovereign rules.
  /// If the LLM call times out, fails validation, or the daemon is offline, it fails
  /// closed to deterministic calibrated fallback content.
  Future<QuestDecreeModel> generateDynamicQuestDecree({
    required String userId,
    required String sectorId,
    required String sectorName,
    required String difficulty,
    String? operatorClass,
    bool isUrgent = false,
  }) async {
    ArbiterDecreeFlavor? flavor;
    try {
      flavor = await _llmService.generateDecreeFlavor(
        operatorClass: operatorClass ?? 'Vanguard',
        sectorName: sectorName,
        difficulty: difficulty,
      );
    } catch (_) {
      flavor = null; // Fails closed
    }

    // Deterministic Sovereign reward calculation (untouched by LLM)
    final int rewardEssence;
    final int rewardLaurels;
    if (difficulty.toUpperCase().contains('S')) {
      rewardEssence = 750;
      rewardLaurels = 50;
    } else if (difficulty.toUpperCase().contains('A')) {
      rewardEssence = 500;
      rewardLaurels = 35;
    } else {
      rewardEssence = 300;
      rewardLaurels = 20;
    }

    final decree = QuestDecreeModel(
      id: 'quest_arbiter_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: flavor?.title ?? 'Reconnaissance in $sectorName',
      sectorId: sectorId,
      sectorName: sectorName,
      decreeText: flavor?.description ??
          'The World Arbiter decrees systematic purge and stabilization of anomalous energy traces.',
      rewardEssence: rewardEssence,
      rewardLaurels: rewardLaurels,
      progress: 0.0,
      isUrgent: isUrgent,
      isClaimed: false,
      difficulty: difficulty,
      createdAt: DateTime.now(),
    );

    await _db.upsertQuestDecree(decree);
    return decree;
  }

  // ==========================================
  // 4. Oracle Divination Chronicle & Buff Engine
  // ==========================================

  static OracleRecord defaultStarterRoll(String userId) {
    return OracleRecord.createCalibratedRecord(
      userId: userId,
      d20Roll: 20,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  Future<void> recordRoll(OracleRecord record) async {
    await _db.recordOracleDivination(record);
  }

  Future<List<OracleRecord>> getHistory(String userId, {int limit = 10}) async {
    final history = await _db.getOracleHistoryForUser(userId, limit: limit);
    if (history.isNotEmpty) return history;

    // Seed initial canonical divination record into SQLite once if empty
    final starter = defaultStarterRoll(userId);
    await _db.recordOracleDivination(starter);
    return await _db.getOracleHistoryForUser(userId, limit: limit);
  }

  /// Atomically executes a divination communion: checks and debits Essence from player_wallets,
  /// queries LLM sidecar for celestial prophecy flavor, and persists to oracle_histories.
  /// If the LLM times out or is offline, fails closed to calibrated template text.
  Future<OracleRecord> communeWithOracle({
    required String userId,
    int costEssence = 25,
    int? rollOverride,
    DateTime? timestamp,
    String? operatorClass,
    String? sector,
  }) async {
    final roll = rollOverride ?? (Random().nextInt(20) + 1);
    final outcomeTier = OracleRecord.determineOutcomeTier(roll);

    String? prophecyOverride;
    try {
      final flavor = await _llmService.generateOracleProphecy(
        d20Roll: roll,
        outcomeTier: outcomeTier,
        operatorClass: operatorClass ?? 'Vanguard',
        sector: sector,
      );
      if (flavor != null && flavor.prophecyText.isNotEmpty) {
        prophecyOverride = flavor.prophecyText;
      }
    } catch (_) {
      prophecyOverride = null; // Fails closed to calibrated template
    }

    return await _db.performDivinationRoll(
      userId: userId,
      costEssence: costEssence,
      d20Roll: roll,
      timestamp: timestamp,
      blessingTextOverride: prophecyOverride,
    );
  }

  /// Returns all active, unexpired temporal buffs for the operator.
  Future<List<ActiveBuff>> getActiveBuffs(String userId) async {
    final history = await getHistory(userId, limit: 10);
    final active = <ActiveBuff>[];
    for (final record in history) {
      final buff = record.activeBuff;
      if (buff != null && !buff.isExpired) {
        active.add(buff);
      }
    }
    return active;
  }

  // ==========================================
  // 5. Sanctuary Social Bulletin
  // ==========================================

  static SocialPostEntry defaultStarterPost() {
    return SocialPostEntry(
      id: 'post_vane_001',
      authorId: 'operator_vane',
      authorName: 'Lord Commander Vane',
      authorTitle: 'Imperial Vanguard Marshal',
      avatarPath: 'assets/icon/app_icon.png',
      content: 'Resonance levels in Sector 4 are stabilizing after planetary calibration. All operators report to Astrolabe stations.',
      isIC: true,
      laurelsCount: 14,
      commentsCount: 0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
    );
  }

  Future<List<SocialPostEntry>> getFeed({int limit = 20}) async {
    final posts = await _db.getSocialPosts(limit: limit);
    if (posts.isNotEmpty) return posts;

    // Seed single calibrated starter post (seed-not-bypass pattern)
    final starter = defaultStarterPost();
    await _db.createSocialPost(starter);
    return await _db.getSocialPosts(limit: limit);
  }

  Future<void> createPost(SocialPostEntry post) async {
    await _db.createSocialPost(post);
  }

  Future<void> endorsePost({required String postId, required String userId}) async {
    await _db.addLaurelToPost(postId: postId, userId: userId);
  }

  Future<List<SocialCommentEntry>> getComments(String postId) async {
    return await _db.getCommentsForPost(postId);
  }

  Future<void> addComment(SocialCommentEntry comment) async {
    await _db.addCommentToPost(comment);
  }
}
