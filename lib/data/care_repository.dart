import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/resident.dart';

/// All Firestore access for residents, care tasks and vitals.
///
/// Queries are scoped by role so a user only ever *asks* for documents
/// `firestore.rules` would let them read; the rules are the real guard.
class CareRepository {
  CareRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;
  final FirebaseFirestore _db;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _residents =>
      _db.collection('residents');

  Stream<List<Resident>> watchResidents(AppUser user) {
    final query = user.isCaregiver
        ? _residents.where('caregiverIds', arrayContains: user.uid)
        : _residents.where(
            'familyEmails',
            arrayContains: user.email.toLowerCase(),
          );
    return query.snapshots().map(
      (s) =>
          s.docs.map(Resident.fromDoc).toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
    );
  }

  Stream<Resident?> watchResident(String id) => _residents
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? Resident.fromDoc(s) : null);

  Stream<List<CareTask>> watchTodayTasks(String residentId) {
    final now = _now();
    final start = DateTime(now.year, now.month, now.day);
    return _residents
        .doc(residentId)
        .collection('tasks')
        .where('dueAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where(
          'dueAt',
          isLessThan: Timestamp.fromDate(start.add(const Duration(days: 1))),
        )
        .orderBy('dueAt')
        .snapshots()
        .map((s) => s.docs.map(CareTask.fromDoc).toList());
  }

  Stream<List<Vital>> watchVitals(String residentId, {int limit = 30}) =>
      _residents
          .doc(residentId)
          .collection('vitals')
          .orderBy('recordedAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map(Vital.fromDoc).toList());

  Future<void> setTaskDone(
    String residentId,
    CareTask task, {
    required bool done,
    required AppUser by,
  }) {
    _requireCaregiver(by);
    return _residents.doc(residentId).collection('tasks').doc(task.id).update({
      'doneAt': done ? Timestamp.fromDate(_now()) : null,
      'doneBy': done ? by.name : null,
    });
  }

  Future<void> addVital(
    String residentId,
    VitalType type,
    double value, {
    required AppUser by,
  }) {
    _requireCaregiver(by);
    if (value < type.validMin || value > type.validMax) {
      throw ArgumentError(
        '${type.label} must be between ${type.validMin} and ${type.validMax} ${type.unit}',
      );
    }
    return _residents.doc(residentId).collection('vitals').add({
      'type': type.name,
      'value': value,
      'recordedAt': Timestamp.fromDate(_now()),
      'recordedBy': by.name,
      'recordedById': by.uid,
    });
  }

  /// Creates a resident assigned to [caregiver] with today's routine, so a
  /// fresh Firebase project has something to show.
  Future<String> createDemoResident(
    AppUser caregiver, {
    required String name,
    String familyEmail = '',
  }) async {
    _requireCaregiver(caregiver);
    final doc = await _residents.add({
      'name': name,
      'room': '${100 + _now().millisecond % 50}',
      'community': 'Sunrise Community',
      'caregiverIds': [caregiver.uid],
      'familyEmails': [
        if (familyEmail.trim().isNotEmpty) familyEmail.trim().toLowerCase(),
      ],
    });
    final today = _now();
    final batch = _db.batch();
    for (final (hour, title) in const [
      (8, 'Morning medication'),
      (9, 'Breakfast'),
      (11, 'Assisted walk'),
      (13, 'Lunch'),
      (17, 'Evening medication'),
      (20, 'Bedtime check'),
    ]) {
      batch.set(doc.collection('tasks').doc(), {
        'title': title,
        'dueAt': Timestamp.fromDate(
          DateTime(today.year, today.month, today.day, hour),
        ),
        'doneAt': null,
        'doneBy': null,
      });
    }
    await batch.commit();
    return doc.id;
  }

  static void _requireCaregiver(AppUser user) {
    if (!user.isCaregiver) {
      throw StateError('Only caregivers can change care records');
    }
  }
}
