// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'field.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Field _$FieldFromJson(Map<String, dynamic> json) {
  return _Field.fromJson(json);
}

/// @nodoc
mixin _$Field {
  String get id => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// GeoJSON polygon coordinates stored as a flat list of {lat, lng} maps.
  /// TODO: Phase 1 — store as PostGIS geometry in Supabase, decode here.
  List<Map<String, double>> get boundaryPoints =>
      throw _privateConstructorUsedError;
  String? get currentCropId => throw _privateConstructorUsedError;
  String? get currentCropName =>
      throw _privateConstructorUsedError; // denormalized for quick display
  FieldVisibility get visibility => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FieldCopyWith<Field> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldCopyWith<$Res> {
  factory $FieldCopyWith(Field value, $Res Function(Field) then) =
      _$FieldCopyWithImpl<$Res, Field>;
  @useResult
  $Res call(
      {String id,
      String farmerId,
      String name,
      List<Map<String, double>> boundaryPoints,
      String? currentCropId,
      String? currentCropName,
      FieldVisibility visibility,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$FieldCopyWithImpl<$Res, $Val extends Field>
    implements $FieldCopyWith<$Res> {
  _$FieldCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? name = null,
    Object? boundaryPoints = null,
    Object? currentCropId = freezed,
    Object? currentCropName = freezed,
    Object? visibility = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      farmerId: null == farmerId
          ? _value.farmerId
          : farmerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      boundaryPoints: null == boundaryPoints
          ? _value.boundaryPoints
          : boundaryPoints // ignore: cast_nullable_to_non_nullable
              as List<Map<String, double>>,
      currentCropId: freezed == currentCropId
          ? _value.currentCropId
          : currentCropId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentCropName: freezed == currentCropName
          ? _value.currentCropName
          : currentCropName // ignore: cast_nullable_to_non_nullable
              as String?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as FieldVisibility,
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
abstract class _$$FieldImplCopyWith<$Res> implements $FieldCopyWith<$Res> {
  factory _$$FieldImplCopyWith(
          _$FieldImpl value, $Res Function(_$FieldImpl) then) =
      __$$FieldImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String farmerId,
      String name,
      List<Map<String, double>> boundaryPoints,
      String? currentCropId,
      String? currentCropName,
      FieldVisibility visibility,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$FieldImplCopyWithImpl<$Res>
    extends _$FieldCopyWithImpl<$Res, _$FieldImpl>
    implements _$$FieldImplCopyWith<$Res> {
  __$$FieldImplCopyWithImpl(
      _$FieldImpl _value, $Res Function(_$FieldImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? name = null,
    Object? boundaryPoints = null,
    Object? currentCropId = freezed,
    Object? currentCropName = freezed,
    Object? visibility = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$FieldImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      farmerId: null == farmerId
          ? _value.farmerId
          : farmerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      boundaryPoints: null == boundaryPoints
          ? _value._boundaryPoints
          : boundaryPoints // ignore: cast_nullable_to_non_nullable
              as List<Map<String, double>>,
      currentCropId: freezed == currentCropId
          ? _value.currentCropId
          : currentCropId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentCropName: freezed == currentCropName
          ? _value.currentCropName
          : currentCropName // ignore: cast_nullable_to_non_nullable
              as String?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as FieldVisibility,
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
class _$FieldImpl implements _Field {
  const _$FieldImpl(
      {required this.id,
      required this.farmerId,
      required this.name,
      required final List<Map<String, double>> boundaryPoints,
      this.currentCropId,
      this.currentCropName,
      this.visibility = FieldVisibility.anonymous,
      this.createdAt,
      this.updatedAt})
      : _boundaryPoints = boundaryPoints;

  factory _$FieldImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldImplFromJson(json);

  @override
  final String id;
  @override
  final String farmerId;
  @override
  final String name;

  /// GeoJSON polygon coordinates stored as a flat list of {lat, lng} maps.
  /// TODO: Phase 1 — store as PostGIS geometry in Supabase, decode here.
  final List<Map<String, double>> _boundaryPoints;

  /// GeoJSON polygon coordinates stored as a flat list of {lat, lng} maps.
  /// TODO: Phase 1 — store as PostGIS geometry in Supabase, decode here.
  @override
  List<Map<String, double>> get boundaryPoints {
    if (_boundaryPoints is EqualUnmodifiableListView) return _boundaryPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boundaryPoints);
  }

  @override
  final String? currentCropId;
  @override
  final String? currentCropName;
// denormalized for quick display
  @override
  @JsonKey()
  final FieldVisibility visibility;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Field(id: $id, farmerId: $farmerId, name: $name, boundaryPoints: $boundaryPoints, currentCropId: $currentCropId, currentCropName: $currentCropName, visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._boundaryPoints, _boundaryPoints) &&
            (identical(other.currentCropId, currentCropId) ||
                other.currentCropId == currentCropId) &&
            (identical(other.currentCropName, currentCropName) ||
                other.currentCropName == currentCropName) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
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
      farmerId,
      name,
      const DeepCollectionEquality().hash(_boundaryPoints),
      currentCropId,
      currentCropName,
      visibility,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldImplCopyWith<_$FieldImpl> get copyWith =>
      __$$FieldImplCopyWithImpl<_$FieldImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldImplToJson(
      this,
    );
  }
}

abstract class _Field implements Field {
  const factory _Field(
      {required final String id,
      required final String farmerId,
      required final String name,
      required final List<Map<String, double>> boundaryPoints,
      final String? currentCropId,
      final String? currentCropName,
      final FieldVisibility visibility,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$FieldImpl;

  factory _Field.fromJson(Map<String, dynamic> json) = _$FieldImpl.fromJson;

  @override
  String get id;
  @override
  String get farmerId;
  @override
  String get name;
  @override

  /// GeoJSON polygon coordinates stored as a flat list of {lat, lng} maps.
  /// TODO: Phase 1 — store as PostGIS geometry in Supabase, decode here.
  List<Map<String, double>> get boundaryPoints;
  @override
  String? get currentCropId;
  @override
  String? get currentCropName;
  @override // denormalized for quick display
  FieldVisibility get visibility;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FieldImplCopyWith<_$FieldImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
