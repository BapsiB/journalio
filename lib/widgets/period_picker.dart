import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PeriodPicker extends StatefulWidget {
  final int initialNumber;
  final String initialUnit;
  final Function(int, String) onChanged;

  PeriodPicker({
    required this.initialNumber,
    required this.initialUnit,
    required this.onChanged,
  });

  @override
  _PeriodPickerState createState() => _PeriodPickerState();
}

class _PeriodPickerState extends State<PeriodPicker> {
  late int _selectedNumber;
  late String _selectedUnit;

  final List<String> _units = ['Days', 'Weeks', 'Months', 'Years'];

  @override
  void initState() {
    super.initState();
    _selectedNumber = widget.initialNumber;
    _selectedUnit = widget.initialUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Reduced height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedNumber = index + 1;
                  widget.onChanged(_selectedNumber, _selectedUnit);
                });
              },
              children: List<Widget>.generate(100, (int index) {
                return Center(child: Text('${index + 1}'));
              }),
              scrollController:
                  FixedExtentScrollController(initialItem: _selectedNumber - 1),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedUnit = _units[index];
                  widget.onChanged(_selectedNumber, _selectedUnit);
                });
              },
              children: _units
                  .map((String unit) => Center(child: Text(unit)))
                  .toList(),
              scrollController: FixedExtentScrollController(
                  initialItem: _units.indexOf(_selectedUnit)),
            ),
          ),
        ],
      ),
    );
  }
}
