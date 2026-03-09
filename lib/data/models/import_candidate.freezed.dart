// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ImportCandidate {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<String> get attendeeEmails => throw _privateConstructorUsedError;
  ImportSourceType get sourceType => throw _privateConstructorUsedError;

  /// Create a copy of ImportCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImportCandidateCopyWith<ImportCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportCandidateCopyWith<$Res> {
  factory $ImportCandidateCopyWith(
          ImportCandidate value, $Res Function(ImportCandidate) then) =
      _$ImportCandidateCopyWithImpl<$Res, ImportCandidate>;
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime date,
      List<String> attendeeEmails,
      ImportSourceType sourceType});
}

/// @nodoc
class _$ImportCandidateCopyWithImpl<$Res, $Val extends ImportCandidate>
    implements $ImportCandidateCopyWith<$Res> {
  _$ImportCandidateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImportCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? date = null,
    Object? attendeeEmails = null,
    Object? sourceType = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      attendeeEmails: null == attendeeEmails
          ? _value.attendeeEmails
          : attendeeEmails // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sourceType: null == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as ImportSourceType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImportCandidateImplCopyWith<$Res>
    implements $ImportCandidateCopyWith<$Res> {
  factory _$$ImportCandidateImplCopyWith(_$ImportCandidateImpl value,
          $Res Function(_$ImportCandidateImpl) then) =
      __$$ImportCandidateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime date,
      List<String> attendeeEmails,
      ImportSourceType sourceType});
}

/// @nodoc
class __$$ImportCandidateImplCopyWithImpl<$Res>
    extends _$ImportCandidateCopyWithImpl<$Res, _$ImportCandidateImpl>
    implements _$$ImportCandidateImplCopyWith<$Res> {
  __$$ImportCandidateImplCopyWithImpl(
      _$ImportCandidateImpl _value, $Res Function(_$ImportCandidateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImportCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? date = null,
    Object? attendeeEmails = null,
    Object? sourceType = null,
  }) {
    return _then(_$ImportCandidateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      attendeeEmails: null == attendeeEmails
          ? _value._attendeeEmails
          : attendeeEmails // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sourceType: null == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as ImportSourceType,
    ));
  }
}

/// @nodoc

class _$ImportCandidateImpl implements _ImportCandidate {
  const _$ImportCandidateImpl(
      {required this.id,
      required this.title,
      required this.date,
      required final List<String> attendeeEmails,
      required this.sourceType})
      : _attendeeEmails = attendeeEmails;

  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime date;
  final List<String> _attendeeEmails;
  @override
  List<String> get attendeeEmails {
    if (_attendeeEmails is EqualUnmodifiableListView) return _attendeeEmails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attendeeEmails);
  }

  @override
  final ImportSourceType sourceType;

  @override
  String toString() {
    return 'ImportCandidate(id: $id, title: $title, date: $date, attendeeEmails: $attendeeEmails, sourceType: $sourceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportCandidateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality()
                .equals(other._attendeeEmails, _attendeeEmails) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, date,
      const DeepCollectionEquality().hash(_attendeeEmails), sourceType);

  /// Create a copy of ImportCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportCandidateImplCopyWith<_$ImportCandidateImpl> get copyWith =>
      __$$ImportCandidateImplCopyWithImpl<_$ImportCandidateImpl>(
          this, _$identity);
}

abstract class _ImportCandidate implements ImportCandidate {
  const factory _ImportCandidate(
      {required final String id,
      required final String title,
      required final DateTime date,
      required final List<String> attendeeEmails,
      required final ImportSourceType sourceType}) = _$ImportCandidateImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  DateTime get date;
  @override
  List<String> get attendeeEmails;
  @override
  ImportSourceType get sourceType;

  /// Create a copy of ImportCandidate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportCandidateImplCopyWith<_$ImportCandidateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
