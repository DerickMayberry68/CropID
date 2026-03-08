import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/farm_map/presentation/screens/farm_map_screen.dart';
import '../../features/spray_planning/presentation/screens/spray_plan_screen.dart';
import '../../features/spray_planning/presentation/screens/chemical_selector_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/crop_duster/presentation/screens/crop_duster_screen.dart';
import '../../features/crop_duster/presentation/screens/contact_screen.dart';
import '../shell/main_shell.dart';

/// Bridges a [Stream] to [ChangeNotifier] so GoRouter re-evaluates
/// its redirect whenever the auth state changes (sign in / sign out).
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ── Route path constants ──────────────────────────────────────────────────
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';           // → FarmMapScreen (shell tab 0)
  static const String sprayPlan = '/spray-plan';
  static const String chemicalSelector = '/spray-plan/chemicals';
  static const String notifications = '/notifications';
  static const String cropDusters = '/crop-dusters';
  static const String cropDusterContact = '/crop-dusters/contact';
  static const String profile = '/profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(
    Supabase.instance.client.auth.onAuthStateChange,
  );
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── Auth (no shell) ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Main shell (bottom nav) ────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const FarmMapScreen(),
          ),
          GoRoute(
            path: AppRoutes.sprayPlan,
            builder: (_, __) => const SprayPlanScreen(),
            routes: [
              GoRoute(
                path: 'chemicals',
                builder: (_, __) => const ChemicalSelectorScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.cropDusters,
            builder: (_, __) => const CropDusterScreen(),
            routes: [
              GoRoute(
                path: 'contact',
                builder: (_, state) {
                  // TODO: Pass crop duster service ID via extra
                  return const ContactScreen();
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
