import 'package:freezed_annotation/freezed_annotation.dart';

part 'friends_quest_task.freezed.dart';
part 'friends_quest_task.g.dart';

@freezed
class FriendsQuestTask with _$FriendsQuestTask {
  const factory FriendsQuestTask({
    required String id,
    required String text,
    String? contextLabel,
    String? sourceTopicId,
    String? sourcePersonId,
    @Default([]) List<String> assignedPersonIds,
    @Default(false) bool isCompleted,
  }) = _FriendsQuestTask;

  factory FriendsQuestTask.fromJson(Map<String, dynamic> json) =>
      _$FriendsQuestTaskFromJson(json);
}
