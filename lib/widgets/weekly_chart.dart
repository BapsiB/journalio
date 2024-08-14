import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/date_navigator.dart';
import '../data/data_manager.dart';
import 'animated_arrow.dart';
import 'dart:math' as math;

import 'animated_bar.dart';

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
  late DateTime firstBarDate;
  late int arrowIndex;
  List<dynamic> weeklyData = [];
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rightBarAnimation;
  bool _isSliding = false;

  @override
  void initState() {
    super.initState();

    arrowIndex = 6;
    firstBarDate =
        DateNavigatorManager().selectedDate.subtract(const Duration(days: 6));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _updateSelectedIndex();
    DateNavigatorManager().addListener(_updateSelectedIndex);
    _updateWeeklyData();
    widget.cardDataNotifier.addListener(_updateWeeklyData);

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1 / 7, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _rightBarAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
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
    final difference = selectedDate.difference(firstBarDate).inDays;

    setState(() {
      arrowIndex = math.max(difference, 1);
    });

    if (difference <= 0 && !_isSliding) {
      _isSliding = true;
      _slideController.forward().then((_) {
        setState(() {
          firstBarDate = firstBarDate.subtract(Duration(days: 1));
          _updateWeeklyData(slide: true);
          arrowIndex = 1;
        });
        _slideController.reset();
        _isSliding = false;
      });
    }
  }

  void _updateWeeklyData({bool slide = false}) {
    final startDate = firstBarDate;

    setState(() {
      weeklyData.clear();
      for (int i = 0; i < 7; i++) {
        DateTime date = startDate.add(Duration(days: i));
        String indexDate = DataManager().getDateString(date);
        weeklyData.add(widget.cardDataNotifier.value[indexDate]);
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
            AnimatedArrow(selectedIndex: arrowIndex),
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
                      child: index == 6
                          ? AnimatedBuilder(
                              animation: _rightBarAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scaleY: _isSliding
                                      ? _rightBarAnimation.value
                                      : 1.0,
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedBar(
                                    question: widget.question,
                                    value: value,
                                    skipAnimation: true,
                                  ),
                                );
                              },
                            )
                          : AnimatedBar(
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
