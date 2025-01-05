import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../utils/strings.dart';

class LeaderboardScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;

  const LeaderboardScreen({Key? key, required this.tournament})
      : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  List<MapEntry<String, String>> _holeNames = [];
  int _maxStrokes = 10; // Default value, updated from config

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    try {
      final maxStrokes = await LeaderboardService.getMaxStrokes();
      final leaderboardData =
          await LeaderboardService.fetchLeaderboard(widget.tournament['id']);

      setState(() {
        _maxStrokes = maxStrokes;
        _leaderboard = leaderboardData['leaderboard'];
        _holeNames = leaderboardData['holes'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  Color _getCellColor(String score) {
    if (score == '--') return Colors.white;
    final scoreValue = int.tryParse(score);
    if (scoreValue == null) return Colors.white;

    final percentage = scoreValue / _maxStrokes;
    return Color.lerp(Colors.green, Colors.red, percentage.clamp(0, 1))!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${Strings.leaderboardTitle} - ${widget.tournament['name']}'),
      ),
      body: _leaderboard.isEmpty || _holeNames.isEmpty
          ? Center(child: Text(Strings.noScoresAvailable))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text(Strings.rank)),
                    const DataColumn(label: Text(Strings.totalScore)),
                    const DataColumn(label: Text(Strings.player)),
                    ..._holeNames
                        .map((hole) => DataColumn(label: Text(hole.value)))
                        .toList(),
                  ],
                  rows: _leaderboard.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final player = entry.value;
                    final scores = player['scores'];
                    final totalScore = player['score'];

                    return DataRow(
                      cells: [
                        DataCell(Text(rank.toString())),
                        DataCell(Text(totalScore.toString())),
                        DataCell(Text(player['name'])),
                        ..._holeNames.map((hole) {
                          final holeId = hole.key;
                          final score = scores[holeId] ?? '--';
                          return DataCell(
                            Container(
                              color: _getCellColor(score),
                              child: Center(child: Text(score)),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
