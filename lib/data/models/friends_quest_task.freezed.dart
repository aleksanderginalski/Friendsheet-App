// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friends_quest_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FriendsQuestTask _$FriendsQuestTaskFromJson(Map<String, dynamic> json) {
  return _FriendsQuestTask.fromJson(json);
}

/// @nodoc
mixin _$FriendsQuestTask {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String? get sourceTopicId => throw _privateConstructorUsedError;
  List<String> get assignedPersonIds => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this FriendsQuestTask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendsQuestTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendsQuestTaskCopyWith<FriendsQuestTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendsQuestTaskCopyWith<$Res> {
  factory $FriendsQuestTaskCopyWith(
          FriendsQuestTask value, $Res Function(FriendsQuestTask) then) =
      _$FriendsQuestTaskCopyWithImpl<$Res, FriendsQuestTask>;
  @useResult
  $Res call(
      {String id,
      String text,
      String? sourceTopicId,
      List<String> assignedPersonIds,
      bool isCompleted});
}

/// @nodoc
class _$FriendsQuestTaskCopyWithImpl<$Res, $Val extends FriendsQuestTask>
    implements $FriendsQuestTaskCopyWith<$Res> {
  _$FriendsQuestTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendsQuestTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? sourceTopicId = freezed,
    Object? assignedPersonIds = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      sourceTopicId: freezed == sourceTopicId
          ? _value.sourceTopicId
          : sourceTopicId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedPersonIds: null == assignedPersonIds
          ? _value.assignedPersonIds
          : assignedPersonIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendsQuestTaskImplCopyWith<$Res>
    implements $FriendsQuestTaskCopyWith<$Res> {
  factory _$$FriendsQuestTaskImplCopyWith(_$FriendsQuestTaskImpl value,
          $Res Function(_$FriendsQuestTaskImpl) then) =
      __$$FriendsQuestTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String text,
      String? sourceTopicId,
      List<String> assignedPersonIds,
      bool isCompleted});
}

/// @nodoc
class __$$FriendsQuestTaskImplCopyWithImpl<$Res>
    extends _$FriendsQuestTaskCopyWithImpl<$Res, _$FriendsQuestTaskImpl>
    implements _$$FriendsQuestTaskImplCopyWith<$Res> {
  __$$FriendsQuestTaskImplCopyWithImpl(_$FriendsQuestTaskImpl _value,
      $Res Function(_$FriendsQuestTaskImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendsQuestTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? sourceTopicId = freezed,
    Object? assignedPersonIds = null,
    Object? isCompleted = null,
  }) {
    return _then(_$FriendsQuestTaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      sourceTopicId: freezed == sourceTopicId
          ? _value.sourceTopicId
          : sourceTopicId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedPersonIds: null == assignedPersonIds
          ? _value._assignedPersonIds
          : assignedPersonIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendsQuestTaskImpl implements _FriendsQuestTask {
  const _$FriendsQuestTaskImpl(
      {required this.id,
      required this.text,
      this.sourceTopicId,
      final List<String> assignedPersonIds = const [],
      this.isCompleted = false})
      : _assignedPersonIds = assignedPersonIds;

  factory _$FriendsQuestTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendsQuestTaskImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  final String? sourceTopicId;
  final List<String> _assignedPersonIds;
  @override
  @JsonKey()
  List<String> get assignedPersonIds {
    if (_assignedPersonIds is EqualUnmodifiableListView)
      return _assignedPersonIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedPersonIds);
  }

  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'FriendsQuestTask(id: $id, text: $text, sourceTopicId: $sourceTopicId, assignedPersonIds: $assignedPersonIds, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendsQuestTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.sourceTopicId, sourceTopicId) ||
                other.sourceTopicId == sourceTopicId) &&
            const DeepCollectionEquality()
                .equals(other._assignedPersonIds, _assignedPersonIds) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, sourceTopicId,
      const DeepCollectionEquality().hash(_assignedPersonIds), isCompleted);

  /// Create a copy of FriendsQuestTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendsQuestTaskImplCopyWith<_$FriendsQuestTaskImpl> get copyWith =>
      __$$FriendsQuestTaskImplCopyWithImpl<_$FriendsQuestTaskImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendsQuestTaskImplToJson(
      this,
    );
  }
}

abstract class _FriendsQuestTask implements FriendsQuestTask {
  const factory _FriendsQuestTask(
      {required final String id,
      required final String text,
      final String? sourceTopicId,
      final List<String> assignedPersonIds,
      final bool isCompleted}) = _$FriendsQuestTaskImpl;

  factory _FriendsQuestTask.fromJson(Map<String, dynamic> json) =
      _$FriendsQuestTaskImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  String? get sourceTopicId;
  @override
  List<String> get assignedPersonIds;
  @override
  bool get isCompleted;

  /// Create a copy of FriendsQuestTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendsQuestTaskImplCopyWith<_$FriendsQuestTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
