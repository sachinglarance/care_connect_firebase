# `lib/ui/auth/`

**Purpose:** Sign-in, sign-up and forgot-password screens, reached through the public routes in lib/core/router.dart.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/ui/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`forgot_password_page.dart`](#forgot_password_pagedart) | Screen that sends a password reset email and shows the same confirmation whether or not the account exists. |
| [`sign_in_page.dart`](#sign_in_pagedart) | Email/password sign-in screen with links to sign-up and forgot-password. |
| [`sign_up_page.dart`](#sign_up_pagedart) | Account creation screen where the user picks a role (caregiver or family) and enters name, email and password. |

## `forgot_password_page.dart`

**Purpose:** Screen that sends a password reset email and shows the same confirmation whether or not the account exists.

Source: [`lib/ui/auth/forgot_password_page.dart`](../../../../lib/ui/auth/forgot_password_page.dart)

- **Uses:** `lib/data/auth_repository.dart`, `lib/state/providers.dart`, `lib/ui/widgets/auth_scaffold.dart`, `lib/ui/widgets/validators.dart`
- **Used by:** `lib/core/router.dart`

### `class ForgotPasswordPage extends ConsumerStatefulWidget`

| Member | Kind | What it does |
|---|---|---|
| `const ForgotPasswordPage({super.key})` | constructor | _(auto)_ Creates an instance. |
| `ConsumerState<ForgotPasswordPage> createState()` | method | _(auto)_ Creates the mutable `State` for this widget. |

### `class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage>`

| Member | Kind | What it does |
|---|---|---|
| `final _form = GlobalKey<FormState>()` | field | Key for the form, used by _submit() to run the field validators. |
| `final _email = TextEditingController()` | field | Holds the email field text. |
| `bool _busy = false` | field | True while the request is running; disables the submit button. |
| `bool _sent = false` | field | Set after a successful request; swaps the form for the "reset link is on its way" message. |
| `String? _error` | field | Friendly error from the last failed attempt, shown above the button; cleared on each submit. |
| `void dispose()` | method | _(auto)_ Releases controllers / listeners when the widget is removed. |
| `Future<void> _submit()` | method | Validates the email, calls sendPasswordReset and sets _sent on success or _error on AuthException. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `sign_in_page.dart`

**Purpose:** Email/password sign-in screen with links to sign-up and forgot-password.

Source: [`lib/ui/auth/sign_in_page.dart`](../../../../lib/ui/auth/sign_in_page.dart)

- **Uses:** `lib/data/auth_repository.dart`, `lib/state/providers.dart`, `lib/ui/widgets/auth_scaffold.dart`, `lib/ui/widgets/validators.dart`
- **Used by:** `lib/core/router.dart`

### `class SignInPage extends ConsumerStatefulWidget`

| Member | Kind | What it does |
|---|---|---|
| `const SignInPage({super.key})` | constructor | _(auto)_ Creates an instance. |
| `ConsumerState<SignInPage> createState()` | method | _(auto)_ Creates the mutable `State` for this widget. |

### `class _SignInPageState extends ConsumerState<SignInPage>`

| Member | Kind | What it does |
|---|---|---|
| `final _form = GlobalKey<FormState>()` | field | Key for the form, used by _submit() to run the field validators. |
| `final _email = TextEditingController()` | field | Holds the email field text. |
| `final _password = TextEditingController()` | field | Holds the password field text. |
| `bool _busy = false` | field | True while the request is running; disables the submit button. |
| `String? _error` | field | Friendly error from the last failed attempt, shown above the button; cleared on each submit. |
| `void dispose()` | method | _(auto)_ Releases controllers / listeners when the widget is removed. |
| `Future<void> _submit()` | method | Validates the form and calls AuthRepository.signIn; on success the router redirects away, on AuthException the message is shown. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `sign_up_page.dart`

**Purpose:** Account creation screen where the user picks a role (caregiver or family) and enters name, email and password.

Source: [`lib/ui/auth/sign_up_page.dart`](../../../../lib/ui/auth/sign_up_page.dart)

- **Uses:** `lib/data/auth_repository.dart`, `lib/models/app_user.dart`, `lib/state/providers.dart`, `lib/ui/widgets/auth_scaffold.dart`, `lib/ui/widgets/validators.dart`
- **Used by:** `lib/core/router.dart`

### `class SignUpPage extends ConsumerStatefulWidget`

| Member | Kind | What it does |
|---|---|---|
| `const SignUpPage({super.key})` | constructor | _(auto)_ Creates an instance. |
| `ConsumerState<SignUpPage> createState()` | method | _(auto)_ Creates the mutable `State` for this widget. |

### `class _SignUpPageState extends ConsumerState<SignUpPage>`

| Member | Kind | What it does |
|---|---|---|
| `final _form = GlobalKey<FormState>()` | field | Key for the form, used by _submit() to run the field validators. |
| `final _name = TextEditingController()` | field | Holds the full name field text. |
| `final _email = TextEditingController()` | field | Holds the email field text. |
| `final _password = TextEditingController()` | field | Holds the password field text. |
| `UserRole _role = UserRole.family` | field | Role chosen in the segmented button (defaults to family); passed to signUp. |
| `bool _busy = false` | field | True while the request is running; disables the submit button. |
| `String? _error` | field | Friendly error from the last failed attempt, shown above the button; cleared on each submit. |
| `void dispose()` | method | _(auto)_ Releases controllers / listeners when the widget is removed. |
| `Future<void> _submit()` | method | Validates the form and calls AuthRepository.signUp with name, email, password and role; shows the AuthException message on failure. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

