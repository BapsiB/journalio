import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryPeach,
    scaffoldBackgroundColor: AppColors.backgroundCream,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryPeach,
      secondary: AppColors.secondaryTeal,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.secondaryTeal,
      inactiveTrackColor: AppColors.primaryPeach,
      thumbColor: AppColors.secondaryTeal,
      overlayColor: AppColors.secondaryTeal.withOpacity(0.3),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? AppColors.secondaryTeal
              : Colors.white),
      trackColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? AppColors.secondaryTeal.withOpacity(0.5)
              : Colors.grey.shade300),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      buttonColor: Colors.white,
    ),
  );
}
