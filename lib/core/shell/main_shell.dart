import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../../features/notifications/providers/notification_provider.dart';

/// Bottom navigation shell wrapping the main app screens.
/// Designed with large, clear icons for non-tech-savvy farmers.
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.map_outlined, label: 'My Farm', route: AppRoutes.home),
    (
      icon: Icons.science_outlined,
      label: 'Spray Plan',
      route: AppRoutes.sprayPlan
    ),
    (
      icon: Icons.notifications_outlined,
      label: 'Alerts',
      route: AppRoutes.notifications
    ),
    (
      icon: Icons.water_drop_outlined,
      label: 'Spraying Services',
      route: AppRoutes.cropDusters
    ),
    (icon: Icons.person_outline, label: 'Profile', route: AppRoutes.profile),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route) ||
          (i == 0 && location == AppRoutes.home)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex(context);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundBase.withValues(alpha: 0.0),
              AppTheme.backgroundBase,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DecoratedBox(
              decoration: AppTheme.panelDecoration(),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) =>
                    context.go(_tabs[index].route),
                destinations: [
                  for (var i = 0; i < _tabs.length; i++)
                    NavigationDestination(
                      icon: i == 2 && unreadCount > 0
                          ? Badge.count(
                              count: unreadCount,
                              backgroundColor: AppTheme.dangerRed,
                              textColor: Colors.white,
                              child: Icon(_tabs[i].icon),
                            )
                          : Icon(_tabs[i].icon),
                      label: _tabs[i].label,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
