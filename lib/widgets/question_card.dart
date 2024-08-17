import 'package:flutter/material.dart';
import 'package:journalio/data/data_manager.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import 'weekly_chart.dart';
import '../widgets/date_navigator.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(dynamic) onAnswered;
  final Function(Question) onClicked;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.onAnswered,
    required this.onClicked,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late ValueNotifier<Map<String, dynamic>> _cardDataNotifier;
  late dynamic _currentAnswer;
  late Question _question;

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _cardDataNotifier =
        ValueNotifier(DataManager().getValuesForQuestion(_question.id));
    _currentAnswer =
        _cardDataNotifier.value[DateNavigatorManager().selectedDate];
    DateNavigatorManager().addListener(_dateChanged);
  }

  @override
  void dispose() {
    _cardDataNotifier.dispose();
    DateNavigatorManager().removeListener(_dateChanged);
    super.dispose();
  }

  void _updateAnswer(dynamic newAnswer) {
    setState(() {
      _currentAnswer = newAnswer;
      String currentDate =
          DataManager().getDateString(DateNavigatorManager().selectedDate);
      _cardDataNotifier.value = {
        ..._cardDataNotifier.value,
        currentDate: newAnswer,
      };
    });
  }

  void _dateChanged() {
    setState(() {
      _currentAnswer = DataManager().getAnswerForQuestion(
          widget.question.id, DateNavigatorManager().selectedDate);

      // Update the card data notifier
      String currentDate =
          DataManager().getDateString(DateNavigatorManager().selectedDate);
      _cardDataNotifier.value = {
        ..._cardDataNotifier.value,
        currentDate: _currentAnswer,
      };
    });
  }

  void _changeEnd(dynamic newAnswer) {
    widget.onAnswered(newAnswer);
    _updateAnswer(newAnswer);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClicked(widget.question),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.question.text,
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              _buildAnswerWidget(),
              SizedBox(height: 12),
              WeeklyChart(
                question: widget.question,
                cardData: _cardDataNotifier.value,
                cardDataNotifier: _cardDataNotifier,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerWidget() {
    switch (widget.question.type) {
      case QuestionType.yesNo:
        return Row(
          children: [
            ChoiceChip(
              label: Text('Yes'),
              selected: _currentAnswer == true,
              onSelected: (selected) {
                _updateAnswer(selected ? true : null);
                _changeEnd(selected ? true : null);
              },
            ),
            SizedBox(width: 8),
            ChoiceChip(
              label: Text('No'),
              selected: _currentAnswer == false,
              onSelected: (selected) {
                _updateAnswer(selected ? false : null);
                _changeEnd(selected ? false : null);
              },
            ),
          ],
        );
      case QuestionType.number:
        return Slider(
          value: _currentAnswer?.toDouble() ?? widget.question.getMin(),
          min: widget.question.getMin(),
          max: widget.question.getMax(),
          divisions:
              (widget.question.getMax() - widget.question.getMin()).round(),
          label: _currentAnswer?.toStringAsFixed(1) ??
              widget.question.getMin().toStringAsFixed(1),
          onChanged: _updateAnswer,
          onChangeEnd: _changeEnd,
        );
      case QuestionType.intensity:
        return Slider(
          value: _currentAnswer?.toDouble() ?? 0,
          min: 0,
          max: 100,
          divisions: 100,
          label: _currentAnswer?.toStringAsFixed(0) ?? '0',
          onChanged: _updateAnswer,
          onChangeEnd: _changeEnd,
        );
      case QuestionType.choice:
        // return Text('Unsupported question type');
        return Wrap(
          spacing: 5.0,
          children: (widget.question.options['choices'] as List<dynamic>)
              .map((entry) {
            return ChoiceChip(
              label: Text(entry),
              selected: _currentAnswer == entry,
              onSelected: (bool selected) {
                _updateAnswer(selected ? entry : null);
                _changeEnd(selected ? entry : null);
              },
            );
          }).toList(),
        );
      case QuestionType.note:
        return TextField(
          controller: TextEditingController(text: _currentAnswer ?? ''),
          onChanged: _updateAnswer,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Enter your note here...',
          ),
        );
      case QuestionType.colour:
        // return Text('Unsupported question type');
        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: (widget.question.options['colors'] as List<dynamic>)
              .map((colorInt) {
            Color color = (colorInt is int) ? Color(colorInt) : Colors.black;
            bool isSelected = _currentAnswer == colorInt;
            return GestureDetector(
              onTap: () {
                _updateAnswer(colorInt);
                _changeEnd(colorInt);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check,
                        color: color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white)
                    : null,
              ),
            );
          }).toList(),
        );
      default:
        return Text('Unsupported question type');
    }
  }
}
