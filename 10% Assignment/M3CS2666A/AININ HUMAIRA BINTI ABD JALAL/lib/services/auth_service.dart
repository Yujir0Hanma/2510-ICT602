import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<AuthUser?> get userStream {
    return _auth.authStateChanges().asyncMap((fb.User? user) async {
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data == null) return null;

      return AuthUser(
        uid: user.uid,
        email: user.email ?? '',
        role: data['role'] ?? 'student',
        studentId: data['studentId'],
        name: data['name'],
      );
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> registerUser(
      String email,
      String password,
      String role, {
        String? studentId,
        String? name,
      }) async {
    try {
      final res = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(res.user!.uid).set({
        'email': email,
        'role': role,
        'studentId': studentId,
        'name': name,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async => _auth.signOut();
}
