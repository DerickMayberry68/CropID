import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';
import '../data/field_repository.dart';
import '../data/models/csb_field.dart';
import '../data/models/field.dart';
import '../../auth/providers/auth_provider.dart';

// ── Repository provider ───────────────────────────────────────────────────

final fieldRepositoryProvider = Provider<FieldRepository>((ref) {
  return FieldRepository(Supabase.instance.client);
});

// ── My fields ─────────────────────────────────────────────────────────────

final myFieldsProvider = FutureProvider.autoDispose<List<Field>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(fieldRepositoryProvider);
  final result = await repo.getMyFields(user.id);
  return result.fold((_) => [], (fields) => fields);
});

// ── Selected field ────────────────────────────────────────────────────────

final selectedFieldProvider = StateProvider<Field?>((ref) => null);

final selectedFieldPlanningReadyProvider = Provider<bool>((ref) {
  final field = ref.watch(selectedFieldProvider);
  if (field == null) return false;
  if (field.id.trim().isEmpty || field.name.trim().isEmpty) return false;
  return field.boundaryPoints.length >= 3;
});

final selectedFieldPlanningMessageProvider = Provider<String?>((ref) {
  final field = ref.watch(selectedFieldProvider);
  if (field == null) {
    return 'Select a field before creating an application plan.';
  }
  if (field.id.trim().isEmpty || field.name.trim().isEmpty) {
    return 'Selected field is missing required details.';
  }
  if (field.boundaryPoints.length < 3) {
    return 'Selected field boundary is incomplete.';
  }
  return null;
});

// ── Adjacent fields ───────────────────────────────────────────────────────

final adjacentFieldsProvider =
    FutureProvider.autoDispose<List<Field>>((ref) async {
  final selected = ref.watch(selectedFieldProvider);
  if (selected == null) return [];

  final user = ref.watch(currentUserProvider);
  final boundary = selected.latLngBoundary;
  final centroid = boundary.length >= 3 ? boundary.centroid : null;

  if (centroid == null) return [];

  final repo = ref.watch(fieldRepositoryProvider);
  final result = await repo.getAdjacentFields(
    lat: centroid.latitude,
    lng: centroid.longitude,
    excludeFarmerId: user?.id,
  );
  return result.fold((_) => [], (fields) => fields);
});

// ── Map center ────────────────────────────────────────────────────────────

final mapCenterProvider = StateProvider<LatLng>(
  (_) => const LatLng(39.5, -98.35), // Default: center of the US
);

// ── Claim a field (USDA CSB boundaries) ───────────────────────────────────

/// Whether the map is in "claim mode", showing unclaimed USDA boundaries
/// that the farmer can tap to take ownership of.
final claimModeProvider = StateProvider<bool>((_) => false);

/// Unclaimed USDA boundaries near the current map center.
/// Only loaded while claim mode is active, so normal map use stays light.
final csbFieldsNearProvider =
    FutureProvider.autoDispose<List<CsbField>>((ref) async {
  if (!ref.watch(claimModeProvider)) return [];

  final center = ref.watch(mapCenterProvider);
  final repo = ref.watch(fieldRepositoryProvider);
  final result = await repo.getCsbFieldsNear(
    lat: center.latitude,
    lng: center.longitude,
    radiusMeters: AppConstants.claimSearchRadiusMeters,
  );
  return result.fold((_) => [], (fields) => fields);
});

/// Claims a USDA boundary as an owned field.
/// Returns `null` on success, or an error message to surface to the farmer.
final claimCsbFieldProvider = Provider<
    Future<String?> Function({required String csbId, String? name})>((ref) {
  return ({required String csbId, String? name}) async {
    final repo = ref.read(fieldRepositoryProvider);
    final result = await repo.claimCsbField(csbId: csbId, name: name);

    return result.fold(
      (error) => error,
      (field) {
        // Refresh owned fields and the claimable layer, then select the new
        // field so the farmer lands straight in the normal field workflow.
        ref.invalidate(myFieldsProvider);
        ref.invalidate(csbFieldsNearProvider);
        ref.read(selectedFieldProvider.notifier).state = field;
        return null;
      },
    );
  };
});
