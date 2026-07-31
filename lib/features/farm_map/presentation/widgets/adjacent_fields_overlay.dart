import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/farm_map_provider.dart';
import '../../../spray_planning/providers/spray_plan_provider.dart';

/// Renders the neighborhood around the selected field.
///
/// Three tiers, drawn back to front:
///  * unclaimed USDA boundaries — grey, nobody on CropID owns these yet
///  * claimed neighbor fields   — amber, with whatever crop the owner shared
///  * dangerous neighbors       — red, the crop conflicts with the planned mix
class AdjacentFieldsOverlay extends ConsumerWidget {
  const AdjacentFieldsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neighborsAsync = ref.watch(neighborFieldsProvider);
    final surroundingAsync = ref.watch(surroundingCsbFieldsProvider);
    final dangerousFieldIds = ref.watch(dangerousFieldsProvider).toSet();

    final polygons = <Polygon>[];

    // Unclaimed USDA boundaries first, so claimed fields draw over them.
    for (final csb in surroundingAsync.valueOrNull ?? const []) {
      polygons.add(
        Polygon(
          points: csb.latLngBoundary,
          color: AppTheme.textSoft.withValues(alpha: 0.10),
          borderColor: AppTheme.textSoft.withValues(alpha: 0.55),
          borderStrokeWidth: 1,
          label: csb.cropLabel,
          labelStyle: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    for (final field in neighborsAsync.valueOrNull ?? const []) {
      if (field.latLngBoundary.isEmpty) continue;
      final isDangerous = dangerousFieldIds.contains(field.id);
      polygons.add(
        Polygon(
          points: field.latLngBoundary,
          color: isDangerous
              ? AppTheme.dangerRed.withValues(alpha: 0.40)
              : AppTheme.accentAmber.withValues(alpha: 0.30),
          borderColor:
              isDangerous ? AppTheme.dangerRed : AppTheme.accentAmber,
          borderStrokeWidth: 2,
          label: _neighborLabel(field.currentCropName),
          labelStyle: TextStyle(
            color: isDangerous ? AppTheme.dangerRed : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return PolygonLayer(polygons: polygons);
  }

  /// Neighbor field names are withheld — only the crop matters for drift risk,
  /// and owners share fields anonymously by default.
  static String _neighborLabel(String? cropName) =>
      (cropName == null || cropName.trim().isEmpty) ? 'Crop not set' : cropName;
}
