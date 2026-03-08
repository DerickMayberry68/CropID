import 'package:freezed_annotation/freezed_annotation.dart';

part 'farmer_profile.freezed.dart';
part 'farmer_profile.g.dart';

@freezed
class FarmerProfile with _$FarmerProfile {
  const factory FarmerProfile({
    required String id,               // matches Supabase auth user id
    required String email,
    required String fullName,
    String? phoneNumber,
    String? farmName,
    double? farmLatitude,
    double? farmLongitude,
    String? avatarUrl,
    @Default(false) bool fieldSharingEnabled,
    DateTime? gdprConsentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FarmerProfile;

  factory FarmerProfile.fromJson(Map<String, dynamic> json) =>
      _$FarmerProfileFromJson(json);
}
