import 'package:flutter_test/flutter_test.dart';
import 'package:crop_id/core/utils/extensions.dart';
import 'package:crop_id/features/notifications/data/models/danger_notification.dart';

void main() {
  test('notifications are ordered newest-first with stable id tie-breaker', () {
    final now = DateTime.parse('2026-03-08T12:00:00Z');
    final notifications = [
      DangerNotification(
        id: 'b',
        recipientFarmerId: 'f1',
        senderFarmerId: 'f2',
        sprayPlanId: 'p1',
        affectedFieldId: 'field-1',
        affectedFieldName: 'North 40',
        createdAt: now,
      ),
      DangerNotification(
        id: 'a',
        recipientFarmerId: 'f1',
        senderFarmerId: 'f3',
        sprayPlanId: 'p2',
        affectedFieldId: 'field-2',
        affectedFieldName: 'South 20',
        createdAt: now,
      ),
      DangerNotification(
        id: 'c',
        recipientFarmerId: 'f1',
        senderFarmerId: 'f4',
        sprayPlanId: 'p3',
        affectedFieldId: 'field-3',
        affectedFieldName: 'West 10',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];

    final sorted = notifications.sortedByCreatedAtDesc(
      createdAt: (n) => n.createdAt,
      stableId: (n) => n.id,
    );

    expect(sorted.map((n) => n.id).toList(), ['a', 'b', 'c']);
    expect(sorted.first.affectedFieldName, 'South 20');
    expect(sorted.last.affectedFieldName, 'West 10');
  });
}
