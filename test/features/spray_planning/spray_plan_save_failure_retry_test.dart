import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crop_id/features/spray_planning/providers/spray_plan_provider.dart';
import 'package:crop_id/features/spray_planning/providers/spray_plan_save_state.dart';

void main() {
  test('failed save state is retryable and can transition to saved', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(sprayPlanSaveStateProvider.notifier).state =
        SprayPlanSaveState.failed;

    expect(container.read(sprayPlanSaveStateProvider).canRetry, isTrue);

    container.read(sprayPlanSaveStateProvider.notifier).state =
        SprayPlanSaveState.saving;
    container.read(sprayPlanSaveStateProvider.notifier).state =
        SprayPlanSaveState.saved;

    expect(
        container.read(sprayPlanSaveStateProvider), SprayPlanSaveState.saved);
    expect(container.read(sprayPlanSaveStateProvider).isTerminal, isTrue);
  });
}
