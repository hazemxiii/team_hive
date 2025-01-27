import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_hive/models/user.dart';

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
          lName: d.get("lName") ?? "");
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

  MyUser get user => _currentUser;
  bool get isLogged => _user != null;
  User? get _user => _auth.currentUser;
}
