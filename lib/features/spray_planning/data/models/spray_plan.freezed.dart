// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spray_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SprayPlan _$SprayPlanFromJson(Map<String, dynamic> json) {
  return _SprayPlan.fromJson(json);
}

/// @nodoc
mixin _$SprayPlan {
  String get id => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  String get fieldId => throw _privateConstructorUsedError;
  String? get fieldName => throw _privateConstructorUsedError;
  List<Chemical> get chemicals => throw _privateConstructorUsedError;
  DateTime? get scheduledDate => throw _privateConstructorUsedError;
  SprayPlanStatus get status => throw _privateConstructorUsedError;

  /// Adjacent field IDs that have at least one chemical danger.
  List<String> get dangerousAdjacentFieldIds =>
      throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SprayPlanCopyWith<SprayPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SprayPlanCopyWith<$Res> {
  factory $SprayPlanCopyWith(SprayPlan value, $Res Function(SprayPlan) then) =
      _$SprayPlanCopyWithImpl<$Res, SprayPlan>;
  @useResult
  $Res call(
      {String id,
      String farmerId,
      String fieldId,
      String? fieldName,
      List<Chemical> chemicals,
      DateTime? scheduledDate,
      SprayPlanStatus status,
      List<String> dangerousAdjacentFieldIds,
      String? notes,
      DateTime? createdAt});
}

/// @nodoc
class _$SprayPlanCopyWithImpl<$Res, $Val extends SprayPlan>
    implements $SprayPlanCopyWith<$Res> {
  _$SprayPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? fieldId = null,
    Object? fieldName = freezed,
    Object? chemicals = null,
    Object? scheduledDate = freezed,
    Object? status = null,
    Object? dangerousAdjacentFieldIds = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
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
      fieldId: null == fieldId
          ? _value.fieldId
          : fieldId // ignore: cast_nullable_to_non_nullable
              as String,
      fieldName: freezed == fieldName
          ? _value.fieldName
          : fieldName // ignore: cast_nullable_to_non_nullable
              as String?,
      chemicals: null == chemicals
          ? _value.chemicals
          : chemicals // ignore: cast_nullable_to_non_nullable
              as List<Chemical>,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SprayPlanStatus,
      dangerousAdjacentFieldIds: null == dangerousAdjacentFieldIds
          ? _value.dangerousAdjacentFieldIds
          : dangerousAdjacentFieldIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SprayPlanImplCopyWith<$Res>
    implements $SprayPlanCopyWith<$Res> {
  factory _$$SprayPlanImplCopyWith(
          _$SprayPlanImpl value, $Res Function(_$SprayPlanImpl) then) =
      __$$SprayPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String farmerId,
      String fieldId,
      String? fieldName,
      List<Chemical> chemicals,
      DateTime? scheduledDate,
      SprayPlanStatus status,
      List<String> dangerousAdjacentFieldIds,
      String? notes,
      DateTime? createdAt});
}

/// @nodoc
class __$$SprayPlanImplCopyWithImpl<$Res>
    extends _$SprayPlanCopyWithImpl<$Res, _$SprayPlanImpl>
    implements _$$SprayPlanImplCopyWith<$Res> {
  __$$SprayPlanImplCopyWithImpl(
      _$SprayPlanImpl _value, $Res Function(_$SprayPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? fieldId = null,
    Object? fieldName = freezed,
    Object? chemicals = null,
    Object? scheduledDate = freezed,
    Object? status = null,
    Object? dangerousAdjacentFieldIds = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$SprayPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      farmerId: null == farmerId
          ? _value.farmerId
          : farmerId // ignore: cast_nullable_to_non_nullable
              as String,
      fieldId: null == fieldId
          ? _value.fieldId
          : fieldId // ignore: cast_nullable_to_non_nullable
              as String,
      fieldName: freezed == fieldName
          ? _value.fieldName
          : fieldName // ignore: cast_nullable_to_non_nullable
              as String?,
      chemicals: null == chemicals
          ? _value._chemicals
          : chemicals // ignore: cast_nullable_to_non_nullable
              as List<Chemical>,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SprayPlanStatus,
      dangerousAdjacentFieldIds: null == dangerousAdjacentFieldIds
          ? _value._dangerousAdjacentFieldIds
          : dangerousAdjacentFieldIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SprayPlanImpl implements _SprayPlan {
  const _$SprayPlanImpl(
      {required this.id,
      required this.farmerId,
      required this.fieldId,
      this.fieldName,
      final List<Chemical> chemicals = const [],
      this.scheduledDate,
      this.status = SprayPlanStatus.draft,
      final List<String> dangerousAdjacentFieldIds = const [],
      this.notes,
      this.createdAt})
      : _chemicals = chemicals,
        _dangerousAdjacentFieldIds = dangerousAdjacentFieldIds;

  factory _$SprayPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$SprayPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String farmerId;
  @override
  final String fieldId;
  @override
  final String? fieldName;
  final List<Chemical> _chemicals;
  @override
  @JsonKey()
  List<Chemical> get chemicals {
    if (_chemicals is EqualUnmodifiableListView) return _chemicals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chemicals);
  }

  @override
  final DateTime? scheduledDate;
  @override
  @JsonKey()
  final SprayPlanStatus status;

  /// Adjacent field IDs that have at least one chemical danger.
  final List<String> _dangerousAdjacentFieldIds;

  /// Adjacent field IDs that have at least one chemical danger.
  @override
  @JsonKey()
  List<String> get dangerousAdjacentFieldIds {
    if (_dangerousAdjacentFieldIds is EqualUnmodifiableListView)
      return _dangerousAdjacentFieldIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dangerousAdjacentFieldIds);
  }

  @override
  final String? notes;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'SprayPlan(id: $id, farmerId: $farmerId, fieldId: $fieldId, fieldName: $fieldName, chemicals: $chemicals, scheduledDate: $scheduledDate, status: $status, dangerousAdjacentFieldIds: $dangerousAdjacentFieldIds, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SprayPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.fieldId, fieldId) || other.fieldId == fieldId) &&
            (identical(other.fieldName, fieldName) ||
                other.fieldName == fieldName) &&
            const DeepCollectionEquality()
                .equals(other._chemicals, _chemicals) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
                other._dangerousAdjacentFieldIds, _dangerousAdjacentFieldIds) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      farmerId,
      fieldId,
      fieldName,
      const DeepCollectionEquality().hash(_chemicals),
      scheduledDate,
      status,
      const DeepCollectionEquality().hash(_dangerousAdjacentFieldIds),
      notes,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SprayPlanImplCopyWith<_$SprayPlanImpl> get copyWith =>
      __$$SprayPlanImplCopyWithImpl<_$SprayPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SprayPlanImplToJson(
      this,
    );
  }
}

abstract class _SprayPlan implements SprayPlan {
  const factory _SprayPlan(
      {required final String id,
      required final String farmerId,
      required final String fieldId,
      final String? fieldName,
      final List<Chemical> chemicals,
      final DateTime? scheduledDate,
      final SprayPlanStatus status,
      final List<String> dangerousAdjacentFieldIds,
      final String? notes,
      final DateTime? createdAt}) = _$SprayPlanImpl;

  factory _SprayPlan.fromJson(Map<String, dynamic> json) =
      _$SprayPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get farmerId;
  @override
  String get fieldId;
  @override
  String? get fieldName;
  @override
  List<Chemical> get chemicals;
  @override
  DateTime? get scheduledDate;
  @override
  SprayPlanStatus get status;
  @override

  /// Adjacent field IDs that have at least one chemical danger.
  List<String> get dangerousAdjacentFieldIds;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SprayPlanImplCopyWith<_$SprayPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
