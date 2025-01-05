import 'package:flutter/material.dart';
import '../services/score_service.dart';
import '../utils/strings.dart';
import '../utils/theme_provider.dart';

class ScoreInputScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;

  const ScoreInputScreen({Key? key, required this.tournament})
      : super(key: key);

  @override
  _ScoreInputScreenState createState() => _ScoreInputScreenState();
}

class _ScoreInputScreenState extends State<ScoreInputScreen> {
  List<Map<String, dynamic>> _holes = [];
  List<Map<String, dynamic>> _matches = [];
  Map<String, int> _scores = {};
  String? _selectedHoleId;
  String? _selectedMatchId;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    try {
      final matches = await ScoreService.fetchMatches(widget.tournament['id']);
      setState(() {
        _matches = matches;
        if (matches.isNotEmpty) {
          _selectedMatchId = matches[0]['id'];
          _fetchHoles();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  Future<void> _fetchHoles() async {
    if (_selectedMatchId == null) return;

    try {
      final holes = await ScoreService.fetchHoles(_selectedMatchId!);
      setState(() {
        _holes = holes;
        _selectedHoleId = holes.isNotEmpty ? holes[0]['id'] : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  Future<void> _saveScore() async {
    if (_selectedHoleId == null || _selectedMatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.selectHoleAndMatchError)),
      );
      return;
    }

    try {
      final score = _scores[_selectedHoleId] ?? 0;
      await ScoreService.saveScore(
        matchId: _selectedMatchId!,
        holeId: _selectedHoleId!,
        tournamentId: widget.tournament['id'],
        score: score,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.scoreSaved)),
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
        title:
            Text('${Strings.scoreInputTitle} - ${widget.tournament['name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveScore,
            tooltip: Strings.saveScore,
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedMatchId,
            items: _matches
                .map((match) => DropdownMenuItem<String>(
                      value: match['id'],
                      child: Text(match['date']),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMatchId = value;
                _fetchHoles();
              });
            },
            decoration: InputDecoration(labelText: Strings.selectMatch),
          ),
          DropdownButtonFormField<String>(
            value: _selectedHoleId,
            items: _holes
                .map((hole) => DropdownMenuItem<String>(
                      value: hole['id'],
                      child: Text(hole['name']),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedHoleId = value;
              });
            },
            decoration: InputDecoration(labelText: Strings.selectHole),
          ),
          const SizedBox(height: 16),
          if (_selectedHoleId != null)
            ListTile(
              title: Text(
                '${Strings.scoreForHole}: ${_holes.firstWhere((hole) => hole['id'] == _selectedHoleId, orElse: () => {
                      'name': ''
                    })['name']}',
              ),
              trailing: SizedBox(
                width: 50,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: Strings.scoreHint),
                  controller: TextEditingController(
                      text: _scores[_selectedHoleId]?.toString() ?? ''),
                  onChanged: (value) {
                    final score = int.tryParse(value) ?? 0;
                    setState(() {
                      _scores[_selectedHoleId!] = score;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
