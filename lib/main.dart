import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../utils/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MiniGolfApp());
}

class MiniGolfApp extends StatelessWidget {
  const MiniGolfApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Golf Tournament',
      theme: ThemeProvider.theme,
      home: AuthScreen(),
    );
  }
}
