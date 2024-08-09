import 'package:flutter/material.dart';
import 'package:journalio/models/data.dart';
import 'package:journalio/utils/shared_constants.dart';
import '../widgets/date_navigator.dart';
import '../widgets/question_card.dart';
import '../models/question.dart';
import '../data/data_manager.dart';
import '../theme/app_colors.dart';
import '../screens/question_editor.dart';

class DailyTrackerPage extends StatefulWidget {
  @override
  _DailyTrackerPageState createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  DateTime _selectedDate = DateNavigatorManager().selectedDate;
  Map<QuestionId, Map<DateTime, dynamic>> _answers = {};
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print("DailyTrackerPage initState called");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
      _loadAnswers();
    });
  }

  Future<void> _loadQuestions() async {
    print("_loadQuestions called");
    try {
      final questions = await DataManager().getQuestions();
      print("Questions loaded: ${questions.length}");
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading questions: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAnswers() async {
    // Initialize _answers as a Map<int, Map<DateTime, dynamic>>
    _answers = {};

    for (int i = 0; i < 7; i++) {
      DateTime date = _selectedDate.subtract(Duration(days: i));
      List<QuestionValue> answersList =
          await DataManager().getValuesForDate(date);

      for (QuestionValue answer in answersList) {
        // Ensure the map for this question ID exists
        _answers.putIfAbsent(answer.id, () => <DateTime, dynamic>{});

        // Now we can safely assign the value
        _answers[answer.id]![date] = answer.v;
      }
    }

    if (mounted) {
      setState(() {
        // The _answers map is now populated
      });
    }
  }

  void _editQuestion(Question question) async {
    print("_editQuestion called");
    final editedQuestion = await Navigator.push<Question>(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionEditor(
          question: question,
          onSave: (Question updatedQuestion) {
            Navigator.pop(context, updatedQuestion);
          },
        ),
      ),
    );

    if (editedQuestion != null) {
      print("Question edited: ${editedQuestion.text}");
      if (mounted) {
        setState(() {
          final index = _questions.indexWhere((q) => q.id == editedQuestion.id);
          if (index != -1) {
            _questions[index] = editedQuestion;
          } else {
            _questions.add(editedQuestion);
          }
          DataManager().saveQuestions();
        });
      }
    }
  }

  void _addNewQuestion() async {
    await Navigator.push<Question>(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionEditor(
          question: null,
          onSave: (Question newQuestion) {
            if (newQuestion != null) {
              if (mounted) {
                setState(() {
                  final actualNewQuestion =
                      DataManager().addQuestionByCopy(newQuestion);
                  _questions.add(actualNewQuestion);
                  DataManager().saveQuestions();
                });
              }
            }
          },
        ),
      ),
    );
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _loadAnswers();
  }

  List<dynamic> _getWeeklyDate(Question question) {
    List<dynamic> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      DateTime date = _selectedDate.subtract(Duration(days: i));

      // Check if we have an answer for this question on this date
      dynamic answer = _answers[question.id]?[date];

      // Add the answer to the list, or null if no answer was found
      weeklyData.add(answer);
    }

    return weeklyData;
  }

  @override
  Widget build(BuildContext context) {
    print(
        "DailyTrackerPage build called. Questions: ${_questions.length}, isLoading: $_isLoading");
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DateNavigator(),
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
                  : _questions.isEmpty
                      ? Center(child: Text("No questions available"))
                      : ListView.builder(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final q = _questions[index];
                            print("Building QuestionCard for ${q.text}");
                            return QuestionCard(
                              question: q,
                              answer: _answers[q.id]?[_selectedDate] ?? 0,
                              onAnswered: (value) {
                                DataManager().setAnswerValue(
                                  q.id,
                                  _selectedDate,
                                  value,
                                );
                                setState(() {
                                  if (_answers[q.id] == null) {
                                    _answers[q.id] = {};
                                  }
                                  _answers[q.id]![_selectedDate] = value;
                                });
                              },
                              onClicked: _editQuestion,
                              weeklyData: _getWeeklyDate(q),
                            );
                          },
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
