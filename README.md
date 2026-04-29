# DailyLog

DailyLog is an offline-first Flutter app for tracking personal progress across daily work, coding practice, projects, content, workouts, reading, learning, and notes.

The app stores data locally with Isar, uses Riverpod for state management, and is organized feature-first with a lightweight repository layer.

## Features

- **Today**: Add and edit daily logs with category-specific forms.
- **Journal**: Search, filter, expand, delete, and inspect past log entries.
- **Stats**: View current streak, longest streak, 90-day contribution heatmap, last 7 days chart, and category totals.
- **Blind 75**: Track solved DSA problems and view attempt history.
- **Projects**: Create projects, cycle project status, and log project sessions.
- **Settings**: Switch theme mode, export progress as JSON, and clear local logs.

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

On startup, the app opens Isar and runs initial seeding from bundled progress assets:

- `PROGRESS.json`
- `PROGRESS.md`

If progress data cannot be loaded and the database is empty, fallback sample data is generated.

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
