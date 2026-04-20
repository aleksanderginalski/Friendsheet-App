// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friends_quest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FriendsQuest _$FriendsQuestFromJson(Map<String, dynamic> json) {
  return _FriendsQuest.fromJson(json);
}

/// @nodoc
mixin _$FriendsQuest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  String? get linkedMeetingId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  List<FriendsQuestTask> get tasks => throw _privateConstructorUsedError;

  /// Serializes this FriendsQuest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendsQuest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendsQuestCopyWith<FriendsQuest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendsQuestCopyWith<$Res> {
  factory $FriendsQuestCopyWith(
          FriendsQuest value, $Res Function(FriendsQuest) then) =
      _$FriendsQuestCopyWithImpl<$Res, FriendsQuest>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> participantIds,
      String? linkedMeetingId,
      DateTime createdAt,
      bool isCompleted,
      List<FriendsQuestTask> tasks});
}

/// @nodoc
class _$FriendsQuestCopyWithImpl<$Res, $Val extends FriendsQuest>
    implements $FriendsQuestCopyWith<$Res> {
  _$FriendsQuestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendsQuest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? participantIds = null,
    Object? linkedMeetingId = freezed,
    Object? createdAt = null,
    Object? isCompleted = null,
    Object? tasks = null,
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
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      linkedMeetingId: freezed == linkedMeetingId
          ? _value.linkedMeetingId
          : linkedMeetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      tasks: null == tasks
          ? _value.tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<FriendsQuestTask>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendsQuestImplCopyWith<$Res>
    implements $FriendsQuestCopyWith<$Res> {
  factory _$$FriendsQuestImplCopyWith(
          _$FriendsQuestImpl value, $Res Function(_$FriendsQuestImpl) then) =
      __$$FriendsQuestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> participantIds,
      String? linkedMeetingId,
      DateTime createdAt,
      bool isCompleted,
      List<FriendsQuestTask> tasks});
}

/// @nodoc
class __$$FriendsQuestImplCopyWithImpl<$Res>
    extends _$FriendsQuestCopyWithImpl<$Res, _$FriendsQuestImpl>
    implements _$$FriendsQuestImplCopyWith<$Res> {
  __$$FriendsQuestImplCopyWithImpl(
      _$FriendsQuestImpl _value, $Res Function(_$FriendsQuestImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendsQuest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? participantIds = null,
    Object? linkedMeetingId = freezed,
    Object? createdAt = null,
    Object? isCompleted = null,
    Object? tasks = null,
  }) {
    return _then(_$FriendsQuestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: null == participantIds
          ? _value._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      linkedMeetingId: freezed == linkedMeetingId
          ? _value.linkedMeetingId
          : linkedMeetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      tasks: null == tasks
          ? _value._tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<FriendsQuestTask>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendsQuestImpl implements _FriendsQuest {
  const _$FriendsQuestImpl(
      {required this.id,
      required this.name,
      required final List<String> participantIds,
      this.linkedMeetingId,
      required this.createdAt,
      this.isCompleted = false,
      final List<FriendsQuestTask> tasks = const []})
      : _participantIds = participantIds,
        _tasks = tasks;

  factory _$FriendsQuestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendsQuestImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String> _participantIds;
  @override
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  @override
  final String? linkedMeetingId;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isCompleted;
  final List<FriendsQuestTask> _tasks;
  @override
  @JsonKey()
  List<FriendsQuestTask> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  String toString() {
    return 'FriendsQuest(id: $id, name: $name, participantIds: $participantIds, linkedMeetingId: $linkedMeetingId, createdAt: $createdAt, isCompleted: $isCompleted, tasks: $tasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendsQuestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            (identical(other.linkedMeetingId, linkedMeetingId) ||
                other.linkedMeetingId == linkedMeetingId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_participantIds),
      linkedMeetingId,
      createdAt,
      isCompleted,
      const DeepCollectionEquality().hash(_tasks));

  /// Create a copy of FriendsQuest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendsQuestImplCopyWith<_$FriendsQuestImpl> get copyWith =>
      __$$FriendsQuestImplCopyWithImpl<_$FriendsQuestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendsQuestImplToJson(
      this,
    );
  }
}

abstract class _FriendsQuest implements FriendsQuest {
  const factory _FriendsQuest(
      {required final String id,
      required final String name,
      required final List<String> participantIds,
      final String? linkedMeetingId,
      required final DateTime createdAt,
      final bool isCompleted,
      final List<FriendsQuestTask> tasks}) = _$FriendsQuestImpl;

  factory _FriendsQuest.fromJson(Map<String, dynamic> json) =
      _$FriendsQuestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String> get participantIds;
  @override
  String? get linkedMeetingId;
  @override
  DateTime get createdAt;
  @override
  bool get isCompleted;
  @override
  List<FriendsQuestTask> get tasks;

  /// Create a copy of FriendsQuest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendsQuestImplCopyWith<_$FriendsQuestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
