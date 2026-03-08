import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../shared/services/supabase_service.dart';
import 'models/danger_notification.dart';

class NotificationRepository {
  final SupabaseClient _client;
  NotificationRepository(this._client);

  Future<Either<String, List<DangerNotification>>> getNotifications(
      String farmerId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.dangerNotificationsTable)
          .select()
          .eq('recipient_farmer_id', farmerId)
          .order('created_at', ascending: false);
      final mapped = (data as List)
          .whereType<Map<String, dynamic>>()
          .map(DangerNotification.fromJson)
          .toList();
      return Right(mapped);
    } catch (e) {
      return Left(SupabaseService.toUserMessage(e));
    }
  }

  Future<Either<String, void>> markAsRead(String notificationId) async {
    try {
      await _client
          .from(SupabaseConstants.dangerNotificationsTable)
          .update({'is_read': true}).eq('id', notificationId);
      return const Right(null);
    } catch (e) {
      return Left(SupabaseService.toUserMessage(e));
    }
  }

  /// Subscribe to new notifications for this farmer via Supabase Realtime.
  RealtimeChannel subscribeToNotifications(
    String farmerId,
    void Function(DangerNotification) onNew,
  ) {
    return _client
        .channel(SupabaseConstants.notificationsChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.dangerNotificationsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_farmer_id',
            value: farmerId,
          ),
          callback: (payload) {
            try {
              onNew(DangerNotification.fromJson(payload.newRecord));
            } catch (_) {
              // Ignore malformed realtime payloads; next refresh repairs state.
            }
          },
        )
        .subscribe();
  }
}
