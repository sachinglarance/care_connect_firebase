# CareConnect: role-based caregiver and family app (Flutter + Firebase)

A care-coordination app for assisted living. **Caregivers** complete each resident's daily
care checklist and record vitals. **Family members** follow their loved one's day in real
time, and get a **push notification** when new vitals are recorded, with a warning when a
value is outside the normal range.

## Features

- **Firebase Auth**: email and password sign-up with a role (Caregiver or Family), sign-in,
  and **Forgot Password**. The reset screen shows the same message whether or not the
  account exists, so it cannot be used to discover registered emails.
- **Role-based access**, enforced in two places:
  - the client asks only for data it is allowed to see (`CareRepository` scopes every query by role)
  - **`firestore.rules`** is the real security boundary. Caregivers see only residents assigned
    to them. Family members see residents linked to their email, and only to read. Tasks can only
    be ticked off, not rewritten. Vitals are an append-only audit trail.
- **Real-time Firestore streams**: the checklist progress and vitals update live on the family's phone
- **Vitals validation**: impossible values (typos) are rejected, and abnormal values are highlighted
- **FCM push**: the device token is saved for each user and refreshed when FCM rotates it.
  Foreground messages appear as an in-app banner, and a background handler covers the rest.
- **Cloud Function** (`functions/index.js`): when a vital is recorded, it sends a notification to
  the resident's family and removes stale tokens
- **Sentry**: uncaught errors, plus a Riverpod `ProviderObserver` that reports any provider
  failure (for example a Firestore permission error) with the provider name. The user's id and
  role are attached as context. The DSN is passed with `--dart-define`, so it is never committed.
- `go_router` redirects based on both the auth state and the profile (role) document

## Architecture

```
lib/
├── models/          # AppUser + UserRole, Resident, CareTask, Vital + VitalType ranges
├── data/            # AuthRepository, CareRepository (all Firebase access)
├── state/           # Riverpod providers; the SDK singletons can be overridden in tests
├── core/            # router, push notifications, Sentry provider observer
└── ui/              # auth pages, residents list, resident detail (tasks/vitals), add-vital sheet
firestore.rules      # role-based security rules
functions/           # Cloud Function: notify family on new vitals
```

### Data model

```
users/{uid}                      name, email, role, fcmTokens[]
residents/{rid}                  name, room, community, caregiverIds[], familyEmails[]
residents/{rid}/tasks/{tid}      title, dueAt, doneAt, doneBy
residents/{rid}/vitals/{vid}     type, value, recordedAt, recordedBy, recordedById
```

## Tests

```bash
flutter test
```

They run with no Firebase project, using `fake_cloud_firestore` and `firebase_auth_mocks`.

- **CareRepository**: role-scoped queries for caregivers and family (case-insensitive email), demo data, task check and uncheck, family write attempts rejected, vitals validation and the abnormal flag
- **AuthRepository**: the profile and role are written at sign-up, error codes become friendly messages, the password reset does not reveal accounts, FCM tokens are not duplicated
- **Widget**: the same screen is interactive for a caregiver and read-only for a family member

## Setup

```bash
# 1. Connect your Firebase project (this generates lib/firebase_options.dart)
dart pub global activate flutterfire_cli
flutterfire configure

# 2. Enable Email/Password sign-in in the Firebase console, then deploy the rules and function
firebase deploy --only firestore:rules,functions

# 3. Run the app (the Sentry DSN is optional)
flutter run --dart-define=SENTRY_DSN=https://<key>@o0.ingest.sentry.io/<project>
```

Until step 1 is done, the app shows a "Firebase is not configured" screen instead of crashing.

To try it, sign up as a **Caregiver**, then tap **Add resident** and enter a family member's
email. Sign up with that email as **Family** on a second device and watch the checklist update
live.

> **Production note:** in this demo users pick their role at sign-up, which keeps it easy to try.
> In a real deployment the caregiver role would be granted by an admin, for example through
> Firebase custom claims set from a Cloud Function, and the rules would check
> `request.auth.token.role`.

**Tech:** Flutter · Dart 3 · Firebase Auth · Cloud Firestore · FCM · Cloud Functions (Node 20) · Security Rules · Sentry · Riverpod 3 · go_router · fake_cloud_firestore
