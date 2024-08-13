import 'package:flutter/material.dart';
import 'screens/daily_tracker_page.dart';
import 'screens/question_editor.dart';
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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => DailyTrackerPage());
        } else if (settings.name == '/edit_question') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => QuestionEditor(
              question: args['question'],
              onSave: args['onSave'],
            ),
          );
        }
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(
            builder: (_) => Scaffold(body: Center(child: Text('Route Error'))));
      },
    );
  }
}
