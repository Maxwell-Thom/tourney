import 'package:flutter/material.dart';
import '../services/registration_service.dart';
import '../utils/strings.dart';
import '../utils/theme_provider.dart';

class TournamentRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;

  const TournamentRegistrationScreen({Key? key, required this.tournament})
      : super(key: key);

  @override
  _TournamentRegistrationScreenState createState() =>
      _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState
    extends State<TournamentRegistrationScreen> {
  List<Map<String, dynamic>> _registeredPlayers = [];
  bool _isAlreadyRegistered = false;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredPlayers();
  }

  Future<void> _fetchRegisteredPlayers() async {
    try {
      final userId = await RegistrationService.getCurrentUserId();
      final players = await RegistrationService.fetchRegisteredPlayers(
          widget.tournament['id']);

      setState(() {
        _registeredPlayers = players;
        _isAlreadyRegistered =
            players.any((player) => player['user_id'] == userId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  Future<void> _registerForTournament() async {
    try {
      await RegistrationService.registerForTournament(widget.tournament['id']);
      await _fetchRegisteredPlayers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.registrationSuccess)),
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
        title: Text(
          '${Strings.registerFor} ${widget.tournament['name']}',
        ),
      ),
      body: Column(
        children: [
          if (!_isAlreadyRegistered)
            ElevatedButton(
              onPressed: _registerForTournament,
              child: Text(Strings.register),
              style: ThemeProvider.elevatedButtonStyle,
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                Strings.alreadyRegistered,
                style: ThemeProvider.successTextStyle,
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _registeredPlayers.length,
              itemBuilder: (context, index) {
                final playerName = _registeredPlayers[index]['users']['name'];
                return ListTile(
                  title: Text(
                    playerName,
                    style: ThemeProvider.listTileTitleStyle,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
