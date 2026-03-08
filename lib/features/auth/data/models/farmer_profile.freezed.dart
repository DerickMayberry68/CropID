// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'farmer_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FarmerProfile _$FarmerProfileFromJson(Map<String, dynamic> json) {
  return _FarmerProfile.fromJson(json);
}

/// @nodoc
mixin _$FarmerProfile {
  String get id =>
      throw _privateConstructorUsedError; // matches Supabase auth user id
  String get email => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get farmName => throw _privateConstructorUsedError;
  double? get farmLatitude => throw _privateConstructorUsedError;
  double? get farmLongitude => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get fieldSharingEnabled => throw _privateConstructorUsedError;
  DateTime? get gdprConsentAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FarmerProfileCopyWith<FarmerProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FarmerProfileCopyWith<$Res> {
  factory $FarmerProfileCopyWith(
          FarmerProfile value, $Res Function(FarmerProfile) then) =
      _$FarmerProfileCopyWithImpl<$Res, FarmerProfile>;
  @useResult
  $Res call(
      {String id,
      String email,
      String fullName,
      String? phoneNumber,
      String? farmName,
      double? farmLatitude,
      double? farmLongitude,
      String? avatarUrl,
      bool fieldSharingEnabled,
      DateTime? gdprConsentAt,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$FarmerProfileCopyWithImpl<$Res, $Val extends FarmerProfile>
    implements $FarmerProfileCopyWith<$Res> {
  _$FarmerProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? phoneNumber = freezed,
    Object? farmName = freezed,
    Object? farmLatitude = freezed,
    Object? farmLongitude = freezed,
    Object? avatarUrl = freezed,
    Object? fieldSharingEnabled = null,
    Object? gdprConsentAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      farmName: freezed == farmName
          ? _value.farmName
          : farmName // ignore: cast_nullable_to_non_nullable
              as String?,
      farmLatitude: freezed == farmLatitude
          ? _value.farmLatitude
          : farmLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      farmLongitude: freezed == farmLongitude
          ? _value.farmLongitude
          : farmLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fieldSharingEnabled: null == fieldSharingEnabled
          ? _value.fieldSharingEnabled
          : fieldSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      gdprConsentAt: freezed == gdprConsentAt
          ? _value.gdprConsentAt
          : gdprConsentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FarmerProfileImplCopyWith<$Res>
    implements $FarmerProfileCopyWith<$Res> {
  factory _$$FarmerProfileImplCopyWith(
          _$FarmerProfileImpl value, $Res Function(_$FarmerProfileImpl) then) =
      __$$FarmerProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String fullName,
      String? phoneNumber,
      String? farmName,
      double? farmLatitude,
      double? farmLongitude,
      String? avatarUrl,
      bool fieldSharingEnabled,
      DateTime? gdprConsentAt,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$FarmerProfileImplCopyWithImpl<$Res>
    extends _$FarmerProfileCopyWithImpl<$Res, _$FarmerProfileImpl>
    implements _$$FarmerProfileImplCopyWith<$Res> {
  __$$FarmerProfileImplCopyWithImpl(
      _$FarmerProfileImpl _value, $Res Function(_$FarmerProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? phoneNumber = freezed,
    Object? farmName = freezed,
    Object? farmLatitude = freezed,
    Object? farmLongitude = freezed,
    Object? avatarUrl = freezed,
    Object? fieldSharingEnabled = null,
    Object? gdprConsentAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$FarmerProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      farmName: freezed == farmName
          ? _value.farmName
          : farmName // ignore: cast_nullable_to_non_nullable
              as String?,
      farmLatitude: freezed == farmLatitude
          ? _value.farmLatitude
          : farmLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      farmLongitude: freezed == farmLongitude
          ? _value.farmLongitude
          : farmLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fieldSharingEnabled: null == fieldSharingEnabled
          ? _value.fieldSharingEnabled
          : fieldSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      gdprConsentAt: freezed == gdprConsentAt
          ? _value.gdprConsentAt
          : gdprConsentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FarmerProfileImpl implements _FarmerProfile {
  const _$FarmerProfileImpl(
      {required this.id,
      required this.email,
      required this.fullName,
      this.phoneNumber,
      this.farmName,
      this.farmLatitude,
      this.farmLongitude,
      this.avatarUrl,
      this.fieldSharingEnabled = false,
      this.gdprConsentAt,
      this.createdAt,
      this.updatedAt});

  factory _$FarmerProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$FarmerProfileImplFromJson(json);

  @override
  final String id;
// matches Supabase auth user id
  @override
  final String email;
  @override
  final String fullName;
  @override
  final String? phoneNumber;
  @override
  final String? farmName;
  @override
  final double? farmLatitude;
  @override
  final double? farmLongitude;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool fieldSharingEnabled;
  @override
  final DateTime? gdprConsentAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'FarmerProfile(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, farmName: $farmName, farmLatitude: $farmLatitude, farmLongitude: $farmLongitude, avatarUrl: $avatarUrl, fieldSharingEnabled: $fieldSharingEnabled, gdprConsentAt: $gdprConsentAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FarmerProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.farmName, farmName) ||
                other.farmName == farmName) &&
            (identical(other.farmLatitude, farmLatitude) ||
                other.farmLatitude == farmLatitude) &&
            (identical(other.farmLongitude, farmLongitude) ||
                other.farmLongitude == farmLongitude) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.fieldSharingEnabled, fieldSharingEnabled) ||
                other.fieldSharingEnabled == fieldSharingEnabled) &&
            (identical(other.gdprConsentAt, gdprConsentAt) ||
                other.gdprConsentAt == gdprConsentAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      fullName,
      phoneNumber,
      farmName,
      farmLatitude,
      farmLongitude,
      avatarUrl,
      fieldSharingEnabled,
      gdprConsentAt,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FarmerProfileImplCopyWith<_$FarmerProfileImpl> get copyWith =>
      __$$FarmerProfileImplCopyWithImpl<_$FarmerProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FarmerProfileImplToJson(
      this,
    );
  }
}

abstract class _FarmerProfile implements FarmerProfile {
  const factory _FarmerProfile(
      {required final String id,
      required final String email,
      required final String fullName,
      final String? phoneNumber,
      final String? farmName,
      final double? farmLatitude,
      final double? farmLongitude,
      final String? avatarUrl,
      final bool fieldSharingEnabled,
      final DateTime? gdprConsentAt,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$FarmerProfileImpl;

  factory _FarmerProfile.fromJson(Map<String, dynamic> json) =
      _$FarmerProfileImpl.fromJson;

  @override
  String get id;
  @override // matches Supabase auth user id
  String get email;
  @override
  String get fullName;
  @override
  String? get phoneNumber;
  @override
  String? get farmName;
  @override
  double? get farmLatitude;
  @override
  double? get farmLongitude;
  @override
  String? get avatarUrl;
  @override
  bool get fieldSharingEnabled;
  @override
  DateTime? get gdprConsentAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FarmerProfileImplCopyWith<_$FarmerProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
