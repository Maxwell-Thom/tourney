import 'package:supabase_flutter/supabase_flutter.dart';

class ScoreService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> fetchMatches(
      String tournamentId) async {
    final response = await _client
        .from('matches')
        .select('id, date')
        .eq('tournament_id', tournamentId)
        .order('date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> fetchHoles(String matchId) async {
    final matchResponse = await _client
        .from('matches')
        .select('course_id')
        .eq('id', matchId)
        .single();

    final courseId = matchResponse['course_id'];

    final holesResponse = await _client
        .from('holes')
        .select('id, name, order')
        .eq('course_id', courseId)
        .order('order', ascending: true);

    return List<Map<String, dynamic>>.from(holesResponse);
  }

  static Future<void> saveScore({
    required String matchId,
    required String holeId,
    required String tournamentId,
    required int score,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(
          'User ID not found. Please ensure the user is logged in.');
    }

    await _client.from('scores').insert({
      'user_id': userId,
      'match_id': matchId,
      'hole_id': holeId,
      'tournament_id': tournamentId,
      'score': score,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
