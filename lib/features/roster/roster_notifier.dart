import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/roster_member.dart';
import '../../services/roster_cache_service.dart';
import '../../services/sheets_service.dart';

/// An AsyncNotifier managing the Roster state.
/// 
/// Employs an offline-first caching pattern: instantly returns the local
/// SharedPreferences cache, then schedules a background sync to fetch the latest
/// data from the cloud.
class RosterNotifier extends AsyncNotifier<List<RosterMember>> {
  @override
  FutureOr<List<RosterMember>> build() {
    // 1. Immediately return the local offline cache
    final cacheService = ref.read(rosterCacheServiceProvider);
    final cachedRoster = cacheService.loadRoster();

    // 2. Schedule a silent background sync to retrieve database updates
    scheduleMicrotask(() => fetchAndSyncRoster());

    return cachedRoster;
  }

  /// Silent background fetch from remote API.
  /// 
  /// Updates the local device cache and shifts the state to match.
  Future<void> fetchAndSyncRoster() async {
    try {
      // Connect to the Cloud Run Sheets Proxy
      final remoteRoster = await ref.read(sheetsServiceProvider).fetchRoster();
      
      // Update local storage
      final cacheService = ref.read(rosterCacheServiceProvider);
      await cacheService.saveRoster(remoteRoster);

      // Update state silently without forcing a loading spinner overlay
      state = AsyncValue.data(remoteRoster);
    } catch (e) {
      debugPrint('Roster silent background synchronization failed: $e');
      // Keep displaying the cached data on network failures
    }
  }
}

/// Provider exposing the RosterNotifier.
final rosterNotifierProvider = AsyncNotifierProvider<RosterNotifier, List<RosterMember>>(() {
  return RosterNotifier();
});
