# Architectural Decisions & Technical Report: My Visits

This document answers the core architectural and evaluation questions for the field-agent task application.

---

### 1. Where does task-status truth live, and what happens when local and server versions disagree?
Task-status truth is **layered and intent-driven**:
- **Confirmed State**: Canonical truth lives on the server when no local mutations are outstanding.
- **Pending/In-Flight State**: The local durable store (`TaskLocalStore` via `SharedPreferences`) represents the definitive record of **unreconciled user intent**.
- **Conflict Resolution**: When `fetchTasks` fetches data from the backend, `TaskRepositoryImpl._reconcileWithPending` reconciles each incoming task against the pending queue. If a pending mutation exists for task $X$, the local desired status (`open` or `done`) takes precedence over the server's stale value, preserving the field agent's work. Only upon verified server synchronization is the mutation dequeued, allowing the server's confirmed state to resume canonical authority. Sequence numbers ensure older, out-of-order network responses never overwrite newer user intent.

---

### 2. Exactly what happens when `updateStatus` throws, including user-visible feedback and final state?
`FlakyTaskApi.updateStatus` exhibits two distinct failure paths:
1. `ApiException('Internal server error')`: Thrown **before** modifying server memory (definite rejection).
2. `TimeoutException('Request timed out')`: Thrown **after** mutating server memory (ambiguous transport failure).

Because client transport errors cannot verify whether the server committed the mutation, **we never blindly roll back optimistic updates**. Doing so after a timeout would leave the UI showing `open` while the server stores `done`.
- **System Action**: The mutation remains durably recorded in `TaskLocalStore`, flagged as `isFailed = true` with incremented `retryCount`. The task's `syncStatus` transitions to `SyncStatus.failed`.
- **User-Visible Feedback**: The task item displays a prominent warning badge: `"Not saved · Retry"` with an amber alert icon. A floating bottom banner appears: *"1 change could not be saved to the server"* with `[Retry]` and `[Dismiss]` actions.
- **Final State & Recovery**: Tapping `Retry` (or pulling to refresh) triggers reconciliation. On refresh, if the server actually committed the change (as occurs during timeout exceptions), the reconciliation logic automatically resolves the mutation, clears the failed queue, and updates the task to `SyncStatus.synced`.

---

### 3. What unexpected behaviours did you discover in `FlakyTaskApi`, and how did you handle each one?
1. **Off-by-One Pagination Overlap**: In `fetchTasks`, the API computes `from = start == 0 ? 0 : start - 1`. On page 2 (start = 20), `from = 19`, returning index 19 twice.  
   *Handling*: `TaskRepositoryImpl` tracks seen task IDs and deduplicates items while preserving cursor ordering.
2. **Missing Task Title**: Task ID `53` contains `title: null`.  
   *Handling*: Handled safely in `TaskItem.fromApi` by supplying `"Untitled visit"` rendered in italic muted typography matching Figma specifications.
3. **Archived Status**: Task ID `89` contains `status: 'archived'`.  
   *Handling*: Represented via `TaskStatus.archived`. The UI displays an `Archived` badge with a file-box icon and disables tap toggling.
4. **Non-Monotonic Search Latency**: Search queries simulate artificial network jitter between 200ms and 2000ms. An older, slower query (e.g., "Lagos") can resolve after a newer, faster query (e.g., "Abuja").  
   *Handling*: Implemented a 300ms debounce and an incremental `_searchGeneration` token in `TaskListNotifier`. Any response arriving with an outdated generation token is discarded immediately.
5. **Pagination Termination**: The API signals dataset exhaustion by returning `nextCursor: null`.  
   *Handling*: `TaskListState` explicitly supports clearing `nextCursor` and sets `hasMore = false`, preventing infinite loading loops.

---

### 4. Why was your state-management approach suitable, and what did it make harder?
- **Why Suitable**: Standard Riverpod (`flutter_riverpod: ^3.3.2` without code generation) provides explicit, decoupled dependency injection (`Provider`, `NotifierProvider`). It requires no `build_runner` or `.g.dart` generation, ensures fast compile times, and enables deterministic provider overrides (`overrideWith`) in unit and widget tests. State is modeled as an immutable `TaskListState` data class with explicit copy transitions.
- **What It Made Harder**: Riverpod 3 enforces strict lifecycle checks where reading uninitialized notifier state during construction throws. We had to pass an optional `initialState` parameter to `TaskListNotifier` and use parameterless closures in `overrideWith`. Manual immutable state models also required explicit `clearNextCursor` flags to differentiate between an omitted parameter and intentional null assignment.

---

### 5. What did you test, and why?
29 automated tests cover the critical, failure-prone offline and concurrent paths:
1. **API Contract & Edge Cases (`flaky_task_api_contract_test.dart`)**: Proved `title == null`, `status == archived`, cursor completion, and index overlap.
2. **Durable Persistence (`task_local_store_test.dart`)**: Proved mutation serialization, sequence monotonicity, and queue restoration across store restarts.
3. **Repository Reconciliation (`task_repository_test.dart`)**: Proved pagination deduplication, optimistic queue priority, timeout vs API exception handling, and rejection of out-of-order responses.
4. **Riverpod Search & Race Conditions (`task_list_notifier_test.dart`)**: Verified 300ms debouncing, the "Lagos" vs "Abuja" race condition, pagination reset on query changes, and optimistic mutation retries.
5. **Widget & Accessibility (`widget_test.dart`)**: Tested skeleton loading shimmer, first-page error with retry, item list row states, empty search, pagination error row, update failure banner, and 200% system font scaling on a 320dp narrow viewport with no RenderFlex overflow.

---

### 6. What did you deliberately leave out, and what would you implement with another four hours?
- **Deliberately Left Out**:
  - Full relational database (SQLite/Drift): `SharedPreferences` with atomic JSON serialization was chosen to avoid C-binding build complications while providing full durability for pending mutations.
  - Automatic connectivity listener (`connectivity_plus`): Manual retry and pull-to-refresh were prioritized over flaky OS connectivity listeners.
  - Exponential backoff with jitter on network retries.
- **With Another Four Hours**:
  1. Add an OS background synchronization worker (e.g. `workmanager` or Android `JobScheduler`) to flush the queue when the app is closed.
  2. Implement bidirectional conflict resolution timestamps ($updated\_at$ comparison) for multi-device sync.
  3. Introduce screenshot-based Golden UI tests across multiple device screen densities.

---

### 7. Which parts used AI tools? Give one example where a suggestion was changed or rejected and explain why.
- **AI Tool Usage**: Antigravity AI was used for inspecting the Figma design via browser automation, analyzing `FlakyTaskApi` behavior, generating boilerplate for models and state transitions, and writing comprehensive test suites.
- **Example of Changed/Rejected Suggestion**: When solving the 200% text scale constraint on a 320dp viewport, an initial suggestion was to wrap the header counter and search controls in a `FittedBox` or reduce font sizes. **This was rejected** because scaling down text directly violates the accessibility requirement that text remain legible at 200% scale. Instead, we refactored the layout to use a flexible `Wrap` container with adaptive `Column`/`Row` breakpoints, preserving the full 200% font scale while guaranteeing the required $\ge 48 \times 48\text{ dp}$ interactive tap targets and zero pixel overflow.

---

### 8. Where did the implementation deviate from Figma or fill a design gap, and why?
- **Rapid Repeated Taps**: Figma did not specify the behavior when an agent rapidly toggles a task multiple times before network completion. We filled this gap by coalescing pending mutations in `TaskLocalStore`: rapid toggles update the desired target status in place without spawning redundant network requests, while displaying an active in-flight spinner.
- **Null Title Presentation**: Figma displays visit names with secondary details. For task 53 (`title: null`), we rendered *"Untitled visit"* in italicized `AppColors.textMuted` to prevent blank lines while signaling to the field agent that the visit record lacks a server label.
