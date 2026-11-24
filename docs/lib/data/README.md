# `lib/data/`

**Purpose:** Repositories that wrap Firebase Auth and Firestore; the only layer that talks to Firebase, used through the providers in lib/state.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`auth_repository.dart`](#auth_repositorydart) | Firebase Auth and `users/{uid}` profile access (sign in/up/out, password reset, FCM tokens) with friendly error messages. |
| [`care_repository.dart`](#care_repositorydart) | All Firestore access for residents, care tasks and vitals. |

## `auth_repository.dart`

**Purpose:** Firebase Auth and `users/{uid}` profile access (sign in/up/out, password reset, FCM tokens) with friendly error messages.

Source: [`lib/data/auth_repository.dart`](../../../lib/data/auth_repository.dart)

- **Uses:** `lib/models/app_user.dart`
- **Used by:** `lib/state/providers.dart`, `lib/ui/auth/forgot_password_page.dart`, `lib/ui/auth/sign_in_page.dart`, `lib/ui/auth/sign_up_page.dart`

### `class AuthException implements Exception`

| Member | Kind | What it does |
|---|---|---|
| `const AuthException(this.message)` | constructor | _(auto)_ Creates an instance. |
| `final String message` | field | User-facing error text, produced by AuthRepository.describe() and shown on the auth screens. |
| `String toString()` | method | Returns just the message, so printing the exception shows the friendly text. |

### `class AuthRepository`

| Member | Kind | What it does |
|---|---|---|
| `AuthRepository(this._auth, this._db)` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final FirebaseAuth _auth` | field | _(auto)_ Injected dependency / private state. |
| `final FirebaseFirestore _db` | field | _(auto)_ Injected dependency / private state. |
| `CollectionReference<Map<String, dynamic>> get _users` | getter | The Firestore `users` collection that holds one profile doc per uid. |
| `Stream<User?> authStateChanges()` | method | Streams the Firebase Auth user (null when signed out); feeds authStateProvider. |
| `Stream<AppUser?> watchProfile(String uid)` | method | Streams the `users/{uid}` doc as an AppUser, or null while it doesn't exist (e.g. just after sign-up); feeds currentUserProvider. |
| `Future<void> signIn(String email, String password)` | method | Signs in with email (trimmed) and password; Firebase errors are rethrown as AuthException. Called by SignInPage. |
| `Future<void> signUp({ required String name, required String email, required String password, required UserRole role, })` | method | Creates the account and the `users/{uid}` profile that holds the role. |
| `Future<void> sendPasswordReset(String email)` | method | Treats "no such user" as success so the reset screen can't be used to check which emails are registered. |
| `Future<void> saveFcmToken(String uid, String token)` | method | Adds the device token to the user doc's `fcmTokens` array (merge, no duplicates); called when PushNotifications receives a token. |
| `Future<void> signOut()` | method | Signs out of Firebase Auth; the router then redirects to /sign-in. Called from the residents page app bar. |
| `Future<void> _guard(Future<void> Function() body)` | method | Runs an auth call and converts any FirebaseAuthException into an AuthException with a friendly message from describe(). |
| `static String describe(String code)` | method | Friendly messages for the codes users actually hit. |

## `care_repository.dart`

**Purpose:** All Firestore access for residents, care tasks and vitals.

Source: [`lib/data/care_repository.dart`](../../../lib/data/care_repository.dart)

- **Uses:** `lib/models/app_user.dart`, `lib/models/resident.dart`
- **Used by:** `lib/state/providers.dart`

### `class CareRepository`

> All Firestore access for residents, care tasks and vitals.
>
> Queries are scoped by role so a user only ever *asks* for documents
> `firestore.rules` would let them read; the rules are the real guard.

| Member | Kind | What it does |
|---|---|---|
| `CareRepository(this._db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final FirebaseFirestore _db` | field | _(auto)_ Injected dependency / private state. |
| `final DateTime Function() _now` | field | Clock used for "today", task completion and vital timestamps; defaults to DateTime.now and can be replaced in tests. |
| `CollectionReference<Map<String, dynamic>> get _residents` | getter | The Firestore `residents` collection; tasks and vitals are subcollections of each resident doc. |
| `Stream<List<Resident>> watchResidents(AppUser user)` | method | Streams residents the user may see: caregivers by `caregiverIds` containing their uid, family by `familyEmails` containing their lowercased email; sorted by name. |
| `Stream<Resident?> watchResident(String id)` | method | Streams one resident doc, or null if it doesn't exist; feeds residentProvider for the detail page. |
| `Stream<List<CareTask>> watchTodayTasks(String residentId)` | method | Streams the resident's tasks due between local midnight today and midnight tomorrow, ordered by due time. |
| `Stream<List<Vital>> watchVitals(String residentId, {int limit = 30})` | method | Streams the most recent vitals (newest first, up to limit) for the resident's vitals tab. |
| `Future<void> setTaskDone(String residentId, CareTask task, { required bool done, required AppUser by, })` | method | Marks a task done (sets doneAt to now and doneBy to the caregiver's name) or clears both when undone; throws StateError for non-caregivers. |
| `Future<void> addVital(String residentId, VitalType type, double value, { required AppUser by, })` | method | Adds a vital reading with timestamp and recorder; throws StateError for non-caregivers and ArgumentError when the value is outside the type's valid range. |
| `Future<String> createDemoResident(AppUser caregiver, { required String name, String familyEmail = '', })` | method | Creates a resident assigned to [caregiver] with today's routine, so a fresh Firebase project has something to show. |
| `static void _requireCaregiver(AppUser user)` | method | Throws StateError unless the user is a caregiver; guards every write method. |

