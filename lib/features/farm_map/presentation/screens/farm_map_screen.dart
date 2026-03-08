import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/services/location_service.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../data/models/field.dart';
import '../../providers/farm_map_provider.dart';
import '../widgets/adjacent_fields_overlay.dart';
import 'draw_field_screen.dart';
import 'edit_field_screen.dart';

class FarmMapScreen extends ConsumerStatefulWidget {
  const FarmMapScreen({super.key});

  @override
  ConsumerState<FarmMapScreen> createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends ConsumerState<FarmMapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnUserLocation();
    });
  }

  Future<void> _centerOnUserLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null && mounted) {
      final center = LatLng(position.latitude, position.longitude);
      ref.read(mapCenterProvider.notifier).state = center;
      _mapController.move(center, AppConstants.defaultMapZoom);
    }
  }

  void _onFieldTap(Field field) {
    ref.read(selectedFieldProvider.notifier).state = field;
    _showFieldBottomSheet(field);
  }

  void _showFieldBottomSheet(Field field) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: AppTheme.panelDecoration(emphasized: true),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSoft,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.crop_square_rounded,
                    color: AppTheme.primaryGreenLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field.name,
                          style: Theme.of(ctx).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        field.currentCropName ?? 'Crop not set',
                        style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            icon: Icons.visibility_outlined,
                            label: field.visibility.name.capitalize,
                          ),
                          _StatusChip(
                            icon: Icons.gesture_outlined,
                            label:
                                '${field.latLngBoundary.length} boundary pts',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit field',
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => EditFieldScreen(field: field),
                    ));
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Plan Spray'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(AppRoutes.sprayPlan);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.agriculture_outlined),
                    label: const Text('Services'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(AppRoutes.cropDusters);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myFieldsAsync = ref.watch(myFieldsProvider);
    final selectedField = ref.watch(selectedFieldProvider);
    final adjacentFieldsAsync = ref.watch(adjacentFieldsProvider);
    final center = ref.watch(mapCenterProvider);
    final notifications = ref.watch(notificationNotifierProvider);
    final farmName =
        ref.watch(farmerProfileProvider).valueOrNull?.farmName ?? 'CropID';

    final unreadAlerts =
        notifications.where((notification) => !notification.isRead).toList();
    final latestUnreadAlert = unreadAlerts.isEmpty ? null : unreadAlerts.first;

    final myFieldCount = myFieldsAsync.valueOrNull?.length ?? 0;
    final adjacentCount = adjacentFieldsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DrawFieldScreen()),
        ),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Field'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: AppConstants.defaultMapZoom,
              onTap: (_, __) =>
                  ref.read(selectedFieldProvider.notifier).state = null,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.osmTileUrl,
                userAgentPackageName: 'app.cropid',
              ),
              myFieldsAsync.when(
                loading: () => const PolygonLayer(polygons: []),
                error: (_, __) => const PolygonLayer(polygons: []),
                data: (fields) => PolygonLayer(
                  polygons: fields
                      .where((field) => field.latLngBoundary.isNotEmpty)
                      .map(
                        (field) => Polygon(
                          points: field.latLngBoundary,
                          color: field.id == selectedField?.id
                              ? AppTheme.primaryGreen.withValues(alpha: 0.42)
                              : AppTheme.primaryGreen.withValues(alpha: 0.24),
                          borderColor: field.id == selectedField?.id
                              ? AppTheme.accentAmber
                              : AppTheme.primaryGreenLight,
                          borderStrokeWidth:
                              field.id == selectedField?.id ? 3 : 2,
                          label: field.name,
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (selectedField != null) const AdjacentFieldsOverlay(),
              myFieldsAsync.maybeWhen(
                data: (fields) => MarkerLayer(
                  markers: fields
                      .where((field) => field.latLngBoundary.length >= 3)
                      .map(
                        (field) => Marker(
                          point: field.latLngBoundary.centroid,
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () => _onFieldTap(field),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      )
                      .toList(),
                ),
                orElse: () => const MarkerLayer(markers: []),
              ),
            ],
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundBase.withValues(alpha: 0.90),
                    AppTheme.backgroundBase.withValues(alpha: 0.58),
                    Colors.transparent,
                    AppTheme.backgroundBase.withValues(alpha: 0.25),
                  ],
                  stops: const [0.0, 0.18, 0.42, 1.0],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FarmHeader(
                        farmName: farmName,
                        onLocate: _centerOnUserLocation,
                      ),
                      const SizedBox(height: 14),
                      _OperationsCard(
                        selectedField: selectedField,
                        fieldCount: myFieldCount,
                        adjacentCount: adjacentCount,
                        unreadAlerts: unreadAlerts.length,
                        onPlanSpray: selectedField == null
                            ? null
                            : () => context.push(AppRoutes.sprayPlan),
                        onOpenServices: () =>
                            context.push(AppRoutes.cropDusters),
                      ),
                      if (latestUnreadAlert != null) ...[
                        const SizedBox(height: 14),
                        _UnreadAlertCard(
                          fieldName: latestUnreadAlert.affectedFieldName,
                          senderFarmName: latestUnreadAlert.senderFarmName,
                          onViewAlerts: () =>
                              context.go(AppRoutes.notifications),
                          createdAt: latestUnreadAlert.createdAt,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (myFieldsAsync.isLoading) const LoadingOverlay(),
          myFieldsAsync.maybeWhen(
            data: (fields) => fields.isEmpty
                ? Positioned(
                    left: 16,
                    right: 16,
                    bottom: 118,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: AppTheme.panelDecoration(),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.add_location_alt_outlined,
                                color: AppTheme.primaryGreenLight,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No fields mapped yet. Add your first boundary to start tracking spray risk and neighboring field exposure.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _FarmHeader extends StatelessWidget {
  final String farmName;
  final VoidCallback onLocate;

  const _FarmHeader({
    required this.farmName,
    required this.onLocate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: AppTheme.panelDecoration(),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'C',
                    style: TextStyle(
                      color: Color(0xFF161A13),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CropID',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        farmName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: AppTheme.panelDecoration(),
          child: IconButton(
            tooltip: 'Center on my location',
            onPressed: onLocate,
            icon: const Icon(Icons.my_location_outlined),
          ),
        ),
      ],
    );
  }
}

class _OperationsCard extends StatelessWidget {
  final Field? selectedField;
  final int fieldCount;
  final int adjacentCount;
  final int unreadAlerts;
  final VoidCallback? onPlanSpray;
  final VoidCallback onOpenServices;

  const _OperationsCard({
    required this.selectedField,
    required this.fieldCount,
    required this.adjacentCount,
    required this.unreadAlerts,
    required this.onPlanSpray,
    required this.onOpenServices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.panelDecoration(emphasized: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 18,
                color: AppTheme.primaryGreenLight,
              ),
              const SizedBox(width: 8),
              Text(
                selectedField == null ? 'FIELD COMMAND' : 'ACTIVE FIELD',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryGreenLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            selectedField?.name ?? 'Select a field from the map',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            selectedField == null
                ? 'Tap a mapped boundary to inspect field details, see neighboring exposure, and launch a spray plan.'
                : '${selectedField?.currentCropName ?? 'Crop not set'} • Visibility ${selectedField!.visibility.name.capitalize}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'FIELDS',
                  value: fieldCount.toString(),
                  tone: AppTheme.primaryGreenLight,
                  note: 'Mapped parcels',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'NEIGHBORS',
                  value: adjacentCount.toString(),
                  tone: AppTheme.skyBlue,
                  note:
                      selectedField == null ? 'Pick a field' : 'Nearby fields',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'ALERTS',
                  value: unreadAlerts.toString(),
                  tone: unreadAlerts > 0
                      ? AppTheme.accentAmber
                      : AppTheme.primaryGreenLight,
                  note: unreadAlerts > 0 ? 'Needs review' : 'All clear',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPlanSpray,
                  icon: const Icon(Icons.science_outlined),
                  label: Text(
                    selectedField == null ? 'Select Field' : 'Plan Spray',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenServices,
                  icon: const Icon(Icons.agriculture_outlined),
                  label: const Text('Services'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final Color tone;

  const _StatTile({
    required this.label,
    required this.value,
    required this.note,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundRaised.withValues(alpha: 0.92),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: tone,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _UnreadAlertCard extends StatelessWidget {
  final String? fieldName;
  final String? senderFarmName;
  final DateTime? createdAt;
  final VoidCallback onViewAlerts;

  const _UnreadAlertCard({
    required this.fieldName,
    required this.senderFarmName,
    required this.createdAt,
    required this.onViewAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(borderColor: AppTheme.accentAmber),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.accentAmber,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Drift Risk Alert',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentAmber,
                      ),
                ),
              ),
              if (createdAt != null)
                _StatusChip(
                  icon: Icons.schedule_outlined,
                  label: _timeAgo(createdAt!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            senderFarmName != null
                ? '$senderFarmName plans to spray near ${fieldName ?? 'one of your fields'}. Review the alert before conditions change.'
                : 'A nearby spray plan may affect ${fieldName ?? 'one of your fields'}. Review the alert before conditions change.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: onViewAlerts,
              child: const Text('View Alerts'),
            ),
          ),
        ],
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

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.panelStroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
