import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/models/user.dart';
import 'package:team_hive/service/app_colors.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late MyUser _currentUser;

  Future<void> getUserData() async {
    if (_user == null) {
      return;
    }
    try {
      DocumentSnapshot d = await _firestore.doc("users/${_user!.uid}").get();
      _currentUser = MyUser(
          uid: _user!.uid,
          email: _user!.email ?? "",
          fName: d.get("fName") ?? "",
          lName: d.get("lName") ?? "",
          teams: await getTeams());
    } catch (e) {
      debugPrint("Error getting user data: $e");
    }
  }

  Future<String?> createEmailAccount(
      String email, String password, String fName, String lName) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _createUserDoc(fName, lName);
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  Future<void> _createUserDoc(String fName, String lName) async {
    if (_user != null) {
      DocumentReference d = _firestore.doc("users/${_user!.uid}");
      try {
        await d.set({"fName": fName, "lName": lName});
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<String?> emailSignIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await getUserData();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  void signOut() {
    _auth.signOut();
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

  Future<List<Team>> getTeams() async {
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
      teams.add(await _getTeamById(id));
    }
    return teams;
  }

  Future<Team> _getTeamById(String id) async {
    Map<String, dynamic> team = {};
    DocumentSnapshot<Map<String, dynamic>> teamDoc =
        await _firestore.doc("teams/$id").get();
    if (teamDoc.exists) {
      team = teamDoc.data() ?? {};
    }

    return Team(
        name: team['name'] ?? "",
        color: Color(team['color'] ?? Style.sec.value),
        owner: await _getOwner(team['owner'] ?? ""),
        id: id);
  }

  Future<MyUser> _getOwner(String id) async {
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
        email: owner['name'] ?? "",
        fName: owner['fName'] ?? "",
        lName: owner['lName'] ?? "",
        teams: []);
  }

  MyUser get user => _currentUser;
  bool get isLogged => _user != null;
  User? get _user => _auth.currentUser;
}
