import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/admittance/admittance_screen.dart';
import '../features/chronicles/chronicles_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/roster/roster_screen.dart';
import '../main.dart';
import '../services/auth_service.dart';

final appRouterHelperProvider = Provider<AppRouterHelper>((ref) {
  return AppRouterHelper(ref);
});

class AppRouterHelper {
  final Ref _ref;
  AppRouterHelper(this._ref);

  /// Dynamic guard ensuring that unauthenticated users are forced to `/login`,
  /// and logged-in users cannot access the `/login` screen.
  String? redirectGuard(BuildContext context, GoRouterState state) {
    final user = _ref.read(currentUserProvider);
    final isLoggingIn = state.matchedLocation == '/login';

    if (user == null) {
      // Force user to login screen unless they are already there
      return isLoggingIn ? null : '/login';
    }

    if (isLoggingIn) {
      // Redirect authenticated user back to the secure dashboard
      return '/';
    }

    return null; // Keep route unchanged
  }
}

/// Dynamic value notifier that triggers GoRouter redirects on Auth changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<User?>(currentUserProvider, (previous, next) {
      notifyListeners();
    });
  }
}

/// Global GoRouter provider.
final routerProvider = Provider<GoRouter>((ref) {
  final helper = ref.watch(appRouterHelperProvider);
  final authNotifier = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: helper.redirectGuard,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/admittance',
        builder: (context, state) => const AdmittanceScreen(),
      ),
      GoRoute(
        path: '/chronicles',
        builder: (context, state) => const ChroniclesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/roster',
        builder: (context, state) => const RosterScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login-callback',
        builder: (context, state) {
          final uri = state.uri;
          // Trigger the exchange in the background. As soon as session resolves,
          // currentUserProvider notifies, routing user to '/' dashboard.
          ref.read(authServiceProvider).handleDeepLinkCallback(uri);
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24.0),
                    Text(
                      'Verifying magic link credentials...',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
});
