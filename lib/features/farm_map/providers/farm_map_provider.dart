import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/extensions.dart';
import '../data/field_repository.dart';
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
  if (field == null) return 'Select a field before creating a spray plan.';
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
