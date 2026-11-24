# `lib/core/`

**Purpose:** App-wide infrastructure used by main.dart: GoRouter setup with auth redirects, push notifications (FCM) and Sentry error reporting.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`error_reporting.dart`](#error_reportingdart) | Sentry error reporting: a provider observer that reports failed providers, and the DSN read from `--dart-define`. |
| [`push_notifications.dart`](#push_notificationsdart) | FCM push setup: permission, token registration and foreground messages, plus the background message handler. |
| [`router.dart`](#routerdart) | GoRouter configuration as a provider: all app routes and the auth/profile-based redirect logic. |

## `error_reporting.dart`

**Purpose:** Sentry error reporting: a provider observer that reports failed providers, and the DSN read from `--dart-define`.

Source: [`lib/core/error_reporting.dart`](../../../lib/core/error_reporting.dart)

- **Uses:** —
- **Used by:** `lib/main.dart`

### `final class SentryProviderObserver extends ProviderObserver`

> Sentry error reporting: a provider observer that reports failed providers,
> and the DSN read from `--dart-define`.
>
> Reports every provider that fails (e.g. a Firestore permission error) to
> Sentry with the provider name attached.

| Member | Kind | What it does |
|---|---|---|
| `const SentryProviderObserver()` | constructor | _(auto)_ Creates an instance. |
| `void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace)` | method | Called by Riverpod when any provider throws; sends the error and stack trace to Sentry tagged with the provider name (or its runtime type if unnamed). |

### variable `const sentryDsn = String.fromEnvironment('SENTRY_DSN')`

> DSN comes from `--dart-define=SENTRY_DSN=...` so it never lives in git.
> With no DSN, Sentry is a no-op.

## `push_notifications.dart`

**Purpose:** FCM push setup: permission, token registration and foreground messages, plus the background message handler.

Source: [`lib/core/push_notifications.dart`](../../../lib/core/push_notifications.dart)

- **Uses:** `lib/firebase_options.dart`
- **Used by:** `lib/main.dart`

### function `Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message)`

> FCM push setup: permission, token registration and foreground messages, plus
> the background message handler.
>
> Runs in a background isolate when a push arrives and the app isn't in the
> foreground. The OS shows `notification` payloads itself.

### `class PushNotifications`

| Member | Kind | What it does |
|---|---|---|
| `PushNotifications([FirebaseMessaging? messaging]) : _messaging = messaging ?? FirebaseMessaging.instance` | constructor | _(auto)_ Creates an instance. |
| `final FirebaseMessaging _messaging` | field | _(auto)_ Injected dependency / private state. |
| `StreamSubscription<String>? _tokenSub` | field | Subscription to FCM token registrations set by start(); each token is passed to saveToken. Cancelled in stop(). |
| `StreamSubscription<RemoteMessage>? _messageSub` | field | Subscription to foreground push messages set by start(); forwards each message to onForeground. Cancelled in stop(). |
| `Future<void> start({ required Future<void> Function(String token) saveToken, required void Function(RemoteMessage message) onForeground, })` | method | Asks for permission, stores the device token for this user and keeps it fresh. [onForeground] lets the UI show an in-app banner. |
| `Future<void> stop()` | method | Cancels the token and foreground-message subscriptions; called from the root app state's dispose(). |

## `router.dart`

**Purpose:** GoRouter configuration as a provider: all app routes and the auth/profile-based redirect logic.

Source: [`lib/core/router.dart`](../../../lib/core/router.dart)

- **Uses:** `lib/state/providers.dart`, `lib/ui/auth/forgot_password_page.dart`, `lib/ui/auth/sign_in_page.dart`, `lib/ui/auth/sign_up_page.dart`, `lib/ui/residents/resident_detail_page.dart`, `lib/ui/residents/residents_page.dart`
- **Used by:** `lib/main.dart`

### variable `const _publicRoutes = {'/sign-in', '/sign-up', '/forgot-password'}`

### variable `final routerProvider = …`

