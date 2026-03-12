// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FriendGroup _$FriendGroupFromJson(Map<String, dynamic> json) {
  return _FriendGroup.fromJson(json);
}

/// @nodoc
mixin _$FriendGroup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get iconIdentifier => throw _privateConstructorUsedError;
  List<String> get personIds => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FriendGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendGroupCopyWith<FriendGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendGroupCopyWith<$Res> {
  factory $FriendGroupCopyWith(
          FriendGroup value, $Res Function(FriendGroup) then) =
      _$FriendGroupCopyWithImpl<$Res, FriendGroup>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? iconIdentifier,
      List<String> personIds,
      DateTime? createdAt});
}

/// @nodoc
class _$FriendGroupCopyWithImpl<$Res, $Val extends FriendGroup>
    implements $FriendGroupCopyWith<$Res> {
  _$FriendGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconIdentifier = freezed,
    Object? personIds = null,
    Object? createdAt = freezed,
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
      iconIdentifier: freezed == iconIdentifier
          ? _value.iconIdentifier
          : iconIdentifier // ignore: cast_nullable_to_non_nullable
              as String?,
      personIds: null == personIds
          ? _value.personIds
          : personIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendGroupImplCopyWith<$Res>
    implements $FriendGroupCopyWith<$Res> {
  factory _$$FriendGroupImplCopyWith(
          _$FriendGroupImpl value, $Res Function(_$FriendGroupImpl) then) =
      __$$FriendGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? iconIdentifier,
      List<String> personIds,
      DateTime? createdAt});
}

/// @nodoc
class __$$FriendGroupImplCopyWithImpl<$Res>
    extends _$FriendGroupCopyWithImpl<$Res, _$FriendGroupImpl>
    implements _$$FriendGroupImplCopyWith<$Res> {
  __$$FriendGroupImplCopyWithImpl(
      _$FriendGroupImpl _value, $Res Function(_$FriendGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconIdentifier = freezed,
    Object? personIds = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$FriendGroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconIdentifier: freezed == iconIdentifier
          ? _value.iconIdentifier
          : iconIdentifier // ignore: cast_nullable_to_non_nullable
              as String?,
      personIds: null == personIds
          ? _value._personIds
          : personIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendGroupImpl extends _FriendGroup {
  const _$FriendGroupImpl(
      {required this.id,
      required this.name,
      this.iconIdentifier,
      final List<String> personIds = const [],
      this.createdAt})
      : _personIds = personIds,
        super._();

  factory _$FriendGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? iconIdentifier;
  final List<String> _personIds;
  @override
  @JsonKey()
  List<String> get personIds {
    if (_personIds is EqualUnmodifiableListView) return _personIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_personIds);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'FriendGroup(id: $id, name: $name, iconIdentifier: $iconIdentifier, personIds: $personIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconIdentifier, iconIdentifier) ||
                other.iconIdentifier == iconIdentifier) &&
            const DeepCollectionEquality()
                .equals(other._personIds, _personIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, iconIdentifier,
      const DeepCollectionEquality().hash(_personIds), createdAt);

  /// Create a copy of FriendGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendGroupImplCopyWith<_$FriendGroupImpl> get copyWith =>
      __$$FriendGroupImplCopyWithImpl<_$FriendGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendGroupImplToJson(
      this,
    );
  }
}

abstract class _FriendGroup extends FriendGroup {
  const factory _FriendGroup(
      {required final String id,
      required final String name,
      final String? iconIdentifier,
      final List<String> personIds,
      final DateTime? createdAt}) = _$FriendGroupImpl;
  const _FriendGroup._() : super._();

  factory _FriendGroup.fromJson(Map<String, dynamic> json) =
      _$FriendGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get iconIdentifier;
  @override
  List<String> get personIds;
  @override
  DateTime? get createdAt;

  /// Create a copy of FriendGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendGroupImplCopyWith<_$FriendGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
