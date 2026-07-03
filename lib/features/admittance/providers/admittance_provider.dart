import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/application.dart';
import '../../../services/sheets_service.dart';

import '../../../services/roster_cache_service.dart';

/// Provider exposing whether the admittance portal is running in offline fallback mode.
final admittanceOfflineProvider = StateProvider<bool>((ref) => false);

/// Notifier driving the list of pending applications under review.
class AdmittanceNotifier extends AsyncNotifier<List<Application>> {
  @override
  FutureOr<List<Application>> build() async {
    try {
      final networkApps = await ref.read(sheetsServiceProvider).fetchPendingApplications();
      // Silently cache successful fetch locally
      await ref.read(rosterCacheServiceProvider).saveApplications(networkApps);
      ref.read(admittanceOfflineProvider.notifier).state = false;
      return networkApps;
    } catch (e) {
      // Offline fallback: load from local cache instead of throwing error
      final cachedApps = ref.read(rosterCacheServiceProvider).loadApplications();
      ref.read(admittanceOfflineProvider.notifier).state = true;
      return cachedApps;
    }
  }

  /// Logs the final administrative decision, updating the UI optimistically.
  Future<void> decideApplication({
    required String appId,
    required String decision,
    required double deepseekScore,
    required List<String> groqFlags,
  }) async {
    final previousState = state.value;
    if (previousState == null) return;

    // 1. Optimistic Update: instantly remove from pending list
    state = AsyncValue.data(
      previousState.where((app) => app.id != appId).toList(),
    );

    try {
      // 2. Outbound writing via proxy
      await ref.read(sheetsServiceProvider).writeAdmittanceDecision(
        appId: appId,
        decision: decision,
        deepseekScore: deepseekScore,
        groqFlags: groqFlags,
      );
    } catch (_) {
      // 3. Rollback on failure
      state = AsyncValue.data(previousState);
      rethrow;
    }
  }
}

/// Provider exposing the AdmittanceNotifier.
final admittanceNotifierProvider =
    AsyncNotifierProvider<AdmittanceNotifier, List<Application>>(() {
  return AdmittanceNotifier();
});
