import 'package:flutter/material.dart';
import '../widgets/date_navigator.dart';
import '../widgets/question_card.dart';
import '../models/question.dart';
import '../data/data_manager.dart';
import '../utils/shared_constants.dart';
import '../theme/app_colors.dart';

class DailyTrackerPage extends StatefulWidget {
  @override
  _DailyTrackerPageState createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _answers = {};
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // Assuming DataManager has a method to get questions
    final questions = await DataManager().getQuestions();
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _addNewQuestion() {
    // Add the question to DataManager
    final newQuestion = DataManager().addQuestion(
      "text",
      QuestionType.intensity,
      {},
      Colors.blue.toString(),
    );

    setState(() {
      _questions.add(newQuestion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DateNavigator(
              selectedDate: _selectedDate,
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
            ElevatedButton(
              onPressed: _addNewQuestion,
              child: Text('Add New Question'),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primaryPeach,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: _questions
                          .map((q) => QuestionCard(
                                question: q,
                                answer: _answers[q.id],
                                onAnswered: (value) =>
                                    setState(() => _answers[q.id] = value),
                                weeklyData: [30, 45, 60, 40, 35, 50, 55],
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
