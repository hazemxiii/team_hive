import 'package:team_hive/models/question/question.dart';

class Quiz {
  late String _name;
  double? _grade;
  DateTime? _startDate;
  DateTime? _deadline;
  List<Question> _questions = [];

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
    _questions = questions;
  }

  void setName(String v) {
    _name = v;
  }

  double totalGrade() {
    double sum = 0;
    for (Question q in _questions) {
      sum += q.mark;
    }
    return sum;
  }

  int? percent() {
    if (grade == null || _questions.isEmpty) {
      return null;
    }
    return (grade! / totalGrade() * 100).ceil();
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

  String get name => _name;
  double? get grade => _grade;
  DateTime? get startDate => _startDate;
  DateTime? get deadline => _deadline;
  List<Question> get questions => _questions;
}
