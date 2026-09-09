# Master Dashboard Celestial Astrolabe Redesign

## 1. Executive Summary

This document defines the architectural blueprint, design system specification, responsive layout strategy, and execution contract for redesigning the **Master Dashboard** in **The Remainder Portal** (`remainder_portal`).

While Phase 4 successfully transformed the [`CharacterDossierScreen`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/character_dossier_screen.dart) into a luxury **Celestial Astrolabe Parchment** interface (utilizing the master 5-color palette, astrolabe glyphs, double-border containers, and tactile decision engines), the primary landing surface—[`DashboardScreen`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart)—remains constructed from generic, flat white cards (`color: Colors.white`). Furthermore, production testing on the primary target mobile device (**Honor X8**, viewport width $\approx 360\text{dp} - 392\text{dp}$) revealed **seven severe horizontal RenderFlex overflow exceptions** across the equipment slots, oracle header, quest progress row, vitality header, community wall header, and social post action bars.

This plan establishes the architecture to:
1. **Unify the Design Language:** Bring the exact celestial astrolabe parchment aesthetic from the Character Dossier to the Dashboard using shared, reusable UI primitives.
2. **Eliminate 100% of RenderFlex Overflows:** Surgically re-engineer every unconstrained horizontal layout with mathematically responsive flex constraints.
3. **Preserve Business Logic & Contracts:** Maintain complete compatibility with all Riverpod providers, SQLite persistence, Patrol E2E tests, and navigation routes.

---

## 2. Current Dashboard Architecture

### 2.1 File & Route Map
- **Primary Screen File:** [`lib/presentation/screens/dashboard_screen.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart)
- **Parent Shell:** [`lib/presentation/screens/main_navigation_shell.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/main_navigation_shell.dart)
- **Navigation Structure:** Hosted as child `0` of an `IndexedStack` inside `MainNavigationShell`, with `extendBody: true` to accommodate the floating [`CelestialBottomNavbar`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/celestial_bottom_navbar.dart).
- **Current Scroll Structure:** `RefreshIndicator` $\rightarrow$ `SingleChildScrollView` (physics: `AlwaysScrollableScrollPhysics`) $\rightarrow$ `Padding(fromLTRB(20, 20, 20, 96))` $\rightarrow$ `Column(crossAxisAlignment: CrossAxisAlignment.start)`. The bottom inset of `96dp` ensures the floating navigation bar does not occlude the final community feed items.

### 2.2 Dependency & State Hierarchy

```
MainNavigationShell (Scaffold, extendBody: true)
  └── IndexedStack (index: 0)
        └── DashboardScreen (ConsumerWidget)
              ├── ref.watch(playerProfileProvider) ──> PlayerProfile (id, name, origin, stats)
              │     └── stats: CharacterSheet (shieldIntegrity, energyReserve, computePower)
              ├── ref.watch(socialFeedProvider) ─────> List<SocialPostModel> (laurels, comments, IC/OOC)
              │
              ├── Section 1: Operator Sovereign Crest (InkWell -> CharacterDossierScreen)
              ├── Section 2: EquipmentSlotsWidget
              │     └── ref.watch(equippedGearProvider) ──> List<EquippedGearItem> (slot, rarity, stats)
              │           └── Tap -> EquipmentDetailSheet.show(context, item)
              ├── Section 3: AetherResonanceOracleWidget (StatefulWidget)
              │     └── _communeWithArbiter() -> Random D20 roll + blessing string
              ├── Section 4: QuestDecreeWidget
              │     └── ref.watch(activeQuestProvider) ───> ActiveQuestModel (progress, reward, sector)
              │           └── Tap -> Navigator.push(DescentScreen)
              ├── Section 5: Stat Gauges (HP, MP, SP)
              │     └── Tap -> _showVesselAttributesSheet(context, vitality, aether, essence)
              ├── Section 6: Sovereign Realms Grid (GridView.count via LayoutBuilder)
              │     ├── DescentScreen
              │     ├── TerminalScreen (Sanctuary Chat)
              │     ├── ExpeditionScreen (Squads)
              │     ├── GuildScreen
              │     ├── ChronoLoomScreen (Canon Lore)
              │     └── TradeScreen (Market)
              └── Section 7: Community Wall Feed
                    └── ListView / mapped children ──> SocialPostCard (StatefulWidget)
```

---

## 3. Character Dossier Design-System Audit

The upgraded Character Dossier ([`CharacterDossierScreen`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/character_dossier_screen.dart)) and its newly implemented subcomponents ([`want_vs_need_scale_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/want_vs_need_scale_widget.dart), [`capability_anatomy_card.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/capability_anatomy_card.dart), [`cognitive_loop_timeline_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/cognitive_loop_timeline_widget.dart), [`voice_register_player_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/voice_register_player_widget.dart)) establish the verified visual benchmark.

### 3.1 Verified Visual Elements
1. **Parchment Card Surfaces:** Replaced cold `#FFFFFF` with warm parchment tones: `const Color(0xFFFAF7F0)` for primary elevated cards and Frosted Cream `const Color(0xFFE1D4C2).withValues(alpha: 0.45)` for inner indented panels.
2. **Double-Border Astrolabe Construction:** Outer border with Warm Terracotta (`0xFF6E473B`) or Almond Taupe (`0xFFA78D78`) at `1.6dp - 1.8dp`, paired with subtle inner container borders at `1.0dp`.
3. **Corner Glyphs & Astrolabe Motifs:** Use of Unicode astral markers (`✦ `, `⟐ `, `◈ `) in section headings and dialog titles.
4. **Typography Hierarchy:**
   - Primary Titles & Screen Headers: `fontFamily: 'serif'`, `fontWeight: FontWeight.bold`, color `0xFF6E473B`, uppercase with letter-spacing `1.2` to `1.5`.
   - Technical Metadata, Badges, & Roll Tags: `fontFamily: 'monospace'`, `fontSize: 8` to `10`, `fontWeight: FontWeight.bold`.
   - Body & Narrative Prose: Inter / system default, `fontSize: 11` to `13`, color `0xFF291C0E` (Deep Espresso), height `1.35` to `1.4`.
5. **Elevation & Shadow Language:** Soft, ambient warm shadows: `BoxShadow(color: Color(0xFF6E473B).withValues(alpha: 0.12 - 0.16), blurRadius: 12 - 16, offset: Offset(0, 4))`.

---

## 4. Canonical Design Tokens

The repository defines its master tokens in [`lib/app/theme/portal_theme.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/app/theme/portal_theme.dart). The Character Dossier and Phase 4 enhancements refined these into an ancient sovereign manuscript system.

### 4.1 Color Palette Truth Table

| Token Name | Hex Code | Verified Canonical Role |
| :--- | :--- | :--- |
| **Canvas Background** | `#E1D4C2` | Scaffold background (`PortalTheme.cream`). |
| **Parchment Surface** | `#FAF7F0` | Elevated card & dialog background (`Warm Parchment`). |
| **Parchment Sub-Surface** | `#E1D4C2` (35–50% alpha) | Indented quote boxes, progress track wells, relic pedestals. |
| **Deep Espresso** | `#291C0E` | Primary body text, high-contrast values, dark structural borders. |
| **Warm Terracotta** | `#6E473B` | Primary headings, active borders, buttons, glyphs, sovereign badges. |
| **Almond Taupe** | `#A78D78` | Secondary borders, unselected tabs, subtitle metadata, stat labels. |
| **Cashmere Stone** | `#BEB5A9` | Unfilled progress tracks, dividers, disabled states. |
| **Aether Teal (Relic)** | `#007791` | Verified relic rarity token in `EquipmentRarity.rare` and astral widgets. |

### 4.2 Spacing & Geometry Tokens
- **Outer Screen Margin:** `20.0dp` horizontal, `20.0dp` top, `96.0dp` bottom.
- **Card Padding:** `16.0dp` standard, `12.0dp` compact.
- **Card Corner Radius:** `BorderRadius.circular(16.0)`.
- **Inner Pill Radius:** `BorderRadius.circular(6.0 - 8.0)`.
- **Standard Border Width:** `1.6dp - 1.8dp` (outer), `1.0dp` (inner).
- **Minimum Interactive Touch Target:** `44.0dp x 44.0dp` (WCAG 2.1 AA compliant).

---

## 5. Dashboard Section Inventory

The Dashboard consists of seven distinct operational sections:

| # | Section Name | Source Widget / Location | Backing Model / Provider | Primary Interaction |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Operator Sovereign Crest** | `dashboard_screen.dart:140-254` | `playerProfileProvider` (`PlayerProfile`) | Tap opens `CharacterDossierScreen`. |
| **2** | **Equipment Relic Pedestals** | `equipment_slots_widget.dart` | `equippedGearProvider` (`EquippedGearItem`) | Tap slot opens `EquipmentDetailSheet`. |
| **3** | **Aether Resonance Oracle** | `aether_resonance_oracle_widget.dart` | Local RNG + D20 state | Tap rolls D20, updates blessing. |
| **4** | **World Arbiter Quest Decree** | `quest_decree_widget.dart` | `activeQuestProvider` (`ActiveQuestModel`) | Tap CTA navigates to `DescentScreen`. |
| **5** | **Sovereign Vitality & Essence** | `dashboard_screen.dart:270-342` | `profile.stats` (`CharacterSheet`) | Tap tile/inspect opens Telemetry sheet. |
| **6** | **Sovereign Realms Grid** | `dashboard_screen.dart:345-422` | Static routing table | Tap routes to 6 subsystem screens. |
| **7** | **Sanctuary Bulletin Wall** | `dashboard_screen.dart:425-455` & `social_post_card.dart` | `socialFeedProvider` (`SocialPostModel`) | Tap laurel increments count; pull-to-refresh. |

---

## 6. Responsive / RenderFlex Root-Cause Audit

Physical testing on the **Honor X8** captured in `Screenshot_20260909_194811_com_remainder_portal_remainder_portal_MainActivity.jpg` verified seven exact horizontal overflow failures.

```
Honor X8 Screen Width: ~360dp - 392dp
Outer Dashboard Padding: 20dp left + 20dp right = 40dp
Usable Content Canvas: ~320dp - 352dp
```

### 6.1 Defect 1: Equipment Slots Pedestal Row (`2.7px overflow`)
* **Location:** [`lib/presentation/widgets/equipment_slots_widget.dart:77-87`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/equipment_slots_widget.dart#L77-L87)
* **Code:** `Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: standardSlots.map((slot) => _buildSlot(...)).toList())`
* **Constraint Failure:** Each `_buildSlot` contains an unconstrained `Column` with a 50x50 box and `Text(item?.name ?? 'Empty')`. Because `item.name` (e.g. `"Astrolabe Core"`, `"Ionic Crystal"`) has intrinsic width without flex constraints, the 4 columns sum to $\approx 322.7\text{dp}$.
* **Root-Cause Architectural Fix:** Rather than forcing four slots into a single cramped row (which yields only $\approx 73\text{dp}$ per slot on a $320\text{dp}$ canvas and severely compresses visual luxury), implement a responsive layout strategy using [`LayoutBuilder`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/equipment_slots_widget.dart):
  - **Compact Mobile Viewports ($< 340\text{dp}$ inner width, e.g. Honor X8):** Reflow the four slots into an elegant $2 \times 2$ grid (using a responsive 2-column `Wrap` or grid layout). Each relic pedestal gains generous width ($\approx 135 - 145\text{dp}$) allowing the slot category, rarity frame, icon, and item name to render with breathing room and tactile prestige.
  - **Standard & Wide Viewports ($\ge 340\text{dp}$ inner width):** Render all 4 slots in a single row where each slot is safely flex-bounded via `Expanded` with `TextOverflow.ellipsis`.

### 6.2 Defect 2: Aether Resonance Oracle Header (`37px overflow`)
* **Location:** [`lib/presentation/widgets/aether_resonance_oracle_widget.dart:59-95`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/aether_resonance_oracle_widget.dart#L59-L95)
* **Code:** `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(...), SizedBox(width: 8), Text('AETHER RESONANCE ORACLE')]), Container(child: Text('D20 ORACLE: $_lastRoll'))])`
* **Constraint Failure:** The title `Row` has unbounded width. Total width needed = $18\text{px (icon)} + 8\text{px} + 225\text{px (text)} + 95\text{px (badge)} + 32\text{px (card padding)} = 378\text{px} > 320\text{px}$.
* **Root-Cause Architectural Fix:** Wrap the title `Row` in `Expanded`, and wrap the `Text('AETHER RESONANCE ORACLE')` in `Expanded(child: Text(..., overflow: TextOverflow.ellipsis))`.

### 6.3 Defect 3: World Arbiter Quest Target Sector Row (`49px overflow`)
* **Location:** [`lib/presentation/widgets/quest_decree_widget.dart:109-130`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/quest_decree_widget.dart#L109-L130)
* **Code:** `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TARGET SECTOR: ${quest.sectorName.toUpperCase()}'), Text('${(quest.progress * 100).toStringAsFixed(0)}% ANOMALY PURGED')])`
* **Constraint Failure:** Sector name `"SANCTUARY 4 (AETHER SPIRE)"` is 34 characters long. Combined with `"65% ANOMALY PURGED"` (19 chars), the row requires $369\text{px} > 320\text{px}$.
* **Root-Cause Architectural Fix:** Wrap `Text('TARGET SECTOR: ...')` in `Expanded(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))`. Keep the percentage badge fixed on the trailing side.

### 6.4 Defect 4: Sovereign Vitality Header Row (`24px overflow`)
* **Location:** [`lib/presentation/screens/dashboard_screen.dart:270-300`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart#L270-L300)
* **Code:** `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('SOVEREIGN VITALITY & ESSENCE GAUGES', style: TextStyle(letterSpacing: 1.2)), InkWell(child: Text('INSPECT ℹ'))])`
* **Constraint Failure:** 35-character heading with letter-spacing $1.2$ requires $288\text{px}$. `INSPECT ℹ` requires $60\text{px}$. Sum = $348\text{px} > 320\text{px}$.
* **Root-Cause Architectural Fix:** Wrap the section title in `Expanded(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))`.

### 6.5 Defect 5: Community Wall Feed Header Row (`57px overflow`)
* **Location:** [`lib/presentation/screens/dashboard_screen.dart:426-450`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart#L426-L450)
* **Code:** `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('SOVEREIGN COMMUNITY WALL & NEWS FEED', style: TextStyle(letterSpacing: 1.5)), Text('${socialPosts.length} POSTS')])`
* **Constraint Failure:** 37-character title with letter-spacing $1.5$ requires $325\text{px}$. Adding trailing text yields $377\text{px} > 320\text{px}$.
* **Root-Cause Architectural Fix:** Wrap the title in `Expanded(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))`.

### 6.6 Defect 6 & 7: Social Post Reaction Bar (`15px & 22px overflow`)
* **Location:** [`lib/presentation/widgets/social_post_card.dart:176-235`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/social_post_card.dart#L176-L235)
* **Code:** `Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [InkWell(child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), ...)), ...])`
* **Constraint Failure:** 3 buttons with $12\text{px}$ horizontal padding on each side consumes $72\text{px}$ in padding alone. Post 1 (`"7 COMMENTS"`) overflows by $15\text{px}$. Post 2 (`"12 COMMENTS"`) overflows by $22\text{px}$.
* **Root-Cause Architectural Fix:** Wrap each of the 3 action buttons in an [`Expanded`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/social_post_card.dart) widget, reduce button horizontal padding to $4\text{px}$, and wrap the text in `Flexible(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))`.

---

## 7. Proposed Component Architecture

To prevent code duplication and guarantee strict visual parity between the Dossier and Dashboard, Thread B will introduce **two shared design primitives** into `lib/presentation/widgets/`:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      SHARED DESIGN PRIMITIVES                          │
├────────────────────────────────────────────────────────────────────────┤
│ 1. [CelestialPanel] Reusable double-border parchment card container    │
│ 2. [AstrolabeSectionHeader] Reusable responsive section header row     │
└────────────────────────────────────────────────────────────────────────┘
```

### 7.1 Primitive 1: `CelestialPanel`
* **File:** [`lib/presentation/widgets/celestial_panel.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/celestial_panel.dart) `[NEW]`
* **Purpose:** Provides the canonical parchment container for all Dashboard sections.
* **API:**
  ```dart
  class CelestialPanel extends StatelessWidget {
    final Widget child;
    final EdgeInsetsGeometry padding;
    final EdgeInsetsGeometry? margin;
    final VoidCallback? onTap;
    final Color backgroundColor;
    final Color borderColor;
    final double borderWidth;
    final bool showAstrolabeCorners;
    
    const CelestialPanel({
      super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16.0),
      this.margin,
      this.onTap,
      this.backgroundColor = const Color(0xFFFAF7F0),
      this.borderColor = const Color(0xFFA78D78),
      this.borderWidth = 1.6,
      this.showAstrolabeCorners = false,
    });
  }
  ```
* **Styling:**
  - Background: `0xFFFAF7F0` (Warm Parchment).
  - Outer border: `Border.all(color: borderColor, width: borderWidth)`.
  - Corner radius: `BorderRadius.circular(16.0)`.
  - Ambient shadow: `BoxShadow(color: Color(0xFF6E473B).withValues(alpha: 0.12), blurRadius: 14, offset: Offset(0, 4))`.
  - Optional `InkWell` wrapper if `onTap` is provided.

### 7.2 Primitive 2: `AstrolabeSectionHeader`
* **File:** [`lib/presentation/widgets/astrolabe_section_header.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/astrolabe_section_header.dart) `[NEW]`
* **Purpose:** Standardizes all section headers across the app with guaranteed flex safety.
* **API:**
  ```dart
  class AstrolabeSectionHeader extends StatelessWidget {
    final String title;
    final String glyph;
    final Widget? trailing;
    final double letterSpacing;
    
    const AstrolabeSectionHeader({
      super.key,
      required this.title,
      this.glyph = '✦',
      this.trailing,
      this.letterSpacing = 1.2,
    });
  }
  ```
* **Styling & Responsive Rules:**
  - Structure: `Row(children: [Text('$glyph '), Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false)), if (trailing != null) trailing!])`.
  - Responsive Constraint Note: While `Expanded` restricts the title widget to the remaining parent flex width, proper defensive text parameters (`maxLines: 1`, `overflow: TextOverflow.ellipsis`, `softWrap: false`) and safe min-content handling are explicitly required to prevent typography and unbreakable token overflow.
  - Typography: `fontFamily: 'serif'`, `fontSize: 12`, `fontWeight: FontWeight.bold`, color: `0xFF6E473B`.

---

## 8. Section-by-Section Implementation Plan

### 8.1 Operator Sovereign Crest
* **Target File:** [`lib/presentation/screens/dashboard_screen.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart)
* **Changes:**
  1. Wrap in `CelestialPanel(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterDossierScreen())))`.
  2. Avatar Frame: Upgrade circular container with dual-ring terracotta-taupe borders (`width: 2.0`) and subtle astrolabe radial glow.
  3. Title Area: Add `'✦ '` glyph prefix, serif typography (`fontSize: 15`, `color: Color(0xFF6E473B)`), and S-Rank Vanguard brass seal subtitle.
  4. Level Badge: Style as an **Astrolabe Dial** with concentric circular rings, `LEVEL` in monospace (`fontSize: 8`, `color: Color(0xFF6E473B)`), and `'88'` in bold serif (`fontSize: 16`, `color: Color(0xFF291C0E)`).
* **Preserved:** All semantics labels (`Semantics(label: ...)`), navigation callback to `CharacterDossierScreen`, and string assertions for tests (`OPERATOR`, `LEVEL`, `88`).

### 8.2 Equipment Relic Pedestals
* **Target File:** [`lib/presentation/widgets/equipment_slots_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/equipment_slots_widget.dart)
* **Changes:**
  1. Wrap outer card in `CelestialPanel`.
  2. Replace header with `AstrolabeSectionHeader(title: 'EQUIPMENT & GEAR SLOTS', glyph: '⟐', trailing: Text('${gearList.length}/4 EQUIPPED'))`.
  3. Implement responsive layout via `LayoutBuilder`:
     - **Compact Viewports ($< 340\text{dp}$, e.g. Honor X8):** Render a responsive $2 \times 2$ grid (using a 2-column `Wrap` or two paired rows) with $8\text{dp}$ padding/spacing. Each slot receives $\approx 135 - 145\text{dp}$ of width, giving full breathing room for the slot name (`WEAPON`, `ARMOR`, etc.), rarity aura, icon, and item name without visual cramping.
     - **Standard Viewports ($\ge 340\text{dp}$):** Render 4 slots in a single `Row` with each wrapped in `Expanded`.
  4. Pedestal Styling: 
     - Rarity frames: Sovereign (Terracotta `#6E473B`), Celestial (Taupe `#A78D78`), Relic (Teal `#007791`), Common (Cashmere `#BEB5A9`).
     - Indented pedestal well: `Color(0xFFE1D4C2).withValues(alpha: 0.4)`.
     - Item name label: `maxLines: 1, overflow: TextOverflow.ellipsis`.
* **Preserved:** `equippedGearProvider` subscription, `EquipmentDetailSheet.show(context, item)` tap callback, and slot labels (`WEAPON`, `ARMOR`, `RELIC`, `CHARM`).

### 8.3 Aether Resonance Oracle
* **Target File:** [`lib/presentation/widgets/aether_resonance_oracle_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/aether_resonance_oracle_widget.dart)
* **Changes:**
  1. Wrap outer card in `CelestialPanel`.
  2. Header: Replace unconstrained `Row` with `Row(children: [const Icon(Icons.auto_awesome, color: Color(0xFF6E473B), size: 16), const SizedBox(width: 8), Expanded(child: Text('AETHER RESONANCE ORACLE', ...)), Container(child: Text('D20 ORACLE: $_lastRoll'))])`.
  3. Prophecy Scroll: Indent container with Frosted Cream parchment fill (`0xFFE1D4C2`, alpha 0.45), border `0xFFA78D78`, and quotation marks (`“$_divineBlessing”`) in italic serif font.
  4. CTA Button: Style `ElevatedButton` with Warm Terracotta background (`#6E473B`), Frosted Cream text (`#E1D4C2`), and embossed double border.
* **Preserved:** `_communeWithArbiter()` RNG logic, `_lastRoll` state, and button text `'COMMUNE WITH WORLD ARBITER (ROLL D20)'`.

### 8.4 World Arbiter Quest Decree
* **Target File:** [`lib/presentation/widgets/quest_decree_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/quest_decree_widget.dart)
* **Changes:**
  1. Wrap outer container in `CelestialPanel`.
  2. Header Row: Ensure `Expanded(child: Text('WORLD ARBITER QUEST DECREE', ...))` preserves room for `URGENT` and `S-RANK` badges.
  3. Target Sector Row: Wrap `Text('TARGET SECTOR: ...')` in `Expanded(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))` so long sector names never overflow.
  4. Anomaly Purge Track: Custom animated celestial track using Cashmere track background and Warm Terracotta fill.
  5. Reward Chips: Style as antique minted medallions (`+750 ESSENCE`, `+50 LAURELS`).
* **Preserved:** `activeQuestProvider` watch, `Navigator.push(context, MaterialPageRoute(builder: (_) => const DescentScreen()))`, and all text assertions.

### 8.5 Sovereign Vitality & Essence Gauges
* **Target File:** [`lib/presentation/screens/dashboard_screen.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart)
* **Changes:**
  1. Replace custom title row with:
     ```dart
     AstrolabeSectionHeader(
       title: 'SOVEREIGN VITALITY & ESSENCE GAUGES',
       trailing: InkWell(
         onTap: () => _showVesselAttributesSheet(context, vitality: vitality, aether: aether, essence: essence),
         child: const Padding(
           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
           child: Text('INSPECT ℹ', style: TextStyle(...)),
         ),
       ),
     )
     ```
  2. Stat Tiles: Refactor `_buildAnimatedStatTile` into **Alchemical Capsule Meters**:
     - Capsule border (`#A78D78`, `width: 1.5`), parchment fill (`#FAF7F0`).
     - Animated liquid level indicator.
     - Numeric readout: `$vitality / 20`, `$aether / 20`, `$essence / 20`.
     - Label with `maxLines: 1, overflow: TextOverflow.ellipsis`.
* **Preserved:** Backing fields `profile.stats.shieldIntegrity`, `energyReserve`, `computePower`, and telemetry bottom sheet modal.

### 8.6 Sovereign Realms & Communion Hubs
* **Target File:** [`lib/presentation/screens/dashboard_screen.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart)
* **Changes:**
  1. Replace title with `AstrolabeSectionHeader(title: 'SOVEREIGN REALMS & COMMUNION HUBS')`.
  2. Subsystem Cards: Restyle `_buildSubsystemCard` as **Celestial Waygate Portals**:
     - Background: `const Color(0xFFFAF7F0)` with dual borders (`#A78D78`, `1.4dp`).
     - Corner astrolabe tick marks.
     - Centered icon with glowing circular aura.
     - Prominent serif title + monospace roleplay subtitle.
* **Preserved:** Navigation routes to `DescentScreen`, `TerminalScreen`, `ExpeditionScreen`, `GuildScreen`, `ChronoLoomScreen`, and `TradeScreen`.

### 8.7 Sanctuary Bulletin Wall
* **Target File:** [`lib/presentation/widgets/social_post_card.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/social_post_card.dart) & [`lib/presentation/screens/dashboard_screen.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/dashboard_screen.dart)
* **Changes:**
  1. Header on Dashboard: Replace with `AstrolabeSectionHeader(title: 'SOVEREIGN COMMUNITY WALL & NEWS FEED', trailing: Text('${socialPosts.length} POSTS', ...))`.
  2. Card Container: Wrap in `CelestialPanel`.
  3. IC/OOC Badge: IC posts receive Warm Terracotta wax-seal badge (`#6E473B`); OOC posts receive Almond Taupe archival badge (`#A78D78`).
  4. Reaction Action Bar:
     - Wrap each button in `Expanded(child: InkWell(...))`.
     - Set button padding to `EdgeInsets.symmetric(horizontal: 4, vertical: 6)`.
     - Wrap button labels in `Flexible(child: Text('$_laurels LAURELS', maxLines: 1, overflow: TextOverflow.ellipsis))`.
* **Preserved:** `_toggleLaurel()` state logic, `_hasLaureled`, `_laurels`, `_comments`, and feed refresh capability.

---

## 9. Responsive Breakpoint Strategy

The redesign supports four standardized viewport classes without layout breakage:

```
┌────────────────────────┬───────────────────┬──────────────────────────────────────┐
│ VIEWPORT CLASS         │ WIDTH (dp)        │ ADAPTIVE BEHAVIOR                    │
├────────────────────────┼───────────────────┼──────────────────────────────────────┤
│ 1. Compact Mobile      │ < 360dp           │ 2-col Waygates grid, compact padding │
│ 2. Standard Mobile     │ 360dp – 480dp     │ 3-col Waygates grid (Honor X8 target)│
│ 3. Tablet / Foldable   │ 481dp – 768dp     │ 3-col Waygates grid, wider pedestals │
│ 4. Desktop / Web       │ > 768dp           │ 6-col Waygates grid, max content 900 │
└────────────────────────┴───────────────────┴──────────────────────────────────────┘
```

### Key Breakpoint Adaptations
- **Waygates Grid:** `final int crossAxisCount = width > 768 ? 6 : (width < 340 ? 2 : 3);`
- **Equipment Slots:** Always 4 slots side-by-side using flex `Expanded(child: ...)`; minimum card width per slot = $\approx 65\text{dp}$ on a $320\text{dp}$ canvas.
- **Desktop Content Centering:** Outer `ConstrainedBox(constraints: BoxConstraints(maxWidth: 900))` prevents excessive stretching on Windows Desktop and Web runners.

---

## 10. Scroll Architecture

- **Root Structure:** Retains `SingleChildScrollView` wrapped in `RefreshIndicator`.
- **Nested Scroll Physics:**
  - The Waygates grid uses `physics: const NeverScrollableScrollPhysics(), shrinkWrap: true`.
  - The Community feed maps `socialPosts.map((post) => SocialPostCard(...)).toList()` directly into the parent `Column` rather than nesting a second unbounded `ListView`.
- **Bottom Inset Safety:** Preserves `EdgeInsets.fromLTRB(20, 20, 20, 96)` to eliminate collision with the floating `CelestialBottomNavbar`.

---

## 11. State / Business Logic Preservation

The redesign is strictly presentation-tier. **Zero changes** will be made to domain models, data repositories, or state notifiers:

| State Entity | Source File | Contract Requirement |
| :--- | :--- | :--- |
| `PlayerProfileNotifier` | [`game_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/game_provider.dart) | Read-only consumption of profile name, origin, and 3 stat attributes. |
| `EquippedGearNotifier` | [`game_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/game_provider.dart) | Read-only consumption of 4 items; `unequipItem()` preserved. |
| `activeQuestProvider` | [`game_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/game_provider.dart) | Read-only consumption of quest title, progress, rewards, sector. |
| `SocialFeedNotifier` | [`game_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/game_provider.dart) | `refreshFeed()` called on pull-to-refresh; post models preserved. |
| `D20 Oracle Logic` | [`aether_resonance_oracle_widget.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/widgets/aether_resonance_oracle_widget.dart) | 400ms delay, `math.Random` roll, and 5 divine blessing strings preserved. |

---

## 12. Accessibility

1. **Semantic Hierarchy:** All interactive cards preserve `Semantics(button: true, label: ...)` tags.
2. **Astrolabe Glyphs:** Decorative astral glyphs (`✦`, `⟐`) are styled purely within text spans or wrapped in `ExcludeSemantics` to prevent screen reader noise.
3. **Contrast Compliance:** All text pairings meet WCAG 2.1 AA ($4.5:1$ minimum ratio):
   - Deep Espresso (`#291C0E`) on Warm Parchment (`#FAF7F0`): **$13.2:1$** (Passes AAA).
   - Warm Terracotta (`#6E473B`) on Warm Parchment (`#FAF7F0`): **$5.8:1$** (Passes AA).
4. **Touch Target Dimensions:** All buttons, waygate tiles, and equipment slots maintain at least $48\text{dp} \times 48\text{dp}$ tappable bounding boxes.

---

## 13. Performance

1. **Repaint Boundaries:** Wrap the animated liquid gauges and Aether Resonance Oracle in `RepaintBoundary` to isolate canvas repaints from the rest of the scroll view.
2. **Shadow Budget:** Restrict box shadows to a single blur pass per card: `blurRadius: 12.0 - 14.0`, spread: `0`, eliminating expensive multi-layer gaussian blur passes on low-power Mali GPUs (Honor X8).
3. **Zero Shader Mask / BackdropFilter:** Pure CSS-style container decoration; no real-time blurs or expensive image blend modes.

---

## 14. Testing Strategy

### 14.1 Existing Test Suite Preservation
All 4 existing widget tests in [`test/dashboard_screen_test.dart`](file:///data/data/com.termux/files/home/remainder-portal/test/dashboard_screen_test.dart) must pass without modification:
1. `renders all core dashboard components and interactive widgets`
2. `tapping equipment slot opens EquipmentDetailSheet modal`
3. `tapping INSPECT opens vessel telemetry attributes sheet`
4. Patrol E2E assertions (`SOVEREIGN VITALITY & ESSENCE GAUGES`).

### 14.2 New Responsive & Overflow Verification Tests
Add targeted responsive widget tests in `test/dashboard_screen_test.dart`:
- **Honor X8 Viewport Test ($360\text{dp} \times 800\text{dp}$):** Pump `DashboardScreen` at $360\text{dp}$ width and verify `tester.takeException()` returns `null` (zero `FlutterError` or `RenderFlex` overflows).
- **Narrow Viewport Test ($320\text{dp} \times 640\text{dp}$):** Verify extreme narrow constraint does not throw horizontal overflow exceptions.
- **Equipment Slots Expanded Test:** Verify all 4 gear slot names render without clipping.
- **Reaction Bar Flex Test:** Verify social post action bar with double-digit comments (`"99 COMMENTS"`) does not overflow.

---

## 15. Visual Acceptance Criteria

- [ ] **Zero Yellow/Black RenderFlex Overflows:** Confirmed across $320\text{dp}$, $360\text{dp}$ (Honor X8), $392\text{dp}$, and $768\text{dp}$ widths.
- [ ] **Parchment Harmony:** Dashboard cards match the warm parchment (`#FAF7F0`) aesthetic of `CharacterDossierScreen`.
- [ ] **Typography Alignment:** All section titles use serif typography with uppercase styling and astrolabe glyph prefixes.
- [ ] **Interactive Integrity:** Tapping the header opens `CharacterDossierScreen`; tapping gear opens `EquipmentDetailSheet`; tapping Oracle rolls D20; tapping Quest navigates to `DescentScreen`.
- [ ] **Cloud CI Pass:** Android, Windows, Web, and Backend runners pass 100% in GitHub Actions.

---

## 16. Risk Register

| # | Risk | Severity | Likelihood | Mitigation Strategy | Verification Method |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **R1** | `TextOverflow.ellipsis` clips critical quest or sector names | Medium | Low | Use `Expanded` with flexible text and keep essential tags on trailing edges. | Honor X8 widget test. |
| **R2** | Equipment slots become too narrow on < 340dp screens | Medium | Low | Ensure icon size ($22\text{dp}$) and slot padding scale dynamically; font size $8\text{dp}$. | $320\text{dp}$ test viewport. |
| **R3** | Existing test finders break due to widget restructuring | High | Low | Retain exact text tokens (`'OPERATOR'`, `'LEVEL'`, `'88'`, `'EQUIPMENT & GEAR SLOTS'`, etc.). | Run `flutter test test/dashboard_screen_test.dart`. |
| **R4** | Floating navbar overlaps bottom community posts | High | Very Low | Preserve `96dp` bottom scroll view padding in `DashboardScreen`. | Scroll to bottom test. |
| **R5** | Repaint thrashing during Oracle d20 roll animation | Low | Low | Isolate Oracle widget inside a `RepaintBoundary`. | Flutter performance profile. |

---

## 17. File-by-File Change Map

```
┌────────────────────────────────────────────────────────────────────────┐
│                        FILE-BY-FILE CHANGE MAP                         │
├────────────────────────────────────────────────────────────────────────┤
│ 1. [NEW] lib/presentation/widgets/celestial_panel.dart                 │
│ 2. [NEW] lib/presentation/widgets/astrolabe_section_header.dart        │
│ 3. [MODIFY] lib/presentation/widgets/equipment_slots_widget.dart       │
│ 4. [MODIFY] lib/presentation/widgets/aether_resonance_oracle_widget.dart│
│ 5. [MODIFY] lib/presentation/widgets/quest_decree_widget.dart          │
│ 6. [MODIFY] lib/presentation/widgets/social_post_card.dart             │
│ 7. [MODIFY] lib/presentation/screens/dashboard_screen.dart             │
│ 8. [MODIFY] test/dashboard_screen_test.dart                            │
└────────────────────────────────────────────────────────────────────────┘
```

### 1. `lib/presentation/widgets/celestial_panel.dart` `[NEW]`
- **Responsibility:** Reusable parchment card container.
- **Changes:** Create component implementing double-border parchment styling (`0xFFFAF7F0`, `0xFFA78D78`, `0xFF6E473B`).
- **Must Preserve:** Pure presentation; no state.
- **Risk:** Low.

### 2. `lib/presentation/widgets/astrolabe_section_header.dart` `[NEW]`
- **Responsibility:** Standardized responsive section header row.
- **Changes:** Create component with glyph prefix, serif title in `Expanded`, and optional trailing widget.
- **Must Preserve:** Text string matching for test finders.
- **Risk:** Low.

### 3. `lib/presentation/widgets/equipment_slots_widget.dart` `[MODIFY]`
- **Responsibility:** Equipment slots card.
- **Changes:** Use `CelestialPanel`, `AstrolabeSectionHeader`, and wrap slots in `Expanded` to fix the 2.7px overflow.
- **Must Preserve:** `equippedGearProvider`, `EquipmentDetailSheet.show(context, item)`.
- **Risk:** Low.

### 4. `lib/presentation/widgets/aether_resonance_oracle_widget.dart` `[MODIFY]`
- **Responsibility:** D20 divine communion widget.
- **Changes:** Use `CelestialPanel`, wrap header in `Expanded` to fix the 37px overflow, style prophecy scroll.
- **Must Preserve:** `_communeWithArbiter()`, RNG timing, blessing strings.
- **Risk:** Low.

### 5. `lib/presentation/widgets/quest_decree_widget.dart` `[MODIFY]`
- **Responsibility:** World Arbiter quest decree card.
- **Changes:** Use `CelestialPanel`, wrap sector name in `Expanded` to fix the 49px overflow.
- **Must Preserve:** `activeQuestProvider`, `DescentScreen` navigation, reward numbers.
- **Risk:** Low.

### 6. `lib/presentation/widgets/social_post_card.dart` `[MODIFY]`
- **Responsibility:** Sanctuary bulletin community post card.
- **Changes:** Use `CelestialPanel`, wrap action buttons in `Expanded` to fix the 15px & 22px overflows.
- **Must Preserve:** `_toggleLaurel()`, laurel/comment counters, author info.
- **Risk:** Low.

### 7. `lib/presentation/screens/dashboard_screen.dart` `[MODIFY]`
- **Responsibility:** Master dashboard assembly and telemetry sheet.
- **Changes:** Upgrade Operator Crest, Vitality header (`AstrolabeSectionHeader` fixes 24px overflow), Alchemical Capsule Meters, Waygates styling, and Community header (`AstrolabeSectionHeader` fixes 57px overflow).
- **Must Preserve:** Provider subscriptions, navigation shell integration, 96dp bottom padding.
- **Risk:** Medium.

### 8. `test/dashboard_screen_test.dart` `[MODIFY]`
- **Responsibility:** Dashboard regression & responsive tests.
- **Changes:** Add Honor X8 ($360\text{dp}$) and narrow ($320\text{dp}$) viewport overflow tests; verify all existing tests pass.
- **Must Preserve:** Existing 4 test cases.
- **Risk:** Low.

---

## 18. Implementation Order

Thread B must execute the redesign in this precise sequential order:

```
Step 1: Create [celestial_panel.dart] and [astrolabe_section_header.dart] primitives
   ↓
Step 2: Refactor [equipment_slots_widget.dart] with CelestialPanel & Expanded slots (Fix Defect 1)
   ↓
Step 3: Refactor [aether_resonance_oracle_widget.dart] with CelestialPanel & flex header (Fix Defect 2)
   ↓
Step 4: Refactor [quest_decree_widget.dart] with CelestialPanel & flex sector row (Fix Defect 3)
   ↓
Step 5: Refactor [social_post_card.dart] with CelestialPanel & flex action bar (Fix Defects 6 & 7)
   ↓
Step 6: Refactor [dashboard_screen.dart] (Operator Crest, Capsule Meters, Waygates, Section Headers) (Fix Defects 4 & 5)
   ↓
Step 7: Expand [test/dashboard_screen_test.dart] with Honor X8 responsive test cases
   ↓
Step 8: Run unit & widget test suite in Cloud CI to verify 100% green status
   ↓
Step 9: Compile ABI-split APK and verify on physical Honor X8 device
```

---

## 19. Thread B Execution Checklist

- [ ] Inspect every target file before making modifications.
- [ ] Create `lib/presentation/widgets/celestial_panel.dart` without external dependencies.
- [ ] Create `lib/presentation/widgets/astrolabe_section_header.dart` with defensive text constraints (`maxLines: 1`, `overflow: TextOverflow.ellipsis`, `softWrap: false`).
- [ ] Implement responsive `LayoutBuilder` in `equipment_slots_widget.dart` ($2 \times 2$ grid on $< 340\text{dp}$, 4-slot row on $\ge 340\text{dp}$).
- [ ] Apply flex constraint to oracle title row in `aether_resonance_oracle_widget.dart`.
- [ ] Apply flex constraint to target sector text in `quest_decree_widget.dart`.
- [ ] Apply `Expanded` to action buttons in `social_post_card.dart`.
- [ ] Upgrade `DashboardScreen` sections while preserving all semantic and text finders.
- [ ] Run `flutter test test/dashboard_screen_test.dart` and ensure 0 failures.
- [ ] Commit with clean git history (`feat(dashboard): celestial astrolabe redesign and responsive overflow resolution`).
- [ ] Push to `main` to trigger GitHub Actions Cloud CI Run.

---

## 20. Final Verification Checklist

- [ ] All 7 RenderFlex overflows completely eliminated.
- [ ] Zero unhandled layout exceptions on Honor X8 viewport ($360\text{dp} \times 800\text{dp}$).
- [ ] Parchment aesthetic (`#FAF7F0`, `#6E473B`, `#A78D78`) 100% consistent with Character Dossier.
- [ ] All 6 navigation waygates route correctly.
- [ ] Telemetry bottom sheet opens and displays accurate attributes.
- [ ] Oracle roll button triggers D20 communion.
- [ ] Pull-to-refresh on community feed remains responsive.
- [ ] GitHub Actions workflow passes on Android, Windows, Web, and Backend.

---

## THREAD B EXECUTION CONTRACT

### ABSOLUTE EXECUTION BOUNDARY & MANDATORY GUARDRAILS

1. **Strict 8-File Scope Baseline:** Thread B is authorized to modify **ONLY** the 8 files identified in Section 17 of this approved plan.
2. **GENUINE ARCHITECTURAL DRIFT GUARDRAIL:** Thread B must **NOT** blindly follow the eight-file list if compilation, Flutter dependencies, or architecture proves another file genuinely must change.  
   **RULE: If an additional file is genuinely required, Thread B MUST STOP AND REPORT IT before modifying it.**  
   *Preserves the Thread A $\rightarrow$ Thread B boundary and strictly prevents silent scope expansion.*
3. **Responsive Grid/Wrap vs. Forced Row:** In `equipment_slots_widget.dart`, Thread B must NOT force four slots into a single cramped row on mobile. Use `LayoutBuilder` ($2 \times 2$ grid on $< 340\text{dp}$, 4-in-a-row on $\ge 340\text{dp}$) to ensure tactile luxury and eliminate cramping.
4. **Preserve Business Logic & Contracts:** All Riverpod providers, SQLite persistence, RNG roll mechanics (`_communeWithArbiter`), telemetry mapping, and navigation routes must remain untouched.
5. **Preserve Test Finders:** All semantic labels and text finders verified in `dashboard_screen_test.dart` and Patrol E2E flows must be preserved verbatim.
6. **No Overflow Hacks:** Overflows must be solved using responsive layouts (`LayoutBuilder`, `Wrap`, `Expanded`, `Flexible`) rather than clipping (`TextOverflow.clip`) or scaling hacks (`Transform.scale`).
7. **Reporting Requirement:** Report every modified file, executed test, and verified viewport upon completion.
