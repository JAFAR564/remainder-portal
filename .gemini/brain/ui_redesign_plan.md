# Implementation Plan: Sovereign Social Feed & MMORPG Community Platform

## Goal Description
Expand **The Remainder Portal** to incorporate **Facebook-style social feeds** (player wall posts, status flexes, character art, comments, and reaction badges) and **MMORPG gameplay mechanics** (equipment slots, guild territory maps, market escrow trading, and party raid assembly).

The AI acts as the overarching **System Administrator / World Arbiter** (issuing system quest popups, dungeon alerts, title awards, and GM arbitration).

---

## 🌐 The Dual Social-MMO Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    SOVEREIGN SOCIAL FEED ("FACEBOOK FOR RPs")           │
│   • Player Timeline Posts (Character Lore, Level-Up Flexes, Guild News)  │
│   • Interactive Comments (IC & OOC Threads)                             │
│   • Sovereign Reaction Badges (Gold Laurel, Energy Pulse, Respect)      │
│   • Player Ally Connections & Trust Scores                              │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        LIVE MMORPG GAMEPLAY ENGINE                      │
│   • Character Equipment Slots (Weapons, Armor, Relics, Charms)          │
│   • Guild Territorial Control & Shared Vaults                           │
│   • P2P Market Escrow Trading (Items, Relics, Gold Tokens)              │
│   • Co-op World Boss Raids & Party Alignment                            │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🏛️ Updated Screen & Feature Matrix

| Screen Name | Social ("Facebook") Feature | MMORPG Feature | System Admin AI Integration |
| :--- | :--- | :--- | :--- |
| **`SystemDashboardScreen`** | Player Profile Card, Status Wall Update, Recent Notifications | Level 88, S-Rank Badge, Vitality/Aether/Essence Stat Meters | Holographic Urgent Quest Window ("Sector 4 Anomaly") |
| **`SystemNexusScreen`** | Community Feed, Post Comments, IC/OOC Channel Tabs | Party LFG (Looking For Group), Raid Alerts | System Admin Announcements & d20 Outcome Arbitrations |
| **`SquadMatrixScreen`** | Ally Trust Endorsements, Roster List | Co-op Dungeon Squad Alignment, Synergy Bonuses | Quest Completion & XP / Loot Distribution |
| **`SovereignGuildsScreen`** | Guild Wall, Member Announcements, Guild Ranks | Guild Treasury, Sector Control Map, Vault Management | Guild War Arbitration & Sector Tax Distribution |
| **`CanonNexusScreen`** | Lore Proposals, Democratic Discussion Threads | World Lore Canon Ledger, Historical Timelines | System Canon Verification |
| **`TradeScreen`** | Player Trade Posts & Showcases | P2P Item Escrow, Relic Swapping, Currency Exchange | Trade Fraud Verification & Attestation |

---

## Proposed Code Updates

### [NEW] `lib/presentation/widgets/social_post_card.dart`
- **Facebook-style Social Post Card for Roleplayers:**
  - Author Avatar, Name, Title (*"Shadow Monarch"*), and Timestamp.
  - Post Content (Character lore snippet, level-up flex, or quest victory).
  - Reaction Bar (Gold Laurel count, Comments count, Share button).
  - IC / OOC Badge.

### [NEW] `lib/presentation/widgets/equipment_slots_widget.dart`
- **MMORPG Character Equipment Grid:**
  - Weapon Slot (e.g. *Shadow Monarch Dagger*).
  - Armor Slot (e.g. *Ethereal Aegis Cuirass*).
  - Relic Slot (e.g. *Astrolabe Core*).
  - Charm Slot (e.g. *Ionic Crystal*).

---

## Verification Plan

### Automated Tests
Offload test verification to GitHub Actions Cloud Runner:
```bash
git add .
git commit -m "feat(ui): add Facebook-style social post card and MMORPG equipment grid widgets"
git push
```

### Manual Verification
1. Open **System Dashboard** $\rightarrow$ Verify Player Status Wall & Equipment slots.
2. Open **Nexus Chat / Feed** $\rightarrow$ Inspect Facebook-style social posts, reactions, comments, and IC/OOC tags.
3. Open **Guilds / Trade** $\rightarrow$ Verify MMORPG guild treasury & P2P escrow showcase.
