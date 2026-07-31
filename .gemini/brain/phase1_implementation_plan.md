# Implementation Plan: Phase 1 Compliance & Offline Rule Engine

**Goal:** Complete the remaining Phase 1 PRD requirements:
1. **Offline Rule Engine Integration** (`lib/data/services/litert_service.dart`)
2. **IC / OOC Dual Chat Mode** (`lib/presentation/screens/terminal_screen.dart` & `lib/presentation/providers/game_provider.dart`)
3. **Drift Migration Strategy** (`lib/data/services/database_service.dart`)

---

## User Review Required

> [!IMPORTANT]
> **Offline Rule Engine Determinism:** The offline rule engine will calculate d20 dice rolls and stat modifiers locally when cloud AI endpoints fail or internet is offline, returning structured atmospheric responses formatted with `[OFFLINE RULE ENGINE]`.
> 
> **IC / OOC Mode Toggle:** Chat messages will now carry an `isIC` flag. A segmented view control in `TerminalScreen` allows filtering between `ALL`, `IC (In-Character)`, and `OOC (Out-of-Character)` views without losing history.

---

## Proposed Changes

### Component 1: AI Foundation & Offline Engine (`lib/data/services/litert_service.dart`)

#### [MODIFY] `lib/data/services/litert_service.dart`
- Intercept HTTP errors, socket exceptions, and non-200 status codes in `generateStoryResponse`.
- Implement `_generateOfflineStoryResponse(prompt, characterClass)`:
  - Generate a d20 dice roll (1–20) + class attribute modifier (+3 for matching origin class).
  - Categorize outcomes:
    - **Critical Success (18–20):** Exceptional outcome, system resonance unlocked.
    - **Success (10–17):** Action executed successfully.
    - **Complication (6–9):** Partial success with energy/shield strain.
    - **Critical Fail (1–5):** Defense countermeasure triggered.
  - Return formatted atmospheric text response incorporating OKF lore context instead of throwing network errors.

```dart
// Snippet preview of offline rule engine fallback logic
String _generateOfflineStoryResponse(String prompt, String? characterClass) {
  final random = math.Random();
  final d20 = random.nextInt(20) + 1;
  final modifier = (characterClass == 'Vanguard' || characterClass == 'Cyber Hacker') ? 3 : 2;
  final total = d20 + modifier;

  String outcomeTitle;
  String narrativeDescription;

  if (total >= 18) {
    outcomeTitle = 'CRITICAL CONSENSUS REACHED';
    narrativeDescription = 'Your command "$prompt" overrides local sector defenses smoothly. System stability restored at +100% capacity.';
  } else if (total >= 10) {
    outcomeTitle = 'SUCCESSFUL COMMAND EXECUTION';
    narrativeDescription = 'Your action "$prompt" has been logged in the local sector node. Neural pathway stabilized.';
  } else if (total >= 6) {
    outcomeTitle = 'PARTIAL CONSENSUS WITH COMPLICATION';
    narrativeDescription = 'Your action "$prompt" succeeded, but triggered minor power fluctuations across your shield integrity.';
  } else {
    outcomeTitle = 'SYSTEM ANOMALY DETECTED';
    narrativeDescription = 'Local sector firewalls rejected the instruction "$prompt". Defense countermeasures engaged.';
  }

  return '[OFFLINE RULE ENGINE]\n'
         'D20 Roll: $d20 + $modifier ($characterClass) = $total\n'
         'Status: $outcomeTitle\n\n'
         '$narrativeDescription';
}
```

---

### Component 2: Chat Model & IC / OOC Dual Mode (`lib/presentation/providers/game_provider.dart` & `lib/presentation/screens/terminal_screen.dart`)

#### [MODIFY] `lib/presentation/providers/game_provider.dart`
- Update `MessageModel`:
  - Add `final bool isIC;` field (defaults to `true`).
- Add `ChatFilter` enum: `enum ChatFilter { all, icOnly, oocOnly }`
- Add `chatFilterProvider = StateProvider<ChatFilter>((ref) => ChatFilter.all)`
- Update `sendPlayerAction(String actionText, String characterClass, {bool isIC = true})` to store and broadcast message IC status.

#### [MODIFY] `lib/presentation/screens/terminal_screen.dart`
- Add a segmented header toggle (`ALL` | `IC ONLY` | `OOC ONLY`) in `TerminalScreen`.
- Add an IC/OOC mode toggle button next to the text input box so roleplayers can tag their input.
- Render distinct visual styles:
  - **IC Messages:** High-contrast cyan/orange border, origin class badge, cyber-gothic text styling.
  - **OOC Messages:** Muted frosted silver container with `[OOC]` label tag.
- Filter displayed list based on `ref.watch(chatFilterProvider)` without deleting underlying chat history.

---

### Component 3: Drift Database Migration Strategy (`lib/data/services/database_service.dart`)

#### [MODIFY] `lib/data/services/database_service.dart`
- Override `MigrationStrategy get migration` inside `AppDatabase`:
  - `onCreate`: Runs `m.createAll()` for fresh database creation.
  - `onUpgrade`: Defines safe forward migration steps for future schema bumps (`from < 2`).
  - `beforeOpen`: Executes `PRAGMA foreign_keys = ON;` to enforce foreign key constraints across `StoryThreads` and `ChatMessages`.

---

## Verification Plan

### Automated Tests
Run static analysis and test suite to ensure zero regressions:
```bash
dart analyze
flutter test
```

### Manual Verification
1. **Offline AI Fallback:**
   - Turn off Wi-Fi/Internet connection.
   - Open `TerminalScreen` and submit an action.
   - Verify that an atmospheric `[OFFLINE RULE ENGINE]` d20 result is returned cleanly without throwing exceptions.
2. **IC / OOC Dual Mode:**
   - Toggle input mode between `[IC]` and `[OOC]` when typing.
   - Toggle view mode filter between `ALL`, `IC`, and `OOC`.
   - Verify that messages filter instantly and persist across screen navigation.
3. **Database Migration:**
   - Launch app, verify SQLite database opens without errors and foreign keys PRAGMA is active.
