import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application.dart';
import '../models/roster_member.dart';

/// Provider exposing the SharedPreferences instance.
/// Must be overridden in main() at app boot.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized. Override in ProviderScope.');
});

/// Service class handling local caching of the roster and applications.
class RosterCacheService {
  final SharedPreferences _prefs;
  static const _cacheKey = 'roster_cache';
  static const _applicationsCacheKey = 'applications_cache';

  static final List<Application> _defaultApplications = [
    const Application(
      id: 'app-01',
      submittedAt: '2026-07-04T12:00:00Z',
      applicantEmail: 'cillian.fan@example.com',
      characterName: 'Alistair Vance',
      faction: 'Aethelgard Alliance',
      answers: [
        'I wish to join the sanctuary to archive precision movements and rare gold timepieces.',
        'My lineage dates back to the old clockmakers of Zurich.',
        'I will dedicate my watches to the grand archive of time.'
      ],
      status: 'Pending',
    ),
    const Application(
      id: 'app-02',
      submittedAt: '2026-07-04T14:30:00Z',
      applicantEmail: 'clara.oswald@example.com',
      characterName: 'Clara Oswald',
      faction: 'Elysium Chrono Syndicate',
      answers: [
        'Time is a canvas, and watches are the paintbrushes.',
        'I travel across timelines to preserve chronological sanity.',
        'I seek entry to share my collection of pocket-watch singularities.'
      ],
      status: 'Pending',
    ),
  ];

  static final List<RosterMember> _defaultRoster = [
    const RosterMember(
      id: 'member-01',
      characterName: 'Alistair Vance',
      playerName: 'Admin',
      faction: 'Aethelgard Alliance',
      faceclaimName: 'Cillian Murphy',
      faceclaimImgUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      status: 'Active',
      joinedDate: '2026-01-15',
    ),
    const RosterMember(
      id: 'member-02',
      characterName: 'Lorna Cole',
      playerName: 'Lorna',
      faction: 'Vanguard Order',
      faceclaimName: 'Jenna Coleman',
      faceclaimImgUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
      status: 'Active',
      joinedDate: '2026-02-20',
    ),
  ];

  RosterCacheService(this._prefs);

  /// Loads the roster members from the local cache.
  /// 
  /// Returns an empty list if no cache is present or if deserialization fails.
  List<RosterMember> loadRoster() {
    final jsonStr = _prefs.getString(_cacheKey);
    if (jsonStr == null) {
      // Seed default roster
      saveRoster(_defaultRoster);
      return _defaultRoster;
    }

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

  /// Loads the pending applications from the local cache.
  List<Application> loadApplications() {
    final jsonStr = _prefs.getString(_applicationsCacheKey);
    if (jsonStr == null) {
      // Seed default applications
      saveApplications(_defaultApplications);
      return _defaultApplications;
    }

    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((item) => Application.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the pending applications list to local storage.
  Future<void> saveApplications(List<Application> apps) async {
    final jsonStr = jsonEncode(apps.map((a) => a.toJson()).toList());
    await _prefs.setString(_applicationsCacheKey, jsonStr);
  }
}

/// Provider exposing the RosterCacheService.
final rosterCacheServiceProvider = Provider<RosterCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RosterCacheService(prefs);
});
