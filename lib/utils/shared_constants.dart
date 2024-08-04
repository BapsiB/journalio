import 'package:flutter/material.dart';

enum QuestionType { yesNo, number, intensity, note, colour, choice, count }

class SharedConstants {
  static final SharedConstants _instance = SharedConstants._internal();

  factory SharedConstants() {
    return _instance;
  }

  SharedConstants._internal();

  String getDateString(DateTime date) {
    final dateStr = date.toLocal().toString().split(' ')[0];
    final today = DateTime.now();
    if (dateStr == today.toLocal().toString().split(' ')[0]) {
      return "$dateStr (today)";
    }
    return dateStr;
  }

  final String apiRoot = "http://lebaptiste.com/my-data-2";
  // final String apiRoot = "http://10.0.2.2:3000";

  String getQuestionTypeText(int questionType) {
    switch (questionType) {
      case QuestionType.yesNo:
        return "yes/no";
      case QuestionType.number:
        return "quantity";
      case QuestionType.intensity:
        return "intensity";
      case QuestionType.colour:
        return "colour";
      case QuestionType.note:
        return "notes";
      default:
        return "";
    }
  }

  String getAnswerText(dynamic answerValue, dynamic question) {
    switch (question.type) {
      case QuestionType.yesNo:
        return answerValue == 1 ? "yes" : "no";
      case QuestionType.number:
        return answerValue.toString();
      case QuestionType.intensity:
        if (answerValue < 15) {
          if (question.options['min'] != "") {
            return question.options['min'];
          }
          return "very low";
        } else if (answerValue < 30) {
          return "low";
        } else if (answerValue < 70) {
          return "mild";
        } else if (answerValue < 85) {
          return "high";
        } else {
          if (question.options['max'] != "") {
            return question.options['max'];
          }
          return "very high";
        }
      case QuestionType.note:
        return "...";
      default:
        return "";
    }
  }

  final ThemeData appTheme = ThemeData(
      primaryColor: Color(0xFFe3e0b5), // Soft Peach
      accentColor: Color(0xFFA0E0E0), // Soft Teal
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        buttonColor: Colors.white,
      ));
}
