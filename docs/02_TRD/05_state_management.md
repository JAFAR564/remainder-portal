# TRD §2.6 — State Management Architecture (Riverpod)

> **Part of:** Module 2: Technical Requirement Document
> **Navigation:** Up from `04_vibe_coding_pipeline.md` | Next to `06_responsive_layout_and_auth.md`

---

```mermaid
graph TD
    subgraph "Provider Layer"
        P1[authProvider\nAsyncNotifierProvider]
        P2[rosterProvider\nAsyncNotifierProvider]
        P3[admittanceProvider\nNotifierProvider]
        P4[chroniclesProvider\nAsyncNotifierProvider]
        P5[aiGradingProvider\nAsyncNotifierProvider]
    end

    subgraph "Data Sources"
        D1[SheetsService]
        D2[AIRouterService]
        D3[OKFService]
        D4[SupabaseClient]
    end

    subgraph "UI Layer"
        U1[RosterScreen\nConsumerWidget]
        U2[AdmittanceScreen\nConsumerWidget]
        U3[ChroniclesScreen\nConsumerWidget]
        U4[ProfileScreen\nConsumerWidget]
    end

    P1 --> D4
    P2 --> D1
    P3 --> D1
    P4 --> D1
    P5 --> D2 & D3

    U1 --> P2
    U2 --> P3 & P5
    U3 --> P4
    U4 --> P2 & P1
```

### Provider Implementation Pattern

```dart
// lib/features/admittance/providers/admittance_provider.dart
@riverpod
class AdmittanceNotifier extends _$AdmittanceNotifier {
  @override
  Future<List<Application>> build() async {
    return ref.watch(sheetsServiceProvider).fetchPendingApplications();
  }

  Future<void> decideApplication({
    required String appId,
    required AdminDecision decision,
  }) async {
    // Optimistic update
    state = AsyncData(state.value!.where((a) => a.id != appId).toList());
    try {
      await ref.read(sheetsServiceProvider).writeAdmittanceDecision(
        appId: appId,
        decision: decision.name,
        deepseekScore: ref.read(aiGradingProvider(appId)).value?.deepseekScore ?? 0,
        groqFlags: ref.read(aiGradingProvider(appId)).value?.groqFlags ?? [],
      );
    } catch (e) {
      // Rollback on error
      ref.invalidateSelf();
      rethrow;
    }
  }
}
```
