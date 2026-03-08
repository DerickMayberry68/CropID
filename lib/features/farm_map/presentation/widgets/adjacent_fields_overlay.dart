import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/field.dart';
import '../../providers/farm_map_provider.dart';
import '../../../spray_planning/providers/spray_plan_provider.dart';

/// Renders adjacent (neighbor) fields on the map when a field is selected.
/// Fields with dangerous chemical interactions are highlighted in red.
class AdjacentFieldsOverlay extends ConsumerWidget {
  const AdjacentFieldsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjacentAsync = ref.watch(adjacentFieldsProvider);
    final dangerousFieldIds = ref.watch(dangerousFieldsProvider).toSet();

    return adjacentAsync.when(
      loading: () => const PolygonLayer(polygons: []),
      error: (_, __) => const PolygonLayer(polygons: []),
      data: (fields) => PolygonLayer(
        polygons: fields
            .where((f) => f.latLngBoundary.isNotEmpty)
            .map((f) {
              final isDangerous = dangerousFieldIds.contains(f.id);
              return Polygon(
                points: f.latLngBoundary,
                color: isDangerous
                    ? AppTheme.dangerRed.withOpacity(0.4)
                    : AppTheme.accentAmber.withOpacity(0.3),
                borderColor: isDangerous
                    ? AppTheme.dangerRed
                    : AppTheme.accentAmber,
                borderStrokeWidth: 2,
                label: '${f.name}\n${f.currentCropName ?? ''}',
                labelStyle: TextStyle(
                  color: isDangerous ? AppTheme.dangerRed : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            })
            .toList(),
      ),
    );
  }
}
