import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/notification_repository.dart';
import '../data/models/danger_notification.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/services/local_notification_service.dart';

// ── Repository provider ────────────────────────────────────────────────────

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

// ── Notification state notifier ───────────────────────────────────────────
/// Loads notifications on init and subscribes to Realtime for live updates.
/// New arrivals are prepended to state and trigger a local push notification.

class NotificationNotifier extends StateNotifier<List<DangerNotification>> {
  final NotificationRepository _repo;
  final String _farmerId;
  RealtimeChannel? _channel;

  NotificationNotifier(this._repo, this._farmerId) : super([]) {
    if (_farmerId.isNotEmpty) {
      _load();
      _subscribe();
    }
  }

  Future<void> _load() async {
    final result = await _repo.getNotifications(_farmerId);
    if (mounted) {
      result.fold((_) {}, (list) => state = _normalize(list));
    }
  }

  void _subscribe() {
    _channel = _repo.subscribeToNotifications(_farmerId, (notification) {
      if (!mounted) return;
      state = _normalize([notification, ...state]);

      // Fire local push on mobile
      LocalNotificationService.showDangerAlert(
        title:
            '⚠️ Spray Alert — ${notification.affectedFieldName ?? 'Your field'}',
        body: notification.senderFarmName != null
            ? '${notification.senderFarmName} is planning to spray near your crops.'
            : 'A neighbor is planning to spray near your crops.',
      );
    });
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    if (mounted) {
      state = _normalize(
          state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList());
    }
  }

  Future<void> refresh() => _load();

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  List<DangerNotification> _normalize(List<DangerNotification> input) {
    final byId = <String, DangerNotification>{};
    for (final notification in input) {
      final existing = byId[notification.id];
      if (existing == null) {
        byId[notification.id] = notification;
        continue;
      }
      final existingTime = existing.createdAt;
      final incomingTime = notification.createdAt;
      if (incomingTime != null &&
          (existingTime == null || incomingTime.isAfter(existingTime))) {
        byId[notification.id] = notification;
      } else if (existingTime == incomingTime && notification.isRead) {
        // Preserve read state when timestamps tie.
        byId[notification.id] = notification;
      }
    }

    return byId.values.sortedByCreatedAtDesc(
      createdAt: (n) => n.createdAt,
      stableId: (n) => n.id,
    );
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, List<DangerNotification>>(
        (ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repo, user?.id ?? '');
});

// ── Unread count (for badge) ───────────────────────────────────────────────

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationNotifierProvider).where((n) => !n.isRead).length;
});
