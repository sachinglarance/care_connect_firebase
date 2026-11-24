import 'package:care_connect_firebase/data/care_repository.dart';
import 'package:care_connect_firebase/models/app_user.dart';
import 'package:care_connect_firebase/models/resident.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

const caregiver = AppUser(
  uid: 'cg1',
  name: 'Priya',
  email: 'priya@care.com',
  role: UserRole.caregiver,
);
const otherCaregiver = AppUser(
  uid: 'cg2',
  name: 'Arun',
  email: 'arun@care.com',
  role: UserRole.caregiver,
);
const family = AppUser(
  uid: 'f1',
  name: 'Meena',
  email: 'meena@mail.com',
  role: UserRole.family,
);

void main() {
  late FakeFirebaseFirestore db;
  late CareRepository repo;
  final now = DateTime(2026, 11, 23, 10);

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = CareRepository(db, clock: () => now);
  });

  test('caregivers see only residents assigned to them', () async {
    await repo.createDemoResident(caregiver, name: 'Lakshmi');
    await repo.createDemoResident(otherCaregiver, name: 'Joseph');

    final mine = await repo.watchResidents(caregiver).first;

    expect(mine.map((r) => r.name), ['Lakshmi']);
  });

  test(
    'family members see residents linked to their email, case-insensitively',
    () async {
      await repo.createDemoResident(
        caregiver,
        name: 'Lakshmi',
        familyEmail: ' Meena@Mail.com ',
      );
      await repo.createDemoResident(caregiver, name: 'Joseph');

      final visible = await repo.watchResidents(family).first;

      expect(visible.map((r) => r.name), ['Lakshmi']);
    },
  );

  test("demo resident gets today's six tasks in time order", () async {
    final id = await repo.createDemoResident(caregiver, name: 'Lakshmi');

    final tasks = await repo.watchTodayTasks(id).first;

    expect(tasks, hasLength(6));
    expect(tasks.first.title, 'Morning medication');
    expect(tasks.where((t) => t.isOverdue(now)).map((t) => t.title), [
      'Morning medication',
      'Breakfast',
    ]);
  });

  test('completing a task records who did it; un-checking clears it', () async {
    final id = await repo.createDemoResident(caregiver, name: 'Lakshmi');
    final task = (await repo.watchTodayTasks(id).first).first;

    await repo.setTaskDone(id, task, done: true, by: caregiver);
    var updated = (await repo.watchTodayTasks(id).first).first;
    expect(updated.isDone, isTrue);
    expect(updated.doneBy, 'Priya');

    await repo.setTaskDone(id, updated, done: false, by: caregiver);
    updated = (await repo.watchTodayTasks(id).first).first;
    expect(updated.isDone, isFalse);
  });

  test('family members cannot change care records', () async {
    final id = await repo.createDemoResident(
      caregiver,
      name: 'Lakshmi',
      familyEmail: family.email,
    );
    final task = (await repo.watchTodayTasks(id).first).first;

    expect(
      () => repo.setTaskDone(id, task, done: true, by: family),
      throwsStateError,
    );
    expect(
      () => repo.addVital(id, VitalType.heartRate, 80, by: family),
      throwsStateError,
    );
  });

  test(
    'vitals: impossible values are rejected, abnormal ones flagged',
    () async {
      final id = await repo.createDemoResident(caregiver, name: 'Lakshmi');

      expect(
        () => repo.addVital(id, VitalType.temperature, 98.6, by: caregiver),
        throwsArgumentError,
      );

      await repo.addVital(id, VitalType.oxygen, 91, by: caregiver);
      await repo.addVital(id, VitalType.heartRate, 72, by: caregiver);
      final vitals = await repo.watchVitals(id).first;

      expect(vitals, hasLength(2));
      expect(
        {for (final v in vitals) v.type: v.isAbnormal},
        {VitalType.oxygen: true, VitalType.heartRate: false},
      );
      expect(vitals.first.recordedBy, 'Priya');
    },
  );
}
