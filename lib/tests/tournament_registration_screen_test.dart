import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../screens/tournament_registration_screen.dart';
import '../services/registration_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'tournament_registration_screen_test.mocks.dart';

@GenerateMocks([RegistrationService])
void main() {
  final mockRegistrationService = MockRegistrationService();
  const testTournament = {'id': '1', 'name': 'Test Tournament'};

  setUp(() {
    when(mockRegistrationService.getCurrentUserId())
        .thenAnswer((_) async => 'test_user_id');
    when(mockRegistrationService.fetchRegisteredPlayers('1'))
        .thenAnswer((_) async => [
              {
                'user_id': 'test_user_id',
                'users': {'name': 'Test Player'}
              }
            ]);
    when(mockRegistrationService.registerForTournament('1'))
        .thenAnswer((_) async => {});
  });

  testWidgets('renders tournament registration screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: TournamentRegistrationScreen(tournament: testTournament)));

    expect(find.text('Register for Test Tournament'), findsOneWidget);
    expect(find.text('Test Player'), findsOneWidget);
  });

  testWidgets('shows register button if not registered',
      (WidgetTester tester) async {
    when(mockRegistrationService.fetchRegisteredPlayers('1'))
        .thenAnswer((_) async => []);
    await tester.pumpWidget(MaterialApp(
        home: TournamentRegistrationScreen(tournament: testTournament)));

    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('registers user when button is pressed',
      (WidgetTester tester) async {
    when(mockRegistrationService.fetchRegisteredPlayers('1'))
        .thenAnswer((_) async => []);
    await tester.pumpWidget(MaterialApp(
        home: TournamentRegistrationScreen(tournament: testTournament)));

    await tester.tap(find.text('Register'));
    await tester.pump();

    verify(mockRegistrationService.registerForTournament('1')).called(1);
  });
}
