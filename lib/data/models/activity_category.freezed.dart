// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActivityCategory _$ActivityCategoryFromJson(Map<String, dynamic> json) {
  return _ActivityCategory.fromJson(json);
}

/// @nodoc
mixin _$ActivityCategory {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get iconIdentifier => throw _privateConstructorUsedError;
  bool get isGlobal => throw _privateConstructorUsedError;
  bool get isSelectableAsActivity => throw _privateConstructorUsedError;
  String? get parentCategoryId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ActivityCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityCategoryCopyWith<ActivityCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityCategoryCopyWith<$Res> {
  factory $ActivityCategoryCopyWith(
          ActivityCategory value, $Res Function(ActivityCategory) then) =
      _$ActivityCategoryCopyWithImpl<$Res, ActivityCategory>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String iconIdentifier,
      bool isGlobal,
      bool isSelectableAsActivity,
      String? parentCategoryId,
      DateTime createdAt});
}

/// @nodoc
class _$ActivityCategoryCopyWithImpl<$Res, $Val extends ActivityCategory>
    implements $ActivityCategoryCopyWith<$Res> {
  _$ActivityCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? iconIdentifier = null,
    Object? isGlobal = null,
    Object? isSelectableAsActivity = null,
    Object? parentCategoryId = freezed,
    Object? createdAt = null,
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
      iconIdentifier: null == iconIdentifier
          ? _value.iconIdentifier
          : iconIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      isGlobal: null == isGlobal
          ? _value.isGlobal
          : isGlobal // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelectableAsActivity: null == isSelectableAsActivity
          ? _value.isSelectableAsActivity
          : isSelectableAsActivity // ignore: cast_nullable_to_non_nullable
              as bool,
      parentCategoryId: freezed == parentCategoryId
          ? _value.parentCategoryId
          : parentCategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityCategoryImplCopyWith<$Res>
    implements $ActivityCategoryCopyWith<$Res> {
  factory _$$ActivityCategoryImplCopyWith(_$ActivityCategoryImpl value,
          $Res Function(_$ActivityCategoryImpl) then) =
      __$$ActivityCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String iconIdentifier,
      bool isGlobal,
      bool isSelectableAsActivity,
      String? parentCategoryId,
      DateTime createdAt});
}

/// @nodoc
class __$$ActivityCategoryImplCopyWithImpl<$Res>
    extends _$ActivityCategoryCopyWithImpl<$Res, _$ActivityCategoryImpl>
    implements _$$ActivityCategoryImplCopyWith<$Res> {
  __$$ActivityCategoryImplCopyWithImpl(_$ActivityCategoryImpl _value,
      $Res Function(_$ActivityCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? iconIdentifier = null,
    Object? isGlobal = null,
    Object? isSelectableAsActivity = null,
    Object? parentCategoryId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$ActivityCategoryImpl(
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
      iconIdentifier: null == iconIdentifier
          ? _value.iconIdentifier
          : iconIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      isGlobal: null == isGlobal
          ? _value.isGlobal
          : isGlobal // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelectableAsActivity: null == isSelectableAsActivity
          ? _value.isSelectableAsActivity
          : isSelectableAsActivity // ignore: cast_nullable_to_non_nullable
              as bool,
      parentCategoryId: freezed == parentCategoryId
          ? _value.parentCategoryId
          : parentCategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityCategoryImpl extends _ActivityCategory {
  const _$ActivityCategoryImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.iconIdentifier,
      required this.isGlobal,
      required this.isSelectableAsActivity,
      this.parentCategoryId,
      required this.createdAt})
      : super._();

  factory _$ActivityCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String iconIdentifier;
  @override
  final bool isGlobal;
  @override
  final bool isSelectableAsActivity;
  @override
  final String? parentCategoryId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ActivityCategory(id: $id, userId: $userId, name: $name, iconIdentifier: $iconIdentifier, isGlobal: $isGlobal, isSelectableAsActivity: $isSelectableAsActivity, parentCategoryId: $parentCategoryId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconIdentifier, iconIdentifier) ||
                other.iconIdentifier == iconIdentifier) &&
            (identical(other.isGlobal, isGlobal) ||
                other.isGlobal == isGlobal) &&
            (identical(other.isSelectableAsActivity, isSelectableAsActivity) ||
                other.isSelectableAsActivity == isSelectableAsActivity) &&
            (identical(other.parentCategoryId, parentCategoryId) ||
                other.parentCategoryId == parentCategoryId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name, iconIdentifier,
      isGlobal, isSelectableAsActivity, parentCategoryId, createdAt);

  /// Create a copy of ActivityCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityCategoryImplCopyWith<_$ActivityCategoryImpl> get copyWith =>
      __$$ActivityCategoryImplCopyWithImpl<_$ActivityCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityCategoryImplToJson(
      this,
    );
  }
}

abstract class _ActivityCategory extends ActivityCategory {
  const factory _ActivityCategory(
      {required final String id,
      required final String userId,
      required final String name,
      required final String iconIdentifier,
      required final bool isGlobal,
      required final bool isSelectableAsActivity,
      final String? parentCategoryId,
      required final DateTime createdAt}) = _$ActivityCategoryImpl;
  const _ActivityCategory._() : super._();

  factory _ActivityCategory.fromJson(Map<String, dynamic> json) =
      _$ActivityCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get iconIdentifier;
  @override
  bool get isGlobal;
  @override
  bool get isSelectableAsActivity;
  @override
  String? get parentCategoryId;
  @override
  DateTime get createdAt;

  /// Create a copy of ActivityCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityCategoryImplCopyWith<_$ActivityCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
