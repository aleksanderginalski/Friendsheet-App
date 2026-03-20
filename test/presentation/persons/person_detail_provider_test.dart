import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/sharing_token_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/persons/person_detail_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'person_detail_provider_test.mocks.dart';

@GenerateMocks(
    [PersonRepository, MeetingRepository, AuthService, SharingTokenRepository])
void main() {
  late MockPersonRepository mockPersonRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockAuthService mockAuthService;
  late MockSharingTokenRepository mockSharingTokenRepository;
  late PersonDetailProvider provider;

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
    when(mockAuthService.currentUserId).thenReturn('u1');
    provider = PersonDetailProvider(
      personRepository: mockPersonRepository,
      meetingRepository: mockMeetingRepository,
      authService: mockAuthService,
      sharingTokenRepository: mockSharingTokenRepository,
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
