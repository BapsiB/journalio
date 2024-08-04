import 'package:flutter/material.dart';
import 'screens/daily_tracker_page.dart';
import 'theme/app_theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: AppTheme.lightTheme,
      home: DailyTrackerPage(),
    );
  }
}
