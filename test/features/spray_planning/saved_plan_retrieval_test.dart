import 'package:flutter_test/flutter_test.dart';
import 'package:crop_id/core/utils/extensions.dart';
import 'package:crop_id/features/spray_planning/data/models/spray_plan.dart';

void main() {
  test('saved plans are sorted deterministically by createdAt desc then id',
      () {
    final t = DateTime.parse('2026-03-08T10:00:00Z');
    final plans = [
      SprayPlan(
        id: 'b',
        farmerId: 'f1',
        fieldId: 'field-1',
        createdAt: t,
      ),
      SprayPlan(
        id: 'a',
        farmerId: 'f1',
        fieldId: 'field-1',
        createdAt: t,
      ),
      SprayPlan(
        id: 'c',
        farmerId: 'f1',
        fieldId: 'field-1',
        createdAt: t.subtract(const Duration(minutes: 1)),
      ),
    ];

    final sorted = plans.sortedByCreatedAtDesc(
      createdAt: (p) => p.createdAt,
      stableId: (p) => p.id,
    );

    expect(sorted.map((p) => p.id).toList(), ['a', 'b', 'c']);
    expect(sorted.first.isPersisted, isTrue);
  });
}
