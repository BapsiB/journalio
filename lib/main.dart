import 'package:flutter/material.dart';
import 'package:journalio/theme/app_colors.dart';
import 'screens/daily_tracker_page.dart';
import 'screens/question_editor.dart';
import 'screens/analytics_page.dart';
import 'screens/settings_page.dart';
import 'theme/app_theme.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('An error occurred: ${details.exception}');
    debugPrint('Stack trace:\n${details.stack}');
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: AppTheme.lightTheme,
      home: MainApp(),
      onGenerateRoute: (settings) {
        if (settings.name == '/edit_question') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => QuestionEditor(
              question: args['question'],
              onSave: args['onSave'],
            ),
          );
        }
        return MaterialPageRoute(
            builder: (_) => Scaffold(body: Center(child: Text('Route Error'))));
      },
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 1; // Set initial index to Journal

  final List<Widget> _screens = [
    AnalyticsPage(),
    DailyTrackerPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundCream,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: AppColors.primaryPeach,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
