import 'package:flutter/material.dart';
import 'package:journalio/data/data_manager.dart';
import 'package:journalio/widgets/slider_answer.dart';
import '../models/question.dart';
import '../utils/shared_constants.dart';
import 'weekly_chart.dart';
import '../widgets/date_navigator.dart';
import '../theme/app_colors.dart';
import '../widgets/yesno_switch_answer.dart';
import '../widgets/slider_answer.dart';

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

  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.question.text,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
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
    );
  }

  Widget _buildAnswerWidget() {
    switch (widget.question.type) {
      case QuestionType.yesNo:
        return YesNoSwitch(
          value: _currentAnswer,
          onChanged: (newValue) {
            _updateAnswer(newValue);
            _changeEnd(newValue);
          },
        );
      case QuestionType.number:
      case QuestionType.intensity:
        return SliderAnswer(
            value: _currentAnswer,
            question: widget.question,
            onChanged: (newValue) {
              _updateAnswer(newValue);
              _changeEnd(newValue);
            });
      case QuestionType.choice:
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5.0,
            children: (widget.question.options['choices'] as List<dynamic>)
                .map((entry) {
              bool isSelected = _currentAnswer == entry;
              return ChoiceChip(
                label: Text(entry),
                selected: isSelected,
                selectedColor: AppColors.primaryPeach,
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                checkmarkColor: Colors.white,
                side: isSelected ? null : BorderSide.none,
                onSelected: (bool selected) {
                  _updateAnswer(selected ? entry : null);
                  _changeEnd(selected ? entry : null);
                },
              );
            }).toList(),
          ),
        );
      case QuestionType.note:
        return Center(
          child: Container(
            width: 300,
            child: TextField(
              controller: TextEditingController(text: _currentAnswer ?? ''),
              onChanged: _updateAnswer,
              maxLines: null,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter your note here...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPeach),
                ),
              ),
            ),
          ),
        );
      case QuestionType.colour:
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
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
                      color: isSelected
                          ? AppColors.primaryPeach
                          : Colors.transparent,
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
          ),
        );
      default:
        return Text('Unsupported question type');
    }
  }

  Widget _buildChoiceChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryPeach,
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
      checkmarkColor: Colors.white,
      side: isSelected ? null : BorderSide.none,
      onSelected: (selected) {
        _updateAnswer(selected ? (label == 'Yes') : null);
        _changeEnd(selected ? (label == 'Yes') : null);
      },
    );
  }
}
