import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/task_list_notifier.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../widgets/empty_search_view.dart';
import '../widgets/first_load_error_view.dart';
import '../widgets/later_page_error_row.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/skeleton_shimmer_view.dart';
import '../widgets/update_failed_banner.dart';
import '../widgets/visit_item_tile.dart';

class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});

  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger next page when within 250 logical pixels of the bottom
    if (currentScroll >= maxScroll - 250) {
      ref.read(taskListProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskListProvider);
    final notifier = ref.read(taskListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const Text(
                              'My visits',
                              style: AppTextStyles.screenTitle,
                            ),
                            if (state.unsyncedCount > 0)
                              _buildUnsyncedBadge(state.unsyncedCount),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchBarWidget(
                    initialQuery: state.searchQuery,
                    onChanged: notifier.onSearchChanged,
                    onClear: notifier.clearSearch,
                  ),
                ),
                const SizedBox(height: 12),

                // Divider below header/search
                const Divider(height: 1, color: AppColors.divider),

                // Main Content Body
                Expanded(
                  child: _buildBody(state, notifier),
                ),
              ],
            ),

            // Floating "Update failed" banner at bottom
            if (state.lastFailedMutation != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: UpdateFailedBanner(
                  taskTitle: state.lastFailedMutation!.taskTitle ?? 'visit',
                  onRetry: () =>
                      notifier.retryMutation(state.lastFailedMutation!.taskId),
                  onDismiss: notifier.dismissFailedBanner,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(dynamic state, TaskListNotifier notifier) {
    // 1. Initial Loading State (First load)
    if (state.isLoadingFirstPage && state.tasks.isEmpty) {
      return const SkeletonShimmerView();
    }

    // 2. Initial Load Failed State (First load failed)
    if (state.firstPageError != null && state.tasks.isEmpty) {
      return FirstLoadErrorView(
        message: state.firstPageError,
        onRetry: notifier.loadInitial,
      );
    }

    // 3. Empty Search Results State (Search · no results)
    if (state.showEmptySearch) {
      return EmptySearchView(query: state.searchQuery);
    }

    // 4. Empty List State (no visits at all)
    if (state.showEmptyList) {
      return const Center(
        child: Text(
          'No visits assigned',
          style: AppTextStyles.errorSubtitle,
        ),
      );
    }

    // 5. Successful Task List with Pagination
    final itemCount = state.tasks.length +
        (state.isLoadingNextPage ? 1 : 0) +
        (state.nextPageError != null ? 1 : 0);

    return RefreshIndicator(
      color: AppColors.primaryTeal,
      backgroundColor: AppColors.surface,
      onRefresh: notifier.refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < state.tasks.length) {
            final task = state.tasks[index];
            return VisitItemTile(
              task: task,
              onToggle: () => notifier.toggleTask(task),
              onRetry: () => notifier.retryMutation(task.id),
            );
          }

          // Bottom loading indicator
          if (state.isLoadingNextPage && index == state.tasks.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                  ),
                ),
              ),
            );
          }

          // Bottom error row with retry
          if (state.nextPageError != null) {
            return LaterPageErrorRow(
              onRetry: notifier.loadNextPage,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUnsyncedBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgePendingBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count unsynced',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.badgePendingText,
        ),
      ),
    );
  }
}
