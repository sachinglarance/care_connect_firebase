# `lib/`

**Purpose:** Source root of the CareConnect Flutter app: entry point, Firebase config, and the core/data/models/state/ui layers.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

## Folders

- [`core/`](core/README.md) — App-wide infrastructure used by main.dart: GoRouter setup with auth redirects, push notifications (FCM) and Sentry error reporting.
- [`data/`](data/README.md) — Repositories that wrap Firebase Auth and Firestore; the only layer that talks to Firebase, used through the providers in lib/state.
- [`models/`](models/README.md) — Plain immutable domain models (users, residents, care tasks, vitals) that parse themselves from Firestore maps and documents.
- [`state/`](state/README.md) — Riverpod providers that expose the Firebase SDKs, repositories and live Firestore streams to the UI and router.
- [`ui/`](ui/README.md) — All screens and widgets: auth pages, resident list/detail pages and shared form widgets.

## Files

| File | Purpose |
|---|---|
| [`firebase_options.dart`](#firebase_optionsdart) | Firebase project settings per platform (placeholders until `flutterfire configure` is run) plus a check for whether they are configured. |
| [`main.dart`](#maindart) | App entry point: initialises Firebase and Sentry, then runs the root MaterialApp.router (or a setup-required screen when Firebase is not configured). |

## `firebase_options.dart`

**Purpose:** Firebase project settings per platform (placeholders until `flutterfire configure` is run) plus a check for whether they are configured.

Source: [`lib/firebase_options.dart`](../../lib/firebase_options.dart)

- **Uses:** —
- **Used by:** `lib/core/push_notifications.dart`, `lib/main.dart`

### `class DefaultFirebaseOptions`

| Member | Kind | What it does |
|---|---|---|
| `static bool get isConfigured` | getter | False until `flutterfire configure` has been run; main() then shows setup instructions instead of crashing. |
| `static FirebaseOptions get currentPlatform` | getter | Returns the iOS options on iOS and the Android options everywhere else; passed to Firebase.initializeApp in main() and the background push handler. |
| `static const android = …` | field | _(auto)_ Constant; long value, see the source. |
| `static const ios = …` | field | _(auto)_ Constant; long value, see the source. |

## `main.dart`

**Purpose:** App entry point: initialises Firebase and Sentry, then runs the root MaterialApp.router (or a setup-required screen when Firebase is not configured).

Source: [`lib/main.dart`](../../lib/main.dart)

- **Uses:** `lib/core/error_reporting.dart`, `lib/core/push_notifications.dart`, `lib/core/router.dart`, `lib/firebase_options.dart`, `lib/state/providers.dart`
- **Used by:** — (entry point, generated-code target, or unused)

### function `Future<void> main()`

### `class CareConnectApp extends ConsumerStatefulWidget`

| Member | Kind | What it does |
|---|---|---|
| `const CareConnectApp({super.key})` | constructor | _(auto)_ Creates an instance. |
| `ConsumerState<CareConnectApp> createState()` | method | _(auto)_ Creates the mutable `State` for this widget. |

### `class _CareConnectAppState extends ConsumerState<CareConnectApp>`

| Member | Kind | What it does |
|---|---|---|
| `final _messenger = GlobalKey<ScaffoldMessengerState>()` | field | Key for the app's ScaffoldMessenger so foreground push messages can show a SnackBar from outside any page. |
| `final _push = PushNotifications()` | field | Push notification helper; started in initState once a user profile loads and stopped in dispose(). |
| `void initState()` | method | _(auto)_ One-time setup when the widget is inserted. |
| `void dispose()` | method | _(auto)_ Releases controllers / listeners when the widget is removed. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

### `class _SetupRequiredApp extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const _SetupRequiredApp()` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

