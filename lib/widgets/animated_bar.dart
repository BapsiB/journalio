import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import '../widgets/date_navigator.dart';
import './animated_bars/color_animated_bar.dart';
import './animated_bars/choice_animated_bar.dart';
import '../theme/app_colors.dart';

abstract class AnimatedBar extends StatelessWidget {
  final Question question;
  final dynamic value;
  final bool isSliding;
  final bool isEntering;
  final bool isExiting;
  final DateTime date;
  final int index;

  const AnimatedBar({
    Key? key,
    required this.question,
    required this.value,
    required this.index,
    required this.date,
    this.isSliding = false,
    this.isEntering = false,
    this.isExiting = false,
  }) : super(key: key);

  factory AnimatedBar.forQuestionType({
    required Question question,
    required dynamic value,
    required int index,
    required DateTime date,
    bool isSliding = false,
    bool isEntering = false,
    bool isExiting = false,
  }) {
    switch (question.type) {
      case QuestionType.yesNo:
        return YesNoAnimatedBar(
            question: question,
            value: value,
            index: index,
            date: date,
            isSliding: isSliding,
            isEntering: isEntering,
            isExiting: isExiting);
      case QuestionType.number:
        return NumberAnimatedBar(
            question: question,
            value: value,
            index: index,
            date: date,
            isSliding: isSliding,
            isEntering: isEntering,
            isExiting: isExiting);
      case QuestionType.intensity:
        return IntensityAnimatedBar(
            question: question,
            value: value,
            index: index,
            date: date,
            isSliding: isSliding,
            isEntering: isEntering,
            isExiting: isExiting);
      case QuestionType.choice:
        return ChoiceAnimatedBar(
            question: question,
            value: value,
            index: index,
            date: date,
            isSliding: isSliding,
            isEntering: isEntering,
            isExiting: isExiting);
      case QuestionType.note:
        return NoteAnimatedBar(
            question: question,
            value: value,
            index: index,
            date: date,
            isSliding: isSliding,
            isEntering: isEntering,
            isExiting: isExiting);
      case QuestionType.colour:
        return ColourAnimatedBar(
            question: question,
            value: value,
            index: index,
            date: date,
            isSliding: isSliding,
            isEntering: isEntering,
            isExiting: isExiting);
      default:
        throw ArgumentError('Unsupported question type: ${question.type}');
    }
  }

  double getDisplayHeight(dynamic value);
  Color getColorForValue(dynamic value);
  Color getBorderColorForValue(dynamic value) => Colors.transparent;
  String getDisplayValueForType(dynamic value);

  @override
  Widget build(BuildContext context) {
    final height = 70 * getDisplayHeight(value);

    Widget barWidget;
    if (isSliding) {
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
        color: getColorForValue(value),
        border: Border.all(
          color: getBorderColorForValue(value),
          width: 2,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Center(
        child: Text(
          getDisplayValueForType(value),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void onBarClicked() {
    DateNavigatorManager().setSelectedDate(date);
  }
}

class YesNoAnimatedBar extends AnimatedBar {
  const YesNoAnimatedBar({
    required super.question,
    required super.value,
    required super.index,
    required super.date,
    super.isSliding,
    super.isEntering,
    super.isExiting,
  });

  @override
  double getDisplayHeight(dynamic value) {
    if (value == null) {
      return 0.1;
    }
    return _toBool(value) ? 1 : 0.2;
  }

  @override
  Color getColorForValue(dynamic value) {
    if (value == null) {
      return Colors.grey;
    }
    return _toBool(value)
        ? AppColors.primaryPeach
        : AppColors.primaryPeach.withAlpha(50);
  }

  @override
  String getDisplayValueForType(dynamic value) {
    return '';
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return value != null;
  }
}

class NumberAnimatedBar extends AnimatedBar {
  const NumberAnimatedBar({
    required super.question,
    required super.value,
    required super.index,
    required super.date,
    super.isSliding,
    super.isEntering,
    super.isExiting,
  });

  @override
  double getDisplayHeight(dynamic value) {
    if (value == null) {
      return 0.1;
    }
    return question.getNormalizedValue(_dynamicToDouble(value));
  }

  @override
  Color getColorForValue(dynamic value) {
    if (value == null) {
      return Colors.grey;
    }
    final normalizedValue = (_dynamicToDouble(value) - question.getMin()) /
        (question.getMax() - question.getMin());
    return Color.lerp(AppColors.primaryPeach.withAlpha(50),
            AppColors.primaryPeach, normalizedValue) ??
        Colors.blue;
  }

  @override
  String getDisplayValueForType(dynamic value) {
    if (value == null) {
      return "";
    }
    return value.toStringAsFixed(0);
  }

  double _dynamicToDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is bool) {
      return value ? 1.0 : 0.0;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }
}

class IntensityAnimatedBar extends NumberAnimatedBar {
  const IntensityAnimatedBar({
    required super.question,
    required super.value,
    required super.index,
    required super.date,
    super.isSliding,
    super.isEntering,
    super.isExiting,
  });

  @override
  String getDisplayValueForType(dynamic value) {
    return "";
  }
}

class NoteAnimatedBar extends AnimatedBar {
  const NoteAnimatedBar({
    required super.question,
    required super.value,
    required super.index,
    required super.date,
    super.isSliding,
    super.isEntering,
    super.isExiting,
  });

  @override
  double getDisplayHeight(dynamic value) {
    if (value == null) {
      return 0.1;
    }
    return value.isNotEmpty ? 1 : 0.1;
  }

  @override
  Color getColorForValue(dynamic value) {
    if (value == null) {
      return Colors.grey;
    }
    return value.isNotEmpty ? Colors.green : Colors.grey;
  }

  @override
  String getDisplayValueForType(dynamic value) {
    if (value == null) {
      return "";
    }
    return value.isNotEmpty ? '✓' : '';
  }
}
