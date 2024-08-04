import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/data.dart';
import '../utils/shared_constants.dart';

class DataManager with ChangeNotifier {
  static const String NOTE_QUESTION_ID = "9999";
  bool questionsLoaded = false;
  List<Question> listQuestions = [];
  Map<String, dynamic> questionsSettings = {};
  late Datas daysData;
  Map<String, VoidCallback> questionCallbacks = {};
  VoidCallback? answersUpdateCallback;

  DataManager() {
    daysData = Datas(this);
    init();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Done.');
  }

  Future<void> _storeData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonValue = prefs.getString(key);
    return jsonValue != null ? jsonDecode(jsonValue) : null;
  }

  Future<void> _loadQuestionsFromStorage() async {
    final questionsData = await getData("@questions");
    if (questionsData != null) {
      listQuestions = [];
      for (var questionData in questionsData) {
        final question = Question.fromJson(questionData);
        listQuestions.add(question);
      }
      questionsLoaded = true;
    }
  }

  void init() async {
    await _loadQuestionsFromStorage();
    callQuestionsCallbacks();

    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final stringDataDayArray =
        allKeys.where((key) => key.startsWith("@DataDay:")).toList();

    for (var key in stringDataDayArray) {
      final object = await getData(key);
      final keyDateOnly = key.split("@DataDay:").last;
      daysData.set(keyDateOnly, object);
    }

    if (answersUpdateCallback != null) {
      answersUpdateCallback!();
    }

    notifyListeners();
  }

  Future<String> getAllDataStorageAsString() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    Map<String, dynamic> allData = {};
    for (var key in allKeys) {
      allData[key] = await getData(key);
    }
    return jsonEncode(allData);
  }

  Map<String, bool> getFilledDates() {
    String convertDateFormat(String dateString) {
      return "${dateString.substring(0, 4)}-${dateString.substring(4, 6)}-${dateString.substring(6)}";
    }

    final allData = daysData.getAllData();
    Map<String, bool> filledDates = {};

    allData.forEach((dayIndex, dayData) {
      bool hasQuestionUnanswered =
          dayData.values.any((value) => value.v == null);
      if (!hasQuestionUnanswered) {
        final properDateFormat = convertDateFormat(dayData.date);
        filledDates[properDateFormat] = true;
      }
    });

    return filledDates;
  }

  // Implement getPartiallyFilledDates() here

  Map<String, dynamic> getQuestionsDataLinear() {
    final container = {
      "fields": ["questions"],
      "data": <List<dynamic>>[]
    };

    final dateLimits = daysData.getMinMaxDates();
    if (dateLimits.min == null || dateLimits.max == null) {
      return container;
    }

    final difference = dateLimits.max!.difference(dateLimits.min!).inDays;
    final days = difference.clamp(0, 10000);

    // Populate date fields
    for (int i = 0; i < days; i++) {
      final currentDate = dateLimits.min!.add(Duration(days: i));
      final dateString = getDateString(currentDate);
      container["fields"].add(dateString);
    }

    // Populate data for each question
    for (var question in listQuestions) {
      final questionRow = [question.text];
      final questionData = question.getArrayValues(normalizeValue: false);

      for (int i = 1; i < (container["fields"] as List).length; i++) {
        final dateString = container["fields"][i];
        final dataPoint = questionData.firstWhere(
          (dp) => getDateString(dp.date) == dateString,
          orElse: () => {"date": DateTime.now(), "value": ""},
        );
        questionRow.add(dataPoint["value"]);
      }

      container["data"].add(questionRow);
    }

    return container;
  }

  void callQuestionsCallbacks() {
    questionCallbacks.values.forEach((callback) => callback());
    notifyListeners();
  }

  void saveListQuestions() {
    final listSavable =
        listQuestions.map((question) => question.toJson()).toList();
    _storeData("@questions", listSavable);
    notifyListeners();
  }

  void updateQuestionsOrder() {
    listQuestions.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    callQuestionsCallbacks();
  }

  void setQuestionVisibility(String questionId, bool visibility) {
    questionsSettings[questionId] = {"visibility": visibility};
    _storeData("@questionsSettings", questionsSettings);
    notifyListeners();
  }

  bool getQuestionVisibility(String questionId) {
    final obj = questionsSettings[questionId];
    if (obj != null) {
      final answer = obj["visibility"];
      if (answer != null) {
        return answer;
      }
    }
    return true;
  }

  String getDateString(DateTime date) {
    return "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
  }

  DateTime getDateFromString(String dateString) {
    final year = int.parse(dateString.substring(0, 4));
    final month = int.parse(dateString.substring(4, 6));
    final day = int.parse(dateString.substring(6, 8));
    return DateTime(year, month, day);
  }

  void setData(String questionID, DateTime date, dynamic value) {
    final dateStr = getDateString(date);
    final tagStoring = "@DataDay:$dateStr";

    var dayData = daysData.getValuesForDate(dateStr) ?? [];

    bool foundIt = false;
    for (var i = 0; i < dayData.length; i++) {
      if (dayData[i]["id"] == questionID) {
        dayData[i]["v"] = value;
        foundIt = true;
        break;
      }
    }

    if (!foundIt) {
      dayData.add({"id": questionID, "v": value});
    }

    daysData.set(dateStr, dayData);
    _storeData(tagStoring, dayData);

    if (answersUpdateCallback != null) {
      answersUpdateCallback!();
    }
    notifyListeners();
  }

  void removeData(String questionID, DateTime date) {
    final dateStr = getDateString(date);
    final tagStoring = "@DataDay:$dateStr";

    var dayData = daysData.getValuesForDate(dateStr);
    if (dayData == null) return;

    dayData.removeWhere((item) => item["id"] == questionID);

    _storeData(tagStoring, dayData);

    if (answersUpdateCallback != null) {
      answersUpdateCallback!();
    }
    notifyListeners();
  }

  String findAvailableId() {
    int maxNum = listQuestions.fold(
        0, (max, question) => math.max(max, int.parse(question.id)));
    return (maxNum + 1).toString();
  }

  Question addQuestion(String questionText, String questionType,
      List<dynamic> options, String colour,
      {String? forcedId}) {
    final id = forcedId ?? findAvailableId();
    final question = Question(
      text: questionText,
      type: questionType,
      options: options,
      colour: colour,
      id: id,
      dataManager: this,
    );
    listQuestions.add(question);
    saveListQuestions();
    callQuestionsCallbacks();
    return question;
  }

  void updateQuestion(String questionId, String questionText,
      String questionType, List<dynamic> options, String colour) {
    final question = listQuestions.firstWhere((q) => q.id == questionId);
    question.text = questionText;
    question.type = questionType;
    question.setOptions(options);
    question.colour = colour;

    saveListQuestions();
    callQuestionsCallbacks();
  }

  bool deleteQuestion(String questionId) {
    final initialLength = listQuestions.length;
    listQuestions.removeWhere((q) => q.id == questionId);

    if (listQuestions.length < initialLength) {
      saveListQuestions();
      callQuestionsCallbacks();
      return true;
    }
    return false;
  }

  Future<List<Question>> getQuestions() async {
    if (!questionsLoaded) {
      await _loadQuestionsFromStorage();
    }
    return listQuestions
        .where(
            (question) => question.type != SharedConstants.QUESTION_TYPE_NOTE)
        .toList();
  }

  // List<Question> getQuestions() {
  //   return listQuestions
  //       .where(
  //           (question) => question.type != SharedConstants.QUESTION_TYPE_NOTE)
  //       .toList();
  // }

  Future<List<Question>> getNotes() {
    if (!questionsLoaded) {
      await _loadQuestionsFromStorage();
    }
    return listQuestions
        .where(
            (question) => question.type == SharedConstants.QUESTION_TYPE_NOTE)
        .toList();
  }

  Future<dynamic> getAppInfo() async {
    return await getData("@appstate");
  }

  void saveAppInfo(dynamic appInfoData) {
    _storeData("@appstate", appInfoData);
  }

  dynamic getAnswerForQuestion(String questionId, DateTime date) {
    final dateStr = getDateString(date);
    return daysData.getValue(dateStr, questionId);
  }

  Map<String, dynamic> getAllData() {
    return daysData.getAllData();
  }

  Question? getQuestionWithId(String id) {
    return listQuestions.firstWhere((q) => q.id == id, orElse: () => null);
  }

  Question? getNoteQuestion(String id) {
    return getQuestionWithId(id);
  }

  void restore(Map<String, dynamic> objectToStore) async {
    await clearAll();
    objectToStore.forEach((key, value) {
      _storeData(key, value);
    });
    init();
  }

  Question? getNextQuestion(String currentQuestionId, bool goForward,
      bool onlyTakeUnreplied, bool discardNotes, DateTime date) {
    final len = listQuestions.length;
    int indexReturn = 0;

    for (int i = 0; i < len; i++) {
      if (listQuestions[i].id == currentQuestionId) {
        if (i == (len - 1) && goForward) {
          indexReturn = 0;
        } else if (i == 0 && !goForward) {
          indexReturn = len - 1;
        } else {
          indexReturn = i + (goForward ? 1 : -1);
        }

        Question nextQuestion = listQuestions[indexReturn];

        if (discardNotes && nextQuestion.isNote()) {
          return getNextQuestion(nextQuestion.id, goForward, onlyTakeUnreplied,
              discardNotes, date);
        }

        if (onlyTakeUnreplied) {
          final answer = getAnswerForQuestion(nextQuestion.id, date);
          if (answer == null) {
            return nextQuestion;
          } else {
            return getNextQuestionUnrespondedInArray(indexReturn, date);
          }
        } else {
          return nextQuestion;
        }
      }
    }

    return null;
  }

  Question? getNextQuestionUnrespondedInArray(int indexInArray, DateTime date) {
    for (int indexAdd = 0; indexAdd < listQuestions.length; indexAdd++) {
      final index = (indexInArray + indexAdd) % listQuestions.length;
      final currentQuestion = listQuestions[index];
      final answer = getAnswerForQuestion(currentQuestion.id, date);

      if (answer == null && !currentQuestion.isNote()) {
        return currentQuestion;
      }
    }
    return null;
  }

  void addQuestionsListener(String stringId, VoidCallback callback) {
    if (questionsLoaded) {
      callback();
    }
    questionCallbacks[stringId] = callback;
  }

  void removeQuestionsListener(String stringId) {
    questionCallbacks.remove(stringId);
  }

  void setAnswersUpdateListener(VoidCallback callback) {
    answersUpdateCallback = callback;
  }
}

final dataManager = DataManager();
