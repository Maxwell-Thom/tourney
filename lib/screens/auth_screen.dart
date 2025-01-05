import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../utils/strings.dart';
import 'tournament_calendar.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLogin = true;

  void _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    try {
      if (_isLogin) {
        await UserService.login(email, password);
      } else {
        await UserService.signUp(email, password, name);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TournamentCalendar()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? Strings.loginTitle : Strings.signupTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: Strings.nameLabel),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: Strings.emailLabel),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: Strings.passwordLabel),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _authenticate,
              child:
                  Text(_isLogin ? Strings.loginButton : Strings.signupButton),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                  _isLogin ? Strings.switchToSignup : Strings.switchToLogin),
            ),
          ],
        ),
      ),
    );
  }
}
