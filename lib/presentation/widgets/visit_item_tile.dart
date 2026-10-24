import 'package:flutter/material.dart';
import '../../data/models/task_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class VisitItemTile extends StatelessWidget {
  const VisitItemTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onRetry,
  });

  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onRetry;

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'Updated ${local.day} $month, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isArchived = task.status.isArchived;

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: isArchived ? null : onToggle,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox / Status toggle target (min 48x48)
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: _buildStatusIcon(),
                ),
              ),
              const SizedBox(width: 8),

              // Title, subtitle and badges
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 180;
                      final textScale = MediaQuery.textScalerOf(context).scale(14);
                      final isLargeText = textScale > 20;

                      // If wide enough and normal text, badge can sit on the right
                      if (!isNarrow && !isLargeText) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTitle(),
                                  const SizedBox(height: 4),
                                  _buildSubtitle(),
                                ],
                              ),
                            ),
                            if (_hasBadge()) ...[
                              const SizedBox(width: 8),
                              _buildBadge(),
                            ],
                          ],
                        );
                      }

                      // Narrow or large text (e.g. 200% scale, 320dp width): stack vertically
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 4),
                          _buildSubtitle(),
                          if (_hasBadge()) ...[
                            const SizedBox(height: 6),
                            _buildBadge(),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasBadge() {
    return task.isFailed || task.isPending || task.status.isArchived;
  }

  Widget _buildTitle() {
    return Text(
      task.displayTitle,
      style: task.isUntitled
          ? AppTextStyles.untitledTaskTitle
          : AppTextStyles.taskTitle,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      _formatDate(task.updatedAt),
      style: AppTextStyles.taskSubtitle,
    );
  }

  Widget _buildStatusIcon() {
    if (task.status.isArchived) {
      return const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textSecondary,
        size: 22,
      );
    }

    if (task.status.isDone) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.primaryTeal,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 14,
        ),
      );
    }

    // Open status
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.checkboxBorder,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (task.isFailed) {
      return Semantics(
        button: true,
        label: 'Retry saving visit',
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.badgeFailedBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Not saved · Retry',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.badgeFailedText,
              ),
            ),
          ),
        ),
      );
    }

    if (task.isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.badgePendingBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Pending',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.badgePendingText,
          ),
        ),
      );
    }

    if (task.status.isArchived) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.badgeArchivedBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Archived',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.badgeArchivedText,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
