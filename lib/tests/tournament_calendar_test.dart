import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../screens/tournament_calendar.dart';
import '../services/tournament_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'tournament_calendar_test.mocks.dart';

@GenerateMocks([TournamentService])
void main() {
  final mockTournamentService = MockTournamentService();

  setUp(() {
    when(mockTournamentService.fetchTournaments()).thenAnswer((_) async => [
          {
            'id': '1',
            'name': 'Test Tournament',
            'matches': [
              {
                'id': '1',
                'date': '2024-01-01',
                'courses': [
                  {'name': 'Test Course'}
                ]
              }
            ]
          }
        ]);
  });

  testWidgets('renders tournament calendar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: TournamentCalendar()));

    expect(find.text('Tournament Calendar'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Test Tournament'), findsOneWidget);
  });

  testWidgets('navigates to create tournament screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: TournamentCalendar()));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Tournament'), findsOneWidget);
  });
}
