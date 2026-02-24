// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Meeting _$MeetingFromJson(Map<String, dynamic> json) {
  return _Meeting.fromJson(json);
}

/// @nodoc
mixin _$Meeting {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get weight => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  List<String> get activityIds => throw _privateConstructorUsedError;
  List<String> get categoryIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Meeting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Meeting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingCopyWith<Meeting> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingCopyWith<$Res> {
  factory $MeetingCopyWith(Meeting value, $Res Function(Meeting) then) =
      _$MeetingCopyWithImpl<$Res, Meeting>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      DateTime date,
      int weight,
      List<String> participantIds,
      List<String> activityIds,
      List<String> categoryIds,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$MeetingCopyWithImpl<$Res, $Val extends Meeting>
    implements $MeetingCopyWith<$Res> {
  _$MeetingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Meeting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? date = null,
    Object? weight = null,
    Object? participantIds = null,
    Object? activityIds = null,
    Object? categoryIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activityIds: null == activityIds
          ? _value.activityIds
          : activityIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      categoryIds: null == categoryIds
          ? _value.categoryIds
          : categoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingImplCopyWith<$Res> implements $MeetingCopyWith<$Res> {
  factory _$$MeetingImplCopyWith(
          _$MeetingImpl value, $Res Function(_$MeetingImpl) then) =
      __$$MeetingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      DateTime date,
      int weight,
      List<String> participantIds,
      List<String> activityIds,
      List<String> categoryIds,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$MeetingImplCopyWithImpl<$Res>
    extends _$MeetingCopyWithImpl<$Res, _$MeetingImpl>
    implements _$$MeetingImplCopyWith<$Res> {
  __$$MeetingImplCopyWithImpl(
      _$MeetingImpl _value, $Res Function(_$MeetingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Meeting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? date = null,
    Object? weight = null,
    Object? participantIds = null,
    Object? activityIds = null,
    Object? categoryIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MeetingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      participantIds: null == participantIds
          ? _value._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activityIds: null == activityIds
          ? _value._activityIds
          : activityIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      categoryIds: null == categoryIds
          ? _value._categoryIds
          : categoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingImpl extends _Meeting {
  const _$MeetingImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.date,
      required this.weight,
      required final List<String> participantIds,
      required final List<String> activityIds,
      final List<String> categoryIds = const [],
      required this.createdAt,
      required this.updatedAt})
      : _participantIds = participantIds,
        _activityIds = activityIds,
        _categoryIds = categoryIds,
        super._();

  factory _$MeetingImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final DateTime date;
  @override
  final int weight;
  final List<String> _participantIds;
  @override
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  final List<String> _activityIds;
  @override
  List<String> get activityIds {
    if (_activityIds is EqualUnmodifiableListView) return _activityIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activityIds);
  }

  final List<String> _categoryIds;
  @override
  @JsonKey()
  List<String> get categoryIds {
    if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryIds);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Meeting(id: $id, userId: $userId, name: $name, date: $date, weight: $weight, participantIds: $participantIds, activityIds: $activityIds, categoryIds: $categoryIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            const DeepCollectionEquality()
                .equals(other._activityIds, _activityIds) &&
            const DeepCollectionEquality()
                .equals(other._categoryIds, _categoryIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      date,
      weight,
      const DeepCollectionEquality().hash(_participantIds),
      const DeepCollectionEquality().hash(_activityIds),
      const DeepCollectionEquality().hash(_categoryIds),
      createdAt,
      updatedAt);

  /// Create a copy of Meeting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingImplCopyWith<_$MeetingImpl> get copyWith =>
      __$$MeetingImplCopyWithImpl<_$MeetingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingImplToJson(
      this,
    );
  }
}

abstract class _Meeting extends Meeting {
  const factory _Meeting(
      {required final String id,
      required final String userId,
      required final String name,
      required final DateTime date,
      required final int weight,
      required final List<String> participantIds,
      required final List<String> activityIds,
      final List<String> categoryIds,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$MeetingImpl;
  const _Meeting._() : super._();

  factory _Meeting.fromJson(Map<String, dynamic> json) = _$MeetingImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  DateTime get date;
  @override
  int get weight;
  @override
  List<String> get participantIds;
  @override
  List<String> get activityIds;
  @override
  List<String> get categoryIds;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Meeting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingImplCopyWith<_$MeetingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
