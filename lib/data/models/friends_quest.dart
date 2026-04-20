import 'package:freezed_annotation/freezed_annotation.dart';

import 'friends_quest_task.dart';

part 'friends_quest.freezed.dart';
part 'friends_quest.g.dart';

@freezed
class FriendsQuest with _$FriendsQuest {
  const factory FriendsQuest({
    required String id,
    required String name,
    required List<String> participantIds,
    String? linkedMeetingId,
    required DateTime createdAt,
    @Default(false) bool isCompleted,
    @Default([]) List<FriendsQuestTask> tasks,
  }) = _FriendsQuest;

  factory FriendsQuest.fromJson(Map<String, dynamic> json) =>
      _$FriendsQuestFromJson(json);
}
