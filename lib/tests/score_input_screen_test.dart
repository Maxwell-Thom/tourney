import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../screens/score_input_screen.dart';
import '../services/score_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'score_input_screen_test.mocks.dart';

@GenerateMocks([ScoreService])
void main() {
  final mockScoreService = MockScoreService();
  const testTournament = {'id': '1', 'name': 'Test Tournament'};

  setUp(() {
    when(mockScoreService.fetchMatches('1')).thenAnswer((_) async => [
          {'id': 'match_1', 'date': '2024-01-01'}
        ]);
    when(mockScoreService.fetchHoles('match_1')).thenAnswer((_) async => [
          {'id': 'hole_1', 'name': 'Hole 1'}
        ]);
    when(mockScoreService.saveScore(
      matchId: 'match_1',
      holeId: 'hole_1',
      tournamentId: '1',
      score: 3,
    )).thenAnswer((_) async => {});
  });

  testWidgets('renders score input screen', (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(home: ScoreInputScreen(tournament: testTournament)));

    expect(find.text('Score Input - Test Tournament'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Hole 1'), findsOneWidget);
  });

  testWidgets('saves score', (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(home: ScoreInputScreen(tournament: testTournament)));

    await tester.enterText(find.byType(TextField), '3');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    verify(mockScoreService.saveScore(
      matchId: 'match_1',
      holeId: 'hole_1',
      tournamentId: '1',
      score: 3,
    )).called(1);
  });
}
