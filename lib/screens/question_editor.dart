import 'package:flutter/material.dart';
import 'package:journalio/data/data_manager.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import '../widgets/period_picker.dart';
import '../widgets/type_picker.dart';

class QuestionEditor extends StatefulWidget {
  final Question? question;
  final Function(Question) onSave;

  const QuestionEditor({Key? key, this.question, required this.onSave})
      : super(key: key);

  @override
  _QuestionEditorState createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  late TextEditingController _textController;
  late QuestionType _selectedType;
  late int _periodNumber;
  late String _periodUnit;
  late DateTime _periodStartingDate;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question?.text ?? '');
    _selectedType = widget.question?.type ?? QuestionType.yesNo;
    _periodNumber = widget.question?.periodDays ?? 1;
    _periodUnit = 'Days'; // You might want to derive this from periodDays
    _periodStartingDate = widget.question?.periodStartingDate ?? DateTime.now();
    _selectedColor = widget.question?.colour ?? SharedConstants().coloursSet[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.question == null ? 'Create Question' : 'Edit Question'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveQuestion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Question Text'),
            ),
            SizedBox(height: 16),
            Text('Question Type',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            TypePicker(
              initialType: _selectedType,
              enabled: widget.question == null,
              onChanged: (QuestionType newType) {
                setState(() {
                  _selectedType = newType;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Period', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            PeriodPicker(
              initialNumber: _periodNumber,
              initialUnit: _periodUnit,
              onChanged: (number, unit) {
                setState(() {
                  _periodNumber = number;
                  _periodUnit = unit;
                });
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Period Starting Date'),
              subtitle: Text(_periodStartingDate.toString().split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _periodStartingDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != _periodStartingDate) {
                  setState(() {
                    _periodStartingDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SharedConstants().coloursSet.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.substring(1, 7), radix: 16) +
                          0xFF000000),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 32),
            if (widget.question != null)
              ElevatedButton(
                onPressed: _showDeleteConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Delete Question'),
              ),
          ],
        ),
      ),
    );
  }

  void _saveQuestion() {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question text cannot be empty')),
      );
      return;
    }

    final question = Question(
      text: _textController.text,
      type: _selectedType,
      periodDays: _convertPeriodToDays(),
      periodStartingDate: _periodStartingDate,
      options: {}, // You might want to handle options based on question type
      id: widget.question?.id ?? DataManager().getNextAvailableId(),
      colour: _selectedColor,
    );

    widget.onSave(question);
    // Navigator.of(context).pop(); // This should return to the previous screen
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Question'),
          content: Text(
              'Are you sure you want to delete this question? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade400,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.question != null) {
                  _onDelete(widget.question!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onDelete(Question question) {
    try {
      DataManager().deleteQuestion(question.id);
      // Navigator.of(context).pop(); // Return to previous screen after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete question: ${e.toString()}')),
      );
    }
  }

  int _convertPeriodToDays() {
    switch (_periodUnit) {
      case 'Days':
        return _periodNumber;
      case 'Weeks':
        return _periodNumber * 7;
      case 'Months':
        return _periodNumber * 30; // Approximation
      case 'Years':
        return _periodNumber * 365; // Approximation
      default:
        return _periodNumber;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
