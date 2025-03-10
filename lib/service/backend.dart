import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/models/user.dart';
import 'package:http/http.dart' as http;

class RequestResponse {
  bool ok;
  String r;
  RequestResponse({required this.ok, required this.r});
}

class BackendService {
  final _auth = FirebaseAuth.instance;
  final _serverUrl = "team-hive-api.vercel.app";
  // final _serverUrl = "127.0.0.1:5000";
  final bool _secure = true;
  MyUser? _currentUser;
  final appVersion = "1.0.1";

  Future<RequestResponse> _makeRequest(String resource, Map data) async {
    data['token'] = await _user!.getIdToken();
    try {
      Uri? url;
      if (_secure) {
        url = Uri.https(_serverUrl, resource);
      } else {
        url = Uri.http(_serverUrl, resource);
      }
      var r = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));
      if (r.statusCode != 200) {
        return RequestResponse(ok: false, r: "Failed to reach the server");
      }

      return RequestResponse(ok: true, r: r.body);
    } catch (e) {
      return RequestResponse(ok: false, r: e.toString());
    }
  }

  Future<bool> toggleShowAnswers(String teamId, String quizName) async {
    RequestResponse r = await _makeRequest(
        "quiz/answers/show", {"team": teamId, "quiz": quizName});
    if (r.r == "ok") {
      return true;
    }
    return false;
  }

  Future<void> getAppData(BuildContext context) async {
    RequestResponse r = await _makeRequest("app", {});
    Map data = jsonDecode(r.r);
    if (r.ok && context.mounted && data['version'] != appVersion) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text("Newer version available"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Features"),
                      ...(data['features'] as List)
                          .map((feature) => Text("- $feature"))
                    ],
                  ),
                ),
              ));
    }
  }

  Future<void> getCurrentUserProfile() async {
    if (_user == null) {
      return;
    }

    RequestResponse r = await _makeRequest("user", {"uid": _user!.uid});
    if (r.ok) {
      Map d = jsonDecode(r.r);
      _currentUser = MyUser(
          uid: _user!.uid,
          email: _user!.email ?? "",
          fName: d["fName"] ?? ".",
          lName: d["lName"] ?? ".",
          teams: await getTeamsNames(),
          isPremium: d['isPremium'] ?? false);
    }
  }

  Future<String?> createEmailAccount(
      String email, String password, String fName, String lName) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _user!.sendEmailVerification();
      // await _createUserDoc(email, fName, lName);
      // await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  Future<void> createUserDoc(String fName, String lName) async {
    if (_user != null) {
      await _makeRequest("user/create", {"fName": fName, "lName": lName});
    }
  }

  Future<bool> editDisplayName(String fName, String lName) async {
    RequestResponse r =
        await _makeRequest("user/updatename", {"fName": fName, "lName": lName});
    if (r.ok) {
      if (r.r == "ok") {
        return true;
      }
    }
    return false;
    // try {
    //   DocumentReference userRef = _firestore.doc("users/${user.uid}");
    //   await userRef.update({"fName": fName, "lName": lName});
    //   return true;
    // } catch (e) {
    //   debugPrint(e.toString());
    //   return false;
    // }
  }

  Future<String?> emailSignIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!_user!.emailVerified) {
        await signOut();
        return "Please Verify Your Account To Sign In";
      }
      await getCurrentUserProfile();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  Future<String?> googleSignIn() async {
    try {
      GoogleAuthProvider provider = GoogleAuthProvider();
      provider.setCustomParameters({"prompt": "select_account"});
      await _auth.signInWithPopup(provider);
      if (_auth.currentUser == null) {
        return null;
      }
      List name = (_auth.currentUser!.displayName ?? "No Name").split(" ");
      await createUserDoc(
          name.isNotEmpty ? name[0] : "No", name.length > 1 ? name[1] : "Name");
      await getCurrentUserProfile();

      return null;
    } catch (e) {
      debugPrint("Error signing in: ${e.toString()}");
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> createTeam(String teamName) async {
    RequestResponse r = await _makeRequest("team/create", {"name": teamName});
    if (r.r == "ok") {
      return true;
    }
    return false;
  }

  Future<void> joinTeam(String teamCode) async {
    await _makeRequest("team/join", {"team": teamCode});
  }

  Future<List<Team>> getTeamsNames() async {
    List<Team> teams = [];
    RequestResponse r = await _makeRequest("teams", {});

    if (r.ok) {
      Map data = {};
      try {
        data = jsonDecode(r.r);
      } catch (e) {
        debugPrint("Failed to decode team names: $e");
      }
      for (String id in data.keys) {
        String name = data[id]['team'];
        Map owner = data[id]['owner'];
        MyUser ownerUser = MyUser(
            email: owner['email'],
            fName: owner['fName'],
            lName: owner['lName'],
            teams: [],
            isPremium: true);
        teams.add(Team(name: name, owner: ownerUser, id: id));
      }
    }
    return teams;
  }

  Future<String?> createQuiz(Team t, Quiz q) async {
    /// Returns an error as a nullable string
    Map<String, dynamic> quizEncoded = q.encode(true);
    quizEncoded['showAnswers'] = false;
    Map<String, dynamic> answers = quizEncoded['answers'];
    quizEncoded.remove("answers");
    quizEncoded.remove("name");
    quizEncoded.remove("grade");
    RequestResponse r = await _makeRequest("quiz/create", {
      "name": q.name,
      "data": quizEncoded,
      "answers": answers,
      "team": t.id
    });
    if (r.ok) {
      t.updateQuizzes([q], true);
      return r.r == "ok" ? null : "Error";
    }
    return null;
  }

  Future<Quiz?> getQuizData(String teamId, String quizName) async {
    Map data = {"team": teamId, "quiz": quizName};
    RequestResponse r = await _makeRequest("quiz", data);
    if (r.ok) {
      Map response = jsonDecode(r.r);
      Map<String, dynamic> quizEncoded = response['quiz'];
      quizEncoded['name'] = quizName;
      if (response.containsKey("userAnswers")) {
        quizEncoded['answers'] = response['userAnswers']['answers'] ?? {};
      }
      quizEncoded['correct'] = response['correctAnswers'];
      return Quiz.decode(quizEncoded);
    }
    return null;
  }

  Future<List<Quiz>> getQuizzesDisplayData(String teamId, bool isOwner) async {
    List<Quiz> quizzes = [];
    Map data = {"isOwner": isOwner, "team": teamId};
    RequestResponse r = await _makeRequest("quizzes", data);
    if (r.ok) {
      List response = jsonDecode(r.r);
      for (var quiz in response) {
        quizzes.add(Quiz(
            name: quiz['quiz'],
            grade: quiz['grade'],
            answersShown: quiz['showAnswers']));
      }
    }
    return quizzes;
  }

  Future<String?> submitQuiz(Quiz q, Team t) async {
    Map<String, dynamic> data = q.encode(false)['answers'];
    data['quiz'] = q.name;
    data['team'] = t.id;
    RequestResponse r = await _makeRequest("quiz/submit", data);
    if (r.ok) {
      if (r.r != "Failed") {
        return null;
      }
    }
    return "Failed To Submit Exam";
  }

  Future<Map?> getQuizResponses(String q, String t) async {
    RequestResponse r =
        await _makeRequest("quiz/responses", {"team": t, "quiz": q});

    Map<MyUser, double> responses = {};
    List<MyUser> noAnswer = [];

    if (r.ok) {
      Map data = {};
      try {
        data = jsonDecode(r.r);
        Map responsesR = data['responses'];
        Map noAnswerR = data['noAnswer'];
        for (var id in responsesR.keys) {
          responses[_parseUserFromResponse(responsesR[id])] =
              responsesR[id]['grade'];
        }
        for (var id in noAnswerR.keys) {
          noAnswer.add(_parseUserFromResponse(noAnswerR[id]));
        }
        return {"responses": responses, "noAnswer": noAnswer};
      } catch (e) {
        debugPrint("Failed to get responses: ${e.toString()}");
        return null;
      }
    }
    debugPrint("Failed to get responses");
    return null;
  }

  MyUser _parseUserFromResponse(Map r) {
    return MyUser(
        email: r['email'],
        fName: r['fName'],
        lName: r['lName'],
        teams: [],
        isPremium: r['isPremium'] ?? false);
  }

  Future<String?> getToken() async {
    return await _auth.currentUser!.getIdToken();
  }

  MyUser get user {
    if (_currentUser == null) {
      _auth.signOut();
      return MyUser(
          email: "email",
          fName: "no",
          lName: "user",
          teams: [],
          isPremium: false);
    }
    return _currentUser!;
  }

  bool get isLogged => _user != null;
  User? get _user => _auth.currentUser;
  bool get isVerified {
    if (_auth.currentUser == null) {
      return false;
    }
    _auth.currentUser!.reload();
    return _auth.currentUser!.emailVerified;
  }
}
