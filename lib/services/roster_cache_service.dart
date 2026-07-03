import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/roster_member.dart';

/// Provider exposing the SharedPreferences instance.
/// Must be overridden in main() at app boot.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized. Override in ProviderScope.');
});

/// Service class handling local caching of the roster.
class RosterCacheService {
  final SharedPreferences _prefs;
  static const _cacheKey = 'roster_cache';

  RosterCacheService(this._prefs);

  /// Loads the roster members from the local cache.
  /// 
  /// Returns an empty list if no cache is present or if deserialization fails.
  List<RosterMember> loadRoster() {
    final jsonStr = _prefs.getString(_cacheKey);
    if (jsonStr == null) return [];

    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((item) => RosterMember.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // Fallback on parse exceptions
    }
  }

  /// Persists the roster members list to local storage.
  Future<void> saveRoster(List<RosterMember> roster) async {
    final jsonStr = jsonEncode(roster.map((m) => m.toJson()).toList());
    await _prefs.setString(_cacheKey, jsonStr);
  }
}

/// Provider exposing the RosterCacheService.
final rosterCacheServiceProvider = Provider<RosterCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RosterCacheService(prefs);
});
