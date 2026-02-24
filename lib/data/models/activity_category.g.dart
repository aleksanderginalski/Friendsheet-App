// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityCategoryImpl _$$ActivityCategoryImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ActivityCategoryImpl',
      json,
      ($checkedConvert) {
        final val = _$ActivityCategoryImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('userId', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          iconIdentifier: $checkedConvert('iconIdentifier', (v) => v as String),
          isGlobal: $checkedConvert('isGlobal', (v) => v as bool),
          parentCategoryId:
              $checkedConvert('parentCategoryId', (v) => v as String?),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ActivityCategoryImplToJson(
        _$ActivityCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'iconIdentifier': instance.iconIdentifier,
      'isGlobal': instance.isGlobal,
      'parentCategoryId': instance.parentCategoryId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
