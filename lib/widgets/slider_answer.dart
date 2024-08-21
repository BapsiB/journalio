import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/shared_constants.dart';
import '../models/question.dart';

class SliderAnswer extends StatelessWidget {
  static const double _sliderWidth = 200.0;
  static const double _trackHeight = 10.0;
  static const double _thumbRadius = 15.0;
  static const double _overlayRadius = 20.0;

  final double? value;
  final Question question;
  final ValueChanged<double> onChanged;

  const SliderAnswer({
    Key? key,
    required this.value,
    required this.question,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sliderWidth,
      child: SliderTheme(
        data: _getSliderThemeData(context),
        child: Slider(
          value: value ?? question.getMin(),
          min: question.type == QuestionType.number ? question.getMin() : 0,
          max: question.type == QuestionType.number ? question.getMax() : 100,
          divisions: question.type == QuestionType.number
              ? (question.getMax() - question.getMin()).round()
              : 100,
          label: value == null ? value?.toStringAsFixed(0) : "set value",
          onChanged: onChanged,
        ),
      ),
    );
  }

  SliderThemeData _getSliderThemeData(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      trackHeight: _trackHeight,
      trackShape: const GradientRectSliderTrackShape(),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: _thumbRadius),
      overlayShape: RoundSliderOverlayShape(overlayRadius: _overlayRadius),
    );
  }
}

class GradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const GradientRectSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeGradient = LinearGradient(
      colors: [AppColors.primaryPeach.withOpacity(0.3), AppColors.primaryPeach],
    );

    // Active track
    final activeTrackRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
      topLeft: Radius.circular(trackRect.height / 2),
      bottomLeft: Radius.circular(trackRect.height / 2),
    );

    context.canvas.drawRRect(
      activeTrackRect,
      Paint()..shader = activeGradient.createShader(activeTrackRect.outerRect),
    );

    // Inactive track
    final inactiveTrackRect = RRect.fromLTRBAndCorners(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      topRight: Radius.circular(trackRect.height / 2),
      bottomRight: Radius.circular(trackRect.height / 2),
    );

    context.canvas.drawRRect(
      inactiveTrackRect,
      Paint()..color = sliderTheme.inactiveTrackColor!,
    );
  }
}
