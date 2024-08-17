import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorSelectionWidget extends StatelessWidget {
  final List<int> selectedColors;
  final Function(Color) onColorAdded;
  final Function(Color) onColorRemoved;

  const ColorSelectionWidget({
    Key? key,
    required this.selectedColors,
    required this.onColorAdded,
    required this.onColorRemoved,
  }) : super(key: key);

  void _addColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickedColor = Colors.blue;
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                onColorAdded(pickedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color Options', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ...selectedColors.map((colorInt) {
              return Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (colorInt is int) ? Color(colorInt) : Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => onColorRemoved(Color(colorInt)),
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _addColor(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
