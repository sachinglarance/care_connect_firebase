import 'package:care_connect_firebase/data/care_repository.dart';
import 'package:care_connect_firebase/models/app_user.dart';
import 'package:care_connect_firebase/state/providers.dart';
import 'package:care_connect_firebase/ui/residents/resident_detail_page.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const caregiver = AppUser(
  uid: 'cg1',
  name: 'Priya',
  email: 'priya@care.com',
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
  late String residentId;

  setUp(() async {
    db = FakeFirebaseFirestore();
    residentId = await CareRepository(
      db,
    ).createDemoResident(caregiver, name: 'Lakshmi', familyEmail: family.email);
  });

  Future<void> pumpAs(WidgetTester tester, AppUser user) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(db),
          currentUserProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              // The page expects the profile to be loaded (the router guarantees it).
              return ref.watch(currentUserProvider).hasValue
                  ? ResidentDetailPage(residentId: residentId)
                  : const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('caregiver can tick tasks and record vitals', (tester) async {
    await pumpAs(tester, caregiver);

    expect(find.text('Lakshmi'), findsOneWidget);
    expect(find.text('0 of 6 completed'), findsOneWidget);
    expect(find.text('Record vital'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('1 of 6 completed'), findsOneWidget);
  });

  testWidgets('family member gets a read-only view', (tester) async {
    await pumpAs(tester, family);

    expect(find.text('Record vital'), findsNothing);
    final box = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile).first,
    );
    expect(box.onChanged, isNull);
  });
}
