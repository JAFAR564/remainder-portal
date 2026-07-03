import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider exposing the default SupabaseClient instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Exposes the live stream of AuthState changes from Supabase.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Exposes the current active user, if logged in.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

/// Service class handling passwordless Magic Link OTP triggers and sessions.
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Triggers a passwordless Magic Link (OTP) sign-in email.
  /// 
  /// The email contains the custom transaction hash token redirect link.
  Future<void> signInWithOtp({required String email}) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : 'com.remainder.portal://login-callback',
      );
    } on AuthException catch (e) {
      debugPrint('Supabase OTP Sign In Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Supabase OTP Sign In Error: $e');
      rethrow;
    }
  }

  /// Exposes standard sign out functionality.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Supabase Sign Out Error: $e');
    }
  }

  /// Explicitly handle the verification token callback (exchange the code for session)
  /// when intercepting Universal/App Link deep link redirects.
  Future<void> handleDeepLinkCallback(Uri uri) async {
    try {
      if (_client.auth.currentSession != null) return;
      
      // Supabase handles query parameter parsing internally if the uri matches standard callbacks
      await _client.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('Supabase deep link exchange error: $e');
      rethrow;
    }
  }
}

/// Provider exposing the AuthService instance.
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});
