# 🌩️ Shorebird OTA Cloud Update Infrastructure Implementation Plan

## Goal Description
Implement an automated, production-ready **Over-The-Air (OTA) Cloud Update & Shorebird Code Push Infrastructure** for *The Remainder Portal*. This eliminates the need for users to manually re-download and reinstall `.apk` binaries for UI, logic, lore, theme, or widget updates.

---

## User Review Required

> [!IMPORTANT]
> **Zero Manual APK Reinstalls:**
> Once this pipeline is active, all Dart code changes, new widgets, theme updates, and bug fixes pushed to GitHub `main` will be packaged into a lightweight AOT patch (1–3 MB) and delivered silently over-the-air to travelers' devices.

> [!NOTE]
> **Native Binary Scope:**
> Native C/C++ FFI plugins or changes to `AndroidManifest.xml` still utilize our automated GitHub Release fallback via `UpdateService.checkForUpdates()`.

---

## Proposed Changes

### 1. Update Service Sync & Version Alignment
#### [MODIFY] `lib/data/services/update_service.dart`
- Update hardcoded `currentVersion` from `1.0.2` to `1.1.0` to align with `pubspec.yaml`.
- Add Shorebird patch detection & OTA state listener methods (`checkShorebirdPatch()`, `isShorebirdAvailable`).

### 2. Shorebird Configuration File
#### [NEW] `shorebird.yaml`
- Add Shorebird project identifier (`app_id`) and default release channel configuration.

### 3. UI Component — Hellenic OTA Patch Banner Widget
#### [NEW] `lib/presentation/widgets/ota_patch_banner_widget.dart`
- Create a Pentelic White Marble & Imperial Gold floating banner that alerts travelers when a new cloud patch has downloaded and is ready to apply on app restart.

### 4. Cloud CI/CD Automation Pipeline
#### [MODIFY] `.github/workflows/flutter-build.yml`
- Add Shorebird CLI setup and automated `shorebird patch android` / `shorebird release android` cloud execution steps.

---

## Verification Plan

### Automated Tests
Offload build runner and test suite execution to GitHub Actions Cloud Runners:
- Run `flutter test` via GitHub Actions CI pipeline.
- Verify zero syntax errors and clean compilation.

### Manual Verification
1. Inspect `shorebird.yaml` configuration.
2. Confirm `UpdateService` correctly detects current version `1.1.0`.
3. Verify `OtaPatchBannerWidget` renders seamlessly within the Hellenic design system tokens.
