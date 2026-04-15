// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_up_topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatchUpTopicImpl _$$CatchUpTopicImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$CatchUpTopicImpl',
      json,
      ($checkedConvert) {
        final val = _$CatchUpTopicImpl(
          id: $checkedConvert('id', (v) => v as String),
          text: $checkedConvert('text', (v) => v as String),
          contextLabel: $checkedConvert('contextLabel', (v) => v as String?),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          isArchived: $checkedConvert('isArchived', (v) => v as bool? ?? false),
          archivedAt: $checkedConvert('archivedAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$CatchUpTopicImplToJson(_$CatchUpTopicImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'contextLabel': instance.contextLabel,
      'createdAt': instance.createdAt.toIso8601String(),
      'isArchived': instance.isArchived,
      'archivedAt': instance.archivedAt?.toIso8601String(),
    };
