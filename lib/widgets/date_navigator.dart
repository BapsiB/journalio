import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class DateNavigator extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateNavigator({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  _DateNavigatorState createState() => _DateNavigatorState();
}

class _DateNavigatorState extends State<DateNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 170),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(DateNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _animationController
          .forward()
          .then((_) => _animationController.reverse());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.selectedDate) {
      widget.onDateChanged(picked);
    }
  }

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
            onPressed: () => widget
                .onDateChanged(widget.selectedDate.subtract(Duration(days: 1))),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    DateFormat('EEE MMM dd yyyy').format(widget.selectedDate),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to open calendar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: AppColors.secondaryTeal),
            onPressed: () => widget
                .onDateChanged(widget.selectedDate.add(Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}
