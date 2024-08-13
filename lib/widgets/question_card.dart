import 'package:flutter/material.dart';
import 'package:journalio/data/data_manager.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import 'weekly_chart.dart';
import '../widgets/date_navigator.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(dynamic) onAnswered;
  final Function(Question) onClicked;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.onAnswered,
    required this.onClicked,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late Map<String, dynamic> _cardData;
  late dynamic _currentAnswer;
  List<dynamic> _currentWeeklyData = [];
  DateTime _dateLast = DateTime.now();
  late Question _question;

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _cardData = DataManager().getValuesForQuestion(_question.id);
    _currentAnswer = _cardData[DateNavigatorManager().selectedDate];
    _currentWeeklyData.clear();
    for (int i = 0; i < 7; i++) {
      DateTime date =
          DateNavigatorManager().selectedDate.add(Duration(days: -6 + i));
      String indexDate = DataManager().getDateString(date);
      _currentWeeklyData.add(_cardData[indexDate]);
    }
  }

  void _updateAnswer(dynamic newAnswer) {
    setState(() {
      _currentAnswer = newAnswer;
      if (_currentWeeklyData.length == 7) {
        int daysDifference =
            (_dateLast.difference(DateNavigatorManager().selectedDate).inDays)
                .abs();
        if (daysDifference < 6) {
          _currentWeeklyData[6 - daysDifference] = newAnswer;
        }
      }
    });
  }

  void _changeEnd(dynamic newAnswer) {
    widget.onAnswered(newAnswer);
    setState(() {
      _currentAnswer = newAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClicked(widget.question),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.question.text,
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              _buildAnswerWidget(),
              SizedBox(height: 12),
              WeeklyChart(
                question: widget.question,
                weeklyData: _currentWeeklyData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerWidget() {
    switch (widget.question.type) {
      case QuestionType.yesNo:
        return Row(
          children: [
            ChoiceChip(
              label: Text('Yes'),
              selected: _currentAnswer == true,
              onSelected: (selected) {
                _updateAnswer(selected ? true : null);
                _changeEnd(selected ? true : null);
              },
            ),
            SizedBox(width: 8),
            ChoiceChip(
              label: Text('No'),
              selected: _currentAnswer == false,
              onSelected: (selected) {
                _updateAnswer(selected ? false : null);
                _changeEnd(selected ? false : null);
              },
            ),
          ],
        );
      case QuestionType.number:
        return Slider(
          value: _currentAnswer?.toDouble() ?? widget.question.getMin(),
          min: widget.question.getMin(),
          max: widget.question.getMax(),
          divisions:
              (widget.question.getMax() - widget.question.getMin()).round(),
          label: _currentAnswer?.toStringAsFixed(1) ??
              widget.question.getMin().toStringAsFixed(1),
          onChanged: _updateAnswer,
          onChangeEnd: _changeEnd,
        );
      case QuestionType.intensity:
        return Slider(
          value: _currentAnswer?.toDouble() ?? 0,
          min: 0,
          max: 100,
          divisions: 100,
          label: _currentAnswer?.toStringAsFixed(0) ?? '0',
          onChanged: _updateAnswer,
          onChangeEnd: _changeEnd,
        );
      case QuestionType.choice:
        return Wrap(
          spacing: 5.0,
          children: widget.question.options.entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.key),
              selected: _currentAnswer == entry.value,
              onSelected: (bool selected) {
                _updateAnswer(selected ? entry.value : null);
                _changeEnd(selected ? entry.value : null);
              },
            );
          }).toList(),
        );
      case QuestionType.note:
        return TextField(
          controller: TextEditingController(text: _currentAnswer ?? ''),
          onChanged: _updateAnswer,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Enter your note here...',
          ),
        );
      default:
        return Text('Unsupported question type');
    }
  }
}
