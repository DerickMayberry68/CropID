import 'package:flutter_test/flutter_test.dart';
import 'package:crop_id/core/utils/extensions.dart';
import 'package:crop_id/features/notifications/data/models/danger_notification.dart';

void main() {
  test('mark read transformation persists read state and preserves ordering',
      () {
    final now = DateTime.parse('2026-03-08T12:00:00Z');
    final existing = [
      DangerNotification(
        id: 'n2',
        recipientFarmerId: 'f1',
        senderFarmerId: 'f2',
        sprayPlanId: 'p2',
        affectedFieldId: 'field-2',
        createdAt: now,
      ),
      DangerNotification(
        id: 'n1',
        recipientFarmerId: 'f1',
        senderFarmerId: 'f3',
        sprayPlanId: 'p1',
        affectedFieldId: 'field-1',
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
    ];

    final updated = existing
        .map((n) => n.id == 'n2' ? n.copyWith(isRead: true) : n)
        .toList()
        .sortedByCreatedAtDesc(
          createdAt: (n) => n.createdAt,
          stableId: (n) => n.id,
        );

    expect(updated.first.id, 'n2');
    expect(updated.first.isRead, isTrue);
    expect(updated.last.id, 'n1');
  });
}
