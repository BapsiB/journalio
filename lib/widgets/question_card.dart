import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final dynamic answer;
  final Function(dynamic) onAnswered;

  const QuestionCard({
    Key? key,
    required this.question,
    this.answer,
    required this.onAnswered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            _buildAnswerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerWidget() {
    switch (question.type) {
      case QuestionType.yesNo:
        return Row(
          children: [
            ChoiceChip(
              label: Text('Yes'),
              selected: answer == true,
              onSelected: (selected) => onAnswered(selected ? true : null),
            ),
            SizedBox(width: 8),
            ChoiceChip(
              label: Text('No'),
              selected: answer == false,
              onSelected: (selected) => onAnswered(selected ? false : null),
            ),
          ],
        );
      case QuestionType.number:
        return Slider(
          value: answer?.toDouble() ?? question.getMin(),
          min: question.getMin(),
          max: question.getMax(),
          divisions: (question.getMax() - question.getMin()).round(),
          label: answer?.toStringAsFixed(1) ??
              question.getMin().toStringAsFixed(1),
          onChanged: onAnswered,
        );
      case QuestionType.intensity:
        return Slider(
          value: answer?.toDouble() ?? 0,
          min: 0,
          max: 100,
          divisions: 100,
          label: answer?.toStringAsFixed(0) ?? '0',
          onChanged: onAnswered,
        );
      case QuestionType.choice:
        return Wrap(
          spacing: 5.0,
          children: List<Widget>.generate(
            3,
            (int index) {
              return ChoiceChip(
                label: Text('Itembb $index'),
                selected: answer == index,
                onSelected: (bool selected) {
                  onAnswered(selected ? index : null);
                },
              );
            },
          ).toList(),
        );
      case QuestionType.note:
        return TextField(
          controller: TextEditingController(text: answer ?? ''),
          onChanged: onAnswered,
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
