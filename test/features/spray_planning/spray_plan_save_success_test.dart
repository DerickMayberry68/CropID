import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crop_id/features/spray_planning/providers/spray_plan_provider.dart';
import 'package:crop_id/features/spray_planning/providers/spray_plan_save_state.dart';

void main() {
  test('save state provider can represent successful terminal state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(sprayPlanSaveStateProvider.notifier).state =
        SprayPlanSaveState.saved;

    final value = container.read(sprayPlanSaveStateProvider);
    expect(value, SprayPlanSaveState.saved);
    expect(value.isTerminal, isTrue);
    expect(value.canRetry, isFalse);
  });
}
