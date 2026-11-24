import 'package:cloud_firestore/cloud_firestore.dart';

class Resident {
  const Resident({
    required this.id,
    required this.name,
    required this.room,
    required this.community,
    required this.caregiverIds,
    required this.familyEmails,
  });

  factory Resident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Resident(
      id: doc.id,
      name: d['name'] as String,
      room: d['room'] as String? ?? '',
      community: d['community'] as String? ?? '',
      caregiverIds: List<String>.from(d['caregiverIds'] as List? ?? const []),
      familyEmails: List<String>.from(d['familyEmails'] as List? ?? const []),
    );
  }

  final String id;
  final String name;
  final String room;
  final String community;

  /// Access control lists; mirrored by `firestore.rules`.
  final List<String> caregiverIds;
  final List<String> familyEmails;
}

class CareTask {
  const CareTask({
    required this.id,
    required this.title,
    required this.dueAt,
    this.doneAt,
    this.doneBy,
  });

  factory CareTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return CareTask(
      id: doc.id,
      title: d['title'] as String,
      dueAt: (d['dueAt'] as Timestamp).toDate(),
      doneAt: (d['doneAt'] as Timestamp?)?.toDate(),
      doneBy: d['doneBy'] as String?,
    );
  }

  final String id;
  final String title;
  final DateTime dueAt;
  final DateTime? doneAt;

  /// Display name of the caregiver who completed it.
  final String? doneBy;

  bool get isDone => doneAt != null;
  bool isOverdue(DateTime now) => !isDone && dueAt.isBefore(now);
}

enum VitalType {
  heartRate('Heart rate', 'bpm', 50, 110, 30, 220),
  temperature('Temperature', '°C', 36.1, 37.8, 30, 45),
  oxygen('SpO₂', '%', 94, 100, 50, 100),
  systolic('Systolic BP', 'mmHg', 90, 140, 50, 260);

  const VitalType(
    this.label,
    this.unit,
    this.normalMin,
    this.normalMax,
    this.validMin,
    this.validMax,
  );
  final String label;
  final String unit;
  final double normalMin;
  final double normalMax;

  /// Physiologically possible range: anything outside is a typo.
  final double validMin;
  final double validMax;
}

class Vital {
  const Vital({
    required this.id,
    required this.type,
    required this.value,
    required this.recordedAt,
    required this.recordedBy,
  });

  factory Vital.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Vital(
      id: doc.id,
      type: VitalType.values.byName(d['type'] as String),
      value: (d['value'] as num).toDouble(),
      recordedAt: (d['recordedAt'] as Timestamp).toDate(),
      recordedBy: d['recordedBy'] as String? ?? '',
    );
  }

  final String id;
  final VitalType type;
  final double value;
  final DateTime recordedAt;
  final String recordedBy;

  bool get isAbnormal => value < type.normalMin || value > type.normalMax;
}
