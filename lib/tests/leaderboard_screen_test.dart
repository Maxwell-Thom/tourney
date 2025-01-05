import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../screens/leaderboard_screen.dart';
import '../services/leaderboard_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'leaderboard_screen_test.mocks.dart';

@GenerateMocks([LeaderboardService])
void main() {
  final mockLeaderboardService = MockLeaderboardService();
  const testTournament = {'id': '1', 'name': 'Test Tournament'};

  setUp(() {
    when(mockLeaderboardService.getMaxStrokes()).thenAnswer((_) async => 10);
    when(mockLeaderboardService.fetchLeaderboard('1')).thenAnswer((_) async => {
          'leaderboard': [
            {
              'name': 'Player 1',
              'scores': {'hole_1': '2', 'hole_2': '--'},
              'score': 2
            }
          ],
          'holes': [
            MapEntry('hole_1', '1'),
            MapEntry('hole_2', '2'),
          ]
        });
  });

  testWidgets('renders leaderboard screen', (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(home: LeaderboardScreen(tournament: testTournament)));

    expect(find.text('Leaderboard - Test Tournament'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
