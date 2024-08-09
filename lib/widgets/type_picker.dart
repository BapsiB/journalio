import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/shared_constants.dart';

class TypePicker extends StatefulWidget {
  final QuestionType initialType;
  final Function(QuestionType) onChanged;
  final bool enabled;

  TypePicker({
    required this.initialType,
    required this.onChanged,
    required this.enabled,
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
    return AbsorbPointer(
      absorbing: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.7,
        child: SizedBox(
          height: widget.enabled ? 100 : 32,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              if (widget.enabled) {
                setState(() {
                  _selectedType = QuestionType.values[index];
                  widget.onChanged(_selectedType);
                });
              }
            },
            children: QuestionType.values.map((QuestionType type) {
              return Center(child: Text(type.toString().split('.').last));
            }).toList(),
            scrollController: FixedExtentScrollController(
              initialItem: QuestionType.values.indexOf(_selectedType),
            ),
          ),
        ),
      ),
    );
  }
}
