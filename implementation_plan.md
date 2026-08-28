# 📋 Patrol Native Android E2E Testing — Implementation Plan

**Repository:** `The Remainder Portal` (`https://github.com/JAFAR564/remainder-portal`)  
**Stage:** 🟢 **Executed & Completed**  
**Target Location:** `/data/data/com.termux/files/home/remainder-portal/implementation_plan.md`  
**Date:** August 28, 2026  

---

## 🔍 1. Repository Analysis Findings

### A. Framework & Application Architecture
* **Flutter SDK:** Flutter `3.44.4` (Channel: `stable`, Dart SDK `>=3.12.2 <4.0.0`).
* **State Management & DI:** `flutter_riverpod: ^2.5.1`.
* **Database & Persistence:** `drift: ^2.20.0` with `sqlite3_flutter_libs: ^0.5.24` and `path_provider`.
* **Platform Channels & Native Integrations:**
  - `workmanager: ^0.9.0` (Android background tasks via `WorkManager`).
  - `ota_update: ^7.1.0` (Android `PackageInstaller` / `FileProvider` download & install).
  - `url_launcher: ^6.3.2` (Android Custom Tabs & Intent resolution).
  - `firebase_crashlytics: ^4.3.10`, `firebase_performance: ^0.10.1+10`, `firebase_auth`, `cloud_firestore`.

### B. Android Native & Gradle Configuration
* **Gradle Build Scripts:** Modern **Kotlin DSL** (`android/build.gradle.kts`, `android/app/build.gradle.kts`, `android/settings.gradle.kts`).
* **Android Gradle Plugin (AGP):** `8.9.1` (declared in `settings.gradle.kts`).
* **Kotlin Version:** `2.0.20` with `JvmTarget.JVM_17`.
* **Java Compatibility:** `JavaVersion.VERSION_17` with `coreLibraryDesugaring` enabled (`desugar_jdk_libs:2.1.4`).
* **Package Identity:** `com.remainder.portal.remainder_portal` (Namespace & `applicationId`).
* **Activity Entry Point:** `MainActivity.kt` extending `FlutterActivity`.
* **Existing Native Test Setup:** Currently **no** `androidTest/` directory exists under `android/app/src/`.

### C. Existing Test Infrastructure & Conventions
* **Test Suite:** Located in `test/` (7 test files):
  - `test/celestial_bottom_navbar_test.dart` (Widget tests for the 5-tab custom icon navigation bar).
  - `test/widget_test.dart` (Basic screen pump tests).
  - `test/database_test.dart` (In-memory Drift SQLite integration).
  - `test/phase1_test.dart` through `test/phase4_test.dart` (Domain, sync ledger, and downloader unit tests).
* **Missing Layer:** There is currently no end-to-end (E2E) UI test layer (`integration_test/` is not yet created).

### D. CI/CD Workflow & Environment
* **Provider:** GitHub Actions ([`.github/workflows/flutter-build.yml`](.github/workflows/flutter-build.yml)).
* **Active Jobs:**
  1. `flutter-build`: Ubuntu runner, JDK 21, runs `flutter test`, builds split-per-abi Android APK (`remainder-portal-arm64.apk`), uploads release artifacts.
  2. `windows-build`: Windows runner, builds desktop binary.
  3. `web-build`: Ubuntu runner, compiles Flutter Web release artifact.
  4. `backend-check`: Ubuntu runner, compiles Node.js / TypeScript serverless backend.

---

## 🏛️ 2. Proposed Patrol Architecture

Patrol provides a unified Dart API for driving both **Flutter widgets** and **native Android OS elements** (permissions, notifications, system trays, webviews).

```
                      PATROL TEST SUITE (Dart)
                      (integration_test/*.dart)
                                 │
           ┌─────────────────────┴─────────────────────┐
           │                                           │
    Flutter Finders                            Native Automator
   $('DASHBOARD').tap()                   $.native.grantPermission()
   $('NEXUS CHAT').tap()                  $.native.openNotifications()
           │                                           │
           ▼                                           ▼
     Flutter Engine                          Patrol JUnit Runner
(Widget Tree & Semantics)                     (UIAutomator & Espresso)
           │                                           │
           └─────────────────────┬─────────────────────┘
                                 │
                     ANDROID OS / EMULATOR (CI)
                     (API 34 / Pixel 6 / KVM)
```

---

## 🛠️ 3. Concrete Implementation Plan

### Step 1: Add Dependencies (`pubspec.yaml`)
Add `patrol` to `dev_dependencies`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  patrol: ^3.11.0
```
Configure Patrol CLI settings in `pubspec.yaml`:
```yaml
patrol:
  app_name: Remainder Portal
  android:
    package_name: com.remainder.portal.remainder_portal
```

### Step 2: Configure Android Gradle Test Runner (`android/app/build.gradle.kts`)
1. In `android { defaultConfig { ... } }`:
   ```kotlin
   testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
   testInstrumentationRunnerArguments["clearPackageData"] = "true"
   ```
2. In `dependencies { ... }`:
   ```kotlin
   androidTestImplementation("androidx.test:runner:1.6.2")
   androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
   androidTestImplementation("androidx.test.uiautomator:uiautomator:2.3.0")
   ```

### Step 3: Create Native Android Test Harness
Create `android/app/src/androidTest/kotlin/com/remainder/portal/remainder_portal/MainActivityTest.kt`:
```kotlin
package com.remainder.portal.remainder_portal

import org.junit.Rule
import org.junit.runner.RunWith
import pl.leancode.patrol.PatrolTestRule
import pl.leancode.patrol.PatrolTestRunner

@RunWith(PatrolTestRunner::class)
class MainActivityTest {
    @get:Rule
    val rule: PatrolTestRule<MainActivity> = PatrolTestRule(MainActivity::class.java)
}
```

### Step 4: Create Initial High-Value Patrol E2E Tests
Create the `integration_test/` test suite:

1. **`integration_test/app_boot_and_navigation_test.dart`** (Initial Test 1):
   - Cold starts the app.
   - Handles any native Android permission dialogs automatically (`$.native.grantPermissionWhenInUse()`).
   - Verifies transition from `SplashScreen` $\rightarrow$ `DashboardScreen`.
   - Tests seamless navigation across the 5 floating tabs: `DASHBOARD`, `NEXUS CHAT`, `SQUADS`, `GUILDS`, `SETTINGS`.
   - Confirms that active tab labels and custom hand-drawn icon opacity render correctly.

2. **`integration_test/oracle_and_chat_flow_test.dart`** (Initial Test 2):
   - On the `DashboardScreen`, taps **"COMMUNE WITH ARBITER"** and asserts the d20 roll animation and blessing card update.
   - Navigates to `NEXUS CHAT` (`TerminalScreen`), toggles IC/OOC mode chip, types a test message, and verifies it appears in the chat log.

### Step 5: Add Dedicated CI E2E Workflow (`.github/workflows/patrol-e2e.yml`)
Add a dedicated, hardware-accelerated Android emulator job in GitHub Actions:

```yaml
name: Patrol Android E2E Tests

on:
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  patrol-android-e2e:
    name: Patrol Android E2E (API 34)
    runs-on: ubuntu-latest
    timeout-minutes: 25

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version: '3.44.4'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Enable KVM Hardware Virtualization
        run: |
          echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm-rules.rules
          sudo udevadm control --reload-rules && sudo udevadm trigger --name-match=kvm

      - name: Install Patrol CLI
        run: dart pub global activate patrol_cli

      - name: Run Patrol Tests on Android Emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          target: google_apis
          arch: x86_64
          profile: pixel_6
          cores: 2
          ram-size: 2048M
          emulator-options: -no-window -gpu swiftshader_indirect -no-snapshot -noaudio -no-boot-anim
          disable-animations: true
          script: |
            export PATH="$PATH":"$HOME/.pub-cache/bin"
            patrol test --target integration_test/app_boot_and_navigation_test.dart

      - name: Upload Patrol Test Reports & Screenshots
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: patrol-test-results
          path: |
            build/app/reports/
            build/app/outputs/androidTest-results/
```

---

## 🎯 4. Test Scopes & Boundaries

| Test Layer | Framework | What It Tests | Execution Target |
| :--- | :--- | :--- | :--- |
| **Unit Tests** | Dart `package:test` | Drift database queries, hardware detection, lore parsers, state reducers. | Local Termux / GitHub CI (`flutter test`) |
| **Widget Tests** | `flutter_test` | Widget layout, 5-color palette styling, button callbacks, navbar animations. | Local Termux / GitHub CI (`flutter test`) |
| **Patrol E2E (Now)** | `patrol` | Full app boot, native permissions, 5-tab navigation, d20 Oracle rolls, chat inputs. | GitHub Actions CI (Android Emulator API 34) |
| **Patrol E2E (Future)** | `patrol` | In-app OTA package installer flows, P2P squad relays, audio leylines, offline sync. | GitHub Actions CI / Firebase Test Lab |

---

## 🛡️ 5. Risk Identification & Mitigation Matrix

| # | Risk | Impact | Mitigation Strategy |
| :--- | :--- | :---: | :--- |
| 1 | **AGP 8.9.1 / Kotlin DSL Incompatibility** | 🔴 High | Use Patrol $\ge 3.11.0$, which officially supports Gradle 8+ and AGP 8.x Kotlin DSL (`build.gradle.kts`). |
| 2 | **Emulator Boot Flakiness in CI** | 🟠 Medium | Use `reactivecircus/android-emulator-runner@v2` with `disable-animations: true`, `swiftshader_indirect`, and KVM hardware acceleration enabled. |
| 3 | **CI Pipeline Bloat / Execution Time** | 🟠 Medium | Run Patrol E2E in a **separate workflow** (`patrol-e2e.yml`) triggered on PRs and manual dispatch, keeping standard `flutter-build.yml` push builds ultra-fast (~2-3 mins). |
| 4 | **Flutter Semantics & Finding Elements** | 🟡 Low | Use Patrol's native selector syntax (`$('DASHBOARD')`, `$(#key)`) which natively bridges Flutter finders without relying on raw coordinate taps. |
| 5 | **Test Isolation & State Leakage** | 🟡 Low | Set `testInstrumentationRunnerArguments["clearPackageData"] = "true"` in Gradle to ensure each test run starts with a clean SQLite / preferences state. |

---

## 📋 6. Files & Configurations Expected to Change (in Thread B)

1. `pubspec.yaml` — Add `patrol: ^3.11.0` and patrol configuration block.
2. `android/app/build.gradle.kts` — Configure `testInstrumentationRunner` and AndroidX test dependencies.
3. `android/app/src/androidTest/kotlin/com/remainder/portal/remainder_portal/MainActivityTest.kt` — Create Kotlin test runner harness.
4. `integration_test/app_boot_and_navigation_test.dart` — Create initial E2E test suite.
5. `.github/workflows/patrol-e2e.yml` — Create dedicated hardware-accelerated Android E2E CI workflow.
6. `ACTIVE_TASK.md` & `HANDOVER.md` — Update documentation and handover notes.

---

## ✋ 7. Assumptions & Handoff Summary

### Confirmed Repository Facts:
- `android/` uses modern Kotlin DSL (`.gradle.kts`) with AGP 8.9.1 and Java 17.
- Existing CI uses GitHub Actions with JDK 21 on `ubuntu-latest`.
- No existing `integration_test/` or `androidTest/` files exist in the repository today.

### Confirmation Points for the Developer:
1. **CI Trigger Strategy**: We recommend isolating Patrol into `.github/workflows/patrol-e2e.yml` (triggered on PRs and manual dispatch) so that standard code pushes continue to build APKs in ~2-3 minutes.
2. **Android Emulator Target**: We recommend **API Level 34 (Android 14) x86_64** on Pixel 6 profile for maximum compatibility.

---

> [!TIP]
> **Execution Complete:** Thread B has completed the implementation of Patrol Native Android E2E Testing, Android Gradle test harness, E2E test suites, and dedicated CI workflow.
