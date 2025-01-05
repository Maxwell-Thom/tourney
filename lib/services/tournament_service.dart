import 'package:supabase_flutter/supabase_flutter.dart';

class TournamentService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> fetchTournaments() async {
    final response = await _client
        .from('tournaments')
        .select('id, name, matches(id, date, courses(name))');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    final response = await _client
        .from('courses')
        .select('id, name')
        .order('name', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createTournament({
    required String name,
    required List<Map<String, dynamic>> matches,
  }) async {
    final tournamentResponse = await _client
        .from('tournaments')
        .insert({'name': name})
        .select('id')
        .single();

    final tournamentId = tournamentResponse['id'];

    final matchesToInsert = matches
        .map((match) => {
              'tournament_id': tournamentId,
              'course_id': match['course_id'],
              'date': match['date']?.toIso8601String(),
            })
        .toList();

    await _client.from('matches').insert(matchesToInsert);
  }
}
