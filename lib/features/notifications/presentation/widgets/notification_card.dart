import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/danger_notification.dart';
import '../../providers/notification_provider.dart';

class NotificationCard extends ConsumerWidget {
  final DangerNotification notification;
  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tone =
        notification.isRead ? AppTheme.textMuted : AppTheme.accentAmber;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (!notification.isRead) {
              ref
                  .read(notificationNotifierProvider.notifier)
                  .markAsRead(notification.id);
            }
          },
          child: Ink(
            decoration: AppTheme.panelDecoration(
              borderColor: notification.isRead
                  ? AppTheme.panelStroke
                  : AppTheme.accentAmber,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: tone.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: tone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.affectedFieldName != null
                                  ? '${notification.affectedFieldName} may be at risk'
                                  : 'Nearby spray planned',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.senderFarmName != null
                                  ? 'Source: ${notification.senderFarmName}'
                                  : 'Neighbor spray alert',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _MetaBadge(
                        label: notification.isRead
                            ? AppConstants.alertStateReviewedLabel
                            : AppConstants.alertStateUnreadLabel,
                        highlight: !notification.isRead,
                      ),
                    ],
                  ),
                  if (notification.dangerousChemicalNames.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: notification.dangerousChemicalNames
                          .take(4)
                          .map(
                            (chemical) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundRaised,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.panelStroke),
                              ),
                              child: Text(
                                chemical,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.textMuted),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.createdAt == null
                              ? (notification.sprayScheduledDate != null
                                  ? 'Scheduled ${notification.sprayScheduledDate!.shortDate}'
                                  : 'Schedule not provided')
                              : _timeAgo(notification.createdAt!),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentAmber,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final bool highlight;

  const _MetaBadge({
    required this.label,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppTheme.accentAmber : AppTheme.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}
