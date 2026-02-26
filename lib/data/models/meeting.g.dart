// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingImpl _$$MeetingImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$MeetingImpl',
      json,
      ($checkedConvert) {
        final val = _$MeetingImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('userId', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
          weight: $checkedConvert('weight', (v) => (v as num).toInt()),
          participantIds: $checkedConvert('participantIds',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          categoryIds: $checkedConvert(
              'categoryIds',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$MeetingImplToJson(_$MeetingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'weight': instance.weight,
      'participantIds': instance.participantIds,
      'categoryIds': instance.categoryIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
