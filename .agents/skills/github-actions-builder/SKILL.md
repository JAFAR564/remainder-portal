---
name: github-actions-builder
description: Handles cloud compilation of the Flutter Android APK using GitHub Actions, preventing local WSL/TUI system freezes on low-spec hardware.
---

# GitHub Actions Cloud Compilation Skill

## 1. Context & Constraints
*   **Hardware Limitation**: The local environment runs inside a resource-constrained WSL2 (Linux) setup. Compiling Java, Kotlin, and Gradle wrapper libraries locally via `flutter build apk` causes terminal hangs, CPU spikes, and machine freezes.
*   **Solution**: Delegate all native compilation tasks to the GitHub Actions cloud runner pipeline.
*   **Target Repo**: `github.com/JAFAR564/remainder-portal` (Git remote: `jafar`).

---

## 2. Agent Execution Steps
When the user asks to compile an Android APK or generate an installation package:
1.  **Do NOT** run `flutter build apk` locally.
2.  Stage all current code changes and commit them with a descriptive message.
3.  Push directly to the remote repository branch:
    ```bash
    git add .
    git commit -m "feat: [describe changes]"
    git push jafar main
    ```
4.  Direct the user to the actions monitoring URL to retrieve the compiled zip artifact:
    *   **Link**: [https://github.com/JAFAR564/remainder-portal/actions](https://github.com/JAFAR564/remainder-portal/actions)
    *   **Artifact Name**: `remainder-portal-apk`

---

## 3. Maintenance
*   The workflow trigger is configured in `.github/workflows/build_apk.yml`.
*   Ensure that any updates to package dependencies (like Java JDK versions or Flutter SDK channels) are mirrored in the workflow configuration file.
