import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationNotifierProvider);
    final unread =
        notifications.where((notification) => !notification.isRead).toList();
    final read =
        notifications.where((notification) => notification.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(notificationNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 128),
          children: [
            _AlertOverviewCard(
              unreadCount: unread.length,
              totalCount: notifications.length,
            ),
            const SizedBox(height: 18),
            if (notifications.isEmpty)
              const _EmptyAlertsCard()
            else ...[
              if (unread.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Active Risk',
                  detail:
                      '${unread.length} new alert${unread.length == 1 ? '' : 's'}',
                  color: AppTheme.accentAmber,
                ),
                const SizedBox(height: 10),
                ...unread.map((notification) =>
                    NotificationCard(notification: notification)),
                const SizedBox(height: 18),
              ],
              if (read.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Cleared Queue',
                  detail: '${read.length} reviewed',
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 10),
                ...read.map((notification) =>
                    NotificationCard(notification: notification)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AlertOverviewCard extends StatelessWidget {
  final int unreadCount;
  final int totalCount;

  const _AlertOverviewCard({
    required this.unreadCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.panelDecoration(emphasized: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPRAY WATCH',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryGreenLight,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            unreadCount == 0
                ? 'No active spray alerts'
                : '$unreadCount alert${unreadCount == 1 ? '' : 's'} need review',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            unreadCount == 0
                ? 'Neighboring spray activity is currently clear. New alerts will surface here as soon as they arrive.'
                : 'Review high-risk notifications first so field plans can be adjusted before neighboring spray windows begin.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'UNREAD',
                  value: unreadCount.toString(),
                  tone: unreadCount == 0
                      ? AppTheme.primaryGreenLight
                      : AppTheme.accentAmber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewStat(
                  label: 'TOTAL',
                  value: totalCount.toString(),
                  tone: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _OverviewStat({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.panelStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSoft,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(color: tone),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlertsCard extends StatelessWidget {
  const _EmptyAlertsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.panelDecoration(),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 30,
              color: AppTheme.primaryGreenLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You will be notified when a neighboring farm plans a spray operation near one of your mapped fields.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String detail;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Text(
            detail,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
