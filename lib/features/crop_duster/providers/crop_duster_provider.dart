import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/crop_duster_repository.dart';
import '../data/models/crop_duster_service.dart';
import '../../farm_map/data/models/field.dart';
import '../../farm_map/providers/farm_map_provider.dart';
import '../../spray_planning/data/models/spray_plan.dart';
import '../../spray_planning/providers/spray_plan_provider.dart';

class CropDusterContactPayload {
  const CropDusterContactPayload({
    required this.fieldName,
    required this.chemicalNames,
    required this.dangerCount,
    this.lat,
    this.lng,
    this.sourcePlanId,
  });

  final String fieldName;
  final List<String> chemicalNames;
  final int dangerCount;
  final double? lat;
  final double? lng;
  final String? sourcePlanId;

  bool get hasRequiredContext => fieldName.trim().isNotEmpty;
}

CropDusterContactPayload mapSavedPlanToContactPayload({
  required SprayPlan plan,
  double? lat,
  double? lng,
}) {
  final names = <String>{};
  for (final chemical in plan.chemicals) {
    final name = chemical.name.trim();
    if (name.isNotEmpty) {
      names.add(name);
    }
  }

  return CropDusterContactPayload(
    fieldName: (plan.fieldName ?? '').trim().isEmpty
        ? 'My Field'
        : plan.fieldName!.trim(),
    chemicalNames: names.toList(growable: false),
    dangerCount: plan.dangerousAdjacentFieldIds.length,
    lat: lat,
    lng: lng,
    sourcePlanId: plan.id.isEmpty ? null : plan.id,
  );
}

final cropDusterRepositoryProvider = Provider<CropDusterRepository>((ref) {
  return CropDusterRepository(Supabase.instance.client);
});

final nearbyServicesProvider =
    FutureProvider.autoDispose<List<CropDusterService>>((ref) async {
  final center = ref.watch(mapCenterProvider);
  final result = await ref.watch(cropDusterRepositoryProvider).getNearbyServices(
        lat: center.latitude,
        lng: center.longitude,
      );
  return result.fold((_) => [], (s) => s);
});

final cropDusterSearchQueryProvider = StateProvider<String>((ref) => '');

final cropDusterSearchResultsProvider =
    FutureProvider.autoDispose<List<CropDusterService>>((ref) async {
  final query = ref.watch(cropDusterSearchQueryProvider);
  if (query.isEmpty) return ref.watch(nearbyServicesProvider).value ?? [];

  final result = await ref
      .watch(cropDusterRepositoryProvider)
      .searchServices(query);
  return result.fold((_) => [], (s) => s);
});

final selectedServiceProvider = StateProvider<CropDusterService?>((ref) => null);

final contactPayloadProvider = Provider<CropDusterContactPayload?>((ref) {
  final activePlan = ref.watch(sprayPlanNotifierProvider).valueOrNull;
  final fields = ref.watch(myFieldsProvider).valueOrNull ?? const [];

  if (activePlan != null && activePlan.fieldId.isNotEmpty) {
    final matching = fields.where((field) => field.id == activePlan.fieldId);
    final matchingField = matching.isEmpty ? null : matching.first;
    final boundary = matchingField?.latLngBoundary;
    final firstPoint =
        boundary != null && boundary.isNotEmpty ? boundary.first : null;
    return mapSavedPlanToContactPayload(
      plan: activePlan,
      lat: firstPoint?.latitude,
      lng: firstPoint?.longitude,
    );
  }

  final selectedField = ref.watch(selectedFieldProvider);
  if (selectedField == null) return null;

  final selectedChemicals = ref.watch(selectedChemicalsProvider);
  final dangerousFields = ref.watch(dangerousFieldsProvider);
  final names = <String>{};
  for (final chemical in selectedChemicals) {
    final name = chemical.name.trim();
    if (name.isNotEmpty) {
      names.add(name);
    }
  }
  final boundary = selectedField.latLngBoundary;
  final firstPoint = boundary.isNotEmpty ? boundary.first : null;
  return CropDusterContactPayload(
    fieldName: selectedField.name,
    chemicalNames: names.toList(growable: false),
    dangerCount: dangerousFields.length,
    lat: firstPoint?.latitude,
    lng: firstPoint?.longitude,
  );
});
