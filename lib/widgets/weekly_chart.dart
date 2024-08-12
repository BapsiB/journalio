import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import '../widgets/date_navigator.dart';

class WeeklyChart extends StatefulWidget {
  final Question question;
  final List<dynamic> weeklyData;

  const WeeklyChart({
    Key? key,
    required this.question,
    required this.weeklyData,
  }) : super(key: key);

  @override
  _WeeklyChartState createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex(DateNavigatorManager().selectedDate);
    DateNavigatorManager().addListener(_updateSelectedIndex);
  }

  @override
  void dispose() {
    DateNavigatorManager().removeListener(_updateSelectedIndex);
    super.dispose();
  }

  void _updateSelectedIndex(DateTime time) {
    final selectedDate = DateNavigatorManager().selectedDate;
    final today = DateTime.now();
    final difference = today.difference(selectedDate).inDays;
    setState(() {
      selectedIndex = difference <= 6 ? 6 - difference : 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        AnimatedArrow(selectedIndex: selectedIndex),
        SizedBox(height: 4),
        Container(
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final value = widget.weeklyData.length > index
                  ? widget.weeklyData[index]
                  : null;
              return Expanded(
                child: AnimatedBar(
                  question: widget.question,
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
            final date = today.subtract(Duration(days: 6 - index));
            return Text(
              DateFormat('E').format(date)[0],
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class AnimatedArrow extends StatefulWidget {
  final int selectedIndex;

  const AnimatedArrow({Key? key, required this.selectedIndex})
      : super(key: key);

  @override
  _AnimatedArrowState createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _updatePosition();
  }

  @override
  void didUpdateWidget(AnimatedArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _updatePosition();
    }
  }

  void _updatePosition() {
    final newPosition = widget.selectedIndex / 6;
    _animation = Tween<double>(
      begin: _animation.value,
      end: newPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth / 7;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final arrowPosition = barWidth * (_animation.value * 6 + 0.5);
            return Container(
              width: constraints.maxWidth,
              height: 20,
              child: Stack(
                children: [
                  Positioned(
                    left: arrowPosition - 15, // Center the 30px wide arrow
                    child: Icon(Icons.arrow_drop_down,
                        color: Colors.blue, size: 30),
                  ),
                ],
              ),
            );
          },
        );
      },
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
        return toBool(value) ? 1 : 0.2;
      case QuestionType.number:
      case QuestionType.intensity:
        return widget.question.getNormalizedValue(dynamicToDouble(value));
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

  double dynamicToDouble(dynamic value) {
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

  bool toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return value != null;
  }

  String _getDisplayValueForType(dynamic value) {
    if (value == null) return '';

    switch (widget.question.type) {
      case QuestionType.yesNo:
        return '';
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
        return toBool(value)
            ? Color.fromARGB(255, 244, 54, 193)
            : const Color.fromARGB(255, 150, 112, 109);
      case QuestionType.number:
      case QuestionType.intensity:
        final normalizedValue =
            (dynamicToDouble(value) - widget.question.getMin()) /
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
