# Vaultlog

Vaultlog is an offline-first Flutter app for tracking personal progress across daily work, coding practice, projects, content, workouts, reading, learning, and notes.

The app stores data locally with Isar, uses Riverpod for state management, and is organized feature-first with a lightweight repository layer.

## Features

- **Today**: Add and edit daily logs with category-specific forms.
- **Journal**: Search, filter, expand, delete, and inspect past log entries.
- **Stats**: View current streak, longest streak, 90-day contribution heatmap, last 7 days chart, and category totals.
- **Blind 75**: Track solved DSA problems and view attempt history.
- **Projects**: Create projects, cycle project status, and log project sessions.
- **Backup Data**: Optional Firebase email/password backup and restore.
- **Settings**: Switch theme mode, export progress report, and clear local logs.

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
  core/
    db/
      isar_service.dart
    models/
      category.dart
      log_entry.dart
      project.dart
    providers/
      isar_provider.dart
      progress_seed.dart
      seed_data.dart
      theme_provider.dart
    router/
      app_router.dart
    theme/
      app_theme.dart

  features/
    dsa_tracker/
      data/
        blind75_problems.dart
        dsa_repository.dart
      providers/
        dsa_provider.dart
      dsa_tracker_screen.dart

    history/
      data/
        history_repository.dart
      providers/
        history_provider.dart
      history_screen.dart
      history_detail_screen.dart

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
      providers/
        settings_provider.dart
      settings_screen.dart

    backup/
      data/
        backup_models.dart
        firebase_backup_repository.dart
      providers/
        backup_provider.dart
      backup_screen.dart

    stats/
      data/
        stats_repository.dart
      providers/
        stats_provider.dart
      widgets/
        contribution_heatmap.dart
        weekly_bar_chart.dart
      stats_screen.dart

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

## Seed Data

On startup, the app opens Isar and generates fallback sample data if the local database is empty.

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

### Firestore Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isOwner(uid) {
      return request.auth != null && request.auth.uid == uid;
    }

    match /userBackups/{uid} {
      allow read, write: if isOwner(uid);

      match /{document=**} {
        allow read, write: if isOwner(uid);
      }
    }
  }
}
```

### Backup Data Shape

```text
/userBackups/{uid}
  schemaVersion
  status
  lastBackupAt
  logCount
  projectCount

/userBackups/{uid}/logs/{isarLogId}
  isarId
  createdAt
  categoryIndex
  payloadJson

/userBackups/{uid}/projects/{isarProjectId}
  isarId
  name
  description
  statusIndex
  createdAt
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
