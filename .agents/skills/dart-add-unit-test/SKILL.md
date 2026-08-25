---
name: dart-add-unit-test
description: >-
  Write unit and widget tests using package:test and flutter_test for regression prevention,
  domain logic verification, and provider testing.
---

# Dart Unit & Widget Testing Skill

This skill outlines guidelines for writing robust, isolated unit and widget tests for Flutter and Dart architectures.

## Best Practices

1. **Test Organization**:
   - Mirror the `lib/` directory structure within `test/` (e.g., `lib/domain/usecases/calculate_progression.dart` $\rightarrow$ `test/domain/usecases/calculate_progression_test.dart`).
   - Group related scenarios using `group('FeatureName', () { ... });`.
   - Name tests with clear intent: `test('should calculate correct progression when trust level is maxed', () { ... });`.

2. **Testing Layers**:
   - **Domain / Usecases**: Test pure business logic functions with deterministic inputs and expected outputs without UI overhead.
   - **Data / Services**: Mock HTTP/P2P endpoints, verify JSON / YAML parsing, test Drift DB queries using in-memory databases (`NativeDatabase.memory()`).
   - **Presentation / Providers**: Test Riverpod StateNotifiers using `ProviderContainer` to verify state mutations independently of the UI.

3. **Running Tests**:
   - Push to CI to run the full test suite in GitHub Actions (`gh workflow run`).
