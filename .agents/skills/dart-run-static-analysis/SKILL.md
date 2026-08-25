---
name: dart-run-static-analysis
description: >-
  Analyze code quality, inspect analysis_options.yaml rules, identify lint warnings,
  and verify code correctness across Flutter and Dart codebases.
---

# Dart & Flutter Static Analysis Skill

This skill guides the inspection and resolution of static analysis issues, linter warnings, and compilation checks.

## Core Capabilities

1. **Rule Verification**: Inspect `analysis_options.yaml` to ensure project linting standards (e.g. `flutter_lints`, strict type inference, missing required parameters) are enforced.
2. **Offline vs Cloud Analysis**:
   - In resource-constrained mobile environments (like Termux on Android), offload heavy compilation and full-suite analysis runs to GitHub Actions cloud runners via `gh workflow run`.
   - Perform lightweight syntax and symbol validation locally before pushing.
3. **Common Dart Lints & Fixes**:
   - **`prefer_const_constructors`**: Add `const` to immutable widget trees to optimize Flutter rebuild performance.
   - **`avoid_print`**: Replace `print()` with structured logging (e.g., `MonitoringService` or `debugPrint`).
   - **`use_build_context_synchronously`**: Check `if (!mounted) return;` after `await` calls in `StatefulWidget` or Riverpod consumers.
   - **Unused imports/variables**: Clean up unused imports and unreferenced variables.

## Execution Workflow

1. Inspect modified Dart files for common static analysis anti-patterns.
2. Ensure all types are explicitly annotated or properly inferred.
3. If checking full project health on mobile, trigger the cloud CI pipeline:
   ```bash
   gh workflow run flutter-build.yml
   gh run list -L 1
   ```
