import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationService {
  static final _client = Supabase.instance.client;

  static Future<String?> getCurrentUserId() async {
    final user = _client.auth.currentUser;
    return user?.id;
  }

  static Future<List<Map<String, dynamic>>> fetchRegisteredPlayers(
      String tournamentId) async {
    final response = await _client
        .from('registrations')
        .select('user_id, users(name)')
        .eq('tournament_id', tournamentId);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> registerForTournament(String tournamentId) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('User is not logged in.');

    await _client.from('registrations').insert({
      'tournament_id': tournamentId,
      'user_id': userId,
    });
  }
}
