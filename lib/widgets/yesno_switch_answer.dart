import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class YesNoSwitch extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const YesNoSwitch({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircle(true),
        SizedBox(width: 16),
        _buildCircle(false),
      ],
    );
  }

  Widget _buildCircle(bool isYes) {
    bool isSelected = value == isYes;
    Color circleColor = isSelected ? AppColors.primaryPeach : Colors.white;
    Color borderColor = AppColors.primaryPeach;
    Color textColor = isSelected ? Colors.white : AppColors.primaryPeach;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          onChanged(null);
        } else {
          onChanged(isYes);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(
                color: isSelected ? textColor : textColor.withAlpha(150),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                isYes ? 'YES' : 'NO',
                style: TextStyle(
                  color: isSelected ? textColor : textColor.withAlpha(150),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
