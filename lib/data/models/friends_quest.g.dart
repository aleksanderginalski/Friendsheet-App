// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_quest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendsQuestImpl _$$FriendsQuestImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$FriendsQuestImpl',
      json,
      ($checkedConvert) {
        final val = _$FriendsQuestImpl(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          participantIds: $checkedConvert('participantIds',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          linkedMeetingId:
              $checkedConvert('linkedMeetingId', (v) => v as String?),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          isCompleted:
              $checkedConvert('isCompleted', (v) => v as bool? ?? false),
          tasks: $checkedConvert(
              'tasks',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          FriendsQuestTask.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const []),
        );
        return val;
      },
    );

Map<String, dynamic> _$$FriendsQuestImplToJson(_$FriendsQuestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'participantIds': instance.participantIds,
      'linkedMeetingId': instance.linkedMeetingId,
      'createdAt': instance.createdAt.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
    };
