# Vaultlog

Vaultlog is an offline-first Flutter app for tracking personal progress across daily work, coding practice, projects, content, workouts, reading, learning, and notes.

The app stores data locally with Isar, uses Riverpod for state management, and is organized feature-first with a lightweight repository layer.

## Features

- **Today**: Add and edit daily logs with category-specific forms.
- **Journal**: Search, filter, expand, delete, and inspect past log entries (bottom nav label: History).
- **Stats**: View current streak, longest streak, year-long contribution heatmap, last 30 days chart, and category totals.
- **Blind 75**: Track solved DSA problems and view attempt history.
- **Projects**: Create projects, cycle project status, and log project sessions.
- **Backup Data**: Optional Firebase email/password backup and restore.
- **More**: Hub for Blind 75, Projects, Settings, and Backup (bottom navigation).
- **Settings**: Switch theme mode, manage custom activities and Today category order, export progress report, and clear local logs.
- **Custom activities**: Define your own log types (fields, labels, Material or 64×64 PNG icons) under Settings → Custom activities; log them from Today via the **Custom** category.
- **Today layout**: Reorder built-in categories on the add-log grid via Settings → **Activity order on Today**.

## Categories

| Category | Main payload fields |
|----------|---------------------|
| DSA / Coding | `problemNumber`, `problemName`, `topic`, `approach`, `status` |
| Content | `platform`, `title`, `statuses` |
| Workout | `exercise`, `count` / `duration`, `sets` |
| Reading | `bookName`, `pagesRead`, `quote` |
| Learning | `note`, `tags` |
| Misc | `title`, `note` |
| Project | `projectId`, `projectName`, `whatDone`, `whatLearnt` |
| Custom | Per-activity fields (`title`, `note`, `number`, `duration`, `tags`) and optional PNG icon |

### Custom activity icons (Android / iOS)

Importing a PNG icon uses the device photo library (`image_picker`). Android declares `READ_MEDIA_IMAGES` (and legacy `READ_EXTERNAL_STORAGE` on API ≤ 32). iOS uses `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist`. Icons are resized to 64×64 and stored under the app documents directory; encrypted cloud backup can include them as base64.

## Tech Stack

| Area | Technology |
|------|------------|
| Framework | Flutter |
| Language | Dart |
| State management | Riverpod |
| Local database | Isar |
| Navigation | go_router |
| Charts | fl_chart |
| Fonts / formatting | google_fonts, intl |
| Cloud backup | Firebase Auth, Cloud Firestore |

Note: `isar_flutter_libs` is vendored under `third_party/` with a small Android namespace patch so it builds with newer Android Gradle Plugin versions.

## Open source

This repository is intended to be **public**. It contains app source only — not user logs, backup passphrases, or Firebase project credentials.

| Topic | Detail |
|-------|--------|
| License | [MIT](LICENSE) |
| Secrets | Never commit `google-services.json`, `GoogleService-Info.plist`, `lib/firebase_options.dart`, or `firebase.json` (all listed in `.gitignore`). |
| Your Firebase | Each developer / fork uses their **own** Firebase project via `flutterfire configure`. |
| Cloud data | Backups are encrypted on-device before upload; Firestore holds ciphertext and metadata. |
| Security rules | Use [`firestore.rules`](firestore.rules) (or copy from [`firestore.rules.example`](firestore.rules.example)) so users can only access `userBackups/{theirUid}`. |

### Fork or clone checklist

1. `flutter pub get` and run the app locally (backup stays unavailable until Firebase is configured).
2. Create a Firebase project, enable Email/Password auth and Firestore, then run `flutterfire configure`.
3. Publish Firestore rules from `firestore.rules` (see [Firestore security rules](#firestore-security-rules)).
4. Run with backup enabled: `flutter run --dart-define=VAULTLOG_FIREBASE_ENABLED=true`.
5. Before your first public push, scan history for leaked keys: `git log -p --all -S 'AIza'`.

Do **not** open GitHub issues with backup passphrases, Firebase passwords, or exported log data.

## App Identity

| Target | Value |
|--------|-------|
| App name | Vaultlog |
| Android package / app ID | `ghost.codes7.vaultlog` |
| iOS/macOS bundle ID | `ghost.codes7.vaultlog` |

## Architecture

This project uses a **feature-first Flutter architecture** with a small repository layer:

```text
Screen / Widget -> Riverpod Provider / Notifier -> Repository -> Isar
```

It is MVVM-like because providers and notifiers hold screen state and actions, but the project does not use a strict MVC or MVVM folder structure.

Current approach:

- UI files render screens and call Riverpod providers/notifiers.
- Provider files own state, invalidation, and user actions.
- Repository files own Isar reads and writes.
- Core files hold app-wide infrastructure such as routing, theme, database setup, models, and shared providers.
- No `domain/`, `usecases/`, or separate entity layer is used yet.

## Project Structure

```text
lib/
  main.dart
  core/
    db/
      isar_service.dart
    models/
      category.dart
      custom_activity.dart
      log_entry.dart
      project.dart
    providers/
      firebase_provider.dart
      isar_provider.dart
      theme_provider.dart
    router/
      app_router.dart
    theme/
      app_theme.dart

  features/
    today/
      data/
        today_repository.dart
      providers/
        today_provider.dart
      widgets/
        forms/
        add_log_bottom_sheet.dart
        category_chip_row.dart
        log_list_view.dart
      today_screen.dart

    history/                    # Journal tab
      data/
        history_repository.dart
      providers/
        history_provider.dart
      history_screen.dart
      history_detail_screen.dart

    stats/
      data/
        stats_repository.dart
      providers/
        stats_provider.dart
      widgets/
        contribution_heatmap.dart
        line_chart_last_30_days.dart
      stats_screen.dart

    more/
      more_screen.dart

    dsa_tracker/
      data/
        blind75_problems.dart
        dsa_repository.dart
      providers/
        dsa_provider.dart
      dsa_tracker_screen.dart

    project/
      data/
        project_repository.dart
      providers/
        project_provider.dart
      widgets/
        project_session_form.dart
      project_screen.dart

    settings/
      data/
        settings_repository.dart
        custom_activity_repository.dart
        category_order_store.dart
      providers/
        settings_provider.dart
        custom_activity_provider.dart
        category_order_provider.dart
      settings_screen.dart
      custom_activities_screen.dart
      custom_activity_editor_screen.dart
      category_order_screen.dart

    backup/
      data/
        backup_models.dart
        backup_crypto.dart
        firebase_backup_repository.dart
      providers/
        backup_provider.dart
      widgets/
        backup_passphrase_dialog.dart
      backup_screen.dart

  shared/
    widgets/
      log_date_selector.dart

  util/
    string_constant.dart
```

## Data Model

`LogEntry` is the main collection for daily activity. It stores:

- `createdAt` for time-based history, streaks, and charts.
- `categoryIndex` instead of a raw enum for safer Isar storage.
- `payloadJson` for category-specific fields.

`Project` is a separate Isar collection used by the Projects feature. Project logs are still saved as `LogEntry` records with project metadata in the payload.

`CustomActivity` stores user-defined activity types (field kinds, labels, optional icon path) for the Custom category on Today.

## Firebase Backup Setup

The backup code is implemented, but a real Firebase project must be connected before it can be used.

1. Create a Firebase project.
2. Enable **Authentication -> Email/Password**.
3. Create **Cloud Firestore**.
4. Register an Android app with package name `ghost.codes7.vaultlog`.
5. Register iOS/macOS apps with bundle ID `ghost.codes7.vaultlog` if you build those targets.
6. Install FlutterFire CLI if needed:

```bash
dart pub global activate flutterfire_cli
```

7. Generate local Firebase configuration:

```bash
flutterfire configure
```

8. Keep generated Firebase config files local. They are ignored by git so each developer can use their own Firebase project.

9. Run with Firebase enabled:

```bash
flutter run --dart-define=VAULTLOG_FIREBASE_ENABLED=true
```

The public repo intentionally does not include Firebase project files or API keys. Without local Firebase configuration, the app still runs, but the backup screen reports Firebase as unavailable.

### Firestore security rules

Deploy [`firestore.rules`](firestore.rules) (same content as [`firestore.rules.example`](firestore.rules.example)):

1. **Firebase Console** — Firestore → Rules → paste → **Publish**.
2. **Firebase CLI** — copy `firestore.rules` into your project, then `firebase deploy --only firestore:rules`.

Rules allow read/write only when `request.auth.uid` matches the `userId` in `userBackups/{userId}`, including the `encrypted/payload` document and legacy `logs` / `projects` subcollections. Everything else is denied.

### Encrypted cloud backup

Backups are **encrypted on the device** (AES-256-GCM) before upload. Firestore stores ciphertext and non-sensitive metadata (counts, timestamps, salt). Log and project content is not stored in plaintext in the cloud.

The user chooses a **backup passphrase** (separate from the Firebase sign-in password). The same passphrase is required to restore on a new device. The app can remember the passphrase locally (Android Keystore / iOS Keychain) for automatic sync.

Older backups created before encryption used plain subcollections (`logs`, `projects`); restore still supports those until the user runs a new encrypted backup.

### Backup data shape (encrypted)

```text
/userBackups/{userId}
  schemaVersion: 2
  encrypted: true
  encryptionSalt        # public; used with passphrase for key derivation
  status, lastBackupAt, logCount, projectCount

/userBackups/{userId}/encrypted/payload
  ciphertext            # AES-GCM blob (logs + projects JSON inside)
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK compatible with `^3.11.1`

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Generate Isar Files

Run this after changing Isar models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Analyze

```bash
flutter analyze lib/features
```

### Release Build

```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## Development Notes

- Keep database reads and writes inside feature repositories.
- Keep Riverpod providers as the state and action layer.
- Keep screens and widgets focused on UI and user interaction.
- Add a heavier domain/usecase layer only if business rules become complex enough to justify it.
