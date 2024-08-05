import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import 'weekly_chart.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final dynamic answer;
  final Function(dynamic) onAnswered;
  final List<dynamic> weeklyData;

  const QuestionCard({
    Key? key,
    required this.question,
    this.answer,
    required this.onAnswered,
    required this.weeklyData,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late List<dynamic> _currentWeeklyData;

  @override
  void initState() {
    super.initState();
    _currentWeeklyData = List.from(widget.weeklyData);
  }

  void _updateAnswer(dynamic newAnswer) {
    widget.onAnswered(newAnswer);
    setState(() {
      if (_currentWeeklyData.length == 7) {
        _currentWeeklyData[6] =
            newAnswer; // Update only the last (most recent) value
      } else if (_currentWeeklyData.length < 7) {
        _currentWeeklyData.add(
            newAnswer); // Add the new answer if we have less than 7 days of data
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }

  Widget _buildAnswerWidget() {
    switch (widget.question.type) {
      case QuestionType.yesNo:
        return Row(
          children: [
            ChoiceChip(
              label: Text('Yes'),
              selected: widget.answer == true,
              onSelected: (selected) => _updateAnswer(selected ? true : null),
            ),
            SizedBox(width: 8),
            ChoiceChip(
              label: Text('No'),
              selected: widget.answer == false,
              onSelected: (selected) => _updateAnswer(selected ? false : null),
            ),
          ],
        );
      case QuestionType.number:
        return Slider(
          value: widget.answer?.toDouble() ?? widget.question.getMin(),
          min: widget.question.getMin(),
          max: widget.question.getMax(),
          divisions:
              (widget.question.getMax() - widget.question.getMin()).round(),
          label: widget.answer?.toStringAsFixed(1) ??
              widget.question.getMin().toStringAsFixed(1),
          onChanged: _updateAnswer,
        );
      case QuestionType.intensity:
        return Slider(
          value: widget.answer?.toDouble() ?? 0,
          min: 0,
          max: 100,
          divisions: 100,
          label: widget.answer?.toStringAsFixed(0) ?? '0',
          onChanged: _updateAnswer,
        );
      case QuestionType.choice:
        return Wrap(
          spacing: 5.0,
          children: widget.question.options.entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.key),
              selected: widget.answer == entry.value,
              onSelected: (bool selected) {
                _updateAnswer(selected ? entry.value : null);
              },
            );
          }).toList(),
        );
      case QuestionType.note:
        return TextField(
          controller: TextEditingController(text: widget.answer ?? ''),
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
