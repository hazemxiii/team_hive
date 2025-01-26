import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? fName;
  String? lName;
  FirebaseService() {
    getName();
  }

  Future<bool> getName() async {
    if (user == null) {
      return false;
    }
    DocumentSnapshot d = await _firestore.doc("users/${user!.uid}").get();
    fName = d.get("fName");
    lName = d.get("lName");
    return true;
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
    if (user != null) {
      DocumentReference d = _firestore.doc("users/${user!.uid}");
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
      await getName();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  void signOut() {
    _auth.signOut();
  }

  User? get user => _auth.currentUser;
}
