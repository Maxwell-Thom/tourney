import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _client = Supabase.instance.client;

  static Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signUp(String email, String password, String name) async {
    final response =
        await _client.auth.signUp(email: email, password: password);
    final userId = response.user?.id;
    if (userId != null) {
      await _client.from('users').insert({'id': userId, 'name': name});
    }
  }
}
