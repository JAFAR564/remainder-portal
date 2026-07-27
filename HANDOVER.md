# 🤝 MANDATORY PROJECT HANDOVER DOCUMENTATION

**Repository:** `The Remainder Portal` (`/home/vortex/remainder-portal`)  
**Active Branch:** `main`  
**Last Updated:** July 27, 2026  

---

## 📊 Project Status

- **Current Development Phase:** Phase 4 Complete — Hardware Tiering & On-Demand Gemma Downloader
- **Current Milestone:** Session 04 (`04-hardware-tiering`) Complete
- **Overall Completion Percentage:** **100%**
  - Phase 1 Foundation: **100%**
  - Phase 2 Social Sovereignty & Cooperative Systems: **100%**
  - Phase 3 Offline Persistence & Synchronization: **100%**
  - Phase 4 Hardware Tiering & Gemma Downloader: **100%**

---

## 📝 Task Summary

* **Objective:** Execute Phase 4 Action Plan: Implement `GemmaModelDownloaderService` with resumable HTTP downloads and chunked SHA-256 verification, update `LiteRtService` with weight validation checks and fallbacks, update `PresentationNotifier` with download state and toggle gating, expand `SettingsScreen` with visual download progress UI, and add unit test coverage in `test/phase4_test.dart`.
* **Scope:** 
  - `pubspec.yaml`
  - `lib/data/services/gemma_model_downloader_service.dart` [NEW]
  - `lib/data/services/litert_service.dart`
  - `lib/presentation/providers/presentation_provider.dart`
  - `lib/presentation/screens/settings_screen.dart`
  - `test/phase4_test.dart` [NEW]
  - `HANDOVER.md`
* **Outcome:** All Phase 4 requirements successfully implemented and verified with automated unit tests.

---

## 📁 Files Modified

| File Path | Action | Description / Rationale |
| :--- | :---: | :--- |
| [pubspec.yaml](file:///home/vortex/remainder-portal/pubspec.yaml) | Modified | Added `crypto: ^3.0.3` for SHA-256 checksum verification. |
| [gemma_model_downloader_service.dart](file:///home/vortex/remainder-portal/lib/data/services/gemma_model_downloader_service.dart) | **NEW** | Implemented `GemmaModelDownloaderService`, HTTP Range header resume support, `ModelDownloadProgress` model, state transitions, and chunked SHA-256 hashing. |
| [litert_service.dart](file:///home/vortex/remainder-portal/lib/data/services/litert_service.dart) | Modified | Injected model weight path validation (`hasValidModelWeights`) and added automatic fallback to d20 Rule Engine/Cloud AI when model weights are missing or invalid. |
| [presentation_provider.dart](file:///home/vortex/remainder-portal/lib/presentation/providers/presentation_provider.dart) | Modified | Integrated `GemmaModelDownloaderService` into `PresentationNotifier`, exposed `downloadProgress`, and gated `setOnDeviceAi()` to require Tier S hardware + verified model weights. |
| [settings_screen.dart](file:///home/vortex/remainder-portal/lib/presentation/screens/settings_screen.dart) | Modified | Expanded Experimental LiteRT AI section with status badges (`DOWNLOADING`, `PAUSED`, `VERIFYING`, `INSTALLED`), linear progress bar, MB/s speed counters, action buttons, and hardware gating warnings. |
| [phase4_test.dart](file:///home/vortex/remainder-portal/test/phase4_test.dart) | **NEW** | Created comprehensive unit test suite covering hardware classification, downloader state machine, SHA-256 verification, LiteRT fallbacks, and provider gating. |
| [HANDOVER.md](file:///home/vortex/remainder-portal/HANDOVER.md) | Modified | Updated mandatory handover documentation with 100% completion metrics. |

---

## 🏗️ Architectural Changes

1. **Resumable On-Demand Model Downloader (`GemmaModelDownloaderService`):**
   * *Change:* Created downloader service using HTTP `Range` headers to support pause, resume, and stream-based background progress reporting.
   * *Rationale:* Keeps initial application binary size compact (158 MB) while allowing Tier S users to fetch the 1.5 GB quantized Gemma model weights on demand.

2. **Chunked SHA-256 Integrity Verification:**
   * *Change:* Streamed chunked SHA-256 hashing (`sha256.startChunkedConversion`) for downloaded model binaries.
   * *Rationale:* Prevents out-of-memory errors on device when calculating SHA-256 hashes on multi-gigabyte model binary files before loading them into LiteRT.

3. **Strict Hardware & Model Weight Gating:**
   * *Change:* `setOnDeviceAi()` returns `false` unless the device is classified as Tier S AND the model weights pass verification on disk.
   * *Rationale:* Protects Tier B / Tier A devices from memory allocation crashes while ensuring Tier S devices execute local inference safely.

---

## ⚡ Cloud Offloading & Local Command Execution Directive
- **Strict Flutter & Dart Cloud Offloading:** ALWAYS offload heavy commands (`flutter test`, `flutter build`, `dart analyze`, `dart run build_runner`) to **GitHub Actions Cloud Runners**. DO NOT run them locally in bash to prevent local CPU/RAM strain and terminal lag.
- **Local `gcloud` & Firebase Execution:** Execute `gcloud` and Firebase Test Lab commands (`gcloud firebase test android run`) in the local terminal because local user credentials and authentication reside on the local workstation setup.
- **Automatic Cloud Log Retrieval:** Whenever a cloud GitHub Actions workflow or Firebase Test Lab matrix finishes, automatically fetch, inspect, and summarize the output logs and test artifacts without requiring explicit user prompts.

---

## 🧪 Testing & CI Validation

* **Unit Tests Executed:**
  * `test/phase4_test.dart` — All unit tests pass:
    - Hardware classification heuristics
    - Gemma model downloader state machine & progress stream
    - SHA-256 checksum verification (valid & invalid)
    - LiteRtService weight validation & d20 rule engine fallback
    - PresentationNotifier toggle gating

---

## ✅ Validation Checklist

- [x] Code compiles successfully
- [x] Static analysis passes
- [x] Handover documentation updated
- [x] All Phase 4 features implemented and verified
- [x] Test suite expanded in `test/phase4_test.dart`
- [x] No duplicate implementations introduced
