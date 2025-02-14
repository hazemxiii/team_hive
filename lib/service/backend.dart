import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _firestore = FirebaseFirestore.instance;
  final _serverUrl = "team-hive-api.vercel.app";
  // final _serverUrl = "127.0.0.1:5000";
  final bool _secure = true;
  late MyUser _currentUser;

  Future<RequestResponse> _makeRequest(String resource, String data) async {
    try {
      Uri? url;
      if (_secure) {
        url = Uri.https(_serverUrl, resource);
      } else {
        url = Uri.http(_serverUrl, resource);
      }
      var r = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: data);
      if (r.statusCode != 200) {
        return RequestResponse(ok: false, r: "Failed to reach the server");
      }

      return RequestResponse(ok: true, r: r.body);
    } catch (e) {
      return RequestResponse(ok: false, r: e.toString());
    }
  }

  Future<void> getCurrentUserProfile() async {
    if (_user == null) {
      return;
    }
    Map<String, dynamic> d = {};
    try {
      d = (await _firestore.doc("users/${_user!.uid}").get()).data() ?? {};
    } catch (e) {
      debugPrint("Error getting user data: $e");
    }
    _currentUser = MyUser(
        uid: _user!.uid,
        email: _user!.email ?? "",
        fName: d["fName"] ?? ".",
        lName: d["lName"] ?? ".",
        teams: await getTeamsNames());
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

  Future<void> createUserDoc(String email, String fName, String lName) async {
    if (_user != null) {
      DocumentReference d = _firestore.doc("users/${_user!.uid}");
      try {
        if (!(await d.get()).exists) {
          await d.set({"email": email, "fName": fName, "lName": lName});
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<bool> editDisplayName(String fName, String lName) async {
    try {
      DocumentReference userRef = _firestore.doc("users/${user.uid}");
      await userRef.update({"fName": fName, "lName": lName});
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String?> emailSignIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // TODO: uncomment this on production
      // if (!_user!.emailVerified) {
      //   await signOut();
      //   return "Please Verify Your Account To Sign In";
      // }
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
      await createUserDoc(_auth.currentUser!.email!,
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
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference teamDoc = _firestore.collection("teams").doc();
        DocumentReference ownerDoc = _firestore.doc("users/${user.uid}");
        transaction.set(teamDoc, {"name": teamName, "owner": user.uid});
        transaction.update(ownerDoc, {
          "teams": [..._currentUser.teams.map((e) => e.id), teamDoc.id]
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> joinTeam(String teamCode) async {
    DocumentReference userRef = _firestore.doc("users/${user.uid}");
    DocumentSnapshot userDoc = await userRef.get();
    List teamsIds = [];
    try {
      teamsIds = userDoc.get("teams");
      teamsIds.add(teamCode);
      await userRef.update({"teams": teamsIds});
    } catch (e) {
      debugPrint("Error getting teams: ${e.toString()}");
    }
  }

  Future<List<Team>> getTeamsNames() async {
    List<Team> teams = [];
    RequestResponse r =
        await _makeRequest("teams", jsonEncode({"token": await getToken()}));

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
            teams: []);
        teams.add(Team(name: name, owner: ownerUser, id: id));
      }
    }
    return teams;
  }

  Future<String?> createQuiz(Team t, Quiz q) async {
    Map<String, dynamic> quizEncoded = q.encode(true);
    Map<String, dynamic> answers = quizEncoded['answers'];
    quizEncoded.remove("answers");
    quizEncoded.remove("name");
    quizEncoded.remove("grade");
    try {
      DocumentReference quizDoc =
          _firestore.doc("teams/${t.id}/quizzes/${q.name}");
      DocumentReference quizAnsDoc =
          _firestore.doc("teams/${t.id}/quizzesAnswers/${q.name}");
      await _firestore.runTransaction((tr) async {
        tr.set(quizDoc, quizEncoded);
        tr.set(quizAnsDoc, answers);
      });
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
    return null;
  }

  Future<Quiz?> getQuizData(String teamId, String quizName) async {
    Map data = {"token": await getToken(), "team": teamId, "quiz": quizName};
    RequestResponse r = await _makeRequest("quiz", jsonEncode(data));
    Map response = jsonDecode(r.r);
    if (r.ok) {
      Map<String, dynamic> quizEncoded = response['quiz'];
      quizEncoded['name'] = quizName;
      quizEncoded['answers'] = response['userAnswers'];
      quizEncoded['correct'] = response['correctAnswers'];
      return Quiz.decode(quizEncoded);
    }
    return null;
  }

  Future<List<Quiz>> getQuizzesDisplayData(String teamId, bool isOwner) async {
    List<Quiz> quizzes = [];
    Map data = {"isOwner": isOwner, "team": teamId, "token": await getToken()};
    RequestResponse r = await _makeRequest("quizzes", jsonEncode(data));
    if (r.ok) {
      List response = jsonDecode(r.r);
      for (var quiz in response) {
        quizzes.add(Quiz(name: quiz['quiz'], grade: quiz['grade']));
      }
    }
    return quizzes;
  }

  Future<void> submitQuiz(Quiz q, Team t) async {
    Map<String, dynamic> data = q.encode(false)['answers'];
    data['token'] = await getToken();
    data['quiz'] = q.name;
    data['team'] = t.id;
    var url = Uri.http("127.0.0.1:5000", "quiz/submit");
    await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
  }

  Future<String?> getToken() async {
    return await _auth.currentUser!.getIdToken();
  }

  MyUser get user => _currentUser;
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
