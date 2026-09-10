import '../models/equipment_item_model.dart';
import '../models/oracle_record.dart';
import '../models/player_wallet.dart';
import '../models/quest_decree_model.dart';
import '../models/social_bulletin_model.dart';
import '../services/database_service.dart' hide PlayerWallet;

/// Repository coordinating persistent domain state for the Sovereign Command Deck.
class SovereignRepository {
  final AppDatabase _db;

  SovereignRepository(this._db);

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
      experiencePoints: 8800,
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

  Future<List<EquipmentItemModel>> getEquipment(String userId) async {
    final items = await _db.getEquipmentForUser(userId);
    if (items.isNotEmpty) return items;

    // Seed default starter gear and vault items
    final now = DateTime.now();
    final starterGear = [
      EquipmentItemModel(
        id: 'relic_weapon_void_reaver',
        userId: userId,
        slot: 'WEAPON',
        name: 'Void-Reaver Glaive',
        rarity: EquipmentRarity.celestial,
        statBonus: '+45 ATK',
        description: 'Forged from super-dense stellar alloy, resonates with raw aether.',
        iconName: 'colorize',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: now,
      ),
      EquipmentItemModel(
        id: 'relic_armor_chrono_weave',
        userId: userId,
        slot: 'ARMOR',
        name: 'Chrono-Weave Cuirass',
        rarity: EquipmentRarity.rare,
        statBonus: '+30 DEF',
        description: 'Interlocking chrono-filaments dissipating entropy impacts.',
        iconName: 'shield',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: now.add(const Duration(seconds: 1)),
      ),
      EquipmentItemModel(
        id: 'relic_relic_aetherial_astrolabe',
        userId: userId,
        slot: 'RELIC',
        name: 'Aetherial Astrolabe',
        rarity: EquipmentRarity.sovereign,
        statBonus: '+15% Resonance',
        description: 'Ancient navigation instrument attuned to celestial currents.',
        iconName: 'auto_awesome',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: now.add(const Duration(seconds: 2)),
      ),
      EquipmentItemModel(
        id: 'relic_charm_sigil_arbiter',
        userId: userId,
        slot: 'CHARM',
        name: 'Sigil of the Arbiter',
        rarity: EquipmentRarity.common,
        statBonus: '+5 Luck',
        description: 'Imperial insignia certifying full clearance across all outer gates.',
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

  Future<List<QuestDecreeModel>> getQuests(String userId) async {
    final quests = await _db.getQuestDecreesForUser(userId);
    if (quests.isNotEmpty) return quests;

    // Seed default initial decrees
    final now = DateTime.now();
    final initialQuests = [
      QuestDecreeModel(
        id: 'quest_sanctuary_outpost',
        userId: userId,
        title: 'Harmonize Sanctuary Outpost',
        sectorId: 'sectors_neon_bastion_4',
        sectorName: 'Aether Resonance Hub - Neon Bastion',
        decreeText: 'Calibrate the local resonance dampeners to neutralize incoming entropy waves from the Sub-Net anomaly.',
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

    for (final q in initialQuests) {
      await _db.upsertQuestDecree(q);
    }
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

  // ==========================================
  // 4. Oracle Divination Chronicle
  // ==========================================

  Future<void> recordRoll(OracleRecord record) async {
    await _db.recordOracleDivination(record);
  }

  Future<List<OracleRecord>> getHistory(String userId, {int limit = 10}) async {
    return await _db.getOracleHistoryForUser(userId, limit: limit);
  }

  // ==========================================
  // 5. Sanctuary Social Bulletin
  // ==========================================

  Future<List<SocialPostEntry>> getFeed({int limit = 20}) async {
    final posts = await _db.getSocialPosts(limit: limit);
    if (posts.isNotEmpty) return posts;

    // Seed default bulletin posts
    final now = DateTime.now();
    final seedPosts = [
      SocialPostEntry(
        id: 'post_vane_001',
        authorId: 'operator_vane',
        authorName: 'Lord Commander Vane',
        authorTitle: 'Imperial Vanguard Marshal',
        avatarPath: 'assets/icon/app_icon.png',
        content: 'Resonance levels in Sector 4 are stabilizing after planetary calibration. All operators report to Astrolabe stations.',
        isIC: true,
        laurelsCount: 14,
        commentsCount: 2,
        createdAt: now.subtract(const Duration(minutes: 42)),
      ),
      SocialPostEntry(
        id: 'post_lyra_002',
        authorId: 'operator_lyra',
        authorName: 'Arbiter Lyra',
        authorTitle: 'Chief Lore Scribe',
        avatarPath: 'assets/icon/app_icon.png',
        content: 'New canonization decree submitted for the Outer Rim beacon. Cast your endorsements before the celestial cycle resets.',
        isIC: true,
        laurelsCount: 8,
        commentsCount: 1,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ];

    for (final post in seedPosts) {
      await _db.createSocialPost(post);
    }
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
