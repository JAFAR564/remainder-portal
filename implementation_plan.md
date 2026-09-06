# 📋 Implementation Plan: Phase 1 — Persistence Foundation & AI Engine Reality

**Target Repository:** `The Remainder Portal` (`https://github.com/JAFAR564/remainder-portal`)  
**Active Branch:** `main`  
**Current Version:** `1.1.8+12`  
**Mode:** 🟢 **Thread B: Executed & Completed**  

---

## 1. Goal Description

The Remainder Portal is designed as a **Persistent Social Storytelling Metaverse (PSSM)**. However, an architectural audit revealed that core game entities—specifically **UTRCS character dossiers** and **Sanctuary chat messages**—reside exclusively in volatile RAM (`StateNotifier` memory). If Android terminates the background process or the user restarts the app, their carefully constructed psychological profile and chat history are wiped. Furthermore, the AI service defaults to `http://localhost:8080/api/gm`, causing physical mobile devices (Honor X8) to silently fail and fall back to offline dice rolls without notifying the user.

This plan details the exact changes for **Thread B Execution** to:
1. **Make UTRCS Persistence Real:** Add a dedicated `UtrcsCharacters` table to Drift SQLite (Schema v4), hydrate the active profile on app startup, and persist edits atomically.
2. **Make Chat Persistence Real:** Wire `ChatHistoryNotifier` to Drift's `ChatMessages` table, hydrating conversation history on boot and saving every player action and GM narrative response.
3. **Operationalize the AI Pipeline:** Allow environment-injected Cloud Run backend URLs, eliminate silent mobile localhost failures, and provide clear in-UI status for offline D20 fallback vs. Cloud Gemini responses.
4. **Harmonize Versions & Link Orphaned Flows:** Align `update_service.dart` with `pubspec.yaml` (`1.1.8+12`) and link `UtrcsCreationScreen` from `CharacterDossierScreen` for character editing.

---

## 2. User Review Required

> [!IMPORTANT]
> **Drift SQLite Schema Migration (Version 3 &rarr; Version 4):**
> We are adding a new `UtrcsCharacters` table to `AppDatabase`. A migration step `if (from < 4) await m.createTable(utrcsCharacters);` will be registered in `migration.onUpgrade`. Because code generation (`database_service.g.dart`) requires `build_runner`, we will supply the table definition and migration logic cleanly. Existing local database tables (`Users`, `StoryThreads`, etc.) will NOT be dropped or wiped.

> [!WARNING]
> **Chat Foreign Key Constraint to `StoryThreads`:**
> In Drift SQLite, `ChatMessages.threadId` references `StoryThreads.id`. To ensure chat messages can be inserted without foreign-key constraint violations on fresh installs, `ChatHistoryNotifier` will automatically ensure a root story thread (`thread_sanctuary_main`) exists before saving messages.

---

## 3. Open Questions

1. **Cloud Run Production Endpoint:**
   - *Current default:* `http://localhost:8080/api/gm`.
   - *Proposed approach:* Support `--dart-define=BACKEND_URL=https://<service-url>` during build, falling back to a configurable constant, while displaying an explicit "OFFLINE D20 FALLBACK" tag when unreachable rather than pretending it was a cloud generation.

---

## 4. Proposed Changes

```
┌────────────────────────────────────────────────────────────────────────┐
│                        THREAD B EXECUTION PIPELINE                     │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Data Layer: database_service.dart (Schema v4, UtrcsCharacters)       │
│ 2. State Layer: utrcs_provider.dart (SQLite Hydration & Save on Edit)  │
│ 3. State Layer: game_provider.dart (Chat Hydration & Message Inserts)  │
│ 4. Service Layer: litert_service.dart (Configurable Cloud Run URL)     │
│ 5. UI Layer: character_dossier_screen.dart (Link UtrcsCreationScreen)  │
│ 6. Verification: test/utrcs_model_test.dart & database_test.dart       │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Component 1: Drift SQLite Persistence Layer

#### [MODIFY] [`lib/data/services/database_service.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/data/services/database_service.dart)
* Define table `UtrcsCharacters` storing character ID, foreign-key link to `Users`, schema version, depth, raw JSON payload, and timestamps.
* Bump `schemaVersion => 4`.
* Add migration logic in `migration.onUpgrade` for `from < 4`.

```dart
// Phase 4: Dedicated UTRCS Characters Persistence Table
class UtrcsCharacters extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable().references(Users, #id)();
  TextColumn get schemaVersion => text().withDefault(const Constant('1.0.0'))();
  TextColumn get completionDepth => text()(); // 'quick', 'standard', 'deep'
  TextColumn get rawJsonPayload => text()();   // Full serialized UtrcsCharacterModel JSON
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

### Component 2: UTRCS State & Hydration Layer

#### [MODIFY] [`lib/presentation/providers/utrcs_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/utrcs_provider.dart)
* Pass `AppDatabase` into `UtrcsCharacterNotifier`.
* On startup, check `db.select(db.utrcsCharacters).getSingleOrNull()`.
* If found, deserialize `UtrcsCharacterModel.fromJson(json.decode(row.rawJsonPayload))`.
* If not found, synthesize from `playerProfileProvider` and immediately persist the baseline to SQLite.
* Update `saveCharacter()`, `addCapability()`, and `updateDepth()` to write directly to SQLite via `insertOnConflictUpdate()`.

---

### Component 3: Sanctuary Chat Persistence Layer

#### [MODIFY] [`lib/presentation/providers/game_provider.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/providers/game_provider.dart)
* Update `ChatHistoryNotifier` to take `AppDatabase` from `databaseProvider`.
* On startup, query `db.chatMessages` (ordered by timestamp ascending).
* If messages exist in DB, hydrate `state` from database rows; if empty, seed the initial greeting and save it to SQLite.
* In `sendPlayerAction()`:
  - Ensure `'thread_sanctuary_main'` exists in `StoryThreads`.
  - Insert user's `MessageModel` into `db.chatMessages`.
  - When GM response arrives, insert GM response into `db.chatMessages`.

---

### Component 4: AI Service & Endpoint Hardening

#### [MODIFY] [`lib/data/services/litert_service.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/data/services/litert_service.dart)
* Inject `backendUrl` via `const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8080/api/gm')`.
* If running on mobile (`Platform.isAndroid || Platform.isIOS`) and using default localhost, log a clear diagnostic and immediately engage the local D20 RPG engine with clear status badging (`[OFFLINE D20 RULE ENGINE]`).
* Update comments and docs to reflect that on-device LiteRT is an upcoming native binding, avoiding claims of active on-device inference until C++ FFI is compiled.

---

### Component 5: Navigation & Orphaned Screen Reintegration

#### [MODIFY] [`lib/presentation/screens/character_dossier_screen.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/presentation/screens/character_dossier_screen.dart)
* Add an "EDIT BIO / EXPAND PSYCHOLOGY" action button in the AppBar and Overview tab navigating to `UtrcsCreationScreen()`.
* When saved in `UtrcsCreationScreen()`, return to `CharacterDossierScreen()` with the updated profile immediately reflected from SQLite.

#### [MODIFY] [`lib/data/services/update_service.dart`](file:///data/data/com.termux/files/home/remainder-portal/lib/data/services/update_service.dart)
* Update `static const String currentVersion = '1.1.8';` to eliminate version mismatch with `pubspec.yaml`.

---

## 5. Verification Plan

### Automated Tests
1. **UTRCS Model & Persistence Tests:**
   ```bash
   flutter test test/utrcs_model_test.dart
   ```
   * Verify round-trip serialization and database JSON schema stability.
2. **Database Schema & Table Tests:**
   ```bash
   flutter test test/database_test.dart
   ```
   * Verify table creation, insertions, and querying for `UtrcsCharacters` and `ChatMessages`.
3. **Full CI Matrix Validation:**
   ```bash
   gh workflow run flutter-build.yml
   ```
   * Verify Android, Windows, Web, and Backend compile cleanly with 0 analyzer warnings.

### Manual Verification
1. **Cold Boot Character Continuity:**
   - Launch app on Honor X8.
   - Tap Operator Header &rarr; Open Dossier &rarr; Add a custom Capability ("Shadow Aegis").
   - Force-close app from Android App Switcher (`Kill process`).
   - Reopen app &rarr; Open Dossier &rarr; Verify "Shadow Aegis" is still present.
2. **Chat History Continuity:**
   - Enter Nexus Chat (`TerminalScreen`).
   - Send: `"Scanning perimeter for anomaly spikes."`
   - Observe Game Master narrative response.
   - Force-close app & reopen &rarr; Enter Nexus Chat.
   - Verify previous exchange is visible in message stream.
