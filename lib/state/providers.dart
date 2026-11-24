import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/care_repository.dart';
import '../models/app_user.dart';
import '../models/resident.dart';

// SDK singletons behind providers so tests can swap in fakes.
/// Riverpod providers for Firebase, the repositories, the auth state and
/// profile, and the resident, task and vitals streams.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);
final careRepositoryProvider = Provider(
  (ref) => CareRepository(ref.watch(firestoreProvider)),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// The signed-in user's profile (with role), or null when signed out.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchProfile(user.uid);
});

final residentsProvider = StreamProvider<List<Resident>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(careRepositoryProvider).watchResidents(user);
});

final residentProvider = StreamProvider.family<Resident?, String>(
  (ref, id) => ref.watch(careRepositoryProvider).watchResident(id),
);

final tasksProvider = StreamProvider.autoDispose.family<List<CareTask>, String>(
  (ref, residentId) =>
      ref.watch(careRepositoryProvider).watchTodayTasks(residentId),
);

final vitalsProvider = StreamProvider.autoDispose.family<List<Vital>, String>(
  (ref, residentId) =>
      ref.watch(careRepositoryProvider).watchVitals(residentId),
);
