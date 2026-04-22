// Shared mock generation for statistics provider tests.
// The generated mocks file (statistics_provider_test.mocks.dart) is imported by:
// - statistics_provider_distribution_test.dart
// - statistics_provider_visibility_test.dart
// - statistics_provider_year_test.dart

import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/friend_group_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  StatisticsRepository,
  AuthService,
  ActivityCategoryRepository,
  PersonRepository,
  FriendGroupRepository,
])
void main() {
  // No tests here — this file exists only to generate shared mocks.
  // See the *_test.dart files in this directory for actual test cases.
}
