import 'package:care_connect_firebase/data/auth_repository.dart';
import 'package:care_connect_firebase/models/app_user.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  test('sign-up creates a profile document with the chosen role', () async {
    final auth = MockFirebaseAuth();
    final db = FakeFirebaseFirestore();
    final repo = AuthRepository(auth, db);

    await repo.signUp(
      name: ' Priya ',
      email: 'Priya@Care.com',
      password: 'secret1',
      role: UserRole.caregiver,
    );

    final uid = auth.currentUser!.uid;
    final profile = await repo.watchProfile(uid).first;
    expect(profile!.role, UserRole.caregiver);
    expect(profile.name, 'Priya');
    expect(profile.email, 'priya@care.com');
  });

  test('Firebase error codes become friendly messages', () async {
    final auth = MockFirebaseAuth();
    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    final repo = AuthRepository(auth, FakeFirebaseFirestore());

    await expectLater(
      repo.signIn('a@b.com', 'wrong'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Incorrect email or password.',
        ),
      ),
    );
  });

  test('password reset does not reveal whether an account exists', () async {
    final auth = MockFirebaseAuth();
    whenCalling(Invocation.method(#sendPasswordResetEmail, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'user-not-found'));
    final repo = AuthRepository(auth, FakeFirebaseFirestore());

    await expectLater(repo.sendPasswordReset('nobody@x.com'), completes);
  });

  test('FCM tokens are added without duplicates', () async {
    final db = FakeFirebaseFirestore();
    final repo = AuthRepository(MockFirebaseAuth(), db);

    await repo.saveFcmToken('u1', 't1');
    await repo.saveFcmToken('u1', 't1');
    await repo.saveFcmToken('u1', 't2');

    final doc = await db.collection('users').doc('u1').get();
    expect(doc.data()!['fcmTokens'], ['t1', 't2']);
  });
}
