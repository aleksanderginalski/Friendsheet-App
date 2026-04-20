// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_quest_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendsQuestTaskImpl _$$FriendsQuestTaskImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$FriendsQuestTaskImpl',
      json,
      ($checkedConvert) {
        final val = _$FriendsQuestTaskImpl(
          id: $checkedConvert('id', (v) => v as String),
          text: $checkedConvert('text', (v) => v as String),
          sourceTopicId: $checkedConvert('sourceTopicId', (v) => v as String?),
          assignedPersonIds: $checkedConvert(
              'assignedPersonIds',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          isCompleted:
              $checkedConvert('isCompleted', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$$FriendsQuestTaskImplToJson(
        _$FriendsQuestTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'sourceTopicId': instance.sourceTopicId,
      'assignedPersonIds': instance.assignedPersonIds,
      'isCompleted': instance.isCompleted,
    };
