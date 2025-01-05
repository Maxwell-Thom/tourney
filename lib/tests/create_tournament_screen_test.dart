import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../screens/create_tournament_screen.dart';
import '../services/tournament_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'create_tournament_screen_test.mocks.dart';

@GenerateMocks([TournamentService])
void main() {
  final mockTournamentService = MockTournamentService();

  setUp(() {
    when(mockTournamentService.fetchCourses()).thenAnswer((_) async => [
          {'id': 'course_1', 'name': 'Test Course'}
        ]);
    when(mockTournamentService.createTournament(
      name: anyNamed('name'),
      matches: anyNamed('matches'),
    )).thenAnswer((_) async => {});
  });

  testWidgets('renders create tournament screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateTournamentScreen()));

    expect(find.text('Create Tournament'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Test Course'), findsOneWidget);
  });

  testWidgets('adds a match when course selected', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateTournamentScreen()));

    await tester.tap(find.byType(DropdownButtonFormField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test Course').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Match'));
    await tester.pump();

    expect(
        find.textContaining('Test Course - No Date Selected'), findsOneWidget);
  });
}
