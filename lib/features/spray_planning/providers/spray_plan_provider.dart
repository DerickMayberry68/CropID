import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/chemical_repository.dart';
import '../data/models/chemical.dart';
import '../data/models/spray_plan.dart';
import '../../auth/providers/auth_provider.dart';
import '../../farm_map/providers/farm_map_provider.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../shared/services/supabase_service.dart';
import 'spray_plan_save_state.dart';

// ── Repository provider ───────────────────────────────────────────────────

final chemicalRepositoryProvider = Provider<ChemicalRepository>((ref) {
  return ChemicalRepository(Supabase.instance.client);
});

// ── All chemicals (for selector screen) ──────────────────────────────────

final allChemicalsProvider =
    FutureProvider.autoDispose<List<Chemical>>((ref) async {
  final result = await ref.watch(chemicalRepositoryProvider).getAllChemicals();
  return result.fold((_) => [], (c) => c);
});

// ── Chemical search ───────────────────────────────────────────────────────

final chemicalSearchQueryProvider = StateProvider<String>((ref) => '');

final chemicalSearchResultsProvider =
    FutureProvider.autoDispose<List<Chemical>>((ref) async {
  final query = ref.watch(chemicalSearchQueryProvider);
  if (query.isEmpty) return ref.watch(allChemicalsProvider).value ?? [];

  final result =
      await ref.watch(chemicalRepositoryProvider).searchChemicals(query);
  return result.fold((_) => [], (c) => c);
});

// ── Currently selected chemicals for a plan ───────────────────────────────

final selectedChemicalsProvider = StateProvider<List<Chemical>>((ref) => []);

// ── Active spray plan state ───────────────────────────────────────────────

class SprayPlanNotifier extends StateNotifier<AsyncValue<SprayPlan?>> {
  final Ref _ref;
  final ChemicalRepository _repo;
  final String? _farmerId;

  SprayPlanNotifier(this._ref, this._repo, this._farmerId)
      : super(const AsyncValue.data(null));

  List<String>? _lastDangerousFieldIds;
  List<String>? _lastChemicalNames;

  void initForField(String fieldId, String fieldName) {
    if (_farmerId == null) return;
    _ref.read(sprayPlanSaveStateProvider.notifier).state =
        SprayPlanSaveState.idle;
    state = AsyncValue.data(SprayPlan(
      id: '', // generated on save
      farmerId: _farmerId,
      fieldId: fieldId,
      fieldName: fieldName,
    ));
  }

  void updateChemicals(List<Chemical> chemicals) {
    state.whenData((plan) {
      if (plan == null) return;
      state = AsyncValue.data(plan.copyWith(chemicals: chemicals));
    });
  }

  /// Saves the spray plan, stamps dangerous field IDs, then calls the
  /// edge function to notify affected neighboring farmers.
  Future<void> save({
    required List<String> dangerousFieldIds,
    required List<String> chemicalNames,
  }) async {
    final plan = state.value;
    if (plan == null) return;
    _lastDangerousFieldIds = dangerousFieldIds;
    _lastChemicalNames = chemicalNames;

    // Stamp danger info onto plan before persisting
    final planWithDanger =
        plan.copyWith(dangerousAdjacentFieldIds: dangerousFieldIds);

    _ref.read(sprayPlanSaveStateProvider.notifier).state =
        SprayPlanSaveState.saving;
    state = const AsyncValue.loading();
    final result = await _repo.saveSprayPlan(planWithDanger);

    result.fold(
      (err) {
        _ref.read(sprayPlanSaveStateProvider.notifier).state =
            SprayPlanSaveState.failed;
        _ref.read(lastSaveUserMessageProvider.notifier).state = err;
        state = AsyncValue.error(
          SupabaseService.toUserMessage(err),
          StackTrace.current,
        );
      },
      (saved) async {
        _ref.read(sprayPlanSaveStateProvider.notifier).state =
            SprayPlanSaveState.saved;
        _ref.read(lastSaveUserMessageProvider.notifier).state = null;
        state = AsyncValue.data(saved);

        // Call edge function to create danger_notifications rows
        if (dangerousFieldIds.isNotEmpty) {
          try {
            final response = await SupabaseService.invokeAuthedFunction(
              SupabaseConstants.sendNotificationFunction,
              body: {
                'spray_plan_id': saved.id,
                'farmer_id': saved.farmerId,
                'field_id': saved.fieldId,
                'dangerous_adjacent_field_ids': dangerousFieldIds,
                'chemical_names': chemicalNames,
                if (saved.scheduledDate != null)
                  'scheduled_date': saved.scheduledDate!.toIso8601String(),
              },
            );
            // TODO: remove debug logging before production
            // ignore: avoid_print
            print(
                '[EdgeFn] send_notification response: ${response.data} status: ${response.status}');
          } on AuthException catch (e) {
            // ignore: avoid_print
            print('[EdgeFn] send_notification auth error: ${e.message}');
          } catch (e) {
            // ignore: avoid_print
            print('[EdgeFn] send_notification error: $e');
            // Edge function failure is non-fatal — plan is already saved.
            // Notification failure will be surfaced in Phase 4 logging.
          }
        }
      },
    );
  }

  Future<void> retryLastSave() async {
    final dangerous = _lastDangerousFieldIds;
    final chemicals = _lastChemicalNames;
    if (dangerous == null || chemicals == null) return;
    await save(
      dangerousFieldIds: dangerous,
      chemicalNames: chemicals,
    );
  }
}

final sprayPlanSaveStateProvider =
    StateProvider<SprayPlanSaveState>((_) => SprayPlanSaveState.idle);

final lastSaveUserMessageProvider = StateProvider<String?>((_) => null);

final mySprayPlansProvider =
    FutureProvider.autoDispose<List<SprayPlan>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(chemicalRepositoryProvider);
  final result = await repo.getMySprayPlans(user.id);
  return result.fold((_) => [], (plans) => plans);
});

final sprayPlanNotifierProvider =
    StateNotifierProvider<SprayPlanNotifier, AsyncValue<SprayPlan?>>((ref) {
  final repo = ref.watch(chemicalRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return SprayPlanNotifier(ref, repo, user?.id);
});

// ── Danger computation ────────────────────────────────────────────────────

final dangerousFieldsProvider = Provider<List<String>>((ref) {
  final chemicals = ref.watch(selectedChemicalsProvider);
  final adjacentFields = ref.watch(adjacentFieldsProvider).value ?? [];
  final repo = ref.watch(chemicalRepositoryProvider);

  final adjacentFieldCropMap = {
    for (final f in adjacentFields)
      if (f.currentCropId != null) f.id: f.currentCropId!
  };

  return repo.computeDangerousFields(
    selectedChemicals: chemicals,
    adjacentFieldCropMap: adjacentFieldCropMap,
  );
});
