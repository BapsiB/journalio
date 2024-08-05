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
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final value =
                  weeklyData.length > index ? weeklyData[index] : null;
              final isLastBar = index == weeklyData.length - 1;
              return Expanded(
                child: AnimatedBar(
                  question: question,
                  value: value,
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
}

class AnimatedBar extends StatefulWidget {
  final Question question;
  final dynamic value;

  const AnimatedBar({
    Key? key,
    required this.question,
    required this.value,
  }) : super(key: key);

  @override
  _AnimatedBarState createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<AnimatedBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: 0,
      end: _getDisplayHeight(widget.value),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _heightAnimation = Tween<double>(
        begin: _heightAnimation.value,
        end: _getDisplayHeight(widget.value),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          height: 70 * _heightAnimation.value,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _getColorForValue(widget.value),
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
          child: Center(
            child: Text(
              _getDisplayValueForType(widget.value),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  double _getDisplayHeight(dynamic value) {
    if (value == null) return 0.1;

    switch (widget.question.type) {
      case QuestionType.yesNo:
        return value ? 1 : 0.2;
      case QuestionType.number:
      case QuestionType.intensity:
        return widget.question.getNormalizedValue(value);
      case QuestionType.choice:
        final optionsList = widget.question.options.values.toList();
        final index = optionsList.indexOf(value);
        return (index + 1) / optionsList.length;
      case QuestionType.note:
        return value.isNotEmpty ? 1 : 0.1;
      default:
        return 0.1;
    }
  }

  String _getDisplayValueForType(dynamic value) {
    if (value == null) return '';

    switch (widget.question.type) {
      case QuestionType.yesNo:
        return value ? 'Y' : 'N';
      case QuestionType.number:
        return value.toStringAsFixed(0);
      case QuestionType.intensity:
        return "";
      case QuestionType.choice:
        return widget.question.options.entries
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

    switch (widget.question.type) {
      case QuestionType.yesNo:
        return value ? Colors.green : Colors.red;
      case QuestionType.number:
      case QuestionType.intensity:
        final normalizedValue = (value - widget.question.getMin()) /
            (widget.question.getMax() - widget.question.getMin());
        return Color.lerp(Color.fromARGB(255, 80, 14, 161),
                Color.fromARGB(255, 244, 54, 193), normalizedValue) ??
            Colors.blue;
      case QuestionType.choice:
        final optionsList = widget.question.options.values.toList();
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
