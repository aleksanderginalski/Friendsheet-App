// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharingTokenImpl _$$SharingTokenImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$SharingTokenImpl',
      json,
      ($checkedConvert) {
        final val = _$SharingTokenImpl(
          id: $checkedConvert('id', (v) => v as String),
          token: $checkedConvert('token', (v) => v as String),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          expiresAt:
              $checkedConvert('expiresAt', (v) => DateTime.parse(v as String)),
          isUsed: $checkedConvert('isUsed', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SharingTokenImplToJson(_$SharingTokenImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isUsed': instance.isUsed,
    };
