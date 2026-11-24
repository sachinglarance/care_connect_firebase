import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<AppUser?> watchProfile(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? AppUser.fromMap(uid, s.data()!) : null);

  Future<void> signIn(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  /// Creates the account and the `users/{uid}` profile that holds the role.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) => _guard(() async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _users.doc(user.uid).set({
      ...AppUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  });

  /// Treats "no such user" as success so the reset screen can't be used to
  /// check which emails are registered.
  Future<void> sendPasswordReset(String email) => _guard(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') rethrow;
    }
  });

  Future<void> saveFcmToken(String uid, String token) => _users.doc(uid).set({
    'fcmTokens': FieldValue.arrayUnion([token]),
  }, SetOptions(merge: true));

  Future<void> signOut() => _auth.signOut();

  Future<void> _guard(Future<void> Function() body) async {
    try {
      await body();
    } on FirebaseAuthException catch (e) {
      throw AuthException(describe(e.code));
    }
  }

  /// Friendly messages for the codes users actually hit.
  static String describe(String code) => switch (code) {
    'invalid-email' => 'That email address looks wrong.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'Use at least 6 characters for the password.',
    'too-many-requests' => 'Too many attempts. Try again in a few minutes.',
    'network-request-failed' => 'No internet connection.',
    _ => 'Something went wrong ($code).',
  };
}
