import 'package:team_hive/models/question/mcq_question.dart';
import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';

class Quiz {
  late String _name;
  double? _grade;
  DateTime? _startDate;
  DateTime? _deadline;
  final List<Question> _questions = [];

  Quiz(
      {required String name,
      double? grade,
      DateTime? startDate,
      DateTime? deadline,
      List<Question> questions = const []}) {
    _name = name;
    _grade = grade;
    _startDate = startDate;
    _deadline = deadline;
    _questions.addAll(questions);
  }

  void copy(Quiz q) {
    _name = q.name;
    _grade = q.grade;
    _startDate = q.startDate;
    _deadline = q.deadline;
    _questions.clear();
    _questions.addAll(q.questions);
  }

  void setName(String v) {
    _name = v;
  }

  int getQuizState() {
    DateTime now = DateTime.now();
    bool noStart = startDate == null;
    bool noEnd = deadline == null;
    if (noStart) {
      if (noEnd) {
        return 0;
      } else {
        return deadline!.isAfter(now) ? 0 : 1;
      }
    } else if (noEnd) {
      return startDate!.isBefore(now) ? 0 : -1;
    } else {
      if (startDate!.isAfter(now)) {
        return -1;
      }
      if (deadline!.isBefore(now)) {
        return 1;
      }
    }
    return 0;
  }

  void addQuestion(Question q) {
    _questions.add(q);
  }

  String? validateQuiz() {
    if (_name.trim() == "") {
      return "Exam Can't Have an Empty Name";
    }
    for (Question q in _questions) {
      if (q.text.trim() == "") {
        return "Question ${questions.indexOf(q) + 1} is Empty";
      }
      if (q is McqQuestion && q.choices.length < 2) {
        return "Question ${questions.indexOf(q) + 1} Must Have More Than One Choice";
      }
      if ((q is SingleMcqQuestion && q.answer == null) ||
          (q is MultiMcqQuestion && q.answer.isEmpty)) {
        return "Question ${questions.indexOf(q) + 1} Must Have a Correct Answer";
      }
    }
    return null;
  }

  Map<String, dynamic> encode(bool isOwner) {
    List<Map<String, dynamic>> questions = [];
    Map<String, dynamic> answers = {};
    for (Question q in _questions) {
      Map<String, dynamic> encoded = q.encode();
      if (encoded['type'] != 0 || !isOwner) {
        answers[q.text] = encoded['answer'];
      }
      encoded.remove("answer");
      questions.add(encoded);
    }
    return {
      "questions": questions,
      "name": _name,
      "startDate": _startDate,
      "deadline": _deadline,
      "answers": answers,
      "grade": _grade
    };
  }

  static Quiz decode(Map<String, dynamic> encoded) {
    List questionsEncoded = encoded['questions'] ?? [];
    List<Question> questions = [];
    for (Map<String, dynamic> q in questionsEncoded) {
      questions.add(Question.decode(q));
    }
    return Quiz(
        name: encoded['name'],
        grade: encoded['grade'],
        startDate: encoded["startDate"]?.toDate(),
        deadline: encoded['deadline']?.toDate(),
        questions: questions);
  }

  String get name => _name;
  double? get grade => _grade;
  DateTime? get startDate => _startDate;
  DateTime? get deadline => _deadline;
  List<Question> get questions => _questions;
}
