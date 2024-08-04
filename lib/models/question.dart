import '../utils/shared_constants.dart';
import '../data/data_manager.dart';

class Question {
  String text;
  QuestionType type;
  int displayOrder;
  Map<String, dynamic> options;
  String colour;
  String id;

  Question({
    required this.text,
    required this.type,
    required this.options,
    required this.id,
    this.displayOrder = 0,
    String? colour,
  }) {
    if (colour != null) {
      if (colour.length <= 2) {
        this.colour = SharedConstants().coloursSet[int.parse(colour)];
      } else {
        this.colour = colour;
      }
    } else {
      this.colour = SharedConstants().coloursSet[0];
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'],
      type: QuestionType.values[json['type']],
      options: json['options'],
      id: json['id'],
      displayOrder: json['displayOrder'] ?? 0,
      colour: json['colour'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.index,
      'options': options,
      'colour': colour,
      'id': id,
      'displayOrder': displayOrder,
    };
  }

  String getText() => text;

  String getColour() => colour;

  bool isNote() => type == QuestionType.note;

  double getMin() {
    switch (type) {
      case QuestionType.yesNo:
      case QuestionType.intensity:
      case QuestionType.colour:
        return 0;
      default:
        return options['min'] ?? 0;
    }
  }

  double getMax() {
    switch (type) {
      case QuestionType.yesNo:
        return 1;
      case QuestionType.intensity:
        return 100;
      case QuestionType.colour:
        return 1;
      default:
        return options['max'] ?? 0;
    }
  }

  void setOptions(Map<String, dynamic> newOptions) {
    newOptions.forEach((key, value) {
      print('$key: $value');
      options[key] = value;
    });
  }

  void setDisplayOrder(int order) {
    displayOrder = order;
  }

  List<Map<String, dynamic>> getArrayValues({
    bool normalizeValue = true,
    int? daysCount,
    DateTime? upToDay,
  }) {
    final allData = DataManager().getAllData();
    List<Map<String, dynamic>> data = [];

    allData.forEach((key, dataDay) {
      final dateStr = dataDay['date'];
      if (daysCount != null) {
        final dateToCompareTo = upToDay ?? DateTime.now();
        final dateOfThis = DataManager().getDateFromString(dataDay['date']);
        final timeDiff = dateToCompareTo.difference(dateOfThis).inDays;
        if (timeDiff > daysCount || timeDiff < 0) {
          return;
        }
      }

      for (var dayVal in dataDay['values']) {
        if (id == dayVal['id']) {
          final valNorm =
              normalizeValue ? normalizeValue(dayVal['v']) : dayVal['v'];
          if (dayVal['v'] != null) {
            data.add({
              'date': DataManager().getDateFromString(dateStr),
              'value': valNorm,
            });
          }
        }
      }
    });

    return data;
  }

  double normalizeValue(dynamic aValue) {
    switch (type) {
      case QuestionType.yesNo:
        return aValue.toDouble();
      case QuestionType.number:
        return (aValue - options['min']) / (options['max'] - options['min']);
      case QuestionType.intensity:
        return aValue / 100;
      case QuestionType.colour:
        return 0.5;
      default:
        return 0;
    }
  }
}
