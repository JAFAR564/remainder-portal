import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:remainder_portal/data/services/database_service.dart' hide PlayerWallet;
import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/models/equipment_item_model.dart';
import 'package:remainder_portal/data/models/quest_decree_model.dart';
import 'package:remainder_portal/data/models/oracle_record.dart';
import 'package:remainder_portal/data/models/social_bulletin_model.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';

void main() {
  late AppDatabase database;
  late SovereignRepository repository;

  setUp(() {
    // Inject a native in-memory database connection for unit testing isolation
    database = AppDatabase(NativeDatabase.memory());
    repository = SovereignRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  // =========================================================================
  // 1. Existing Drift Schema & UTRCS Ingestion Tests (Preserved)
  // =========================================================================

  test('Drift Schema Offline Ingestion: User profile creation and retrieval works', () async {
    final now = DateTime.now();
    await database.into(database.users).insert(
      UsersCompanion.insert(
        id: 'operator_alpha',
        displayName: 'Kaelen Ally',
        email: 'ally@remainder.net',
        origin: 'Amatsukrion Sync',
        activeSector: 'sectors_neon_bastion_4',
        reputationRanks: const Value('{"Vanguard": 2}'),
        joinedDate: now,
        trustScore: 0.88,
      ),
    );

    final users = await database.select(database.users).get();
    expect(users.length, 1);
    
    final user = users.first;
    expect(user.id, 'operator_alpha');
    expect(user.displayName, 'Kaelen Ally');
    expect(user.origin, 'Amatsukrion Sync');
    expect(user.activeSector, 'sectors_neon_bastion_4');
    expect(user.trustScore, 0.88);
  });

  test('Drift Schema Offline Ingestion: Chat history and sync tracking queues properly', () async {
    final now = DateTime.now();
    
    // Insert user first to satisfy foreign key constraints
    await database.into(database.users).insert(
      UsersCompanion.insert(
        id: 'operator_alpha',
        displayName: 'Kaelen Ally',
        email: 'ally@remainder.net',
        origin: 'Amatsukrion Sync',
        activeSector: 'sectors_neon_bastion_4',
        joinedDate: now,
        trustScore: 0.88,
      ),
    );

    // Insert story thread session
    await database.into(database.storyThreads).insert(
      StoryThreadsCompanion.insert(
        id: 'session_001',
        userId: 'operator_alpha',
        title: 'Genesis Encounter',
        currentSectorId: 'sectors_neon_bastion_4',
        lastInteraction: now,
      ),
    );

    // Insert pending chat message
    await database.into(database.chatMessages).insert(
      ChatMessagesCompanion.insert(
        id: 'msg_101',
        threadId: 'session_001',
        role: 'user',
        content: 'Analyzing portal signals.',
        timestamp: now,
        syncStatus: const Value(0), // 0: Pending, 1: Synced
      ),
    );

    final messages = await database.select(database.chatMessages).get();
    expect(messages.length, 1);
    
    final message = messages.first;
    expect(message.id, 'msg_101');
    expect(message.threadId, 'session_001');
    expect(message.role, 'user');
    expect(message.content, 'Analyzing portal signals.');
    expect(message.syncStatus, 0);
  });

  test('Drift Schema Offline Ingestion: UTRCS character persistence saves and retrieves raw JSON payload', () async {
    final now = DateTime.now();
    const testJson = '{"id":"utrcs_test_1","name":"Operator Kael","concept":"Aether Vanguard"}';

    await database.saveUtrcsCharacter(
      id: 'utrcs_test_1',
      userId: null,
      schemaVersion: '1.0.0',
      completionDepth: 'quick',
      rawJsonPayload: testJson,
      createdAt: now,
      updatedAt: now,
    );

    final characterRow = await database.getActiveUtrcsCharacter();
    expect(characterRow, isNotNull);
    expect(characterRow!['id'], 'utrcs_test_1');
    expect(characterRow['completion_depth'], 'quick');
    expect(characterRow['raw_json_payload'], testJson);
  });

  // =========================================================================
  // 2. Schema v5 Initialization & Migration Verification
  // =========================================================================

  test('Schema v5: Fresh DB initialization provides schemaVersion 5 and all tables', () {
    expect(database.schemaVersion, 5);
  });

  test('Migration v4 -> v5: Preserves existing UTRCS characters, users, and chat messages', () async {
    final now = DateTime.now();
    const testJson = '{"id":"utrcs_pre_migration","name":"Sovereign Vanguard","concept":"Chrono Explorer"}';

    // Insert pre-migration records
    await database.saveUtrcsCharacter(
      id: 'utrcs_pre_migration',
      userId: null,
      schemaVersion: '1.0.0',
      completionDepth: 'deep',
      rawJsonPayload: testJson,
      createdAt: now,
      updatedAt: now,
    );

    // Simulate calling onUpgrade from v4 to v5
    await database.migration.onUpgrade(database.createMigrator(), 4, 5);

    // Re-verify that UTRCS record remains completely intact
    final utrcsAfter = await database.getActiveUtrcsCharacter();
    expect(utrcsAfter, isNotNull);
    expect(utrcsAfter!['id'], 'utrcs_pre_migration');
    expect(utrcsAfter['raw_json_payload'], testJson);

    // Calling onUpgrade again should be completely idempotent without throwing
    await expectLater(
      database.migration.onUpgrade(database.createMigrator(), 4, 5),
      completes,
    );
  });

  // =========================================================================
  // 3. Player Wallet & Currency Engine Tests
  // =========================================================================

  test('Player Wallet: Saves and retrieves wallet with calculated level progression', () async {
    final now = DateTime.now();
    final wallet = PlayerWallet(
      userId: 'operator_wallet_test',
      essenceBalance: 2500,
      laurelBalance: 320,
      experiencePoints: 765000,
      currentLevel: 88,
      unallocatedAttributePoints: 2,
      lastUpdated: now,
    );

    await database.savePlayerWallet(wallet);
    final retrieved = await database.getPlayerWallet('operator_wallet_test');

    expect(retrieved, isNotNull);
    expect(retrieved!.userId, 'operator_wallet_test');
    expect(retrieved.essenceBalance, 2500);
    expect(retrieved.laurelBalance, 320);
    expect(retrieved.experiencePoints, 765000);
    expect(retrieved.currentLevel, 88);
    expect(retrieved.unallocatedAttributePoints, 2);
    expect(retrieved.levelProgress, greaterThan(0.0));
    expect(retrieved.levelProgress, lessThanOrEqualTo(1.0));
  });

  test('Player Wallet: Atomic balance adjustments and overdraft protection', () async {
    final now = DateTime.now();
    await database.savePlayerWallet(PlayerWallet(
      userId: 'operator_bank',
      essenceBalance: 500,
      laurelBalance: 50,
      experiencePoints: 1000,
      currentLevel: 10,
      lastUpdated: now,
    ));

    // Deposit essence & laurels
    final updated = await database.adjustWalletBalance(
      userId: 'operator_bank',
      essenceDelta: 200,
      laurelDelta: 25,
    );
    expect(updated.essenceBalance, 700);
    expect(updated.laurelBalance, 75);

    // Deduct valid amount
    final afterDeduct = await database.adjustWalletBalance(
      userId: 'operator_bank',
      essenceDelta: -300,
    );
    expect(afterDeduct.essenceBalance, 400);

    // Attempt overdraft: essence deduction > current balance must throw StateError
    expect(
      () => database.adjustWalletBalance(userId: 'operator_bank', essenceDelta: -1000),
      throwsA(isA<StateError>()),
    );

    // Verify balance was not modified by failed transaction
    final balanceCheck = await database.getPlayerWallet('operator_bank');
    expect(balanceCheck!.essenceBalance, 400);
  });

  // =========================================================================
  // 4. Imperial Relic Vault & Non-Destructive Unequip Tests
  // =========================================================================

  test('Imperial Vault: Safe unequip retains item in vault without deletion', () async {
    final now = DateTime.now();
    final weapon = EquipmentItemModel(
      id: 'gear_glaive_01',
      userId: 'operator_vault_test',
      slot: 'WEAPON',
      name: 'Void-Reaver Glaive',
      rarity: EquipmentRarity.celestial,
      statBonus: '+45 ATK',
      description: 'Stellar alloy weapon.',
      iconName: 'colorize',
      upgradeLevel: 1,
      isEquipped: true,
      acquiredAt: now,
    );

    await database.upsertEquipment(weapon);

    // Unequip weapon
    await database.unequipItem(userId: 'operator_vault_test', itemId: 'gear_glaive_01');

    // Item must still exist in DB, but with isEquipped == false
    final itemAfterUnequip = await database.getEquipmentById('gear_glaive_01');
    expect(itemAfterUnequip, isNotNull);
    expect(itemAfterUnequip!.isEquipped, false);
    expect(itemAfterUnequip.name, 'Void-Reaver Glaive');

    // Re-equip weapon
    await database.equipItem(
      userId: 'operator_vault_test',
      itemId: 'gear_glaive_01',
      slot: 'WEAPON',
    );
    final itemAfterEquip = await database.getEquipmentById('gear_glaive_01');
    expect(itemAfterEquip!.isEquipped, true);
  });

  test('Imperial Vault: Equipping slot swaps existing equipped item', () async {
    final now = DateTime.now();
    final weapon1 = EquipmentItemModel(
      id: 'weapon_old',
      userId: 'operator_swap',
      slot: 'WEAPON',
      name: 'Old Blade',
      rarity: EquipmentRarity.common,
      statBonus: '+10 ATK',
      description: 'Worn iron sword.',
      iconName: 'colorize',
      isEquipped: true,
      acquiredAt: now,
    );
    final weapon2 = EquipmentItemModel(
      id: 'weapon_new',
      userId: 'operator_swap',
      slot: 'WEAPON',
      name: 'Sun-Forged Blade',
      rarity: EquipmentRarity.sovereign,
      statBonus: '+60 ATK',
      description: 'Radiant blade of imperial fire.',
      iconName: 'colorize',
      isEquipped: false,
      acquiredAt: now.add(const Duration(seconds: 1)),
    );

    await database.upsertEquipment(weapon1);
    await database.upsertEquipment(weapon2);

    // Equip weapon2
    await database.equipItem(
      userId: 'operator_swap',
      itemId: 'weapon_new',
      slot: 'WEAPON',
    );

    final w1 = await database.getEquipmentById('weapon_old');
    final w2 = await database.getEquipmentById('weapon_new');
    expect(w1!.isEquipped, false);
    expect(w2!.isEquipped, true);
  });

  test('Imperial Vault: Upgrading equipment increments tier and deducts essence', () async {
    final now = DateTime.now();
    await database.savePlayerWallet(PlayerWallet(
      userId: 'operator_upgrade',
      essenceBalance: 500,
      lastUpdated: now,
    ));

    final cuirass = EquipmentItemModel(
      id: 'armor_cuirass_upgrade',
      userId: 'operator_upgrade',
      slot: 'ARMOR',
      name: 'Chrono-Weave Cuirass',
      rarity: EquipmentRarity.rare,
      statBonus: '+30 DEF',
      description: 'Reinforced mesh.',
      iconName: 'shield',
      upgradeLevel: 0,
      isEquipped: true,
      acquiredAt: now,
    );
    await database.upsertEquipment(cuirass);

    // Upgrade item costing 150 Essence
    final upgraded = await database.upgradeEquipment(
      itemId: 'armor_cuirass_upgrade',
      userId: 'operator_upgrade',
      costEssence: 150,
    );

    expect(upgraded.upgradeLevel, 1);

    // Check wallet balance was deducted
    final wallet = await database.getPlayerWallet('operator_upgrade');
    expect(wallet!.essenceBalance, 350);
  });

  // =========================================================================
  // 5. Quest Decrees & Idempotent Reward Claim Tests
  // =========================================================================

  test('Quest Decrees: Claiming rewards pays wallet atomically and prevents double claim', () async {
    final now = DateTime.now();
    await database.savePlayerWallet(PlayerWallet(
      userId: 'operator_quest_hero',
      essenceBalance: 1000,
      laurelBalance: 150,
      lastUpdated: now,
    ));

    final completedQuest = QuestDecreeModel(
      id: 'decree_complete_01',
      userId: 'operator_quest_hero',
      title: 'Harmonize Sanctuary Outpost',
      sectorId: 'sectors_neon_bastion_4',
      sectorName: 'Neon Bastion Hub',
      decreeText: 'Neutralize entropy waves.',
      rewardEssence: 750,
      rewardLaurels: 50,
      progress: 1.0,
      isClaimed: false,
      createdAt: now,
    );
    await database.upsertQuestDecree(completedQuest);

    // Initial claim must succeed
    final firstClaim = await database.claimQuestReward(
      questId: 'decree_complete_01',
      userId: 'operator_quest_hero',
    );
    expect(firstClaim, true);

    // Wallet balances must reflect payout
    final walletAfterPayout = await database.getPlayerWallet('operator_quest_hero');
    expect(walletAfterPayout!.essenceBalance, 1750);
    expect(walletAfterPayout.laurelBalance, 200);

    // Second claim attempt must return false (idempotent, no double payout!)
    final secondClaim = await database.claimQuestReward(
      questId: 'decree_complete_01',
      userId: 'operator_quest_hero',
    );
    expect(secondClaim, false);

    // Balance must remain strictly unchanged
    final walletAfterSecondClaim = await database.getPlayerWallet('operator_quest_hero');
    expect(walletAfterSecondClaim!.essenceBalance, 1750);
    expect(walletAfterSecondClaim.laurelBalance, 200);
  });

  test('Quest Decrees: Incomplete quest cannot be claimed', () async {
    final now = DateTime.now();
    final incompleteQuest = QuestDecreeModel(
      id: 'decree_in_progress',
      userId: 'operator_quest_hero',
      title: 'Realign Resonance',
      sectorId: 'sectors_neon_bastion_4',
      sectorName: 'Neon Bastion',
      decreeText: 'In progress task.',
      rewardEssence: 500,
      rewardLaurels: 25,
      progress: 0.65,
      isClaimed: false,
      createdAt: now,
    );
    await database.upsertQuestDecree(incompleteQuest);

    expect(
      () => database.claimQuestReward(questId: 'decree_in_progress', userId: 'operator_quest_hero'),
      throwsA(isA<StateError>()),
    );
  });

  // =========================================================================
  // 6. Oracle Divination Chronicle Tests
  // =========================================================================

  test('Oracle Divination: Logs roll records and retrieves in reverse-chronological order', () async {
    final now = DateTime.now();
    final roll1 = OracleRecord(
      id: 'roll_001',
      userId: 'operator_oracle',
      d20Roll: 14,
      outcomeTier: 'HARMONIC AETHER',
      blessingText: 'Aetheric current stabilizes operations.',
      buffGranted: '+15% Essence Gain',
      timestamp: now.subtract(const Duration(minutes: 5)),
    );
    final roll2 = OracleRecord(
      id: 'roll_002',
      userId: 'operator_oracle',
      d20Roll: 20,
      outcomeTier: 'CRITICAL CONSENSUS',
      blessingText: 'The Loom converges into transcendent alignment.',
      buffGranted: '+50% All Rewards',
      timestamp: now,
    );

    await database.recordOracleDivination(roll1);
    await database.recordOracleDivination(roll2);

    final history = await database.getOracleHistoryForUser('operator_oracle', limit: 10);
    expect(history.length, 2);
    // Newest roll first
    expect(history.first.d20Roll, 20);
    expect(history.first.outcomeTier, 'CRITICAL CONSENSUS');
    expect(history.last.d20Roll, 14);
  });

  // =========================================================================
  // 7. Sanctuary Social Bulletin Tests
  // =========================================================================

  test('Social Bulletin: Posts and comments lifecycle with counter increments', () async {
    final now = DateTime.now();
    final post = SocialPostEntry(
      id: 'post_comm_01',
      authorId: 'operator_marshal',
      authorName: 'Marshal Thorne',
      authorTitle: 'Sub-Net Commander',
      avatarPath: 'assets/icon/app_icon.png',
      content: 'Perimeter breached in Sector 9.',
      isIC: true,
      laurelsCount: 5,
      commentsCount: 0,
      createdAt: now,
    );

    await database.createSocialPost(post);

    // Endorse post with a laurel
    await database.addLaurelToPost(postId: 'post_comm_01', userId: 'operator_friend');

    // Add comment
    final comment = SocialCommentEntry(
      id: 'comment_01',
      postId: 'post_comm_01',
      authorName: 'Vanguard Lyra',
      content: 'Deploying reinforcements now.',
      createdAt: now.add(const Duration(seconds: 10)),
    );
    await database.addCommentToPost(comment);

    final posts = await database.getSocialPosts();
    expect(posts.length, 1);
    expect(posts.first.laurelsCount, 6);
    expect(posts.first.commentsCount, 1);

    final comments = await database.getCommentsForPost('post_comm_01');
    expect(comments.length, 1);
    expect(comments.first.authorName, 'Vanguard Lyra');
    expect(comments.first.content, 'Deploying reinforcements now.');
  });

  // =========================================================================
  // 8. SovereignRepository Domain Seeding & Integration Tests
  // =========================================================================

  test('SovereignRepository: Auto-seeds initial wallet, equipment, and quests on cold boot', () async {
    const userId = 'operator_fresh_boot';

    // 1. Wallet seeding
    final wallet = await repository.getWallet(userId);
    expect(wallet.userId, userId);
    expect(wallet.essenceBalance, 1000);
    expect(wallet.laurelBalance, 150);
    expect(wallet.currentLevel, 88);

    // 2. Equipment seeding (4 equipped, 2 vault)
    final equipment = await repository.getEquipment(userId);
    expect(equipment.length, 6);
    final equipped = equipment.where((e) => e.isEquipped).toList();
    final vault = equipment.where((e) => !e.isEquipped).toList();
    expect(equipped.length, 4);
    expect(vault.length, 2);

    // 3. Quest seeding
    final quests = await repository.getQuests(userId);
    expect(quests.length, 2);
    expect(quests.any((q) => q.id == 'quest_sanctuary_outpost'), true);

    // 4. Social feed seeding (single calibrated starter post per Sovereign mandate)
    final feed = await repository.getFeed();
    expect(feed.length, 1);
    expect(feed.first.id, 'post_vane_001');
    expect(feed.first.authorName, 'Lord Commander Vane');
  });
}
