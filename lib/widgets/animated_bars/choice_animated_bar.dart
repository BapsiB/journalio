import 'package:flutter/material.dart';
import '../animated_bar.dart';
import '../../theme/app_colors.dart';

class ChoiceAnimatedBar extends AnimatedBar {
  const ChoiceAnimatedBar({
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
    return 1;
  }

  @override
  Color getColorForValue(dynamic value) {
    if (value == null) {
      return Colors.grey;
    }
    return AppColors.primaryPeach;
  }

  @override
  Color getBorderColorForValue(dynamic value) {
    if (value == null) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }

  @override
  String getDisplayValueForType(dynamic value) {
    if (value == null) {
      return "";
    }
    return value;
  }
}
