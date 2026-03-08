// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Crop _$CropFromJson(Map<String, dynamic> json) {
  return _Crop.fromJson(json);
}

/// @nodoc
mixin _$Crop {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get scientificName => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;

  /// General sensitivity flags — used to cross-reference chemical dangers.
  List<String> get sensitiveTo =>
      throw _privateConstructorUsedError; // list of chemical_id strings
  List<String> get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CropCopyWith<Crop> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CropCopyWith<$Res> {
  factory $CropCopyWith(Crop value, $Res Function(Crop) then) =
      _$CropCopyWithImpl<$Res, Crop>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? scientificName,
      String? iconUrl,
      List<String> sensitiveTo,
      List<String> tags});
}

/// @nodoc
class _$CropCopyWithImpl<$Res, $Val extends Crop>
    implements $CropCopyWith<$Res> {
  _$CropCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? scientificName = freezed,
    Object? iconUrl = freezed,
    Object? sensitiveTo = null,
    Object? tags = null,
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
      scientificName: freezed == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sensitiveTo: null == sensitiveTo
          ? _value.sensitiveTo
          : sensitiveTo // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CropImplCopyWith<$Res> implements $CropCopyWith<$Res> {
  factory _$$CropImplCopyWith(
          _$CropImpl value, $Res Function(_$CropImpl) then) =
      __$$CropImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? scientificName,
      String? iconUrl,
      List<String> sensitiveTo,
      List<String> tags});
}

/// @nodoc
class __$$CropImplCopyWithImpl<$Res>
    extends _$CropCopyWithImpl<$Res, _$CropImpl>
    implements _$$CropImplCopyWith<$Res> {
  __$$CropImplCopyWithImpl(_$CropImpl _value, $Res Function(_$CropImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? scientificName = freezed,
    Object? iconUrl = freezed,
    Object? sensitiveTo = null,
    Object? tags = null,
  }) {
    return _then(_$CropImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: freezed == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sensitiveTo: null == sensitiveTo
          ? _value._sensitiveTo
          : sensitiveTo // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CropImpl implements _Crop {
  const _$CropImpl(
      {required this.id,
      required this.name,
      this.scientificName,
      this.iconUrl,
      final List<String> sensitiveTo = const [],
      final List<String> tags = const []})
      : _sensitiveTo = sensitiveTo,
        _tags = tags;

  factory _$CropImpl.fromJson(Map<String, dynamic> json) =>
      _$$CropImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? scientificName;
  @override
  final String? iconUrl;

  /// General sensitivity flags — used to cross-reference chemical dangers.
  final List<String> _sensitiveTo;

  /// General sensitivity flags — used to cross-reference chemical dangers.
  @override
  @JsonKey()
  List<String> get sensitiveTo {
    if (_sensitiveTo is EqualUnmodifiableListView) return _sensitiveTo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sensitiveTo);
  }

// list of chemical_id strings
  final List<String> _tags;
// list of chemical_id strings
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'Crop(id: $id, name: $name, scientificName: $scientificName, iconUrl: $iconUrl, sensitiveTo: $sensitiveTo, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CropImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.scientificName, scientificName) ||
                other.scientificName == scientificName) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            const DeepCollectionEquality()
                .equals(other._sensitiveTo, _sensitiveTo) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      scientificName,
      iconUrl,
      const DeepCollectionEquality().hash(_sensitiveTo),
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CropImplCopyWith<_$CropImpl> get copyWith =>
      __$$CropImplCopyWithImpl<_$CropImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CropImplToJson(
      this,
    );
  }
}

abstract class _Crop implements Crop {
  const factory _Crop(
      {required final String id,
      required final String name,
      final String? scientificName,
      final String? iconUrl,
      final List<String> sensitiveTo,
      final List<String> tags}) = _$CropImpl;

  factory _Crop.fromJson(Map<String, dynamic> json) = _$CropImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get scientificName;
  @override
  String? get iconUrl;
  @override

  /// General sensitivity flags — used to cross-reference chemical dangers.
  List<String> get sensitiveTo;
  @override // list of chemical_id strings
  List<String> get tags;
  @override
  @JsonKey(ignore: true)
  _$$CropImplCopyWith<_$CropImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
