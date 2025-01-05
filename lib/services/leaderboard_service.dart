import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardService {
  static final _client = Supabase.instance.client;

  static Future<int> getMaxStrokes() async {
    final response = await _client
        .from('config')
        .select('value')
        .eq('key', 'max_strokes')
        .single();
    return int.tryParse(response['value']) ?? 10;
  }

  static Future<Map<String, dynamic>> fetchLeaderboard(
      String tournamentId) async {
    final matchesResponse = await _client
        .from('matches')
        .select('course_id')
        .eq('tournament_id', tournamentId);

    final matches = List<Map<String, dynamic>>.from(matchesResponse);
    final courseIds = matches.map((match) => match['course_id']).toSet();

    if (courseIds.isEmpty) return {'leaderboard': [], 'holes': []};

    final holesResponse = await _client
        .from('holes')
        .select('id, name, course_id, order')
        .filter('course_id', 'in', courseIds.toList())
        .order('order', ascending: true);

    final holes = List<Map<String, dynamic>>.from(holesResponse);

    final scoresResponse = await _client
        .from('scores')
        .select('user_id, users(name), hole_id, score')
        .eq('tournament_id', tournamentId);

    final scores = List<Map<String, dynamic>>.from(scoresResponse);
    final leaderboard = {};

    for (final score in scores) {
      final userId = score['user_id'];
      final userName = score['users']['name'];
      final holeId = score['hole_id'];
      final totalScore = score['score'];

      if (!leaderboard.containsKey(userId)) {
        leaderboard[userId] = {
          'name': userName,
          'scores': {for (var hole in holes) hole['id']: '--'},
          'score': 0,
        };
      }

      leaderboard[userId]['scores'][holeId] = totalScore.toString();
      leaderboard[userId]['score'] += totalScore as int;
    }

    final sortedLeaderboard = leaderboard.entries
        .map((entry) => {
              'user_id': entry.key,
              'name': entry.value['name'],
              'scores': entry.value['scores'],
              'score': entry.value['score'],
            })
        .toList()
      ..sort((a, b) => a['score'].compareTo(b['score']));

    final holeEntries = holes
        .map((hole) => MapEntry(hole['id'] as String, hole['name'] as String))
        .toList();

    return {'leaderboard': sortedLeaderboard, 'holes': holeEntries};
  }
}
