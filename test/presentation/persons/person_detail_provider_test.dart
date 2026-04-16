import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/sharing_token_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/data/services/relationship_score_service.dart';
import 'package:friendsheet/presentation/persons/person_detail_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'person_detail_provider_test.mocks.dart';

@GenerateMocks([
  PersonRepository,
  MeetingRepository,
  AuthService,
  SharingTokenRepository,
  RelationshipScoreService,
])
void main() {
  late MockPersonRepository mockPersonRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockAuthService mockAuthService;
  late MockSharingTokenRepository mockSharingTokenRepository;
  late MockRelationshipScoreService mockRelationshipScoreService;
  late PersonDetailProvider provider;

  const stubScore = RelationshipScore(
    score: 50,
    label: 'Good',
    meetingsIn2y: 10,
    daysSinceLast: 30,
    distinctCategories2y: 3,
    distinctWeights2y: 2,
  );

  final testPerson = Person(
    id: 'p1',
    userId: 'u1',
    firstName: 'Anna',
    lastName: 'Kowalska',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockAuthService = MockAuthService();
    mockSharingTokenRepository = MockSharingTokenRepository();
    mockRelationshipScoreService = MockRelationshipScoreService();
    when(mockAuthService.currentUserId).thenReturn('u1');
    when(mockRelationshipScoreService.computeScore(any, any))
        .thenAnswer((_) async => stubScore);
    provider = PersonDetailProvider(
      personRepository: mockPersonRepository,
      meetingRepository: mockMeetingRepository,
      authService: mockAuthService,
      sharingTokenRepository: mockSharingTokenRepository,
      relationshipScoreService: mockRelationshipScoreService,
    );
  });

  group('PersonDetailProvider', () {
    test('initialize fetches meeting count and stores it', () async {
      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 3);

      await provider.initialize(testPerson);

      expect(provider.meetingCount, equals(3));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('initialize stores the person', () async {
      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 0);

      await provider.initialize(testPerson);

      expect(provider.person, equals(testPerson));
    });

    test('initialize computes and stores relationship score', () async {
      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 0);

      await provider.initialize(testPerson);

      expect(provider.score, equals(stubScore));
    });

    test('updatePerson calls repository and updates _person on success',
        () async {
      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 0);
      when(mockPersonRepository.updatePerson(any))
          .thenAnswer((_) => Future<void>.value());

      await provider.initialize(testPerson);
      final result = await provider.updatePerson('Maria', 'Nowak');

      expect(result, isTrue);
      expect(provider.person!.firstName, equals('Maria'));
      expect(provider.person!.lastName, equals('Nowak'));
      verify(mockPersonRepository.updatePerson(any)).called(1);
    });

    test('updatePerson returns false when firstName is empty', () async {
      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 0);

      await provider.initialize(testPerson);
      final result = await provider.updatePerson('', 'Nowak');

      expect(result, isFalse);
      expect(provider.errorMessage, isNotNull);
      verifyNever(mockPersonRepository.updatePerson(any));
    });

    test('deletePerson calls repository and returns true on success', () async {
      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 0);
      when(mockPersonRepository.deletePerson('u1', 'p1'))
          .thenAnswer((_) => Future<void>.value());

      await provider.initialize(testPerson);
      final result = await provider.deletePerson();

      expect(result, isTrue);
      verify(mockPersonRepository.deletePerson('u1', 'p1')).called(1);
    });

    test('refreshMeetingCount updates count without setting isLoading',
        () async {
      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 5);
      await provider.initialize(testPerson);

      when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
          .thenAnswer((_) async => 2);
      await provider.refreshMeetingCount();

      expect(provider.meetingCount, equals(2));
      expect(provider.isLoading, isFalse);
    });

    group('updateBirthDayMonth', () {
      setUp(() async {
        when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
            .thenAnswer((_) async => 0);
        when(mockPersonRepository.updatePerson(any))
            .thenAnswer((_) => Future<void>.value());
        await provider.initialize(testPerson);
      });

      test('sets birthDayMonth and saves to repository', () async {
        await provider.updateBirthDayMonth('03-15');

        expect(provider.person!.birthDayMonth, '03-15');
        verify(mockPersonRepository.updatePerson(any)).called(1);
      });

      test('clears birthDayMonth when null is passed', () async {
        await provider.updateBirthDayMonth('03-15');
        await provider.updateBirthDayMonth(null);

        expect(provider.person!.birthDayMonth, isNull);
      });
    });

    group('setPartner', () {
      setUp(() async {
        when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
            .thenAnswer((_) async => 0);
        await provider.initialize(testPerson);
      });

      test('updates partnerId and partnerLinkedAt on person', () {
        final linkedAt = DateTime(2026, 4, 10);

        provider.setPartner('p2', linkedAt);

        expect(provider.person!.partnerId, equals('p2'));
        expect(provider.person!.partnerLinkedAt, equals(linkedAt));
      });
    });

    group('linkFriendAccount', () {
      setUp(() async {
        when(mockMeetingRepository.getMeetingsCountForPerson('u1', 'p1'))
            .thenAnswer((_) async => 0);
        await provider.initialize(testPerson);
      });

      test('returns success, calls updatePerson and markAsUsed on valid token',
          () async {
        const validResult = TokenValidationResult.success(
          ownerUid: 'uid-friend-42',
          tokenId: 'token-doc-1',
        );
        when(mockSharingTokenRepository.validateAndClaimToken('ABCDEF'))
            .thenAnswer((_) async => validResult);
        when(mockPersonRepository.updatePerson(any))
            .thenAnswer((_) => Future<void>.value());
        when(mockSharingTokenRepository.markAsUsed(
                'uid-friend-42', 'token-doc-1'))
            .thenAnswer((_) => Future<void>.value());

        // Input with lowercase and whitespace — provider must trim+uppercase.
        final result = await provider.linkFriendAccount(' abcdef ');

        expect(result.isSuccess, isTrue);
        expect(result.ownerUid, 'uid-friend-42');
        expect(provider.person!.linkedUserId, 'uid-friend-42');
        expect(provider.isLinking, isFalse);
        verify(mockPersonRepository.updatePerson(any)).called(1);
        verify(mockSharingTokenRepository.markAsUsed(
                'uid-friend-42', 'token-doc-1'))
            .called(1);
      });

      test('returns notFound and does not call updatePerson', () async {
        const failResult =
            TokenValidationResult.failure(TokenValidationError.notFound);
        when(mockSharingTokenRepository.validateAndClaimToken('ZZZZZZ'))
            .thenAnswer((_) async => failResult);

        final result = await provider.linkFriendAccount('ZZZZZZ');

        expect(result.isSuccess, isFalse);
        expect(result.error, TokenValidationError.notFound);
        verifyNever(mockPersonRepository.updatePerson(any));
      });

      test('returns serverError when validateAndClaimToken throws', () async {
        when(mockSharingTokenRepository.validateAndClaimToken(any))
            .thenThrow(Exception('network error'));

        final result = await provider.linkFriendAccount('ABCDEF');

        expect(result.isSuccess, isFalse);
        expect(result.error, TokenValidationError.serverError);
        expect(provider.isLinking, isFalse);
      });
    });
  });
}
