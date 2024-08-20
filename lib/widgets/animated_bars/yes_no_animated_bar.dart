import 'package:flutter/material.dart';
import './animated_bar.dart';
import '../../theme/app_colors.dart';

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
