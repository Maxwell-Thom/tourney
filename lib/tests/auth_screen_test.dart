import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../screens/auth_screen.dart';
import '../services/user_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_screen_test.mocks.dart';

@GenerateMocks([UserService])
void main() {
  final mockUserService = MockUserService();

  setUp(() {
    when(mockUserService.login(any, any)).thenAnswer((_) async => {});
    when(mockUserService.signUp(any, any, any)).thenAnswer((_) async => {});
  });

  testWidgets('renders login screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthScreen()));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);
  });

  testWidgets('switches to sign-up screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthScreen()));

    await tester.tap(find.text('Create an Account'));
    await tester.pump();

    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Already have an account? Login'), findsOneWidget);
  });

  testWidgets('calls login on button tap', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    verify(mockUserService.login('test@example.com', 'password123')).called(1);
  });

  testWidgets('calls sign-up on button tap', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthScreen()));

    await tester.tap(find.text('Create an Account'));
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    verify(mockUserService.signUp(
            'test@example.com', 'password123', 'Test User'))
        .called(1);
  });
}
