import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';

class TypePicker extends StatefulWidget {
  final QuestionType initialType;
  final Function(QuestionType) onChanged;

  TypePicker({
    required this.initialType,
    required this.onChanged,
  });

  @override
  _TypePickerState createState() => _TypePickerState();
}

class _TypePickerState extends State<TypePicker> {
  late QuestionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: CupertinoPicker(
        itemExtent: 32.0,
        onSelectedItemChanged: (int index) {
          setState(() {
            _selectedType = QuestionType.values[index];
            widget.onChanged(_selectedType);
          });
        },
        children: QuestionType.values.map((QuestionType type) {
          return Center(child: Text(type.toString().split('.').last));
        }).toList(),
        scrollController: FixedExtentScrollController(
          initialItem: QuestionType.values.indexOf(_selectedType),
        ),
      ),
    );
  }
}
