import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/csb_field.dart';
import '../../providers/farm_map_provider.dart';

/// Renders unclaimed USDA field boundaries as faint "tap to claim" outlines.
///
/// Only visible while claim mode is active. Owned fields keep their solid
/// green styling so claimed and unclaimed land stay visually distinct.
class ClaimableFieldsOverlay extends ConsumerWidget {
  const ClaimableFieldsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimable = ref.watch(csbFieldsNearProvider);

    return claimable.maybeWhen(
      data: (fields) => PolygonLayer(
        polygons: fields
            .map(
              (csb) => Polygon(
                points: csb.latLngBoundary,
                color: AppTheme.skyBlue.withValues(alpha: 0.12),
                borderColor: AppTheme.skyBlue.withValues(alpha: 0.85),
                borderStrokeWidth: 1.5,
              ),
            )
            .toList(),
      ),
      orElse: () => const PolygonLayer(polygons: []),
    );
  }
}

/// Tap targets for claimable boundaries, drawn above the outline layer.
class ClaimableFieldsMarkers extends ConsumerWidget {
  final void Function(CsbField csb) onTap;

  const ClaimableFieldsMarkers({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimable = ref.watch(csbFieldsNearProvider);

    return claimable.maybeWhen(
      data: (fields) => MarkerLayer(
        markers: fields
            .map(
              (csb) => Marker(
                point: csb.latLngBoundary.centroid,
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => onTap(csb),
                  child: Center(
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppTheme.skyBlue.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.backgroundBase,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: AppTheme.backgroundBase,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
      orElse: () => const MarkerLayer(markers: []),
    );
  }
}
