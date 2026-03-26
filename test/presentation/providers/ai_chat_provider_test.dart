import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/ai_exceptions.dart';
import 'package:friendsheet/data/models/buddy_context.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/services/buddy_write_service.dart';
import 'package:friendsheet/data/services/context_builder_service.dart';
import 'package:friendsheet/data/services/open_ai_service.dart';
import 'package:friendsheet/presentation/ai_chat/ai_chat_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ai_chat_provider_test.mocks.dart';

@GenerateMocks([OpenAIService, ContextBuilderService, BuddyWriteService])
void main() {
  late MockOpenAIService mockOpenAI;
  late MockContextBuilderService mockContextBuilder;
  late MockBuddyWriteService mockBuddyWrite;
  late AIChatProvider provider;

  final now = DateTime(2026, 3, 10);

  const emptyContext = BuddyContext(
    meetings: [],
    persons: [],
    pseudonymToRealName: {},
    personIdToPseudonym: {},
  );

  Meeting makeMeeting({
    String id = 'm1',
    String name = 'Coffee',
    List<String> notes = const [],
  }) =>
      Meeting(
        id: id,
        userId: 'user-1',
        name: name,
        date: now,
        weight: 3,
        participantIds: const [],
        categoryIds: const [],
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    mockOpenAI = MockOpenAIService();
    mockContextBuilder = MockContextBuilderService();
    mockBuddyWrite = MockBuddyWriteService();

    provider = AIChatProvider(
      openAIService: mockOpenAI,
      contextBuilderService: mockContextBuilder,
      buddyWriteService: mockBuddyWrite,
    );
  });

  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------

  group('initial state', () {
    test('all fields are at default values', () {
      expect(provider.messages, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // initialize — no meetingId / no personId (generic greeting)
  // ---------------------------------------------------------------------------

  group('initialize — generic mode', () {
    test('adds default greeting when no recent meeting without notes',
        () async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);

      await provider.initialize('user-1');

      expect(provider.messages.length, 1);
      expect(provider.messages.first.role, 'assistant');
      expect(provider.messages.first.content, contains('Buddy'));
      expect(provider.isLoading, isFalse);
    });

    test('adds proactive note prompt when recent meeting without notes exists',
        () async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => makeMeeting(name: 'Team Lunch'));

      await provider.initialize('user-1');

      expect(provider.messages.first.content, contains('Team Lunch'));
    });
  });

  // ---------------------------------------------------------------------------
  // initialize — meetingId provided (Mode 1)
  // ---------------------------------------------------------------------------

  group('initialize — meeting mode', () {
    test('greeting mentions meeting name when meetingId provided', () async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.getMeetingById('user-1', 'm1'))
          .thenAnswer((_) async => makeMeeting(name: 'Birthday Party'));

      await provider.initialize('user-1', meetingId: 'm1');

      expect(provider.messages.first.content, contains('Birthday Party'));
    });

    test('fallback greeting when meetingId resolves to null', () async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.getMeetingById(any, any))
          .thenAnswer((_) async => null);

      await provider.initialize('user-1', meetingId: 'unknown');

      expect(provider.messages.first.content, contains('this meeting'));
    });
  });

  // ---------------------------------------------------------------------------
  // initialize — personId provided
  // ---------------------------------------------------------------------------

  group('initialize — person mode', () {
    test('uses buildPersonContext when personId provided', () async {
      when(mockContextBuilder.buildPersonContext('user-1', 'p1'))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);

      await provider.initialize('user-1', personId: 'p1');

      verify(mockContextBuilder.buildPersonContext('user-1', 'p1')).called(1);
      verifyNever(mockContextBuilder.buildFullContext(any));
    });
  });

  // ---------------------------------------------------------------------------
  // sendMessage
  // ---------------------------------------------------------------------------

  group('sendMessage', () {
    setUp(() async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);
      when(mockContextBuilder.serializeToPrompt(any,
              includeNotes: anyNamed('includeNotes')))
          .thenReturn('## Social Context\n');
      await provider.initialize('user-1');
    });

    test('happy path — user and assistant messages added, loading cleared',
        () async {
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.fromIterable(['Hello', ' there']));

      await provider.sendMessage('Hi');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      // messages: [greeting, user, assistant]
      expect(provider.messages.length, 3);
      expect(provider.messages[1].role, 'user');
      expect(provider.messages[1].content, 'Hi');
      expect(provider.messages[2].role, 'assistant');
      expect(provider.messages[2].content, 'Hello there');
    });

    test('translates pseudonyms to real names in response', () async {
      const contextWithMapping = BuddyContext(
        meetings: [],
        persons: [],
        pseudonymToRealName: {'Friend_A': 'Anna Kowalska'},
        personIdToPseudonym: {},
      );
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => contextWithMapping);
      when(mockContextBuilder.serializeToPrompt(any,
              includeNotes: anyNamed('includeNotes')))
          .thenReturn('context');
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);

      // Re-initialize with mapping context.
      final providerWithMapping = AIChatProvider(
        openAIService: mockOpenAI,
        contextBuilderService: mockContextBuilder,
        buddyWriteService: mockBuddyWrite,
      );
      await providerWithMapping.initialize('user-1');

      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.value('You met with Friend_A recently.'));

      await providerWithMapping.sendMessage('Who did I meet?');

      final reply = providerWithMapping.messages.last.content;
      expect(reply, contains('Anna Kowalska'));
      expect(reply, isNot(contains('Friend_A')));
    });

    test('sets errorMessage on NetworkException', () async {
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.error(const NetworkException()));

      await provider.sendMessage('Hello');

      expect(provider.errorMessage, contains('internet'));
      expect(provider.isLoading, isFalse);
    });

    test('sets errorMessage on InvalidKeyException', () async {
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.error(const InvalidKeyException()));

      await provider.sendMessage('Hello');

      expect(provider.errorMessage, contains('API key'));
    });

    test('sets errorMessage on QuotaExceededException', () async {
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.error(const QuotaExceededException()));

      await provider.sendMessage('Hello');

      expect(provider.errorMessage, contains('quota'));
    });

    test('sets generic errorMessage on unknown exception', () async {
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.error(Exception('unknown')));

      await provider.sendMessage('Hello');

      expect(provider.errorMessage, contains('went wrong'));
    });
  });

  // ---------------------------------------------------------------------------
  // retry
  // ---------------------------------------------------------------------------

  group('retry', () {
    setUp(() async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);
      when(mockContextBuilder.serializeToPrompt(any,
              includeNotes: anyNamed('includeNotes')))
          .thenReturn('context');
      await provider.initialize('user-1');
    });

    test('removes last assistant message and re-sends last user message',
        () async {
      // First send — succeeds.
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.value('First reply'));
      await provider.sendMessage('Test question');

      // Retry — new response.
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.value('Retry reply'));
      await provider.retry();

      expect(provider.messages.last.content, 'Retry reply');
    });

    test('does not call AI when no user message exists', () async {
      // Only the greeting assistant message is present — no user message to retry.
      await provider.retry();

      // AI must not have been called.
      verifyNever(mockOpenAI.sendMessage(any, any, any));
    });
  });

  // ---------------------------------------------------------------------------
  // saveNotes
  // ---------------------------------------------------------------------------

  group('saveNotes', () {
    test('delegates to BuddyWriteService when userId and meetingId set',
        () async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.getMeetingById(any, any))
          .thenAnswer((_) async => makeMeeting());
      when(mockBuddyWrite.saveNotes(any, any, any))
          .thenAnswer((_) async {});

      await provider.initialize('user-1', meetingId: 'm1');
      await provider.saveNotes(['note 1', 'note 2']);

      verify(mockBuddyWrite.saveNotes('user-1', 'm1', ['note 1', 'note 2']))
          .called(1);
    });

    test('does nothing when no meetingId set', () async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);

      await provider.initialize('user-1');
      await provider.saveNotes(['note']);

      verifyNever(mockBuddyWrite.saveNotes(any, any, any));
    });
  });

  // ---------------------------------------------------------------------------
  // clearError
  // ---------------------------------------------------------------------------

  group('clearError', () {
    test('clears existing errorMessage', () async {
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => emptyContext);
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);
      when(mockContextBuilder.serializeToPrompt(any,
              includeNotes: anyNamed('includeNotes')))
          .thenReturn('context');
      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.error(const NetworkException()));

      await provider.initialize('user-1');
      await provider.sendMessage('Hi');
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // pseudonym translation — longest match first
  // ---------------------------------------------------------------------------

  group('pseudonym translation order', () {
    test(
        'longer pseudonym replaced before shorter one to prevent partial match',
        () async {
      const contextWithMapping = BuddyContext(
        meetings: [],
        persons: [],
        pseudonymToRealName: {
          'Friend_A': 'Anna',
          'Friend_AB': 'Aleksander Borowski',
        },
        personIdToPseudonym: {},
      );
      when(mockContextBuilder.buildFullContext(any))
          .thenAnswer((_) async => contextWithMapping);
      when(mockContextBuilder.serializeToPrompt(any,
              includeNotes: anyNamed('includeNotes')))
          .thenReturn('context');
      when(mockContextBuilder.findMostRecentMeetingWithoutNotes(any))
          .thenAnswer((_) async => null);

      final p = AIChatProvider(
        openAIService: mockOpenAI,
        contextBuilderService: mockContextBuilder,
        buddyWriteService: mockBuddyWrite,
      );
      await p.initialize('user-1');

      when(mockOpenAI.sendMessage(any, any, any))
          .thenAnswer((_) => Stream.value('Friend_AB met Friend_A'));

      await p.sendMessage('Who met?');

      final reply = p.messages.last.content;
      // Friend_AB → Aleksander Borowski, Friend_A → Anna
      expect(reply, contains('Aleksander Borowski'));
      expect(reply, contains('Anna'));
      // No leftover pseudonym fragments
      expect(reply, isNot(contains('Friend_')));
    });
  });
}
