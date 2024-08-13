import '../data/data_manager.dart';

/*
* type to define the question id.
*/
class QuestionId {
  final String value;

  const QuestionId(this.value);

  String toJson() => value;

  factory QuestionId.fromJson(String json) => QuestionId(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class QuestionValue {
  QuestionId id;
  dynamic v;

  QuestionValue({required this.id, required this.v});

  factory QuestionValue.fromJson(Map<String, dynamic> json) {
    return QuestionValue(
      id: QuestionId(json['id']),
      v: json['v'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'v': v,
      };
}

class DayData {
  String date;
  List<QuestionValue> values;

  DayData({required this.date, required this.values});

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      date: json['date'],
      values: (json['values'] as List)
          .map((v) => QuestionValue.fromJson(v))
          .toList(),
    );
  }

  void removeDataFromQuestion(QuestionId questionId) {
    values.removeWhere((value) => value.id == questionId);
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'values': values.map((v) => v.toJson()).toList(),
      };
}

class Datas {
  List<DayData> daysData = [];
  final DataManager dataManager;

  Datas(this.dataManager);

  void clear() {
    daysData = [];
  }

  List<DayData> getAllData() {
    return daysData;
  }

  Map<String, DateTime> getMinMaxDates() {
    if (daysData.isEmpty) {
      return {'min': DateTime.now(), 'max': DateTime.now()};
    }

    DateTime min = dataManager.getDateFromString(daysData.first.date);
    DateTime max = min;

    for (var dayData in daysData) {
      final date = dataManager.getDateFromString(dayData.date);
      if (date.isBefore(min)) min = date;
      if (date.isAfter(max)) max = date;
    }

    return {'min': min, 'max': max};
  }

  void set(String date, List<QuestionValue> values) {
    final index = daysData.indexWhere((dayData) => dayData.date == date);
    if (index != -1) {
      daysData[index].values = values;
    } else {
      daysData.add(DayData(date: date, values: values));
      _sort();
    }
  }

  void deleteDatasForQuestion(QuestionId aQuestionId) {
    for (var dayData in daysData) {
      dayData.removeDataFromQuestion(aQuestionId);
    }
  }

  List<QuestionValue> getValuesForDate(String date) {
    final dayData = daysData.firstWhere(
      (dayData) => dayData.date == date,
      orElse: () => DayData(date: date, values: []),
    );
    return dayData.values;
  }

  Map<String, dynamic> getValuesForQuestion(QuestionId aQuestionId) {
    Map<String, dynamic> result = {};
    for (var dayData in daysData) {
      String date = dayData.date;
      for (var value in dayData.values) {
        if (value.id == aQuestionId) {
          result[date] = value.v;
          break;
        }
      }
    }
    return result;
  }

  void _sort() {
    daysData.sort((a, b) => a.date.compareTo(b.date));
  }

  String? getValue(String date, QuestionId questionId) {
    final dateData = getValuesForDate(date);
    final questionValue = dateData.firstWhere(
      (data) => data.id == questionId,
      orElse: () => QuestionValue(id: questionId, v: ''),
    );
    return questionValue.v.isNotEmpty ? questionValue.v : null;
  }
}
