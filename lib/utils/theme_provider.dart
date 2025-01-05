import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ThemeProvider {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.green,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
      ),
    );
  }

  static final calendarStyle = CalendarStyle(
    todayDecoration: BoxDecoration(
      color: Colors.green,
      shape: BoxShape.circle,
    ),
    selectedDecoration: BoxDecoration(
      color: Colors.lightGreen,
      shape: BoxShape.circle,
    ),
    weekendTextStyle: TextStyle(color: Colors.red),
  );

  static final calendarHeaderStyle = HeaderStyle(
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    formatButtonTextStyle: TextStyle(color: Colors.green),
  );

  static final listTileTitleStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static final elevatedButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.green),
    padding: MaterialStateProperty.all(
      EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    ),
    textStyle: MaterialStateProperty.all(TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    )),
  );

  static final successTextStyle = TextStyle(
    color: Colors.green,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
