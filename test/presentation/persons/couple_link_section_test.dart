import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/presentation/persons/couple_link_section.dart';

void main() {
  final DateTime testDate = DateTime(2026, 1, 1);

  Person makePerson({
    String id = 'p1',
    String firstName = 'Anna',
    String? partnerId,
    DateTime? partnerLinkedAt,
  }) {
    return Person(
      id: id,
      userId: 'u1',
      firstName: firstName,
      createdAt: testDate,
      partnerId: partnerId,
      partnerLinkedAt: partnerLinkedAt,
    );
  }

  Widget buildWidget({
    required Person person,
    Person? partnerPerson,
    VoidCallback? onLinkTap,
    VoidCallback? onUnlinkTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CoupleLinkSection(
          person: person,
          partnerPerson: partnerPerson,
          onLinkTap: onLinkTap ?? () {},
          onUnlinkTap: onUnlinkTap,
        ),
      ),
    );
  }

  group('CoupleLinkSection', () {
    testWidgets('shows "Link as couple" title when person is unlinked',
        (tester) async {
      await tester.pumpWidget(buildWidget(person: makePerson()));

      expect(find.text('Link as couple'), findsOneWidget);
    });

    testWidgets('shows "Couple" title when person is linked', (tester) async {
      final person = makePerson(
        partnerId: 'p2',
        partnerLinkedAt: DateTime(2026, 4, 10),
      );
      final partner = makePerson(id: 'p2', firstName: 'Bob');

      await tester
          .pumpWidget(buildWidget(person: person, partnerPerson: partner));

      expect(find.text('Couple'), findsOneWidget);
    });

    testWidgets('shows partner full name in subtitle when linked',
        (tester) async {
      final person = makePerson(
        partnerId: 'p2',
        partnerLinkedAt: DateTime(2026, 4, 10),
      );
      final partner = makePerson(id: 'p2', firstName: 'Bob');

      await tester
          .pumpWidget(buildWidget(person: person, partnerPerson: partner));

      expect(find.textContaining('Bob'), findsOneWidget);
    });

    testWidgets('calls onLinkTap when tapped and unlinked', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
          buildWidget(person: makePerson(), onLinkTap: () => tapped = true));

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onLinkTap when tapped and already linked',
        (tester) async {
      var tapped = false;
      final person = makePerson(
        partnerId: 'p2',
        partnerLinkedAt: DateTime(2026, 4, 10),
      );
      final partner = makePerson(id: 'p2', firstName: 'Bob');

      await tester.pumpWidget(buildWidget(
        person: person,
        partnerPerson: partner,
        onLinkTap: () => tapped = true,
      ));

      await tester.tap(find.byType(ListTile));
      expect(tapped, isFalse);
    });

    testWidgets('shows Unlink button when person is linked', (tester) async {
      final person = makePerson(
        partnerId: 'p2',
        partnerLinkedAt: DateTime(2026, 4, 10),
      );
      final partner = makePerson(id: 'p2', firstName: 'Bob');

      await tester.pumpWidget(buildWidget(
        person: person,
        partnerPerson: partner,
      ));

      expect(find.text('Unlink'), findsOneWidget);
    });

    testWidgets('does not show Unlink button when person is unlinked',
        (tester) async {
      await tester.pumpWidget(buildWidget(person: makePerson()));

      expect(find.text('Unlink'), findsNothing);
    });

    testWidgets('calls onUnlinkTap when Unlink button pressed', (tester) async {
      var called = false;
      final person = makePerson(
        partnerId: 'p2',
        partnerLinkedAt: DateTime(2026, 4, 10),
      );
      final partner = makePerson(id: 'p2', firstName: 'Bob');

      await tester.pumpWidget(buildWidget(
        person: person,
        partnerPerson: partner,
        onUnlinkTap: () => called = true,
      ));

      await tester.tap(find.text('Unlink'));
      expect(called, isTrue);
    });
  });
}
