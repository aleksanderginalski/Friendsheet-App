// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityImpl _$$ActivityImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ActivityImpl',
      json,
      ($checkedConvert) {
        final val = _$ActivityImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('userId', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String),
          isGlobal: $checkedConvert('isGlobal', (v) => v as bool),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          categoryId: $checkedConvert('categoryId', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ActivityImplToJson(_$ActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'isGlobal': instance.isGlobal,
      'createdAt': instance.createdAt.toIso8601String(),
      'categoryId': instance.categoryId,
    };
