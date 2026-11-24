# `lib/ui/widgets/`

**Purpose:** Shared building blocks for the auth screens: the common page layout and form field validators.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/ui/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`auth_scaffold.dart`](#auth_scaffolddart) | Shared centered, width-limited layout with logo and title used by the auth screens. |
| [`validators.dart`](#validatorsdart) | Form field validators for email, password length and required fields. |

## `auth_scaffold.dart`

**Purpose:** Shared centered, width-limited layout with logo and title used by the auth screens.

Source: [`lib/ui/widgets/auth_scaffold.dart`](../../../../lib/ui/widgets/auth_scaffold.dart)

- **Uses:** —
- **Used by:** `lib/ui/auth/forgot_password_page.dart`, `lib/ui/auth/sign_in_page.dart`, `lib/ui/auth/sign_up_page.dart`

### `class AuthScaffold extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const AuthScaffold({super.key, required this.title, required this.children})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String title` | field | _(auto)_ Value passed in by the parent widget. |
| `final List<Widget> children` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `validators.dart`

**Purpose:** Form field validators for email, password length and required fields.

Source: [`lib/ui/widgets/validators.dart`](../../../../lib/ui/widgets/validators.dart)

- **Uses:** —
- **Used by:** `lib/ui/auth/forgot_password_page.dart`, `lib/ui/auth/sign_in_page.dart`, `lib/ui/auth/sign_up_page.dart`

### `abstract final class Validators`

| Member | Kind | What it does |
|---|---|---|
| `static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')` | field | Loose email pattern: something@something.something with no spaces. |
| `static String? email(String? v)` | method | Returns "Enter a valid email" unless the trimmed value matches the email pattern, else null. |
| `static String? password(String? v)` | method | Returns "At least 6 characters" for null or shorter passwords (matches Firebase's minimum), else null. |
| `static String? required(String? v, [String field = 'This field'])` | method | Returns "<field> is required" when the value is null or blank, else null. |

