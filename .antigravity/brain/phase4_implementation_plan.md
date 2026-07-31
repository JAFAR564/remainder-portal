# Phase 4 Implementation Plan: On-Demand Gemma Model Weight Downloader & Hardware Tiering

## Goal Description
Implement an on-demand, resumable background downloader service (`GemmaModelDownloaderService`) for 1.5 GB quantized Gemma `.bin` model weights on **Tier S Flagship/Desktop** hardware. The system will perform SHA-256 checksum verification, provide download/pause/resume/delete capabilities, update `SettingsScreen` with visual download progress metrics, and enable local LiteRT execution when model weights are verified on disk.

---

## User Review Required

> [!IMPORTANT]
> - **On-Demand Storage & Download Strategy:** The 1.5 GB Gemma model binary is **not** bundled into the app build (`app-debug.apk`) to keep app size minimal (158 MB). It is fetched on-demand when enabled by the user on Tier S devices.
> - **Hardware Gating:** Download and local execution controls remain strictly locked on Tier B (Budget) and Tier A (Mid-Range) devices to prevent out-of-memory crashes on low-spec hardware.

---

## Proposed Changes

### Data & Service Layer

#### [NEW] `lib/data/services/gemma_model_downloader_service.dart`
- Create `ModelDownloadState` enum (`notDownloaded`, `downloading`, `paused`, `verifying`, `ready`, `error`).
- Create `ModelDownloadProgress` model holding `bytesDownloaded`, `totalBytes` (1.5 GB), `percentage`, `downloadSpeed`, `status`, and `errorMessage`.
- Implement `GemmaModelDownloaderService` with HTTP Range header resume support, SHA-256 integrity validation using `crypto` package, local disk storage management in application support directory, and `Stream<ModelDownloadProgress>` updates.

#### [MODIFY] `lib/data/services/litert_service.dart`
- Inject model weight path parameter into `LiteRtService`.
- Check if model weight file exists on disk and has passed SHA-256 verification before attempting local LiteRT inference; fall back to d20 Rule Engine or Cloud Genkit if model weights are missing.

---

### Presentation Layer

#### [MODIFY] `lib/presentation/providers/presentation_provider.dart`
- Expose `GemmaModelDownloaderService` and `ModelDownloadProgress` state via `presentationProvider`.
- Add `startModelDownload()`, `pauseModelDownload()`, `cancelModelDownload()`, and `deleteModelWeights()` methods to notifier.

#### [MODIFY] `lib/presentation/screens/settings_screen.dart`
- Expand the **EXPERIMENTAL LOCAL LiteRT GEMMA AI** card on Tier S devices with:
  - Download status badge (`NOT INSTALLED`, `DOWNLOADING (45%)`, `VERIFYING SHA-256`, `INSTALLED & READY`).
  - Animated linear progress bar showing download percentage and MB downloaded / total 1536 MB.
  - Action buttons (`DOWNLOAD MODEL (1.5 GB)`, `PAUSE`, `RESUME`, `DELETE MODEL`).
  - Hardware requirements warning banner for non-Tier S devices.

---

### Automated Testing Layer

#### [NEW] `test/phase4_test.dart`
- Unit tests for `HardwareTierService` classification heuristics.
- Unit tests for `GemmaModelDownloaderService` state transitions (`notDownloaded` $\rightarrow$ `downloading` $\rightarrow$ `verifying` $\rightarrow$ `ready`).
- Unit tests for SHA-256 checksum integrity verification logic.
- Unit tests for `LiteRtService` fallback behavior when model weights are missing vs installed.

---

## Verification Plan

### Automated Tests
Execute unit test suite via shell command:
```bash
flutter test test/phase4_test.dart
```

### Manual Verification
1. Open `SettingsScreen` on desktop / Tier S hardware.
2. Verify hardware profile shows `TIER S (FLAGSHIP / DESKTOP)`.
3. Tap `DOWNLOAD MODEL (1.5 GB)` and observe live progress bar and MB counter.
4. Verify SHA-256 verification state transitions to `INSTALLED & READY`.
5. Toggle `EXPERIMENTAL LOCAL LiteRT GEMMA AI` on and test story response generation in `TerminalScreen`.
