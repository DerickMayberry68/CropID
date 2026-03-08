import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/crop_duster_repository.dart';
import '../data/models/crop_duster_service.dart';
import '../../farm_map/providers/farm_map_provider.dart';

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
