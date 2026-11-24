# `lib/state/`

**Purpose:** Riverpod providers that expose the Firebase SDKs, repositories and live Firestore streams to the UI and router.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`providers.dart`](#providersdart) | Riverpod providers for Firebase, the repositories, the auth state and profile, and the resident, task and vitals streams. |

## `providers.dart`

**Purpose:** Riverpod providers for Firebase, the repositories, the auth state and profile, and the resident, task and vitals streams.

Source: [`lib/state/providers.dart`](../../../lib/state/providers.dart)

- **Uses:** `lib/data/auth_repository.dart`, `lib/data/care_repository.dart`, `lib/models/app_user.dart`, `lib/models/resident.dart`
- **Used by:** `lib/core/router.dart`, `lib/main.dart`, `lib/ui/auth/forgot_password_page.dart`, `lib/ui/auth/sign_in_page.dart`, `lib/ui/auth/sign_up_page.dart`, `lib/ui/residents/add_vital_sheet.dart`, `lib/ui/residents/resident_detail_page.dart`, `lib/ui/residents/residents_page.dart`

### variable `final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance)`

> Riverpod providers for Firebase, the repositories, the auth state and
> profile, and the resident, task and vitals streams.

### variable `final firestoreProvider = …`

### variable `final authRepositoryProvider = …`

### variable `final careRepositoryProvider = …`

### variable `final authStateProvider = …`

### variable `final currentUserProvider = …`

> The signed-in user's profile (with role), or null when signed out.

### variable `final residentsProvider = …`

### variable `final residentProvider = …`

### variable `final tasksProvider = …`

### variable `final vitalsProvider = …`

