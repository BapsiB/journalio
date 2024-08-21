import 'package:flutter/material.dart';
import 'package:journalio/models/data.dart';
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
    DataManager().addQuestionsListener('dailyTracker', _loadQuestions);
    _loadQuestions();
  }

  @override
  void dispose() {
    DataManager().removeQuestionsListener('dailyTracker');
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    debugPrint("_loadQuestions called");
    try {
      final questions = await DataManager().getQuestions();
      debugPrint("Questions loaded: ${questions.length}");
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
        _loadAnswers();
      }
    } catch (e) {
      debugPrint("Error loading questions: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAnswers() async {
    _answers = {};

    for (int i = 0; i < 7; i++) {
      DateTime date = _selectedDate.subtract(Duration(days: i));
      List<QuestionValue> answersList =
          await DataManager().getValuesForDate(date);

      for (QuestionValue answer in answersList) {
        _answers.putIfAbsent(answer.id, () => <DateTime, dynamic>{});
        _answers[answer.id]![date] = answer.v;
      }
    }

    if (mounted) {
      setState(() {});
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
            _questions[index].update(editedQuestion);
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
            if (mounted) {
              setState(() {
                final actualNewQuestion =
                    DataManager().addQuestionByCopy(newQuestion);
                _questions.add(actualNewQuestion);
                DataManager().saveQuestions();
                print(
                    "New question added and saved: ${actualNewQuestion.text}");
                Navigator.pop(context, newQuestion);
              });
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

  @override
  Widget build(BuildContext context) {
    print(
        "DailyTrackerPage build called. Questions: ${_questions.length}, isLoading: $_isLoading");
    return Scaffold(
      body: Container(
        color: AppColors.backgroundCream,
        child: SafeArea(
          child: Column(
            children: [
              DateNavigator(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.edit_outlined, 'Edit'),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _questions.isEmpty
                        ? Center(child: Text("No questions available"))
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: _questions.length,
                            itemBuilder: (context, index) {
                              final q = _questions[index];
                              return QuestionCard(
                                question: q,
                                onAnswered: (value) {
                                  DataManager().setAnswerValue(
                                    q.id,
                                    DateNavigatorManager().selectedDate,
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
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return TextButton.icon(
      icon: Icon(icon, color: AppColors.primaryPeach),
      label: Text(label, style: TextStyle(color: AppColors.primaryPeach)),
      onPressed: () {
        // Implement action
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
