import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class DateNavigatorManager {
  static final DateNavigatorManager _instance =
      DateNavigatorManager._internal();

  factory DateNavigatorManager() {
    return _instance;
  }

  DateNavigatorManager._internal();

  DateTime _selectedDate = DateTime.now();
  final List<Function()> _listeners = [];

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _notifyListeners();
  }

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}

class DateNavigator extends StatefulWidget {
  const DateNavigator({Key? key}) : super(key: key);

  @override
  _DateNavigatorState createState() => _DateNavigatorState();
}

class _DateNavigatorState extends State<DateNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final DateNavigatorManager _manager = DateNavigatorManager();

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
    _manager.addListener(_onDateChanged);
  }

  void _onDateChanged() {
    setState(() {});
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _manager.removeListener(_onDateChanged);
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _manager.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _manager.selectedDate) {
      _manager.setSelectedDate(picked);
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
            onPressed: () => _manager.setSelectedDate(
                _manager.selectedDate.subtract(Duration(days: 1))),
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
                    DateFormat('EEE MMM dd yyyy').format(_manager.selectedDate),
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
            onPressed: () => _manager
                .setSelectedDate(_manager.selectedDate.add(Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}
