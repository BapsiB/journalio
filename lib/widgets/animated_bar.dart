import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import '../widgets/date_navigator.dart';

class AnimatedBar extends StatelessWidget {
  final Question question;
  final dynamic value;
  final bool isSliding;
  final bool isEntering;
  final bool isExiting;
  final DateTime date;
  final int index;
  // final Function(DateTime date, dynamic value) onBarClicked;

  const AnimatedBar({
    Key? key,
    required this.question,
    required this.value,
    required this.index,
    required this.date,
    // required this.onBarClicked,
    this.isSliding = false,
    this.isEntering = false,
    this.isExiting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = 70 * _getDisplayHeight(value);

    Widget barWidget;
    if (this.isSliding && !this.isExiting) {
      barWidget = _buildBar(height);
    } else if (isSliding) {
      if (isEntering) {
        barWidget = TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: height),
          duration: Duration(milliseconds: 300),
          builder: (context, value, child) => _buildBar(value),
        );
      } else if (isExiting) {
        barWidget = TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: height, end: 0),
          duration: Duration(milliseconds: 300),
          builder: (context, value, child) => _buildBar(value),
        );
      } else {
        barWidget = _buildBar(height);
      }
    } else {
      barWidget = AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: height,
        child: _buildBar(height),
      );
    }

    return GestureDetector(
      onTap: onBarClicked,
      child: barWidget,
    );
  }

  Widget _buildBar(double height) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: _getColorForValue(value),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
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
    );
  }

  void onBarClicked() {
    DateNavigatorManager().setSelectedDate(date);
  }

  double _getDisplayHeight(dynamic value) {
    if (value == null) return 0.1;

    switch (question.type) {
      case QuestionType.yesNo:
        return _toBool(value) ? 1 : 0.2;
      case QuestionType.number:
      case QuestionType.intensity:
        return question.getNormalizedValue(_dynamicToDouble(value));
      case QuestionType.choice:
        final optionsList = question.options.values.toList();
        final index = optionsList.indexOf(value);
        return (index + 1) / optionsList.length;
      case QuestionType.note:
        return value.isNotEmpty ? 1 : 0.1;
      default:
        return 0.1;
    }
  }

  double _dynamicToDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is bool) {
      return value ? 1.0 : 0.0;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0; // Default value for unsupported types
    }
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return value != null;
  }

  String _getDisplayValueForType(dynamic value) {
    if (value == null) return '';

    switch (question.type) {
      case QuestionType.yesNo:
        return '';
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

  Color _getColorForValue(dynamic value) {
    if (value == null) return Colors.grey.withOpacity(0.3);

    switch (question.type) {
      case QuestionType.yesNo:
        return _toBool(value)
            ? Color.fromARGB(255, 244, 54, 193)
            : const Color.fromARGB(255, 150, 112, 109);
      case QuestionType.number:
      case QuestionType.intensity:
        final normalizedValue = (_dynamicToDouble(value) - question.getMin()) /
            (question.getMax() - question.getMin());
        return Color.lerp(Color.fromARGB(255, 80, 14, 161),
                Color.fromARGB(255, 244, 54, 193), normalizedValue) ??
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
}
