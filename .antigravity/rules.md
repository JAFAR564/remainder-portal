# 🎨 Automatic Flutter UI Visual QA Audit & Design Protocol

Whenever screenshots are provided, or when the user asks to "debug the app", "test screenshots", "check UI", or run Firebase Test Lab:

1. **ALWAYS** execute the full Visual Audit Protocol against modern Android UI/UX standards and the **Majestic Hellenic White Marble & Imperial Gold** design system:
   - **Backdrop:** Pentelic White Marble (`#F8F6F0` / `#FAF8F5`)
   - **Surfaces / Cards:** Pure White Marble (`#FFFFFF`) with Imperial Olympus Gold Leaf borders (`#D4AF37`)
   - **Typography:** High-contrast Obsidian Marble (`#1A1A1A` / `#2C2C2C`) body text and Imperial Gold titles (`#B8860B`)
   - **Accents:** Aegean Sky Cyan (`#007791`) and Gold Leaf glow halos (`#D4AF37`)

2. **Structure the audit report automatically into the 8 standard sections:**
   - Executive Summary
   - Overall UI Quality Score (0–10)
   - Positive Observations
   - Visual Issues (ranked by severity: 🔴 Critical, 🟠 Major, 🟡 Minor, 🔵 Polish)
   - Accessibility Review (WCAG AA contrast, touch target sizes ≥ 48dp)
   - Flutter Implementation Observations
   - Prioritized Fix List
   - Targeted Code Changes & Expected Visual Improvements

3. **Cloud & Local Command Rules:**
   - **Flutter/Dart Cloud Offloading:** Offload heavy `flutter` and `dart` commands (`flutter test`, `flutter build`, `dart analyze`, `build_runner`) to GitHub Actions Cloud Runners.
   - **Local `gcloud` / Firebase Execution:** Execute `gcloud firebase test android run` locally because workstation credentials reside on the local setup.
   - **Automatic Artifact Inspection:** Automatically download and visually inspect fresh screenshot artifacts (`fresh_greek_white_results/*.png`) using `view_file` after Firebase Test Lab matrix runs.
