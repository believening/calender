import 'package:flutter/material.dart';
import 'ui/views/calendar_view.dart';

void main() {
  runApp(const MultiCalendarApp());
}

class MultiCalendarApp extends StatelessWidget {
  const MultiCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '多民族日历',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const CalendarView(),
    );
  }
}
