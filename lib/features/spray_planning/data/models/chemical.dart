import 'package:freezed_annotation/freezed_annotation.dart';

part 'chemical.freezed.dart';
part 'chemical.g.dart';

enum ToxicityLevel {
  @JsonValue('low') low,
  @JsonValue('moderate') moderate,
  @JsonValue('high') high,
  @JsonValue('extreme') extreme,
}

@freezed
class Chemical with _$Chemical {
  const factory Chemical({
    required String id,
    required String name,
    String? commonName,
    String? manufacturer,
    @Default(ToxicityLevel.moderate) ToxicityLevel toxicityLevel,
    /// List of crop IDs this chemical is dangerous to.
    @Default([]) List<String> dangerousToCropIds,
    /// Human-readable list of crop types harmed (e.g. ['soybeans', 'corn']).
    @Default([]) List<String> dangerousToCropNames,
    /// Mixing incompatibilities — list of other chemical IDs not to combine.
    @Default([]) List<String> incompatibleWithChemicalIds,
    String? withdrawalPeriodDays,
    String? notes,
  }) = _Chemical;

  factory Chemical.fromJson(Map<String, dynamic> json) =>
      _$ChemicalFromJson(json);
}
