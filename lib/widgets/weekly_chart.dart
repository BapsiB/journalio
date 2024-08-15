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

  bool _isSlidingRight = false;
  bool _isSlidingLeft = false;
  double gapX = 0;
  @override
  void initState() {
    super.initState();
    arrowIndex = 6;
    firstBarDate =
        DateNavigatorManager().selectedDate.subtract(const Duration(days: 8));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _updateSelectedIndex();
    DateNavigatorManager().addListener(_updateSelectedIndex);
    _updateWeeklyData();
    widget.cardDataNotifier.addListener(_updateWeeklyData);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0 + gapX, 0),
      end: Offset(1 / 9 + gapX, 0),
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
      arrowIndex = math.max(difference - 1, 1);
      arrowIndex = math.min(arrowIndex, 5);
    });

    if (difference <= 1 && !isSliding()) {
      _isSlidingRight = true;
      _slideAnimation = Tween<Offset>(
        begin: Offset(0 + gapX, 0),
        end: Offset(1 / 9 + gapX, 0),
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      ));
      _slideController.forward().then((_) {
        setState(() {
          firstBarDate = firstBarDate.subtract(Duration(days: 1));
          _updateWeeklyData(slide: true, skipAnimation: true);
          arrowIndex = 1;
        });
        _slideController.reset();
        _isSlidingRight = false;
      });
    } else if (difference >= 7 && !isSliding()) {
      _isSlidingLeft = true;
      _slideAnimation = Tween<Offset>(
        begin: Offset(0 + gapX, 0),
        end: Offset(-1 / 9 + gapX, 0),
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      ));
      _slideController.forward().then((_) {
        setState(() {
          firstBarDate = firstBarDate.add(Duration(days: 1));
          _updateWeeklyData(slide: true, skipAnimation: true);
          arrowIndex = 5;
        });
        _slideController.reset();

        _isSlidingLeft = false;
      });
    }
  }

  bool isSliding() {
    return _isSlidingLeft || _isSlidingRight;
  }

  void _updateWeeklyData({bool slide = false, bool skipAnimation = false}) {
    final startDate = firstBarDate;

    setState(() {
      weeklyData.clear();
      for (int i = 0; i < 9; i++) {
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
            ClipRect(
              child: SizedBox(
                height: 70,
                width: constraints.maxWidth,
                child: OverflowBox(
                  maxWidth: barWidth * 9,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SizedBox(
                      width: barWidth * 9,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(9, (index) {
                          var value = weeklyData.length > index
                              ? weeklyData[index]
                              : null;
                          return SizedBox(
                            width: barWidth,
                            child: AnimatedBar(
                              question: widget.question,
                              value: value,
                              index: index,
                              isSliding: isSliding(),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
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
