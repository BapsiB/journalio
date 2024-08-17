import 'package:flutter/material.dart';

class ChoiceSelectionWidget extends StatelessWidget {
  final List<String> selectedChoices;
  final Function(String) onChoiceAdded;
  final Function(String) onChoiceRemoved;

  const ChoiceSelectionWidget({
    Key? key,
    required this.selectedChoices,
    required this.onChoiceAdded,
    required this.onChoiceRemoved,
  }) : super(key: key);

  void _addChoice(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newChoice = '';
        return AlertDialog(
          title: Text('Add a choice'),
          content: TextField(
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(hintText: 'Enter choice text'),
            onChanged: (value) {
              newChoice = value;
            },
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
                if (newChoice.isNotEmpty) {
                  onChoiceAdded(newChoice);
                  Navigator.of(context).pop();
                }
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
        Text('Choice Options', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedChoices.map((choice) {
              return Chip(
                label: Text(choice),
                deleteIcon: Icon(Icons.close),
                onDeleted: () => onChoiceRemoved(choice),
              );
            }).toList(),
            GestureDetector(
              onTap: () => _addChoice(context),
              child: Container(
                width: 50,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
