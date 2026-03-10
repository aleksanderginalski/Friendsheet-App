// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImportCandidateImpl _$$ImportCandidateImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ImportCandidateImpl',
      json,
      ($checkedConvert) {
        final val = _$ImportCandidateImpl(
          id: $checkedConvert('id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
          attendeeEmails: $checkedConvert('attendeeEmails',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          sourceType: $checkedConvert(
              'sourceType', (v) => $enumDecode(_$ImportSourceTypeEnumMap, v)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ImportCandidateImplToJson(
        _$ImportCandidateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'attendeeEmails': instance.attendeeEmails,
      'sourceType': _$ImportSourceTypeEnumMap[instance.sourceType]!,
    };

const _$ImportSourceTypeEnumMap = {
  ImportSourceType.calendar: 'calendar',
  ImportSourceType.photos: 'photos',
};
