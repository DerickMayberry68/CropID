// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chemical.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Chemical _$ChemicalFromJson(Map<String, dynamic> json) {
  return _Chemical.fromJson(json);
}

/// @nodoc
mixin _$Chemical {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get commonName => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  ToxicityLevel get toxicityLevel => throw _privateConstructorUsedError;

  /// List of crop IDs this chemical is dangerous to.
  List<String> get dangerousToCropIds => throw _privateConstructorUsedError;

  /// Human-readable list of crop types harmed (e.g. ['soybeans', 'corn']).
  List<String> get dangerousToCropNames => throw _privateConstructorUsedError;

  /// Mixing incompatibilities — list of other chemical IDs not to combine.
  List<String> get incompatibleWithChemicalIds =>
      throw _privateConstructorUsedError;
  String? get withdrawalPeriodDays => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChemicalCopyWith<Chemical> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChemicalCopyWith<$Res> {
  factory $ChemicalCopyWith(Chemical value, $Res Function(Chemical) then) =
      _$ChemicalCopyWithImpl<$Res, Chemical>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? commonName,
      String? manufacturer,
      ToxicityLevel toxicityLevel,
      List<String> dangerousToCropIds,
      List<String> dangerousToCropNames,
      List<String> incompatibleWithChemicalIds,
      String? withdrawalPeriodDays,
      String? notes});
}

/// @nodoc
class _$ChemicalCopyWithImpl<$Res, $Val extends Chemical>
    implements $ChemicalCopyWith<$Res> {
  _$ChemicalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? commonName = freezed,
    Object? manufacturer = freezed,
    Object? toxicityLevel = null,
    Object? dangerousToCropIds = null,
    Object? dangerousToCropNames = null,
    Object? incompatibleWithChemicalIds = null,
    Object? withdrawalPeriodDays = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: freezed == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      toxicityLevel: null == toxicityLevel
          ? _value.toxicityLevel
          : toxicityLevel // ignore: cast_nullable_to_non_nullable
              as ToxicityLevel,
      dangerousToCropIds: null == dangerousToCropIds
          ? _value.dangerousToCropIds
          : dangerousToCropIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dangerousToCropNames: null == dangerousToCropNames
          ? _value.dangerousToCropNames
          : dangerousToCropNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      incompatibleWithChemicalIds: null == incompatibleWithChemicalIds
          ? _value.incompatibleWithChemicalIds
          : incompatibleWithChemicalIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      withdrawalPeriodDays: freezed == withdrawalPeriodDays
          ? _value.withdrawalPeriodDays
          : withdrawalPeriodDays // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChemicalImplCopyWith<$Res>
    implements $ChemicalCopyWith<$Res> {
  factory _$$ChemicalImplCopyWith(
          _$ChemicalImpl value, $Res Function(_$ChemicalImpl) then) =
      __$$ChemicalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? commonName,
      String? manufacturer,
      ToxicityLevel toxicityLevel,
      List<String> dangerousToCropIds,
      List<String> dangerousToCropNames,
      List<String> incompatibleWithChemicalIds,
      String? withdrawalPeriodDays,
      String? notes});
}

/// @nodoc
class __$$ChemicalImplCopyWithImpl<$Res>
    extends _$ChemicalCopyWithImpl<$Res, _$ChemicalImpl>
    implements _$$ChemicalImplCopyWith<$Res> {
  __$$ChemicalImplCopyWithImpl(
      _$ChemicalImpl _value, $Res Function(_$ChemicalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? commonName = freezed,
    Object? manufacturer = freezed,
    Object? toxicityLevel = null,
    Object? dangerousToCropIds = null,
    Object? dangerousToCropNames = null,
    Object? incompatibleWithChemicalIds = null,
    Object? withdrawalPeriodDays = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$ChemicalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: freezed == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      toxicityLevel: null == toxicityLevel
          ? _value.toxicityLevel
          : toxicityLevel // ignore: cast_nullable_to_non_nullable
              as ToxicityLevel,
      dangerousToCropIds: null == dangerousToCropIds
          ? _value._dangerousToCropIds
          : dangerousToCropIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dangerousToCropNames: null == dangerousToCropNames
          ? _value._dangerousToCropNames
          : dangerousToCropNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      incompatibleWithChemicalIds: null == incompatibleWithChemicalIds
          ? _value._incompatibleWithChemicalIds
          : incompatibleWithChemicalIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      withdrawalPeriodDays: freezed == withdrawalPeriodDays
          ? _value.withdrawalPeriodDays
          : withdrawalPeriodDays // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChemicalImpl implements _Chemical {
  const _$ChemicalImpl(
      {required this.id,
      required this.name,
      this.commonName,
      this.manufacturer,
      this.toxicityLevel = ToxicityLevel.moderate,
      final List<String> dangerousToCropIds = const [],
      final List<String> dangerousToCropNames = const [],
      final List<String> incompatibleWithChemicalIds = const [],
      this.withdrawalPeriodDays,
      this.notes})
      : _dangerousToCropIds = dangerousToCropIds,
        _dangerousToCropNames = dangerousToCropNames,
        _incompatibleWithChemicalIds = incompatibleWithChemicalIds;

  factory _$ChemicalImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChemicalImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? commonName;
  @override
  final String? manufacturer;
  @override
  @JsonKey()
  final ToxicityLevel toxicityLevel;

  /// List of crop IDs this chemical is dangerous to.
  final List<String> _dangerousToCropIds;

  /// List of crop IDs this chemical is dangerous to.
  @override
  @JsonKey()
  List<String> get dangerousToCropIds {
    if (_dangerousToCropIds is EqualUnmodifiableListView)
      return _dangerousToCropIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dangerousToCropIds);
  }

  /// Human-readable list of crop types harmed (e.g. ['soybeans', 'corn']).
  final List<String> _dangerousToCropNames;

  /// Human-readable list of crop types harmed (e.g. ['soybeans', 'corn']).
  @override
  @JsonKey()
  List<String> get dangerousToCropNames {
    if (_dangerousToCropNames is EqualUnmodifiableListView)
      return _dangerousToCropNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dangerousToCropNames);
  }

  /// Mixing incompatibilities — list of other chemical IDs not to combine.
  final List<String> _incompatibleWithChemicalIds;

  /// Mixing incompatibilities — list of other chemical IDs not to combine.
  @override
  @JsonKey()
  List<String> get incompatibleWithChemicalIds {
    if (_incompatibleWithChemicalIds is EqualUnmodifiableListView)
      return _incompatibleWithChemicalIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incompatibleWithChemicalIds);
  }

  @override
  final String? withdrawalPeriodDays;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Chemical(id: $id, name: $name, commonName: $commonName, manufacturer: $manufacturer, toxicityLevel: $toxicityLevel, dangerousToCropIds: $dangerousToCropIds, dangerousToCropNames: $dangerousToCropNames, incompatibleWithChemicalIds: $incompatibleWithChemicalIds, withdrawalPeriodDays: $withdrawalPeriodDays, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChemicalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.commonName, commonName) ||
                other.commonName == commonName) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.toxicityLevel, toxicityLevel) ||
                other.toxicityLevel == toxicityLevel) &&
            const DeepCollectionEquality()
                .equals(other._dangerousToCropIds, _dangerousToCropIds) &&
            const DeepCollectionEquality()
                .equals(other._dangerousToCropNames, _dangerousToCropNames) &&
            const DeepCollectionEquality().equals(
                other._incompatibleWithChemicalIds,
                _incompatibleWithChemicalIds) &&
            (identical(other.withdrawalPeriodDays, withdrawalPeriodDays) ||
                other.withdrawalPeriodDays == withdrawalPeriodDays) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      commonName,
      manufacturer,
      toxicityLevel,
      const DeepCollectionEquality().hash(_dangerousToCropIds),
      const DeepCollectionEquality().hash(_dangerousToCropNames),
      const DeepCollectionEquality().hash(_incompatibleWithChemicalIds),
      withdrawalPeriodDays,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChemicalImplCopyWith<_$ChemicalImpl> get copyWith =>
      __$$ChemicalImplCopyWithImpl<_$ChemicalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChemicalImplToJson(
      this,
    );
  }
}

abstract class _Chemical implements Chemical {
  const factory _Chemical(
      {required final String id,
      required final String name,
      final String? commonName,
      final String? manufacturer,
      final ToxicityLevel toxicityLevel,
      final List<String> dangerousToCropIds,
      final List<String> dangerousToCropNames,
      final List<String> incompatibleWithChemicalIds,
      final String? withdrawalPeriodDays,
      final String? notes}) = _$ChemicalImpl;

  factory _Chemical.fromJson(Map<String, dynamic> json) =
      _$ChemicalImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get commonName;
  @override
  String? get manufacturer;
  @override
  ToxicityLevel get toxicityLevel;
  @override

  /// List of crop IDs this chemical is dangerous to.
  List<String> get dangerousToCropIds;
  @override

  /// Human-readable list of crop types harmed (e.g. ['soybeans', 'corn']).
  List<String> get dangerousToCropNames;
  @override

  /// Mixing incompatibilities — list of other chemical IDs not to combine.
  List<String> get incompatibleWithChemicalIds;
  @override
  String? get withdrawalPeriodDays;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$ChemicalImplCopyWith<_$ChemicalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
