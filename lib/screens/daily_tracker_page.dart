import 'package:flutter/material.dart';
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
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _answers = {};
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
    // final answers = await DataManager().getAnswersForDate(_selectedDate);
    // setState(() {
    //   _answers = answers;
    // });
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
                              answer: 0,
                              onAnswered: (value) {
                                DataManager().setAnswerValue(
                                  q.id,
                                  _selectedDate,
                                  value,
                                );
                                setState(() {
                                  _answers[q.id] = value;
                                });
                              },
                              onClicked: _editQuestion,
                              weeklyData: q.type == QuestionType.yesNo
                                  ? [
                                      true,
                                      true,
                                      false,
                                      true,
                                      false,
                                      false,
                                      false
                                    ]
                                  : [10, 45, 60, 40, 35, 50, 95],
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
