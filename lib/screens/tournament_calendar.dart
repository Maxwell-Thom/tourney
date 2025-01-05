import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/registration_service.dart';
import '../services/tournament_service.dart';
import '../utils/strings.dart';
import '../utils/theme_provider.dart';
import 'score_input_screen.dart';
import 'tournament_registration_screen.dart';
import 'leaderboard_screen.dart';
import 'create_tournament_screen.dart';

class TournamentCalendar extends StatefulWidget {
  @override
  _TournamentCalendarState createState() => _TournamentCalendarState();
}

class _TournamentCalendarState extends State<TournamentCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _tournaments = [];
  Set<DateTime> _highlightedDates = {};

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    try {
      final tournaments = await TournamentService.fetchTournaments();
      final highlightedDates = tournaments
          .expand((tournament) {
            final matches = tournament['matches'] ?? [];
            return matches.map((match) => DateTime.parse(match['date']));
          })
          .toSet()
          .cast<DateTime>();

      setState(() {
        _tournaments = tournaments;
        _highlightedDates = highlightedDates;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  void _navigateToScoreInput(Map<String, dynamic> tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreInputScreen(tournament: tournament),
      ),
    );
  }

  void _navigateToRegistrationScreen(Map<String, dynamic> tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TournamentRegistrationScreen(tournament: tournament),
      ),
    );
  }

  void _navigateToLeaderboard(Map<String, dynamic> tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(tournament: tournament),
      ),
    );
  }

  void _navigateToCreateTournament() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTournamentScreen()),
    ).then((_) => _fetchTournaments());
  }

  Future<void> _handleTournamentAction(Map<String, dynamic> tournament) async {
    try {
      final userId = await RegistrationService.getCurrentUserId();
      final registeredPlayers =
          await RegistrationService.fetchRegisteredPlayers(tournament['id']);
      final isRegistered =
          registeredPlayers.any((player) => player['user_id'] == userId);

      if (isRegistered) {
        _navigateToScoreInput(tournament);
      } else {
        _navigateToRegistrationScreen(tournament);
      }
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
        title: Text(Strings.tournamentCalendarTitle),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2024),
            lastDay: DateTime(2026),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => _highlightedDates
                    .any((highlightedDate) => isSameDay(highlightedDate, day))
                ? [Strings.eventTournament]
                : [],
            calendarStyle: ThemeProvider.calendarStyle,
            headerStyle: ThemeProvider.calendarHeaderStyle,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tournaments.length,
              itemBuilder: (context, index) {
                final tournament = _tournaments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      tournament['name'],
                      style: ThemeProvider.listTileTitleStyle,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.leaderboard),
                          onPressed: () => _navigateToLeaderboard(tournament),
                          tooltip: Strings.viewLeaderboard,
                        ),
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () => _handleTournamentAction(tournament),
                          tooltip: Strings.inputScore,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTournament,
        child: Icon(Icons.add),
        tooltip: Strings.createTournament,
      ),
    );
  }
}
