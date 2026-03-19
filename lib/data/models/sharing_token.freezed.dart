// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sharing_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SharingToken _$SharingTokenFromJson(Map<String, dynamic> json) {
  return _SharingToken.fromJson(json);
}

/// @nodoc
mixin _$SharingToken {
  String get id => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  bool get isUsed => throw _privateConstructorUsedError;

  /// Serializes this SharingToken to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharingToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharingTokenCopyWith<SharingToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharingTokenCopyWith<$Res> {
  factory $SharingTokenCopyWith(
          SharingToken value, $Res Function(SharingToken) then) =
      _$SharingTokenCopyWithImpl<$Res, SharingToken>;
  @useResult
  $Res call(
      {String id,
      String token,
      DateTime createdAt,
      DateTime expiresAt,
      bool isUsed});
}

/// @nodoc
class _$SharingTokenCopyWithImpl<$Res, $Val extends SharingToken>
    implements $SharingTokenCopyWith<$Res> {
  _$SharingTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharingToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? token = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? isUsed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SharingTokenImplCopyWith<$Res>
    implements $SharingTokenCopyWith<$Res> {
  factory _$$SharingTokenImplCopyWith(
          _$SharingTokenImpl value, $Res Function(_$SharingTokenImpl) then) =
      __$$SharingTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String token,
      DateTime createdAt,
      DateTime expiresAt,
      bool isUsed});
}

/// @nodoc
class __$$SharingTokenImplCopyWithImpl<$Res>
    extends _$SharingTokenCopyWithImpl<$Res, _$SharingTokenImpl>
    implements _$$SharingTokenImplCopyWith<$Res> {
  __$$SharingTokenImplCopyWithImpl(
      _$SharingTokenImpl _value, $Res Function(_$SharingTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of SharingToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? token = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? isUsed = null,
  }) {
    return _then(_$SharingTokenImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SharingTokenImpl extends _SharingToken {
  const _$SharingTokenImpl(
      {required this.id,
      required this.token,
      required this.createdAt,
      required this.expiresAt,
      this.isUsed = false})
      : super._();

  factory _$SharingTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharingTokenImplFromJson(json);

  @override
  final String id;
  @override
  final String token;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  @JsonKey()
  final bool isUsed;

  @override
  String toString() {
    return 'SharingToken(id: $id, token: $token, createdAt: $createdAt, expiresAt: $expiresAt, isUsed: $isUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharingTokenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, token, createdAt, expiresAt, isUsed);

  /// Create a copy of SharingToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharingTokenImplCopyWith<_$SharingTokenImpl> get copyWith =>
      __$$SharingTokenImplCopyWithImpl<_$SharingTokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SharingTokenImplToJson(
      this,
    );
  }
}

abstract class _SharingToken extends SharingToken {
  const factory _SharingToken(
      {required final String id,
      required final String token,
      required final DateTime createdAt,
      required final DateTime expiresAt,
      final bool isUsed}) = _$SharingTokenImpl;
  const _SharingToken._() : super._();

  factory _SharingToken.fromJson(Map<String, dynamic> json) =
      _$SharingTokenImpl.fromJson;

  @override
  String get id;
  @override
  String get token;
  @override
  DateTime get createdAt;
  @override
  DateTime get expiresAt;
  @override
  bool get isUsed;

  /// Create a copy of SharingToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharingTokenImplCopyWith<_$SharingTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
