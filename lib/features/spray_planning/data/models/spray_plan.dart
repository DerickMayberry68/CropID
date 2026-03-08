import 'package:freezed_annotation/freezed_annotation.dart';

import 'chemical.dart';

part 'spray_plan.freezed.dart';
part 'spray_plan.g.dart';

enum SprayPlanStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class SprayPlan with _$SprayPlan {
  const factory SprayPlan({
    required String id,
    required String farmerId,
    required String fieldId,
    String? fieldName,
    @Default([]) List<Chemical> chemicals,
    DateTime? scheduledDate,
    @Default(SprayPlanStatus.draft) SprayPlanStatus status,

    /// Adjacent field IDs that have at least one chemical danger.
    @Default([]) List<String> dangerousAdjacentFieldIds,
    String? notes,
    DateTime? createdAt,
  }) = _SprayPlan;

  factory SprayPlan.fromJson(Map<String, dynamic> json) =>
      _$SprayPlanFromJson(json);
}

extension SprayPlanMetadataExt on SprayPlan {
  /// Treat plan as persisted when it has a non-empty database ID.
  /// Some legacy rows may have null timestamps but are still persisted.
  bool get isPersisted => id.isNotEmpty;

  /// Stable key used for deterministic sorting in UI lists.
  String get stableKey => '$id-${createdAt?.millisecondsSinceEpoch ?? 0}';
}
