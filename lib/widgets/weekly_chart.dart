// weekly_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';

class WeeklyChart extends StatelessWidget {
  final Question question;
  final List<dynamic> weeklyData;

  const WeeklyChart({
    Key? key,
    required this.question,
    required this.weeklyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Container(
          height: 40,
          child: Row(
            children: List.generate(7, (index) {
              final value =
                  weeklyData.length > index ? weeklyData[index] : null;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _getColorForValue(value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      _getDisplayValueForType(value),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final date = DateTime.now().subtract(Duration(days: 6 - index));
            return Text(
              DateFormat('E').format(date)[0],
              style: TextStyle(fontSize: 10, color: Colors.black54),
            );
          }),
        ),
      ],
    );
  }

  Color _getColorForValue(dynamic value) {
    if (value == null) return Colors.grey.withOpacity(0.3);

    switch (question.type) {
      case QuestionType.yesNo:
        return value ? Colors.green : Colors.red;
      case QuestionType.number:
      case QuestionType.intensity:
        final normalizedValue = (value - question.getMin()) /
            (question.getMax() - question.getMin());
        return Color.lerp(Colors.blue, Colors.red, normalizedValue) ??
            Colors.blue;
      case QuestionType.choice:
        final optionsList = question.options.values.toList();
        final index = optionsList.indexOf(value);
        final normalizedValue = index / (optionsList.length - 1);
        return Color.lerp(Colors.blue, Colors.red, normalizedValue) ??
            Colors.blue;
      case QuestionType.note:
        return value.isNotEmpty ? Colors.green : Colors.grey;
      default:
        return Colors.grey;
    }
  }

  double _getDisplayHeight(dynamic value) {
    if (value == null) return 1;

    switch (question.type) {
      case QuestionType.yesNo:
        return value ? 1 : 0.05;
      case QuestionType.number:
      case QuestionType.intensity:
        return question.getNormalizedValue(value);
      case QuestionType.choice:
        return 1;
      case QuestionType.note:
        return 1;
      default:
        return 1;
    }
  }

  String _getDisplayValueForType(dynamic value) {
    if (value == null) return '';

    switch (question.type) {
      case QuestionType.yesNo:
        return value ? 'Y' : 'N';
      case QuestionType.number:
        return value.toStringAsFixed(0);
      case QuestionType.intensity:
        return "";
      case QuestionType.choice:
        return question.options.entries
            .firstWhere((entry) => entry.value == value,
                orElse: () => MapEntry('', ''))
            .key[0];
      case QuestionType.note:
        return value.isNotEmpty ? '✓' : '';
      default:
        return '';
    }
  }
}
