// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonImpl _$$PersonImplFromJson(Map<String, dynamic> json) => $checkedCreate(
      r'_$PersonImpl',
      json,
      ($checkedConvert) {
        final val = _$PersonImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('userId', (v) => v as String),
          firstName: $checkedConvert('firstName', (v) => v as String),
          lastName: $checkedConvert('lastName', (v) => v as String?),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          nicknames: $checkedConvert(
              'nicknames',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          linkedUserId: $checkedConvert('linkedUserId', (v) => v as String?),
          birthDayMonth: $checkedConvert('birthDayMonth', (v) => v as String?),
          partnerId: $checkedConvert('partnerId', (v) => v as String?),
          partnerLinkedAt: $checkedConvert('partnerLinkedAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$PersonImplToJson(_$PersonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'createdAt': instance.createdAt.toIso8601String(),
      'nicknames': instance.nicknames,
      'linkedUserId': instance.linkedUserId,
      'birthDayMonth': instance.birthDayMonth,
      'partnerId': instance.partnerId,
      'partnerLinkedAt': instance.partnerLinkedAt?.toIso8601String(),
    };
