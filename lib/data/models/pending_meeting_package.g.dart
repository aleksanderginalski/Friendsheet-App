// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_meeting_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PendingMeetingPackageImpl _$$PendingMeetingPackageImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PendingMeetingPackageImpl',
      json,
      ($checkedConvert) {
        final val = _$PendingMeetingPackageImpl(
          id: $checkedConvert('id', (v) => v as String),
          senderUid: $checkedConvert('senderUid', (v) => v as String),
          senderFirstName:
              $checkedConvert('senderFirstName', (v) => v as String),
          senderLastName: $checkedConvert('senderLastName', (v) => v as String),
          senderNickname:
              $checkedConvert('senderNickname', (v) => v as String?),
          sentAt: $checkedConvert('sentAt', (v) => DateTime.parse(v as String)),
          meetings: $checkedConvert(
              'meetings',
              (v) => (v as List<dynamic>)
                  .map((e) => SharedMeeting.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$PendingMeetingPackageImplToJson(
        _$PendingMeetingPackageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderUid': instance.senderUid,
      'senderFirstName': instance.senderFirstName,
      'senderLastName': instance.senderLastName,
      'senderNickname': instance.senderNickname,
      'sentAt': instance.sentAt.toIso8601String(),
      'meetings': instance.meetings.map((e) => e.toJson()).toList(),
    };

_$SharedMeetingImpl _$$SharedMeetingImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$SharedMeetingImpl',
      json,
      ($checkedConvert) {
        final val = _$SharedMeetingImpl(
          name: $checkedConvert('name', (v) => v as String),
          date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
          weight: $checkedConvert('weight', (v) => (v as num).toInt()),
          participants: $checkedConvert(
              'participants',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          SharedPerson.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const []),
          categoryNames: $checkedConvert(
              'categoryNames',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SharedMeetingImplToJson(_$SharedMeetingImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'weight': instance.weight,
      'participants': instance.participants.map((e) => e.toJson()).toList(),
      'categoryNames': instance.categoryNames,
    };

_$SharedPersonImpl _$$SharedPersonImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$SharedPersonImpl',
      json,
      ($checkedConvert) {
        final val = _$SharedPersonImpl(
          firstName: $checkedConvert('firstName', (v) => v as String),
          lastName: $checkedConvert('lastName', (v) => v as String?),
          nickname: $checkedConvert('nickname', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SharedPersonImplToJson(_$SharedPersonImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'nickname': instance.nickname,
    };
