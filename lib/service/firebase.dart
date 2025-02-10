import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/models/user.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:http/http.dart' as http;

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late MyUser _currentUser;

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
        fName: d["fName"] ?? "",
        lName: d["lName"] ?? "",
        teams: await getTeamsNames());
  }

  Future<String?> createEmailAccount(
      String email, String password, String fName, String lName) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _createUserDoc(email, fName, lName);
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  Future<void> _createUserDoc(String email, String fName, String lName) async {
    if (_user != null) {
      DocumentReference d = _firestore.doc("users/${_user!.uid}");
      try {
        await d.set({"email": email, "fName": fName, "lName": lName});
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<String?> emailSignIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await getCurrentUserProfile();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
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
    List<String> teamsIds = [];
    try {
      teamsIds = userDoc.get("teams");
    } catch (e) {
      debugPrint("Error getting teams: ${e.toString()}");
    }
    teamsIds.add(teamCode);
    await userRef.update({"teams": teamsIds});
  }

  Future<List<Team>> getTeamsNames() async {
    List<Team> teams = [];
    List<dynamic> teamsId = [];
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.doc("users/${_user!.uid}").get();
      if (userDoc.exists) {
        teamsId = userDoc.get("teams") ?? [];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    for (String id in teamsId) {
      teams.add(await _getTeamNameById(id));
    }
    return teams;
  }

  Future<Team> _getTeamNameById(String id) async {
    Map<String, dynamic> team = {};
    DocumentSnapshot<Map<String, dynamic>> teamDoc =
        await _firestore.doc("teams/$id").get();
    if (teamDoc.exists) {
      team = teamDoc.data() ?? {};
    }

    return Team(
        name: team['name'] ?? "",
        color: Color(team['color'] ?? Style.sec.value),
        owner: await _getOwnerProfile(team['owner'] ?? ""),
        id: id);
  }

  Future<MyUser> _getOwnerProfile(String id) async {
    Map<String, dynamic> owner = {};
    try {
      DocumentSnapshot<Map<String, dynamic>> ownerDoc =
          await _firestore.doc("users/$id").get();
      if (ownerDoc.exists) {
        owner = ownerDoc.data() ?? {};
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return MyUser(
        uid: id,
        email: owner['email'] ?? "",
        fName: owner['fName'] ?? "",
        lName: owner['lName'] ?? "",
        teams: []);
  }

  Future<String?> createQuiz(Team t, Quiz q) async {
    Map<String, dynamic> quizEncoded = q.encode(true);
    Map<String, dynamic> answers = quizEncoded['answers'];
    quizEncoded.remove("answers");
    quizEncoded.remove("name");
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

  Future<Quiz?> getQuizData(
      String teamId, String quizName, bool isOwner) async {
    if (!isOwner) {
      bool start = await _startQuizSession(quizName, teamId);
      if (!start) {
        return null;
      }
    }
    Map<String, dynamic> quizEncoded = {};
    try {
      DocumentSnapshot<Map<String, dynamic>> quizDoc =
          await _firestore.doc("teams/$teamId/quizzes/$quizName").get();

      DocumentSnapshot<Map<String, dynamic>> userAnsDoc = await _firestore
          .doc("/teams/$teamId/responses/$quizName/r/${user.uid}")
          .get();

      Map<String, dynamic> userAns = {};

      if (userAnsDoc.exists) {
        userAns = userAnsDoc.data() ?? {};
      }

      Map<String, dynamic> correctAnswers = (await _firestore
                  .doc("/teams/$teamId/quizzesAnswers/$quizName")
                  .get())
              .data() ??
          {};

      quizEncoded = quizDoc.data() ?? {};
      quizEncoded['correct'] = correctAnswers;
      quizEncoded['answers'] = userAns['answers'];
      quizEncoded['name'] = quizName;
    } catch (e) {
      debugPrint(e.toString());
    }
    if (quizEncoded.isEmpty) {
      return null;
    }
    return Quiz.decode(quizEncoded);
  }

  Future<List<Quiz>> getQuizzesDisplayData(String teamId, bool isOwner) async {
    List<Quiz> quizzes = [];
    try {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
          (await _firestore.collection("teams/$teamId/quizzes").get()).docs;
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
        Map<String, dynamic> data = doc.data();
        Timestamp? startDate = data["startDate"];
        Timestamp? deadline = data["deadline"];
        Map<String, dynamic> answers = {};
        if (!isOwner) {
          DocumentSnapshot<Map<String, dynamic>> answerDoc = await _firestore
              .doc("/teams/$teamId/responses/${doc.id}/r/${user.uid}")
              .get();
          if (answerDoc.exists) {
            answers = answerDoc.data() ?? {};
          }
        }
        quizzes.add(Quiz(
            grade: answers['grade'],
            name: doc.id,
            startDate: startDate?.toDate(),
            deadline: deadline?.toDate()));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return quizzes;
  }

  Future<bool> _startQuizSession(String quizName, String teamId) async {
    Map<String, String> data = {
      "quiz": quizName,
      "team": teamId,
      "token": await getToken() ?? ""
    };
    try {
      var url = Uri.http("127.0.0.1:5000", "quiz/start");
      var r = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));
      if (r.body == "true") {
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return false;
  }

  Future<void> submitQuiz(Quiz q, Team t) async {
    Map<String, dynamic> data = q.encode(t.isOwner(user))['answers'];
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
}
