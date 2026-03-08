import 'package:freezed_annotation/freezed_annotation.dart';

part 'crop.freezed.dart';
part 'crop.g.dart';

@freezed
class Crop with _$Crop {
  const factory Crop({
    required String id,
    required String name,
    String? scientificName,
    String? iconUrl,
    /// General sensitivity flags — used to cross-reference chemical dangers.
    @Default([]) List<String> sensitiveTo,   // list of chemical_id strings
    @Default([]) List<String> tags,          // e.g. ['grain', 'broadleaf']
  }) = _Crop;

  factory Crop.fromJson(Map<String, dynamic> json) => _$CropFromJson(json);
}
