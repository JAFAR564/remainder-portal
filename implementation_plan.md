# Sovereign Dashboard Interactivity Upgrade

## 1. Executive Summary

This document defines the architectural blueprint, domain design, persistence contracts, and execution plan for evolving the **Master Dashboard** in **The Remainder Portal** (`remainder_portal`) from a primarily display-oriented surface into a **fully interactive, persistent Sovereign Command Deck**.

Following the successful completion of Thread B's Celestial Astrolabe visual overhaul and layout hardening, the visual layer is stable, responsive across mobile viewports (Honor X8), and verified in Cloud CI. However, a deep architectural audit reveals that several core interactions are currently **display-only stubs, ephemeral in-memory state, or destructive prototypes**:
1. **Equipment Slots:** Unequipping an item permanently deletes it from memory; tapping an empty slot does nothing because there is no backing Vault/Inventory browser.
2. **Quest Decrees:** Quest progress is locked at 65%; there is no mechanism to advance progress, claim rewards, deposit currencies into a persistent wallet, or dispatch new decrees.
3. **Oracle Divination:** D20 rolls generate a temporary string in local widget state with zero gameplay consequences, zero buff tracking, and zero persistence.
4. **Vessel Vitality & Essence:** The telemetry modal is read-only; no alchemical restoration, healing, or attribute point allocation exists.
5. **Sanctuary Bulletin:** Comments and Share buttons are empty closures (`onTap: () {}`), and there is no composer to author new broadcasts.
6. **Sovereign Waygates:** The six portal tiles navigate correctly, but render static labels with zero live telemetry from their underlying subsystems.

### The Sovereign Command Deck Principle
The Master Dashboard is **strictly a command and telemetry surface**, not the domain engine of the universe. The Dashboard must never directly mutate database tables, duplicate combat math, or become a bloated monolith. Every interaction on the Dashboard must follow a strict unidirectional domain pipeline:
$$\text{Dashboard UI} \longrightarrow \text{Domain Command / Notifier} \longrightarrow \text{Repository / Service} \longrightarrow \text{Drift Transaction} \longrightarrow \text{Provider Invalidation} \longrightarrow \text{Dashboard Re-render}$$

This plan establishes the architecture to unlock 100% interactive, persistent capabilities across all seven operational areas without breaking existing test suites, database integrity, or offline-first guarantees.

---

## 2. Current System Audit

| Section | Current UI Widget | Current Backing Source | Current Behavior | Architectural Limitation / Gap |
| :--- | :--- | :--- | :--- | :--- |
| **1. Operator Crest** | `dashboard_screen.dart:148-272` | `playerProfileProvider` (null fallback) | Static "Level 88", hardcoded string name fallback, tap opens `CharacterDossierScreen`. | Level/XP is hardcoded; does not dynamically react to active UTRCS character edits or level-ups. |
| **2. Equipment Slots** | `equipment_slots_widget.dart` | `equippedGearProvider` (in-memory) | Displays 4 fixed items; tap opens `EquipmentDetailSheet`. Tap empty slot = `null`. Unequip deletes item. | No inventory vault exists; unequipped items are permanently lost; no re-equip flow; no upgrade system. |
| **3. Aether Oracle** | `aether_resonance_oracle_widget.dart` | Local widget `State` (`_lastRoll`) | Rolls D20, delays 400ms, picks 1 of 5 hardcoded strings. | Purely ephemeral; no buffs applied; no expiration timer; no persistent divination chronicle. |
| **4. Quest Decree** | `quest_decree_widget.dart` | `activeQuestProvider` (`StateProvider`) | Shows fixed quest (65% progress). "Depart" pushes `DescentScreen`. | Read-only state; no purge action; no reward claiming; no player wallet to receive Essence/Laurels; no quest dispatcher. |
| **5. Vitality Gauges** | `dashboard_screen.dart:288-352` | `profile?.stats` (null fallback: 16, 18, 14) | Shows 3 capsule meters. Tap opens read-only telemetry modal. | Read-only; no alchemical healing; no aether channeling; no attribute allocation on level-up. |
| **6. Waygate Hubs** | `dashboard_screen.dart:354-427` | Static routing table | 6 tiles navigate to Descent, Chat, Squads, Guilds, Canon, Market. | Zero live badges or telemetry reflecting pending trades, unread chat, active squads, or active lore votes. |
| **7. Bulletin Wall** | `dashboard_screen.dart:430-455` & `social_post_card.dart` | `socialFeedProvider` (in-memory) | Displays 2 posts; laurel increments locally. Comment & Share buttons have empty `onTap: () {}`. | Comments and Share are dead ends; no composer dialog to post new scrolls; no channel filter (IC vs OOC). |

---

## 3. Existing Domain Capabilities

The audit verified that the repository already possesses substantial backend machinery across its subsystems:

1. **Universal Roleplay Character System (UTRCS):**
   - File: [`lib/data/models/utrcs_character.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/data/models/utrcs_character.dart)
   - Persistence: `utrcs_characters` table in Drift SQLite (Schema v4).
   - Provider: [`utrcsCharacterProvider`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/utrcs_provider.dart) with full JSON serialization, capability lists, and psychological layers.
2. **AI Story Generation & GM Service:**
   - File: [`lib/data/services/litert_service.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/data/services/litert_service.dart)
   - Capabilities: Cloud Firebase Genkit routing with local fallback to deterministic D20 narrative rule engine.
3. **P2P Squad Matrix & Cooperative Checks:**
   - File: [`lib/presentation/providers/expedition_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/expedition_provider.dart)
   - Persistence: `expeditions` and `expedition_members` tables.
   - Capabilities: D20 skill checks combining player stats, leader attributes, and trust scores.
4. **Sovereign Guilds & Governance:**
   - File: [`lib/presentation/providers/guild_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/guild_provider.dart)
   - Persistence: `guilds`, `guild_members`, `governance_rules` tables.
   - Capabilities: Guild creation, treasury balance management, sector laws.
5. **Chrono-Loom Canon Lore Voting:**
   - File: [`lib/presentation/providers/chrono_loom_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/chrono_loom_provider.dart)
   - Persistence: `lore_proposals` and `lore_history` tables.
   - Capabilities: Proposal submission, yes/no vote casting, quorum calculation.
6. **Escrow Trade Matrix:**
   - File: [`lib/presentation/providers/economy_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/economy_provider.dart)
   - Persistence: `player_trades` and `trade_escrow` tables.
   - Capabilities: Multi-item trade negotiation, energy escrow, atomic state transitions (`pending` $\rightarrow$ `escrowLocked` $\rightarrow$ `completed`).

---

## 4. Missing Capabilities

The audit revealed specific architectural gaps preventing true interactivity:

1. **Player Wallet & Currency System:**
   - There is no persistent player currency store for `Essence` or `Laurels`.
   - The `Users` table lacks currency columns.
   - Claiming quest rewards or paying for equipment upgrades currently has no transactional destination.
2. **Equipment Vault & Inventory Management:**
   - While Drift has a `CharacterInventory` table, it is completely disconnected from `EquippedGearItem` and has no concept of gear slots (`WEAPON`, `ARMOR`, etc.) or equipping states.
   - There is no repository or provider to query unequipped items.
3. **Quest State Management:**
   - `activeQuestProvider` is a static `StateProvider<ActiveQuestModel>`.
   - There is no `QuestNotifier` to mutate progress, mark decrees as claimed, or fetch new decrees.
4. **Oracle Buff Engine & History:**
   - There is no data model or provider for active temporary buffs.
   - There is no table to record past D20 divination rolls.
5. **Social Bulletin Interaction:**
   - There is no `CommentModel`, no `comments` table, and no `addComment` or `createPost` method.

---

## 5. State Ownership Matrix

To prevent the Dashboard from becoming a monolithic second source of truth, state ownership is assigned strictly to domain owners:

| State Entity | Canonical Domain Owner | Storage Mechanism | Riverpod Provider | Dashboard Access | Dashboard Mutation Action |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Active Player Identity** | Identity Domain | Drift `utrcs_characters` & `users` | `utrcsCharacterProvider` | Read Name, Origin, Level | Switch active character |
| **Player Wallet (Essence, Laurels, XP)** | Economy / Progression Domain | Drift `player_wallet` (New Table) | `playerWalletProvider` (New) | Read Balances, Level, XP | Add rewards, deduct costs |
| **Equipped Gear** | Equipment Domain | Drift `equipment_items` (New/Migrated) | `equippedGearProvider` | Read 4 active slots | Equip / Unequip / Upgrade |
| **Vault Inventory** | Equipment Domain | Drift `equipment_items` (New/Migrated) | `equipmentVaultProvider` (New) | Read unequipped items | Filter & select to equip |
| **Active Session Buffs** | Combat / Buff Domain | In-Memory + SQLite `active_buffs` | `activeBuffsProvider` (New) | Read active multipliers | D20 Oracle invocation |
| **Oracle History** | Divination Domain | Drift `oracle_history` (New Table) | `oracleHistoryProvider` (New) | Read roll & blessing log | Append new roll |
| **Active Quest Decree** | Quest Domain | Drift `quest_decrees` (New Table) | `questLifecycleProvider` (New) | Read progress, reward, sector | Purge step, Claim reward |
| **Vessel Telemetry (HP/MP/SP)** | Character Mechanics | Drift `utrcs_characters` (`mechanical`) | `utrcsCharacterProvider` | Read HP, MP, SP values | Heal HP, Channel MP, Allocate |
| **Waygate Telemetry Counts** | Subsystem Domains | Derived from respective tables | Selected from existing providers | Read unread/pending badges | Pure navigation trigger |
| **Sanctuary Social Feed** | Social Domain | Drift `social_posts` & `social_comments` | `socialFeedProvider` | Read post stream | Laurel, Comment, Inscribe, Share |

---

## 6. Persistence Gap Analysis

| Feature | Current State | Current Persistence | Required Persistence | Domain Owner | Gap Classification |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Player Wallet** | Non-existent | None | Drift Table (`player_wallet`) | Economy | **C — New Domain Capability** |
| **Level & XP Progress** | Hardcoded ('88') | None | Drift Table (`player_wallet.xp`) | Progression | **B — Small Extension** |
| **Equipment Vault** | Destructive array | In-Memory only | Drift Table (`equipment_items`) | Equipment | **C — New Domain Capability** |
| **Equipment Upgrades** | Non-existent | None | Drift Column (`upgrade_level`) | Equipment | **B — Small Extension** |
| **Oracle Buff Engine** | Widget string | In-Memory only | In-Memory StateNotifier + SQLite | Divination | **B — Small Extension** |
| **Oracle Chronicle** | Non-existent | None | Drift Table (`oracle_history`) | Divination | **B — Small Extension** |
| **Quest Progress** | Fixed 0.65 float | In-Memory only | Drift Table (`quest_decrees`) | Quest | **B — Small Extension** |
| **Quest Claim Idempotency**| Non-existent | None | Drift Column (`is_claimed`) | Quest | **B — Small Extension** |
| **Vessel Restoration** | Read-only sheet | None | Drift `utrcs_characters` update | Mechanics | **A — Existing Infrastructure** |
| **Waygate Telemetry** | Static strings | None | Derived in-memory from providers | Telemetry | **A — Existing Infrastructure** |
| **Social Comments** | Empty callback | None | Drift Table (`social_comments`) | Social | **C — New Domain Capability** |
| **Social Post Composer**| Non-existent | None | Drift Table (`social_posts`) | Social | **B — Small Extension** |

---

## 7. Dashboard Interaction Architecture

Every interaction on the Dashboard adheres to a strict Command-Query Separation pattern:

```
[DashboardScreen / Sub-Widget]
           │
           │ 1. User Dispatches Action (e.g. Tap "CLAIM REWARD" or "EQUIP")
           ▼
[Domain StateNotifier] (e.g. QuestLifecycleNotifier / EquipmentNotifier)
           │
           │ 2. Validates Business Rules & Preconditions (e.g. Progress == 1.0, Balance >= Cost)
           ▼
[Drift AppDatabase]
           │
           │ 3. Executes Atomic Transaction (e.g. Mark Claimed + Deposit Currency)
           ▼
[Riverpod State Invalidation]
           │
           │ 4. Emits fresh immutable State to subscribers
           ▼
[DashboardScreen Widget Tree]
           │
           │ 5. Smoothly re-renders updated gauges, badges, and buttons
```

Rules:
1. **Zero Direct SQL in UI:** Widgets never reference `_db.into(...)` or raw queries.
2. **Zero Game Logic in UI:** Widgets do not calculate XP curves, stat formulas, or RNG weighting.
3. **Atomic Transactions:** Any multi-table mutation (e.g., deducting Essence while adding an item attribute) must occur inside `_db.transaction(...)`.

---

## 8. Section 1 — Operator Sovereign Crest

### 8.1 Level & XP Progression
* **Current Behavior:** Hardcoded text `'88'`.
* **Target Architecture:**
  1. Progression Formula: $\text{Level} = 1 + \lfloor \sqrt{\text{XP} / 100} \rfloor$. Threshold for next level: $\text{NextXP} = (\text{Level})^2 \times 100$.
  2. Level Dial: Renders dynamic level derived from `playerWalletProvider.select((w) => w.level)`.
  3. Progression Modal: Tapping the Level dial opens the **"Vanguard Sovereign Rank & Progression"** sheet:
     - Current Level & Astral Rank (e.g. *Level 88: High Sovereign Sentinel*).
     - Progress Bar: $\text{XP in current tier} / \text{XP required for next tier}$.
     - Unlocked Sovereign Privileges (e.g. *Access to Sector 4 Sanctum, +10% Escrow Trading Limit*).

### 8.2 Active UTRCS Identity Switching
* **Target Architecture:**
  1. Tapping the circular Avatar Crest displays the **"Sovereign Vessel Manifest"** modal.
  2. Queries all saved characters from `utrcs_characters` table.
  3. Selecting a character calls `ref.read(utrcsCharacterProvider.notifier).switchActiveCharacter(characterId)`.
  4. **Atomic Dependency Cascading:** When active character switches:
     - `playerProfileProvider` updates immediately.
     - Vitality, Aether, and System gauges recalculate based on the new character's `baseStats`.
     - Equipment slots refresh to display the new character's gear.

---

## 9. Section 2 — Equipment & Imperial Vault

### 9.1 The Imperial Relic Vault Flow
To resolve the destructive deletion bug and provide full inventory management:
1. **Empty Slot Tap:**
   - Tapping an empty slot (`item == null`) triggers `ImperialVaultSheet.show(context, slot: slot)`.
   - The Vault queries all unequipped items matching that slot type from `equipmentVaultProvider`.
   - Displays items with rarity borders, stat bonuses, and an **"EQUIP RELIC"** button.
   - Tapping "EQUIP" calls `ref.read(equippedGearProvider.notifier).equipItem(item)`:
     - Moves item to equipped state.
     - Saves state to Drift database.
     - Recalculates player vessel attribute bonuses.
2. **Safe Unequip Flow:**
   - In [`EquipmentDetailSheet`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/equipment_detail_sheet.dart), tapping **"UNEQUIP"**:
     - Does **NOT** delete the item.
     - Returns the item to the Vault inventory list (`isEquipped = false`).
     - Clears the active slot on the Dashboard.
     - Displays a confirmation toast: `"${item.name} returned to Imperial Vault"`.

### 9.2 Relic Infusion & Upgrade System
* In `EquipmentDetailSheet`, add an **"INFUSE AETHER (UPGRADE)"** action:
  - Displays upgrade cost: $50 \times (\text{currentLevel} + 1)$ Essence.
  - Validates player has sufficient Essence via `playerWalletProvider`.
  - Transaction: Deducts Essence from wallet $\rightarrow$ increments item `upgradeLevel` $\rightarrow$ increases stat bonus by $+2$ $\rightarrow$ persists to Drift.
  - If player lacks Essence, button is disabled with tooltip: *"Insufficient Essence (Requires X)"*.

---

## 10. Section 3 — Oracle & Buff Engine

### 10.1 Generic Buff Model
```dart
enum BuffType { aetherMultiplier, questRewardBoost, computeFocus, anomalyTurbulence }

class ActiveBuff {
  final String id;
  final BuffType type;
  final String title;
  final double multiplier;
  final DateTime expiresAt;
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

### 10.2 D20 Outcome Mechanics
* **Natural 20 (Critical Harmonic Consensus):**
  - Grants `BuffType.questRewardBoost` ($+20\%$ rewards for 30 minutes).
  - Instantly restores Aether Reserve to $100\%$.
* **Roll 15–19 (Aether Resonance):**
  - Grants `BuffType.computeFocus` ($+15\%$ Compute Power in terminal chats for 15 minutes).
* **Roll 6–14 (Stable Leyline Equilibrium):**
  - Grants standard blessing flavor text; mild vitality shield buffer ($+2$ temporary shield).
* **Roll 1–5 (Anomaly Turbulence):**
  - Applies a minor anomaly warning (aesthetic screen pulse; prompt to cleanse in Descent).

### 10.3 Oracle Chronicle History
* Every invocation records an entry into `oracle_history` table: `id`, `roll`, `blessing_text`, `timestamp`.
* Tapping the `D20 ORACLE: X` badge opens the **"Chronicle of Celestial Divination"** modal showing past rolls and time remaining on active blessings.

---

## 11. Section 4 — Quest Decree Lifecycle

### 11.1 Quest Ownership & Separation of Concerns
* **The Rule:** Complex dungeon combat and deep lore encounters belong inside **Descent**, not inline on the dashboard card.
* **Dashboard Role:**
  1. **Purge Anomaly Mini-Check:** Tapping a new secondary action **"COMMUNE PURGE"** on the card allows the player to perform an active skill check using their character's `computePower` or `shieldIntegrity`.
     - Success advances anomaly purge progress by $+15\%$ (e.g. $65\% \rightarrow 80\% \rightarrow 95\% \rightarrow 100\%$).
     - Displays brief narrative toast from `LiteRtService`.
  2. **Deep Descent:** Tapping **"DEPART ON QUEST"** routes to `DescentScreen` with the active quest parameters pre-loaded.

### 11.2 Atomic Reward Claiming
* When progress reaches $1.0$ ($100\%$), the button changes to a glowing Warm Terracotta **"CLAIM REWARDS"** button.
* Tapping "CLAIM REWARDS" executes an **idempotent transaction**:
  ```dart
  await _db.transaction(() async {
    final quest = await _db.getQuest(questId);
    if (quest.isClaimed) return; // Prevent double-claim replay
    await _db.markQuestClaimed(questId);
    await _db.depositCurrency(essence: quest.rewardEssence, laurels: quest.rewardLaurels);
    await _db.addExperience(xp: 250);
  });
  ```
* UI plays celebration animation and prompts **"DISPATCH NEXT DECREE"**.

### 11.3 Procedural Decree Dispatcher
* Minimal, deterministic generator creates the next decree based on player rank and sector:
  - Selects sector from OKF repository (e.g. *Sanctuary 4 Spire*, *Neon Bastion*, *Abyssal Rift*).
  - Scales anomaly difficulty ($C \rightarrow B \rightarrow A \rightarrow S$).
  - Calculates rewards scaled to difficulty.

---

## 12. Section 5 — Sovereign Vitality & Alchemical Restoration

### 12.1 Semantic Resource Definitions
* **Vitality (HP) $\rightarrow$ Shield Integrity:** Absorbs physical shock and anomaly strain. Default: $16 / 20$.
* **Aether (MP) $\rightarrow$ Energy Reserve:** Powers active capabilities and cooperative leylines. Default: $18 / 20$.
* **System (SP) $\rightarrow$ Compute Power:** Powers local AI decryptors and governance votes. Default: $14 / 20$.

### 12.2 Alchemical Restoration Engine
In the **"Soul Vessel Attribute Telemetry"** bottom sheet ([`_showVesselAttributesSheet`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart#L22-L96)), replace the static dismiss button with interactive sovereign restoration actions:
1. **"Synthesize Nanite Salve (Restore HP)":**
   - Cost: $15$ Essence.
   - Restores Shield Integrity back to $20/20$.
   - Triggers dynamic fluid fill animation in the Vitality capsule meter.
2. **"Meditate upon Astral Leylines (Restore MP)":**
   - Cost: Free (with a 2-minute cooldown) or $10$ Essence.
   - Restores Energy Reserve back to $20/20$.
3. **"Allocate Attribute Points":**
   - When a player levels up, they receive $+1$ Unallocated Attribute Point.
   - Tapping $+$ next to Vitality, Aether, or System permanently increments the base stat and persists to `utrcs_characters`.

---

## 13. Section 6 — Sovereign Waygate Telemetry

### 13.1 Event-Driven Badging (No Polling)
To prevent battery drain and CPU spikes on the Honor X8, **zero periodic timers** will be introduced. Badges derive reactively from existing Riverpod providers:
1. **Market Waygate (`TradeScreen`):**
   - Badge: Pending trade offers where `receiverId == currentUserId && status == TradeStatus.pending`.
   - Source: `ref.watch(economyProvider.select((s) => s.activeTrades.length))`.
2. **Canon Waygate (`ChronoLoomScreen`):**
   - Badge: Active lore proposals awaiting community votes.
   - Source: `ref.watch(chronoLoomProvider.select((s) => s.activeProposals.length))`.
3. **Squads Waygate (`ExpeditionScreen`):**
   - Badge: Active P2P co-op squad members in the room.
   - Source: `ref.watch(expeditionProvider.select((s) => s.currentSquad?.members.length ?? 0))`.
4. **Sanctuary Chat Waygate (`TerminalScreen`):**
   - Badge: New unread IC roleplay messages since last visit.
5. **Descent Waygate (`DescentScreen`):**
   - Badge: Active sector anomaly threat indicator (*"S-Rank Threat"*).

---

## 14. Section 7 — Sanctuary Bulletin Wall & Community Feed

### 14.1 Scroll Composer ("Inscribe Bulletin")
* Add an **"INSCRIBE SCROLL"** action button in the section header or as a floating astrolabe action.
* Opens the **"Sanctuary Living Bulletin Composer"** modal:
  - Channel selector: **IN-CHARACTER (IC)** vs **OUT-OF-CHARACTER (OOC)**.
  - Text area with character counter ($280$ characters max).
  - Automatically affixes author identity (`playerName`), title (`playerOrigin`), and timestamp.
  - Tapping **"INSCRIBE TO LEYLINES"** calls `ref.read(socialFeedProvider.notifier).createPost(...)`.
  - Appends to feed, saves to Drift SQLite, and shows confirmation toast.

### 14.2 Interactive Comments Modal
* Tapping the **Comment Button** on any `SocialPostCard`:
  - Opens the **"Archival Commentary"** bottom sheet.
  - Displays comment history (author, timestamp, text).
  - Contains an interactive text field: *"Draft communion reply..."*.
  - Submitting appends the comment, increments the post's comment counter, and persists to SQLite.

### 14.3 Functional Clipboard Share
* Tapping the **Share Button**:
  - Formats post into clean Markdown:
    ```markdown
    📜 Remainder Portal — Sanctuary Bulletin
    Author: [Author Name] ([Title]) • [Time]
    Channel: [IC / OOC]
    ---
    "[Post content]"
    ---
    Laurels: [Count] • Comments: [Count]
    ```
  - Copies to Android clipboard via Flutter's built-in `Clipboard.setData(ClipboardData(text: ...))`.
  - Displays a warm parchment snackbar: *"Archival bulletin copied to clipboard!"*.

### 14.4 In-Memory Channel Filtering
* Add a 3-way toggle strip beneath the section header: `ALL`, `IC LORE`, `OOC ARCHIVES`.
* Filters the post list in-memory without database requeries.

---

## 15. Navigation Architecture

```
DashboardScreen
  ├── Tap Level Dial ──────────> Modal: Vanguard Level & Progression Sheet
  ├── Tap Avatar Crest ────────> Modal: Sovereign Vessel Manifest (Character Switcher)
  ├── Tap Empty Gear Slot ─────> Modal: Imperial Relic Vault Gear Picker
  ├── Tap Equipped Relic ──────> Modal: EquipmentDetailSheet (+ Aether Infusion)
  ├── Tap Oracle Badge ────────> Modal: Chronicle of Celestial Divination (History)
  ├── Tap Quest "COMMUNE" ─────> Inline Action: Mini-encounter skill check (+15% progress)
  ├── Tap Quest "DEPART" ──────> Route: DescentScreen (with active quest sector pre-loaded)
  ├── Tap Quest "CLAIM" ───────> Atomic Transaction: Reward payout + celebration dialog
  ├── Tap Telemetry INSPECT ───> Modal: Soul Vessel Telemetry (+ Nanite Salve / Leyline Meditation)
  ├── Tap 6 Waygate Tiles ─────> Direct Routes: Descent, Terminal, Expedition, Guild, ChronoLoom, Trade
  ├── Tap "Inscribe Scroll" ───> Modal: Sanctuary Bulletin Composer Dialog
  ├── Tap Post Comments ───────> Modal: Archival Commentary Sheet
  └── Tap Post Share ──────────> System Action: Clipboard copy + Toast
```

---

## 16. Database & Migration Impact

### Schema Upgrade: Drift Schema Version 4 $\rightarrow$ Version 5

To support full persistence without losing existing character or chat data:

```sql
-- Migration v4 -> v5

-- 1. Player Wallet Table (Currencies & XP)
CREATE TABLE IF NOT EXISTS player_wallet (
  user_id TEXT NOT NULL PRIMARY KEY REFERENCES users (id),
  essence_balance INTEGER NOT NULL DEFAULT 1000,
  laurel_balance INTEGER NOT NULL DEFAULT 150,
  experience_points INTEGER NOT NULL DEFAULT 8800,
  current_level INTEGER NOT NULL DEFAULT 88,
  unallocated_attribute_points INTEGER NOT NULL DEFAULT 0,
  last_updated INTEGER NOT NULL
);

-- 2. Equipment Items Table (Vault & Equipped State)
CREATE TABLE IF NOT EXISTS equipment_items (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id),
  slot TEXT NOT NULL, -- 'WEAPON', 'ARMOR', 'RELIC', 'CHARM'
  name TEXT NOT NULL,
  rarity TEXT NOT NULL, -- 'common', 'rare', 'celestial', 'sovereign'
  stat_bonus TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_code_point INTEGER NOT NULL,
  upgrade_level INTEGER NOT NULL DEFAULT 0,
  is_equipped INTEGER NOT NULL DEFAULT 0,
  acquired_at INTEGER NOT NULL
);

-- 3. Oracle Divination History Table
CREATE TABLE IF NOT EXISTS oracle_history (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id),
  d20_roll INTEGER NOT NULL,
  outcome_tier TEXT NOT NULL,
  blessing_text TEXT NOT NULL,
  buff_granted TEXT,
  timestamp INTEGER NOT NULL
);

-- 4. Quest Decrees Table
CREATE TABLE IF NOT EXISTS quest_decrees (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id),
  title TEXT NOT NULL,
  sector_id TEXT NOT NULL,
  sector_name TEXT NOT NULL,
  decree_text TEXT NOT NULL,
  reward_essence INTEGER NOT NULL,
  reward_laurels INTEGER NOT NULL,
  progress REAL NOT NULL DEFAULT 0.0,
  is_urgent INTEGER NOT NULL DEFAULT 0,
  is_claimed INTEGER NOT NULL DEFAULT 0,
  difficulty TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

-- 5. Social Posts & Comments Tables
CREATE TABLE IF NOT EXISTS social_posts (
  id TEXT NOT NULL PRIMARY KEY,
  author_id TEXT NOT NULL REFERENCES users (id),
  author_name TEXT NOT NULL,
  author_title TEXT NOT NULL,
  avatar_path TEXT NOT NULL,
  content TEXT NOT NULL,
  is_ic INTEGER NOT NULL DEFAULT 1,
  laurels_count INTEGER NOT NULL DEFAULT 0,
  comments_count INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS social_comments (
  id TEXT NOT NULL PRIMARY KEY,
  post_id TEXT NOT NULL REFERENCES social_posts (id),
  author_name TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at INTEGER NOT NULL
);
```

---

## 17. Provider Architecture

Instead of creating a giant monolithic `dashboardProvider`, the architecture introduces clean, domain-scoped Riverpod providers:

```
AppDatabase (Drift Singleton)
     │
     ├── playerWalletProvider (StateNotifierProvider<PlayerWalletNotifier, PlayerWallet>)
     ├── equipmentVaultProvider (StateNotifierProvider<EquipmentVaultNotifier, EquipmentVaultState>)
     ├── questLifecycleProvider (StateNotifierProvider<QuestLifecycleNotifier, QuestLifecycleState>)
     ├── oracleBuffProvider (StateNotifierProvider<OracleBuffNotifier, OracleBuffState>)
     ├── socialFeedProvider (StateNotifierProvider<SocialFeedNotifier, List<SocialPostModel>>)
     └── utrcsCharacterProvider (StateNotifierProvider<UtrcsCharacterNotifier, UtrcsCharacterModel?>)
```

The `DashboardScreen` simply composes these focused providers using fine-grained `.select(...)` expressions to minimize widget rebuilds.

---

## 18. Offline-First Strategy

The Remainder Portal is designed for network-resilient offline operation:
1. **100% Offline Capability:** All 7 interactive features function completely without internet connectivity.
2. **Local WAL SQLite:** All transactions write immediately to the on-device Drift SQLite database with Write-Ahead Logging (`PRAGMA journal_mode=WAL`).
3. **Deterministic Offline Fallbacks:**
   - LiteRT AI story responses use deterministic local D20 rule engine when offline.
   - Procedural quests generate from local OKF sector templates.
4. **SyncLedger Integration:** When network connectivity is restored, mutations queue to `SyncLedger` and sync with cloud Firestore in the background.

---

## 19. Security & Data Integrity

1. **Anti-Replay Reward Guard:** The `is_claimed` column in `quest_decrees` is checked within an atomic database transaction. Tapping "CLAIM" rapidly cannot award multiple payouts.
2. **Negative Balance Prevention:** Currency deductions (for healing, upgrades, or trading) check `balance >= cost` prior to executing. Database columns use `CHECK (essence_balance >= 0)`.
3. **Equipment Duplication Prevention:** An item can only exist either in the equipped state (`is_equipped = 1`) or in the vault (`is_equipped = 0`).
4. **Sanitization:** Social post and comment strings are trimmed and capped at length limits ($280$ chars for posts, $140$ chars for comments) to prevent memory exhaustion.

---

## 20. Performance Budget (Honor X8 Target)

* **Zero Background Polling:** No `Timer.periodic` instances running on the Dashboard.
* **Repaint Boundaries:** Retain `RepaintBoundary` wrappers around the animated Oracle altar and progress rings.
* **Granular Selectors:** Use `ref.watch(playerWalletProvider.select((w) => w.essenceBalance))` so updating currency does not cause the entire 600-line screen to rebuild.
* **Lazy Bottom Sheets:** Modals (Vault, Telemetry, Chronicle, Composer) instantiate their widget subtrees only when opened.

---

## 21. Testing Strategy

### 21.1 Unit & Domain Tests
* Wallet deposit/deduction math and negative balance guards.
* XP-to-Level progression formula and rank tier calculation.
* Equipment equip/unequip state transitions.
* Quest progress clamping ($0.0 \le \text{progress} \le 1.0$) and claim idempotency.

### 21.2 Drift Persistence & Migration Tests
* Verify migration from Schema v4 to Schema v5 preserves existing `utrcs_characters` and `chat_messages`.
* Test rollback behavior if a multi-table transaction encounters an error.

### 21.3 Widget Tests
* Tapping empty equipment slot renders `ImperialVaultSheet`.
* Tapping unequip returns item to vault without deleting.
* Tapping "CLAIM REWARDS" updates wallet display.
* Tapping "INSCRIBE SCROLL" posts to bulletin wall.
* Verify all existing finders in [`test/dashboard_screen_test.dart`](file:///data/data/com.termux/files/home/remainder-portal/test/dashboard_screen_test.dart) remain 100% green.

### 21.4 Patrol Native E2E Tests
* End-to-end journey: Cold boot $\rightarrow$ Tap empty gear slot $\rightarrow$ Equip Shadow Dagger from Vault $\rightarrow$ Commune with Oracle $\rightarrow$ Purge quest anomaly $\rightarrow$ Claim rewards $\rightarrow$ Verify updated currency.

---

## 22. MVP Scope vs. 23. Future Scope

### 22. Required for Interactive Dashboard MVP
1. **Dynamic Operator Level, XP & UTRCS Identity:** Dynamic level dial with Progression sheet; instant UTRCS character switching.
2. **Imperial Relic Vault & Safe Unequip/Equip:** Non-destructive unequip; Vault picker modal for empty slots; reactive stat bonus recalculation.
3. **Interactive Alchemical Restoration:** Functional healing (HP salve) and aether recharge in the telemetry sheet with live fluid gauge animation.
4. **Quest Progress & Idempotent Reward Claiming:** "COMMUNE PURGE" anomaly skill check; atomic reward claim into persistent wallet; deterministic new decree dispatch.
5. **Oracle Buff Engine & Chronicle:** D20 rolls grant real session buffs (e.g. reward multipliers); persistent history modal.
6. **Sanctuary Bulletin Composer & Comments:** "Inscribe Scroll" dialog; comments bottom sheet; functional clipboard share.
7. **Reactive Waygate Telemetry Badges:** Live unread/pending counters on Market, Canon, Squads, and Chat portals.

### 23. Deferred to Future Expansion
* Real-time P2P WebRTC audio/video squad telemetry.
* Cross-device Bluetooth mesh trading.
* Multi-user auction house and automated bidding bots.
* Full generative AI video rendering for oracle prophecies.

---

## 24. File-by-File Implementation Map

| Category | Target File Path | Current Role | Scope of Change | Risk |
| :--- | :--- | :--- | :--- | :---: |
| **Database** | [`lib/data/services/database_service.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/data/services/database_service.dart) | Schema v4, tables, Drift config | Add Schema v5 migration, tables: `player_wallet`, `equipment_items`, `oracle_history`, `quest_decrees`, `social_posts`, `social_comments`. | High |
| **Domain Models** | `lib/data/models/player_wallet.dart` `[NEW]` | None | Create `PlayerWallet` data model. | Low |
| **Domain Models** | `lib/data/models/active_buff.dart` `[NEW]` | None | Create `ActiveBuff` model and `BuffType` enum. | Low |
| **Providers** | `lib/presentation/providers/wallet_provider.dart` `[NEW]` | None | Create `playerWalletProvider` with deposit/deduct methods. | Medium |
| **Providers** | `lib/presentation/providers/equipment_vault_provider.dart` `[NEW]` | None | Create `equipmentVaultProvider` managing unequipped items. | Medium |
| **Providers** | [`lib/presentation/providers/game_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/game_provider.dart) | Static providers | Upgrade `equippedGearProvider`, `activeQuestProvider`, `socialFeedProvider` to persistent notifiers. | High |
| **UI Widgets** | `lib/presentation/widgets/imperial_vault_sheet.dart` `[NEW]` | None | Create bottom sheet to browse and equip vault gear. | Medium |
| **UI Widgets** | `lib/presentation/widgets/bulletin_composer_dialog.dart` `[NEW]` | None | Create dialog to compose new IC/OOC scrolls. | Low |
| **UI Widgets** | `lib/presentation/widgets/post_comments_sheet.dart` `[NEW]` | None | Create bottom sheet for post replies and comments. | Low |
| **UI Widgets** | [`lib/presentation/widgets/equipment_detail_sheet.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/equipment_detail_sheet.dart) | Detail modal | Add Aether Infusion upgrade action; update unequip to return to vault. | Medium |
| **UI Widgets** | [`lib/presentation/widgets/equipment_slots_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/equipment_slots_widget.dart) | 4 gear slots | Wire empty slots to open `ImperialVaultSheet`. | Medium |
| **UI Widgets** | [`lib/presentation/widgets/aether_resonance_oracle_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/aether_resonance_oracle_widget.dart) | D20 altar | Wire roll to `oracleBuffProvider`; open Chronicle modal on badge tap. | Medium |
| **UI Widgets** | [`lib/presentation/widgets/quest_decree_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/quest_decree_widget.dart) | Quest card | Add "COMMUNE PURGE" action and "CLAIM REWARDS" button state. | Medium |
| **UI Widgets** | [`lib/presentation/widgets/social_post_card.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/social_post_card.dart) | Post card | Wire comments button to `PostCommentsSheet`; wire share to clipboard. | Low |
| **Screens** | [`lib/presentation/screens/dashboard_screen.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart) | Master dashboard | Wire level dial, avatar crest, restoration telemetry actions, and waygate badges. | High |
| **Tests** | [`test/dashboard_screen_test.dart`](file:///data/data/com.termux/files/home/remainder-portal/test/dashboard_screen_test.dart) | Widget tests | Add test cases for vault picking, unequip/re-equip, reward claiming, and comments. | Medium |
| **Tests** | `test/wallet_and_quest_test.dart` `[NEW]` | None | Unit tests for wallet transactions and quest idempotency. | Low |

---

## 25. Risk Register

| Risk Description | Severity | Likelihood | Architectural Mitigation |
| :--- | :---: | :---: | :--- |
| **Database Migration Data Loss:** Upgrading to Schema v5 could corrupt or wipe existing UTRCS characters if migration fails. | Critical | Low | Use non-destructive `CREATE TABLE IF NOT EXISTS` migration statements and verify database tests pass before proceeding. |
| **Double-Reward Claiming Exploit:** Rapid tapping on "CLAIM REWARDS" could pay out multiple times before state settles. | High | Medium | Execute claim check inside an atomic SQLite transaction and disable button immediately upon initial tap. |
| **Test Finder Regression:** Renaming labels or restructuring headers could break existing tests in `dashboard_screen_test.dart`. | High | Low | Retain 100% of existing semantic labels and text finders (`'OPERATOR'`, `'LEVEL'`, `'88'`, `'EQUIPMENT & GEAR SLOTS'`, etc.). |
| **Memory / CPU Spikes on Honor X8:** Multiple live telemetry streams causing excessive widget rebuilds. | Medium | Medium | Use strict `.select(...)` provider subscriptions and zero background polling timers. |
| **Floating Navbar Occlusion:** Adding new dashboard cards or modals could alter the 96dp bottom padding. | Medium | Low | Strictly preserve `EdgeInsets.fromLTRB(20, 20, 20, 96)` on the scroll view. |

---

## 26. Implementation Order

To ensure the repository remains continuously buildable and testable at every step:

```
Phase 0: Persistence & Domain Foundations
   ├── 0.1 Add Drift Schema v5 tables (PlayerWallet, EquipmentItems, QuestDecrees, etc.)
   ├── 0.2 Create PlayerWallet and ActiveBuff domain models
   └── 0.3 Verify database migration tests pass cleanly
   ↓
Phase 1: Equipment & Imperial Vault System
   ├── 1.1 Create EquipmentVaultNotifier and ImperialVaultSheet
   ├── 1.2 Update equipment_slots_widget.dart to trigger Vault on empty slots
   ├── 1.3 Update equipment_detail_sheet.dart with safe unequip & Aether Infusion
   └── 1.4 Test equip/unequip roundtrip
   ↓
Phase 2: Quest Lifecycle & Player Wallet
   ├── 2.1 Create QuestLifecycleNotifier with progress mutation & claim transaction
   ├── 2.2 Update quest_decree_widget.dart with Purge action and Claim button
   └── 2.3 Verify atomic reward payout and idempotency
   ↓
Phase 3: Oracle Buff Engine & Vessel Restoration
   ├── 3.1 Implement OracleBuffNotifier and Chronicle history logging
   ├── 3.2 Add alchemical restoration controls (Heal/Channel/Allocate) to telemetry sheet
   └── 3.3 Verify live capsule meter animations
   ↓
Phase 4: Social Bulletin & Waygate Telemetry
   ├── 4.1 Create BulletinComposerDialog and PostCommentsSheet
   ├── 4.2 Wire SocialPostCard comments and clipboard share
   └── 4.3 Add reactive telemetry badges to the 6 Waygate portal cards
   ↓
Phase 5: Full Integration, Regression Tests & CI Verification
   ├── 5.1 Run test suite across all 47+ existing and new test cases
   ├── 5.2 Compile and test on Honor X8 mobile viewport
   └── 5.3 Commit, push to main, and verify GitHub Actions Cloud CI
```

---

## 27. Thread B Execution Contract

Thread B will execute the implementation according to these non-negotiable rules:

1. **Strict File Scope:** Thread B may modify only the files listed in Section 24. If an additional file is genuinely required, Thread B must **STOP and report it** for explicit approval before editing.
2. **Domain Separation:** Dashboard widgets must never write direct database queries or contain combat math; all mutations route through domain notifiers.
3. **Preserve Test Finders:** All existing string finders and semantic labels tested in `dashboard_screen_test.dart` and Patrol E2E tests must remain intact.
4. **Preserve Responsive Layouts:** Zero RenderFlex overflows allowed across Honor X8 ($360\text{dp}$) and narrow ($320\text{dp}$) viewports.
5. **Continuous Verification:** Run tests after completing each phase to guarantee 100% green status before pushing to main.

---

## 28. Final Acceptance Criteria

1. **Identity:** Level dial reflects real wallet level; avatar crest opens UTRCS manifest and switches characters atomically.
2. **Gear:** Tapping an empty slot opens the Imperial Vault; unequipped items return safely to the Vault; equipped items can be upgraded with Essence.
3. **Oracle:** D20 rolls grant active session buffs; roll history is logged and viewable in the Chronicle modal.
4. **Quests:** Decrees can be advanced via purge actions; completed quests pay out Essence and Laurels into the wallet without double-claim glitches; new decrees can be dispatched.
5. **Vitality:** Soul vessel telemetry sheet supports healing HP and channeling MP, with live fluid animation on the capsule meters.
6. **Waygates:** Waygate tiles display live badge counts for pending trades, unread messages, and active squads without polling timers.
7. **Social:** Players can inscribe new scrolls to the bulletin wall, view/post comments, and copy formatted posts to the clipboard.
8. **CI & Tests:** 100% green pass on `flutter test` and GitHub Actions Cloud CI across Android, Windows, Web, and Backend runners.
