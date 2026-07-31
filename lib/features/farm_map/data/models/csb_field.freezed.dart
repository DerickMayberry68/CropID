// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'csb_field.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CsbField _$CsbFieldFromJson(Map<String, dynamic> json) {
  return _CsbField.fromJson(json);
}

/// @nodoc
mixin _$CsbField {
  String get csbId => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String? get countyFips => throw _privateConstructorUsedError;
  @BoundaryPointsConverter()
  List<Map<String, double>> get boundaryPoints =>
      throw _privateConstructorUsedError;
  @NumericConverter()
  double? get acres => throw _privateConstructorUsedError;
  int? get cropYear => throw _privateConstructorUsedError;
  String? get predictedCropId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CsbFieldCopyWith<CsbField> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CsbFieldCopyWith<$Res> {
  factory $CsbFieldCopyWith(CsbField value, $Res Function(CsbField) then) =
      _$CsbFieldCopyWithImpl<$Res, CsbField>;
  @useResult
  $Res call(
      {String csbId,
      String state,
      String? countyFips,
      @BoundaryPointsConverter() List<Map<String, double>> boundaryPoints,
      @NumericConverter() double? acres,
      int? cropYear,
      String? predictedCropId});
}

/// @nodoc
class _$CsbFieldCopyWithImpl<$Res, $Val extends CsbField>
    implements $CsbFieldCopyWith<$Res> {
  _$CsbFieldCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? csbId = null,
    Object? state = null,
    Object? countyFips = freezed,
    Object? boundaryPoints = null,
    Object? acres = freezed,
    Object? cropYear = freezed,
    Object? predictedCropId = freezed,
  }) {
    return _then(_value.copyWith(
      csbId: null == csbId
          ? _value.csbId
          : csbId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      countyFips: freezed == countyFips
          ? _value.countyFips
          : countyFips // ignore: cast_nullable_to_non_nullable
              as String?,
      boundaryPoints: null == boundaryPoints
          ? _value.boundaryPoints
          : boundaryPoints // ignore: cast_nullable_to_non_nullable
              as List<Map<String, double>>,
      acres: freezed == acres
          ? _value.acres
          : acres // ignore: cast_nullable_to_non_nullable
              as double?,
      cropYear: freezed == cropYear
          ? _value.cropYear
          : cropYear // ignore: cast_nullable_to_non_nullable
              as int?,
      predictedCropId: freezed == predictedCropId
          ? _value.predictedCropId
          : predictedCropId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CsbFieldImplCopyWith<$Res>
    implements $CsbFieldCopyWith<$Res> {
  factory _$$CsbFieldImplCopyWith(
          _$CsbFieldImpl value, $Res Function(_$CsbFieldImpl) then) =
      __$$CsbFieldImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String csbId,
      String state,
      String? countyFips,
      @BoundaryPointsConverter() List<Map<String, double>> boundaryPoints,
      @NumericConverter() double? acres,
      int? cropYear,
      String? predictedCropId});
}

/// @nodoc
class __$$CsbFieldImplCopyWithImpl<$Res>
    extends _$CsbFieldCopyWithImpl<$Res, _$CsbFieldImpl>
    implements _$$CsbFieldImplCopyWith<$Res> {
  __$$CsbFieldImplCopyWithImpl(
      _$CsbFieldImpl _value, $Res Function(_$CsbFieldImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? csbId = null,
    Object? state = null,
    Object? countyFips = freezed,
    Object? boundaryPoints = null,
    Object? acres = freezed,
    Object? cropYear = freezed,
    Object? predictedCropId = freezed,
  }) {
    return _then(_$CsbFieldImpl(
      csbId: null == csbId
          ? _value.csbId
          : csbId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      countyFips: freezed == countyFips
          ? _value.countyFips
          : countyFips // ignore: cast_nullable_to_non_nullable
              as String?,
      boundaryPoints: null == boundaryPoints
          ? _value._boundaryPoints
          : boundaryPoints // ignore: cast_nullable_to_non_nullable
              as List<Map<String, double>>,
      acres: freezed == acres
          ? _value.acres
          : acres // ignore: cast_nullable_to_non_nullable
              as double?,
      cropYear: freezed == cropYear
          ? _value.cropYear
          : cropYear // ignore: cast_nullable_to_non_nullable
              as int?,
      predictedCropId: freezed == predictedCropId
          ? _value.predictedCropId
          : predictedCropId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CsbFieldImpl implements _CsbField {
  const _$CsbFieldImpl(
      {required this.csbId,
      required this.state,
      this.countyFips,
      @BoundaryPointsConverter()
      final List<Map<String, double>> boundaryPoints =
          const <Map<String, double>>[],
      @NumericConverter() this.acres,
      this.cropYear,
      this.predictedCropId})
      : _boundaryPoints = boundaryPoints;

  factory _$CsbFieldImpl.fromJson(Map<String, dynamic> json) =>
      _$$CsbFieldImplFromJson(json);

  @override
  final String csbId;
  @override
  final String state;
  @override
  final String? countyFips;
  final List<Map<String, double>> _boundaryPoints;
  @override
  @JsonKey()
  @BoundaryPointsConverter()
  List<Map<String, double>> get boundaryPoints {
    if (_boundaryPoints is EqualUnmodifiableListView) return _boundaryPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boundaryPoints);
  }

  @override
  @NumericConverter()
  final double? acres;
  @override
  final int? cropYear;
  @override
  final String? predictedCropId;

  @override
  String toString() {
    return 'CsbField(csbId: $csbId, state: $state, countyFips: $countyFips, boundaryPoints: $boundaryPoints, acres: $acres, cropYear: $cropYear, predictedCropId: $predictedCropId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CsbFieldImpl &&
            (identical(other.csbId, csbId) || other.csbId == csbId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.countyFips, countyFips) ||
                other.countyFips == countyFips) &&
            const DeepCollectionEquality()
                .equals(other._boundaryPoints, _boundaryPoints) &&
            (identical(other.acres, acres) || other.acres == acres) &&
            (identical(other.cropYear, cropYear) ||
                other.cropYear == cropYear) &&
            (identical(other.predictedCropId, predictedCropId) ||
                other.predictedCropId == predictedCropId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      csbId,
      state,
      countyFips,
      const DeepCollectionEquality().hash(_boundaryPoints),
      acres,
      cropYear,
      predictedCropId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CsbFieldImplCopyWith<_$CsbFieldImpl> get copyWith =>
      __$$CsbFieldImplCopyWithImpl<_$CsbFieldImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CsbFieldImplToJson(
      this,
    );
  }
}

abstract class _CsbField implements CsbField {
  const factory _CsbField(
      {required final String csbId,
      required final String state,
      final String? countyFips,
      @BoundaryPointsConverter() final List<Map<String, double>> boundaryPoints,
      @NumericConverter() final double? acres,
      final int? cropYear,
      final String? predictedCropId}) = _$CsbFieldImpl;

  factory _CsbField.fromJson(Map<String, dynamic> json) =
      _$CsbFieldImpl.fromJson;

  @override
  String get csbId;
  @override
  String get state;
  @override
  String? get countyFips;
  @override
  @BoundaryPointsConverter()
  List<Map<String, double>> get boundaryPoints;
  @override
  @NumericConverter()
  double? get acres;
  @override
  int? get cropYear;
  @override
  String? get predictedCropId;
  @override
  @JsonKey(ignore: true)
  _$$CsbFieldImplCopyWith<_$CsbFieldImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
