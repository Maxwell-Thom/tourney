import 'package:flutter/material.dart';
import '../services/registration_service.dart';
import '../services/tournament_service.dart';
import '../utils/strings.dart';
import '../utils/theme_provider.dart';

class CreateTournamentScreen extends StatefulWidget {
  @override
  _CreateTournamentScreenState createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _matches = [];
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await TournamentService.fetchCourses();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  void _addMatch() {
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.selectCourseError)),
      );
      return;
    }

    setState(() {
      _matches.add({
        'course_id': _selectedCourseId,
        'course_name': _courses
            .firstWhere((course) => course['id'] == _selectedCourseId)['name'],
        'date': null,
      });
    });
  }

  Future<void> _createTournament() async {
    final name = _nameController.text.trim();

    if (name.isEmpty || _matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.tournamentDetailsError)),
      );
      return;
    }

    try {
      await TournamentService.createTournament(
        name: name,
        matches: _matches,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.tournamentCreated)),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.errorPrefix}: $e')),
      );
    }
  }

  Future<void> _selectMatchDate(int index) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );

    if (pickedDate != null) {
      setState(() {
        _matches[index]['date'] = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.createTournament),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: Strings.tournamentName),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              items: _courses
                  .map((course) => DropdownMenuItem<String>(
                        value: course['id'],
                        child: Text(course['name']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value;
                });
              },
              decoration: InputDecoration(labelText: Strings.selectCourse),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMatch,
              child: Text(Strings.addMatch),
              style: ThemeProvider.elevatedButtonStyle,
            ),
            const SizedBox(height: 16),
            Text(
              Strings.matches,
              style: ThemeProvider.listTileTitleStyle,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _matches.length,
                itemBuilder: (context, index) {
                  final match = _matches[index];
                  return ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      '${match['course_name']} - ${match['date'] != null ? '${match['date'].year}-${match['date'].month}-${match['date'].day}' : Strings.noDateSelected}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _selectMatchDate(index),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _createTournament,
              child: Text(Strings.createTournament),
              style: ThemeProvider.elevatedButtonStyle,
            ),
          ],
        ),
      ),
    );
  }
}
