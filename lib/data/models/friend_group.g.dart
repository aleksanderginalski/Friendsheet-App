// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendGroupImpl _$$FriendGroupImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$FriendGroupImpl',
      json,
      ($checkedConvert) {
        final val = _$FriendGroupImpl(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          iconIdentifier:
              $checkedConvert('iconIdentifier', (v) => v as String?),
          personIds: $checkedConvert(
              'personIds',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          createdAt: $checkedConvert('createdAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$FriendGroupImplToJson(_$FriendGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconIdentifier': instance.iconIdentifier,
      'personIds': instance.personIds,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
