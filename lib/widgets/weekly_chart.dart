import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import '../widgets/date_navigator.dart';
import '../data/data_manager.dart';

class WeeklyChart extends StatefulWidget {
  final Question question;
  final Map<String, dynamic> cardData;
  final ValueNotifier<Map<String, dynamic>> cardDataNotifier;

  const WeeklyChart({
    Key? key,
    required this.question,
    required this.cardData,
    required this.cardDataNotifier,
  }) : super(key: key);

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  List<dynamic> weeklyData = [];
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isSliding = false;
  Key _barKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    DateNavigatorManager().addListener(_updateSelectedIndex);
    _updateWeeklyData();
    widget.cardDataNotifier.addListener(_updateWeeklyData);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1 / 7, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    DateNavigatorManager().removeListener(_updateSelectedIndex);
    widget.cardDataNotifier.removeListener(_updateWeeklyData);
    _slideController.dispose();
    super.dispose();
  }

  void _updateSelectedIndex() {
    final selectedDate = DateNavigatorManager().selectedDate;
    final today = DateTime.now();
    final difference = today.difference(selectedDate).inDays;

    setState(() {
      selectedIndex = difference <= 6 ? 6 - difference : 6;
    });

    if (selectedIndex == 0 && !_isSliding) {
      _isSliding = true;
      _slideController.forward().then((_) {
        setState(() {
          _updateWeeklyData(slide: true);
          selectedIndex = 1;
          _barKey = UniqueKey(); // Force rebuild of AnimatedBars
        });
        _slideController.reset();
        _isSliding = false;
      });
    }
  }

  void _updateWeeklyData({bool slide = false}) {
    final startDate = slide
        ? DateNavigatorManager().selectedDate.subtract(Duration(days: 1))
        : DateNavigatorManager().selectedDate.subtract(Duration(days: 6));

    setState(() {
      weeklyData.clear();
      for (int i = 0; i < 7; i++) {
        DateTime date = startDate.add(Duration(days: i));
        String indexDate = DataManager().getDateString(date);
        weeklyData.add(widget.cardDataNotifier.value[indexDate]);
      }
      if (!slide) {
        _barKey =
            UniqueKey(); // Force rebuild of AnimatedBars for non-slide updates
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth / 7;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            AnimatedArrow(selectedIndex: selectedIndex),
            SizedBox(height: 4),
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: 70,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final value =
                        weeklyData.length > index ? weeklyData[index] : null;
                    return SizedBox(
                      width: barWidth,
                      child: AnimatedBar(
                        key: ValueKey('$_barKey-$index'),
                        question: widget.question,
                        value: value,
                        skipAnimation: _isSliding,
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final Question question;
  final dynamic value;
  final bool skipAnimation;

  const AnimatedBar({
    Key? key,
    required this.question,
    required this.value,
    this.skipAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = 70 * _getDisplayHeight(value);

    if (skipAnimation) {
      return _buildBar(height);
    } else {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: height,
        child: _buildBar(height),
      );
    }
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
                    left: arrowPosition - 5, // Center the 30px wide arrow
                    child: CustomPaint(
                      size: Size(10, 6),
                      painter: ArrowPainter(),
                    ),
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

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 177, 202, 223)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
