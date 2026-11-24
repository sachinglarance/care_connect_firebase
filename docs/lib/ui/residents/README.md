# `lib/ui/residents/`

**Purpose:** Resident list, resident detail (today's tasks and vitals tabs) and the record-vital bottom sheet.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/ui/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`add_vital_sheet.dart`](#add_vital_sheetdart) | Bottom sheet where a caregiver picks a vital type, enters a value and saves it for a resident. |
| [`resident_detail_page.dart`](#resident_detail_pagedart) | Resident detail screen with a today's-care checklist tab, a vitals history tab and a record-vital button for caregivers. |
| [`residents_page.dart`](#residents_pagedart) | Home screen listing the residents the user can see, with sign-out and (for caregivers) an add-resident dialog. |

## `add_vital_sheet.dart`

**Purpose:** Bottom sheet where a caregiver picks a vital type, enters a value and saves it for a resident.

Source: [`lib/ui/residents/add_vital_sheet.dart`](../../../../lib/ui/residents/add_vital_sheet.dart)

- **Uses:** `lib/models/app_user.dart`, `lib/models/resident.dart`, `lib/state/providers.dart`
- **Used by:** `lib/ui/residents/resident_detail_page.dart`

### `class AddVitalSheet extends ConsumerStatefulWidget`

| Member | Kind | What it does |
|---|---|---|
| `const AddVitalSheet({ super.key, required this.residentId, required this.user, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String residentId` | field | _(auto)_ Value passed in by the parent widget. |
| `final AppUser user` | field | _(auto)_ Value passed in by the parent widget. |
| `ConsumerState<AddVitalSheet> createState()` | method | _(auto)_ Creates the mutable `State` for this widget. |

### `class _AddVitalSheetState extends ConsumerState<AddVitalSheet>`

| Member | Kind | What it does |
|---|---|---|
| `final _value = TextEditingController()` | field | Holds the typed vital value. |
| `VitalType _type = VitalType.heartRate` | field | Vital type selected with the choice chips; drives the field label and normal-range hint. |
| `String? _error` | field | Error shown under the value field ("Enter a number" or the out-of-range message). |
| `void dispose()` | method | _(auto)_ Releases controllers / listeners when the widget is removed. |
| `Future<void> _save()` | method | Parses the value, calls CareRepository.addVital and closes the sheet; shows an error for non-numbers or out-of-range values (ArgumentError). |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `resident_detail_page.dart`

**Purpose:** Resident detail screen with a today's-care checklist tab, a vitals history tab and a record-vital button for caregivers.

Source: [`lib/ui/residents/resident_detail_page.dart`](../../../../lib/ui/residents/resident_detail_page.dart)

- **Uses:** `lib/models/app_user.dart`, `lib/models/resident.dart`, `lib/state/providers.dart`, `lib/ui/residents/add_vital_sheet.dart`
- **Used by:** `lib/core/router.dart`

### `class ResidentDetailPage extends ConsumerWidget`

| Member | Kind | What it does |
|---|---|---|
| `const ResidentDetailPage({super.key, required this.residentId})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String residentId` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context, WidgetRef ref)` | method | _(auto)_ Builds this widget's UI. |

### `class _TasksTab extends ConsumerWidget`

| Member | Kind | What it does |
|---|---|---|
| `const _TasksTab({required this.residentId, required this.user})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String residentId` | field | _(auto)_ Value passed in by the parent widget. |
| `final AppUser user` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context, WidgetRef ref)` | method | _(auto)_ Builds this widget's UI. |

### `class _VitalsTab extends ConsumerWidget`

| Member | Kind | What it does |
|---|---|---|
| `const _VitalsTab({required this.residentId})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String residentId` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context, WidgetRef ref)` | method | _(auto)_ Builds this widget's UI. |
| `static String _format(double v)` | method | Formats a value with no decimals when it is whole, otherwise one decimal place. |
| `static IconData _icon(VitalType t)` | method | Picks the list icon for each vital type (heart, thermometer, air, blood). |

## `residents_page.dart`

**Purpose:** Home screen listing the residents the user can see, with sign-out and (for caregivers) an add-resident dialog.

Source: [`lib/ui/residents/residents_page.dart`](../../../../lib/ui/residents/residents_page.dart)

- **Uses:** `lib/models/app_user.dart`, `lib/state/providers.dart`
- **Used by:** `lib/core/router.dart`

### `class ResidentsPage extends ConsumerWidget`

| Member | Kind | What it does |
|---|---|---|
| `const ResidentsPage({super.key})` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context, WidgetRef ref)` | method | _(auto)_ Builds this widget's UI. |
| `Future<void> _addResident(BuildContext context, WidgetRef ref, AppUser user)` | method | Shows a dialog for resident name and optional family email, and on Add with a non-empty name calls createDemoResident; caregiver-only via the FAB. |

### `class _Empty extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const _Empty({required this.user})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final AppUser user` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

