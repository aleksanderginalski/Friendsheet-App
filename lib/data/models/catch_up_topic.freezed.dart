// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catch_up_topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CatchUpTopic _$CatchUpTopicFromJson(Map<String, dynamic> json) {
  return _CatchUpTopic.fromJson(json);
}

/// @nodoc
mixin _$CatchUpTopic {
  String get id => throw _privateConstructorUsedError;
  String get text =>
      throw _privateConstructorUsedError; // Optional label indicating when to return to this topic, e.g. "Lipiec 2026".
  String? get contextLabel => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;

  /// Serializes this CatchUpTopic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatchUpTopic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatchUpTopicCopyWith<CatchUpTopic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatchUpTopicCopyWith<$Res> {
  factory $CatchUpTopicCopyWith(
          CatchUpTopic value, $Res Function(CatchUpTopic) then) =
      _$CatchUpTopicCopyWithImpl<$Res, CatchUpTopic>;
  @useResult
  $Res call(
      {String id,
      String text,
      String? contextLabel,
      DateTime createdAt,
      bool isArchived,
      DateTime? archivedAt});
}

/// @nodoc
class _$CatchUpTopicCopyWithImpl<$Res, $Val extends CatchUpTopic>
    implements $CatchUpTopicCopyWith<$Res> {
  _$CatchUpTopicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatchUpTopic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? contextLabel = freezed,
    Object? createdAt = null,
    Object? isArchived = null,
    Object? archivedAt = freezed,
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
      contextLabel: freezed == contextLabel
          ? _value.contextLabel
          : contextLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CatchUpTopicImplCopyWith<$Res>
    implements $CatchUpTopicCopyWith<$Res> {
  factory _$$CatchUpTopicImplCopyWith(
          _$CatchUpTopicImpl value, $Res Function(_$CatchUpTopicImpl) then) =
      __$$CatchUpTopicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String text,
      String? contextLabel,
      DateTime createdAt,
      bool isArchived,
      DateTime? archivedAt});
}

/// @nodoc
class __$$CatchUpTopicImplCopyWithImpl<$Res>
    extends _$CatchUpTopicCopyWithImpl<$Res, _$CatchUpTopicImpl>
    implements _$$CatchUpTopicImplCopyWith<$Res> {
  __$$CatchUpTopicImplCopyWithImpl(
      _$CatchUpTopicImpl _value, $Res Function(_$CatchUpTopicImpl) _then)
      : super(_value, _then);

  /// Create a copy of CatchUpTopic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? contextLabel = freezed,
    Object? createdAt = null,
    Object? isArchived = null,
    Object? archivedAt = freezed,
  }) {
    return _then(_$CatchUpTopicImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      contextLabel: freezed == contextLabel
          ? _value.contextLabel
          : contextLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CatchUpTopicImpl extends _CatchUpTopic {
  const _$CatchUpTopicImpl(
      {required this.id,
      required this.text,
      this.contextLabel,
      required this.createdAt,
      this.isArchived = false,
      this.archivedAt})
      : super._();

  factory _$CatchUpTopicImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatchUpTopicImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
// Optional label indicating when to return to this topic, e.g. "Lipiec 2026".
  @override
  final String? contextLabel;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  final DateTime? archivedAt;

  @override
  String toString() {
    return 'CatchUpTopic(id: $id, text: $text, contextLabel: $contextLabel, createdAt: $createdAt, isArchived: $isArchived, archivedAt: $archivedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatchUpTopicImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.contextLabel, contextLabel) ||
                other.contextLabel == contextLabel) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, text, contextLabel, createdAt, isArchived, archivedAt);

  /// Create a copy of CatchUpTopic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatchUpTopicImplCopyWith<_$CatchUpTopicImpl> get copyWith =>
      __$$CatchUpTopicImplCopyWithImpl<_$CatchUpTopicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatchUpTopicImplToJson(
      this,
    );
  }
}

abstract class _CatchUpTopic extends CatchUpTopic {
  const factory _CatchUpTopic(
      {required final String id,
      required final String text,
      final String? contextLabel,
      required final DateTime createdAt,
      final bool isArchived,
      final DateTime? archivedAt}) = _$CatchUpTopicImpl;
  const _CatchUpTopic._() : super._();

  factory _CatchUpTopic.fromJson(Map<String, dynamic> json) =
      _$CatchUpTopicImpl.fromJson;

  @override
  String get id;
  @override
  String
      get text; // Optional label indicating when to return to this topic, e.g. "Lipiec 2026".
  @override
  String? get contextLabel;
  @override
  DateTime get createdAt;
  @override
  bool get isArchived;
  @override
  DateTime? get archivedAt;

  /// Create a copy of CatchUpTopic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatchUpTopicImplCopyWith<_$CatchUpTopicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
