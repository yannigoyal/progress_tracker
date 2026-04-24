# Progress Tracker

A Flutter app for tracking daily progress across multiple areas: DSA/coding, content creation, workouts, reading, learning, and miscellaneous notes.

## Features

- **Today** - Log daily activities with category-specific forms
- **Stats** - View streaks, contribution heatmap, weekly charts, and category totals
- **History** - Browse past log entries
- **DSA Tracker** - Track Blind 75 problems solved
- **Settings** - Theme toggle (light/dark mode)

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter |
| **State Management** | Riverpod |
| **Local Database** | Isar |
| **Navigation** | go_router (StatefulShellRoute for bottom nav) |
| **Charts** | fl_chart |

## Project Structure

```
lib/
├── core/                      # Shared infrastructure
│   ├── db/
│   │   └── isar_service.dart  # Isar database singleton
│   ├── models/
│   │   ├── category.dart      # Category enum + extension (colors, icons, labels)
│   │   └── log_entry.dart     # Main collection model (flexible JSON payload)
│   ├── providers/
│   │   ├── isar_provider.dart # Isar instance provider
│   │   ├── seed_data.dart     # Sample data generator (24 days of logs)
│   │   └── theme_provider.dart# Theme state management
│   ├── router/
│   │   └── app_router.dart    # go_router config with 5 bottom nav tabs
│   └── theme/
│       └── app_theme.dart     # Light/dark theme definitions
│
└── features/                  # Feature-first organization
    ├── dsa_tracker/
    │   ├── data/
    │   │   └── blind75_problems.dart  # List of 190+ problems
    │   ├── providers/
    │   │   └── dsa_provider.dart      # DSA state logic
    │   └── dsa_tracker_screen.dart
    │
    ├── history/
    │   ├── providers/
    │   │   └── history_provider.dart
    │   └── history_screen.dart
    │
    ├── stats/
    │   ├── providers/
    │   │   └── stats_provider.dart    # Streak, heatmap, totals calculation
    │   ├── widgets/
    │   │   ├── contribution_heatmap.dart  # GitHub-style heatmap
    │   │   └── weekly_bar_chart.dart      # Last 7 days bar chart
    │   └── stats_screen.dart
    │
    ├── today/
    │   ├── providers/
    │   │   └── today_provider.dart        # Today's logs + day number
    │   ├── widgets/
    │   │   ├── add_log_bottom_sheet.dart  # Category picker
    │   │   ├── category_chip_row.dart     # Category summary chips
    │   │   ├── log_list_view.dart         # Entry list display
    │   │   └── forms/
    │   │       ├── form_shell.dart        # Common form wrapper
    │   │       ├── dsa_form.dart          # Problem #, name, topic, approach
    │   │       ├── content_form.dart      # Platform, title, status
    │   │       ├── workout_form.dart      # Exercise, count/duration, sets
    │   │       ├── reading_form.dart      # Book name, pages, quote
    │   │       ├── learning_form.dart     # Note, tags
    │   │       └── misc_form.dart         # Generic note taking
    │   └── today_screen.dart
    │
    └── settings/
        └── settings_screen.dart           # Theme toggle
```

## Key Design Decisions

### 1. Flexible Payload Model
Instead of creating separate tables for each category, `LogEntry` uses a JSON `payload` field to store category-specific data. This keeps the schema simple while allowing flexible data per category.

### 2. Category Storage
Categories are stored as `categoryIndex` (int) rather than enum directly to avoid Isar enum-annotation edge cases.

### 3. Stateful Bottom Navigation
Uses `StatefulShellRoute` from go_router to preserve state when switching between tabs (e.g., scroll position, form state).

### 4. Seed Data
On first launch, generates 24 days of sample data with realistic patterns:
- DSA: 1-3 problems daily from Blind 75
- Workout: Every other day
- Reading: Every 3rd day
- Content: Every 5th day
- Learning: ~50% daily chance

## Categories

| Category | Icon | Color | Payload Fields |
|----------|------|-------|----------------|
| DSA | `code` | Indigo | problemNumber, problemName, topic, approach, status |
| Content | `videocam` | Pink | platform, title, status |
| Workout | `fitness_center` | Green | exercise, count/duration, sets |
| Reading | `menu_book` | Amber | bookName, pagesRead, quote |
| Learning | `lightbulb` | Teal | note, tags |
| Misc | `notes` | Gray | title, note |

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Isar database setup

### Installation
```bash
flutter pub get
flutter run
```

## Development Notes

- **Day Number**: Calculated as days since first log entry (or seed data start)
- **Streak Calculation**: Consecutive days with at least one log entry
- **Heatmap**: GitHub-style contribution graph showing activity intensity

