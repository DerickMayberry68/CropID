import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_id/core/constants/app_constants.dart';
import 'package:crop_id/features/notifications/data/models/danger_notification.dart';
import 'package:crop_id/features/notifications/presentation/widgets/notification_card.dart';

void main() {
  testWidgets('notification card shows unread and reviewed status labels',
      (tester) async {
    final unread = DangerNotification(
      id: 'n1',
      recipientFarmerId: 'f1',
      senderFarmerId: 'f2',
      sprayPlanId: 'p1',
      affectedFieldId: 'field-1',
      affectedFieldName: 'North 40',
      createdAt: DateTime.parse('2026-03-08T12:00:00Z'),
    );
    final reviewed = unread.copyWith(id: 'n2', isRead: true);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NotificationCard(notification: unread),
                NotificationCard(notification: reviewed),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text(AppConstants.alertStateUnreadLabel), findsOneWidget);
    expect(find.text(AppConstants.alertStateReviewedLabel), findsOneWidget);
    expect(find.textContaining('North 40 may be at risk'), findsNWidgets(2));
  });
}
