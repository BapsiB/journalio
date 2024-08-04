import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class DateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateNavigator(
      {Key? key, required this.selectedDate, required this.onDateChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: AppColors.primaryPeach,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: AppColors.secondaryTeal),
            onPressed: () =>
                onDateChanged(selectedDate.subtract(Duration(days: 1))),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEE MMM dd yyyy').format(selectedDate),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              SizedBox(height: 4),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.secondaryTeal),
                onPressed: () =>
                    onDateChanged(selectedDate.add(Duration(days: 1))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
