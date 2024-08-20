import 'package:flutter/material.dart';
import '../animated_bar.dart';

class ColourAnimatedBar extends AnimatedBar {
  const ColourAnimatedBar({
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
    return value > 0 ? 1 : 0.1;
  }

  @override
  Color getColorForValue(dynamic value) {
    if (value == null) {
      return Colors.grey.shade400;
    }
    return value > 0 ? Color(value) : Colors.grey;
  }

  @override
  String getDisplayValueForType(dynamic value) {
    return '';
  }
}
