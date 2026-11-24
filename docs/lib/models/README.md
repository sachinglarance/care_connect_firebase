# `lib/models/`

**Purpose:** Plain immutable domain models (users, residents, care tasks, vitals) that parse themselves from Firestore maps and documents.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`app_user.dart`](#app_userdart) | The signed-in user's profile model and the caregiver/family role enum. |
| [`resident.dart`](#residentdart) | Care models read from Firestore: Resident, CareTask, Vital and the VitalType enum with its normal and valid ranges. |

## `app_user.dart`

**Purpose:** The signed-in user's profile model and the caregiver/family role enum.

Source: [`lib/models/app_user.dart`](../../../lib/models/app_user.dart)

- **Uses:** —
- **Used by:** `lib/data/auth_repository.dart`, `lib/data/care_repository.dart`, `lib/state/providers.dart`, `lib/ui/auth/sign_up_page.dart`, `lib/ui/residents/add_vital_sheet.dart`, `lib/ui/residents/resident_detail_page.dart`, `lib/ui/residents/residents_page.dart`

### `enum UserRole`

| Member | Kind | What it does |
|---|---|---|
| `caregiver('Caregiver')` | value | _(auto)_ Enum value. |
| `family('Family member')` | value | _(auto)_ Enum value. |
| `const UserRole(this.label)` | constructor | _(auto)_ Creates an instance. |
| `final String label` | field | Human-readable role name shown in the sign-up role picker and the residents page chip. |

### `class AppUser`

| Member | Kind | What it does |
|---|---|---|
| `const AppUser({ required this.uid, required this.name, required this.email, required this.role, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `factory AppUser.fromMap(String uid, Map<String, dynamic> map)` | constructor | _(auto)_ Creates an instance. |
| `final String uid` | field | Firebase Auth user id; also the `users` doc id. |
| `final String name` | field | Display name; recorded as doneBy/recordedBy on care records. |
| `final String email` | field | Email address; family access to residents is matched on its lowercased form. |
| `final UserRole role` | field | Caregiver or family; decides which residents are queried and whether the user can edit records. Unknown values parse as family. |
| `bool get isCaregiver` | getter | True when the role is caregiver; used to show write actions and to guard repository writes. |
| `Map<String, dynamic> toMap()` | method | Serialises name, lowercased email and role name for the `users/{uid}` doc written at sign-up. |

## `resident.dart`

**Purpose:** Care models read from Firestore: Resident, CareTask, Vital and the VitalType enum with its normal and valid ranges.

Source: [`lib/models/resident.dart`](../../../lib/models/resident.dart)

- **Uses:** —
- **Used by:** `lib/data/care_repository.dart`, `lib/state/providers.dart`, `lib/ui/residents/add_vital_sheet.dart`, `lib/ui/residents/resident_detail_page.dart`

### `class Resident`

| Member | Kind | What it does |
|---|---|---|
| `const Resident({ required this.id, required this.name, required this.room, required this.community, required this.caregiverIds, required this.familyEmails, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `factory Resident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)` | constructor | _(auto)_ Creates an instance. |
| `final String id` | field | Firestore document id of the resident; used in the /residents/:id route. |
| `final String name` | field | Resident's name, shown in the list and detail app bar. |
| `final String room` | field | Room number (empty string if missing). |
| `final String community` | field | Care community name (empty string if missing). |
| `final List<String> caregiverIds` | field | Access control lists; mirrored by `firestore.rules`. |
| `final List<String> familyEmails` | field | Lowercased emails of family members allowed to view this resident; matched by watchResidents for family users. |

### `class CareTask`

| Member | Kind | What it does |
|---|---|---|
| `const CareTask({ required this.id, required this.title, required this.dueAt, this.doneAt, this.doneBy, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `factory CareTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)` | constructor | _(auto)_ Creates an instance. |
| `final String id` | field | Firestore document id of the task within the resident's `tasks` subcollection. |
| `final String title` | field | Task name, e.g. "Morning medication". |
| `final DateTime dueAt` | field | When the task is due; used for today's query, ordering and overdue checks. |
| `final DateTime? doneAt` | field | When it was completed, or null if still open. |
| `final String? doneBy` | field | Display name of the caregiver who completed it. |
| `bool get isDone` | getter | True when doneAt is set. |
| `bool isOverdue(DateTime now)` | method | True when the task is not done and its due time is before now; the detail page shows it in the error color. |

### `enum VitalType`

| Member | Kind | What it does |
|---|---|---|
| `heartRate('Heart rate', 'bpm', 50, 110, 30, 220)` | value | _(auto)_ Enum value. |
| `temperature('Temperature', '°C', 36.1, 37.8, 30, 45)` | value | _(auto)_ Enum value. |
| `oxygen('SpO₂', '%', 94, 100, 50, 100)` | value | _(auto)_ Enum value. |
| `systolic('Systolic BP', 'mmHg', 90, 140, 50, 260)` | value | _(auto)_ Enum value. |
| `const VitalType(this.label, this.unit, this.normalMin, this.normalMax, this.validMin, this.validMax)` | constructor | _(auto)_ Creates an instance. |
| `final String label` | field | Display name, e.g. "Heart rate". |
| `final String unit` | field | Measurement unit shown next to values, e.g. "bpm". |
| `final double normalMin` | field | Lower bound of the normal range; readings below it are flagged abnormal. |
| `final double normalMax` | field | Upper bound of the normal range; readings above it are flagged abnormal. |
| `final double validMin` | field | Physiologically possible range: anything outside is a typo. |
| `final double validMax` | field | Upper bound of the possible range; addVital rejects values above it. |

### `class Vital`

| Member | Kind | What it does |
|---|---|---|
| `const Vital({ required this.id, required this.type, required this.value, required this.recordedAt, required this.recordedBy, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `factory Vital.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)` | constructor | _(auto)_ Creates an instance. |
| `final String id` | field | Firestore document id within the resident's `vitals` subcollection. |
| `final VitalType type` | field | Which vital this reading is; parsed from the stored enum name. |
| `final double value` | field | The measured value in the type's unit. |
| `final DateTime recordedAt` | field | When the reading was saved; vitals are listed newest first by this. |
| `final String recordedBy` | field | Name of the caregiver who recorded it (empty if missing). |
| `bool get isAbnormal` | getter | True when the value is outside the type's normal range; the vitals tab shows it in red with a warning icon. |

