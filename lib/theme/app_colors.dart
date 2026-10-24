import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand / status colors
  static const Color primaryTeal = Color(0xFF0B6753);
  static const Color primaryTealLight = Color(0xFFE6F4F1);

  // Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Borders and dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Badges
  // Pending & Header Unsynced
  static const Color badgePendingBg = Color(0xFFFEF3C7);
  static const Color badgePendingText = Color(0xFFB45309);

  // Failed / Not saved
  static const Color badgeFailedBg = Color(0xFFFEE2E2);
  static const Color badgeFailedText = Color(0xFFB91C1C);

  // Archived
  static const Color badgeArchivedBg = Color(0xFFF3F4F6);
  static const Color badgeArchivedText = Color(0xFF4B5563);

  // Checkbox outline
  static const Color checkboxBorder = Color(0xFF9CA3AF);

  // Floating Banner / Snackbar
  static const Color bannerBackground = Color(0xFF1E293B);
  static const Color bannerText = Colors.white;
  static const Color bannerAction = Color(0xFF2DD4BF);

  // Skeleton
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
}
