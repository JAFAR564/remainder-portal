import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/roster_member.dart';
import '../../../services/auth_service.dart';
import '../../../services/roster_cache_service.dart';
import '../../roster/roster_notifier.dart';

/// Notifier driving the active character/avatar identity state.
/// 
/// Resolves which roster characters belong to the currently logged in email,
/// handles switching identities, and persists selections locally.
class ActiveCharacterNotifier extends AsyncNotifier<RosterMember?> {
  static const _activeCharacterKey = 'active_character_id';

  @override
  FutureOr<RosterMember?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    // Watch roster list changes
    final roster = ref.watch(rosterNotifierProvider).value ?? const [];
    final email = user.email ?? '';

    // Filter characters belonging to this player OOC username / email
    final myCharacters = roster.where((member) => _isUserMatch(member.playerName, email)).toList();

    if (myCharacters.isEmpty) {
      // Fallback default virtual character if no approved roster claims exist yet
      return RosterMember(
        id: 'virtual-member',
        characterName: 'Member #01',
        playerName: email.split('@')[0],
        faction: 'Vanguard Order',
        faceclaimName: 'Default Avatar',
        faceclaimImgUrl: '',
        status: 'Active',
        joinedDate: '2026-07-06',
      );
    }

    // Retrieve last saved selection from local storage cache
    final prefs = ref.read(sharedPreferencesProvider);
    final savedId = prefs.getString(_activeCharacterKey);

    if (savedId != null) {
      final active = myCharacters.firstWhere(
        (c) => c.id == savedId,
        orElse: () => myCharacters.first,
      );
      return active;
    }

    return myCharacters.first;
  }

  /// Switch the active character and persist the selection.
  Future<void> switchCharacter(String characterId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final roster = ref.read(rosterNotifierProvider).value ?? const [];
    final email = user.email ?? '';
    final myCharacters = roster.where((member) => _isUserMatch(member.playerName, email)).toList();

    final target = myCharacters.firstWhere(
      (c) => c.id == characterId,
      orElse: () => myCharacters.first,
    );
    
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_activeCharacterKey, target.id);

    state = AsyncValue.data(target);
  }

  /// Gets all characters belonging to the active logged in user.
  List<RosterMember> getMyCharacters() {
    final user = ref.read(currentUserProvider);
    if (user == null) return const [];

    final roster = ref.read(rosterNotifierProvider).value ?? const [];
    final email = user.email ?? '';
    return roster.where((member) => _isUserMatch(member.playerName, email)).toList();
  }

  bool _isUserMatch(String playerName, String email) {
    final cleanPlayer = playerName.toLowerCase().trim();
    final cleanEmail = email.toLowerCase().trim();
    final prefix = cleanEmail.split('@')[0];
    
    if (cleanPlayer == 'admin' && (cleanEmail.contains('admin') || cleanEmail.contains('dev'))) {
      return true;
    }
    return cleanPlayer == prefix || cleanEmail.contains(cleanPlayer);
  }
}

/// Provider exposing the active character/avatar state.
final activeCharacterProvider = AsyncNotifierProvider<ActiveCharacterNotifier, RosterMember?>(() {
  return ActiveCharacterNotifier();
});
