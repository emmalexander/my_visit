# My Visits — Field Task Application

An offline-first, single-screen Flutter application built for field agents viewing, managing, and completing assigned site visits in low-connectivity or unreliable network environments.

---

## Overview

Field agents operate in areas with intermittent connectivity. This application provides a responsive, offline-first interface backed by an unreliable mock backend (`FlakyTaskApi`). The app ensures that user intent is captured instantly, persisted durably across app restarts, and reconciled reliably with the server without allowing stale network responses to overwrite newer changes.

### Key Features Implemented

1. **Infinite Pagination with Deduplication**:
   - Loads tasks in batches of 20 with cursor-based pagination.
   - Detects and eliminates the backend's off-by-one cursor overlap (`from = start - 1`) so tasks are never rendered twice.
   - Preserves previously loaded pages if a later page request fails.
   - Includes inline recoverable error rows with one-tap retry for failed pagination requests.

2. **Race-Safe Server Search**:
   - Filters tasks through the backend API with a 300ms debounce.
   - Uses request generation sequence tracking (`_searchGeneration`) so slower, older search responses (e.g., "Lagos") can never overwrite newer responses (e.g., "Abuja").
   - Instantly resets pagination when the query changes or is cleared.
   - Dedicated empty state (`No visits match "<query>"`) and error states.

3. **Optimistic Status Toggling & Durable Offline Queue**:
   - Tapping an open visit immediately marks it as done with local UI updates.
   - Persists pending mutations to local durable storage (`SharedPreferences`) **before** initiating network requests.
   - Survives app backgrounding, force termination, and device restarts.
   - Restores and drains pending mutations upon application startup.
   - Coalesces rapid consecutive toggles on the same item, ensuring the final user intent is preserved.

4. **Honest Error Handling & Server Reconciliation**:
   - Differentiates between definite server rejections (`ApiException`) and ambiguous transport timeouts (`TimeoutException`) where the server actually committed the change before timing out.
   - Avoids destructive rollbacks: failed mutations are tagged with a `"Not saved · Retry"` badge and exposed in a floating bottom alert banner with a manual `[Retry]` action.
   - Reconciles local and server state on pull-to-refresh or page fetch, automatically clearing resolved mutations when server data catches up.

5. **Figma Design Fidelity & Strict Accessibility**:
   - Built to match the Figma specifications ("My Visits - Take-Home Design").
   - Implements full design tokens for colors, typography, elevations, and states (`AppColors`, `AppTextStyles`, `AppTheme`).
   - Skeleton loading shimmer for initial load.
   - Every interactive control meets or exceeds the **$48 \times 48$ logical pixel** minimum tap target.
   - Supports **200% system font scaling** on narrow **320dp viewports** without clipping, overflow, or broken wrapping.
   - Handles API edge cases: task 53 with `title: null` renders as *"Untitled visit"*, and task 89 with `status: 'archived'` renders with an archive badge and disabled toggling.

---

## Tech Stack & Versions

- **Flutter**: `3.38.5` (channel stable)
- **Dart**: `3.10.4`
- **State Management**: `flutter_riverpod: ^3.3.2` (*Strictly without code generation*)
- **Local Persistence**: `shared_preferences: ^2.5.5`
- **Formatting**: `intl: ^0.20.3`
- **Target Platform**: Android (minSdkVersion 21+, compileSdkVersion 34+)

---

## Architecture

The project follows a clean layered architecture with strict separation of concerns and dependency inversion:

```
lib/
├── api/
│   └── flaky_task_api.dart             # Supplied external mock backend (unchanged)
├── data/
│   ├── local/
│   │   ├── task_local_store.dart       # Local persistence contract
│   │   ├── shared_prefs_task_local_store.dart  # Production SharedPreferences store
│   │   └── in_memory_task_local_store.dart    # Test fake for deterministic unit tests
│   ├── models/
│   │   ├── task_status.dart            # TaskStatus enum (open, done, archived, unknown)
│   │   ├── task_item.dart              # TaskItem domain model with SyncStatus
│   │   └── pending_mutation.dart       # Durable offline queue item with sequence ID
│   └── repository/
│       ├── task_repository.dart        # Repository interface & result classes
│       └── task_repository_impl.dart   # Implementation: deduplication, queue & reconciliation
├── presentation/
│   ├── screens/
│   │   └── visits_screen.dart          # Main field task view with pull-to-refresh & banner
│   └── widgets/
│       ├── empty_search_view.dart      # Empty state for search queries
│       ├── first_load_error_view.dart  # Fullscreen recoverable error view
│       ├── later_page_error_row.dart   # In-list pagination failure retry row
│       ├── search_bar_widget.dart      # Accessible debounced search input
│       ├── skeleton_shimmer_view.dart  # Shimmer skeleton loader
│       ├── update_failed_banner.dart   # Floating offline failure banner
│       └── visit_item_tile.dart        # Accessible task item tile with status badges
├── state/
│   ├── task_list_notifier.dart         # Manual Riverpod Notifier & Provider declarations
│   └── task_list_state.dart            # Immutable UI state class
├── theme/
│   ├── app_colors.dart                 # Design tokens from Figma
│   ├── app_text_styles.dart            # Typography tokens
│   └── app_theme.dart                  # ThemeData configuration
└── main.dart                           # Entry point with ProviderScope and local store setup
```

### State Management Guidelines
Per assessment requirements, this project uses **standard Riverpod without code generation**:
- No `riverpod_annotation`, `@riverpod`, `build_runner`, or `.g.dart` files.
- Providers are declared explicitly as top-level constants (`taskListProvider`, `taskRepositoryProvider`, `taskLocalStoreProvider`, `flakyTaskApiProvider`).
- Notifiers extend `Notifier<TaskListState>`.
- Testing utilizes `ProviderContainer` with `overrideWith` for isolated, deterministic unit testing.

---

## Setup & Running the Application

### 1. Prerequisites
- Flutter SDK 3.38+ installed and configured in your `PATH`.
- An Android emulator, physical Android device, or Chrome for web preview.

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
To run on your connected device or emulator:
```bash
flutter run
```

Or target a specific device:
```bash
# Android emulator or device
flutter run -d android

# Chrome (for rapid desktop verification)
flutter run -d chrome
```

---

## Running Verification & Tests

### Run Static Analysis
Ensure there are no lint warnings or static analyzer issues:
```bash
flutter analyze
```

### Run Automated Tests
Execute the entire test suite (29 tests across unit, contract, integration, and widget layers):
```bash
flutter test
```

### Run Specific Test Suites
```bash
# Backend contract quirks test
flutter test test/unit/flaky_task_api_contract_test.dart

# Local storage persistence and queue restart test
flutter test test/unit/task_local_store_test.dart

# Repository deduplication and reconciliation test
flutter test test/unit/task_repository_test.dart

# Search race condition and optimistic update test
flutter test test/unit/task_list_notifier_test.dart

# Widget rendering, error states, and 200% text scale test
flutter test test/widget_test.dart
```

---

## Design and Decisions Summary

For detailed answers to the 8 mandatory architectural questions (including task-status truth resolution, backend quirks, AI tooling account, and design gap resolutions), please refer to [DECISIONS.md](DECISIONS.md).
