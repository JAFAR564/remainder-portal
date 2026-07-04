import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import 'auth_service.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService(this._client);

  /// Retrieves the profile of a given user ID.
  /// Returns null if profile does not exist.
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      debugPrint('Error getting profile: $e');
      rethrow;
    }
  }

  /// Saves (creates or updates) the user profile.
  Future<Profile> saveProfile(Profile profile) async {
    try {
      final data = profile.toJson();
      final response = await _client
          .from('profiles')
          .upsert(data)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      debugPrint('Error saving profile: $e');
      rethrow;
    }
  }
}

/// Provider exposing the ProfileService.
final profileServiceProvider = Provider<ProfileService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileService(client);
});

/// AsyncNotifier provider managing the current user's profile state.
final userProfileProvider = AsyncNotifierProvider<UserProfileNotifier, Profile?>(() {
  return UserProfileNotifier();
});

class UserProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;
    return ref.read(profileServiceProvider).getProfile(user.id);
  }

  Future<void> updateProfile({
    required String characterName,
    required String faction,
    required String faceclaim,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('User not authenticated');

    final updated = Profile(
      id: user.id,
      characterName: characterName,
      faction: faction,
      faceclaim: faceclaim,
    );

    state = const AsyncValue.loading();
    try {
      final saved = await ref.read(profileServiceProvider).saveProfile(updated);
      state = AsyncValue.data(saved);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
