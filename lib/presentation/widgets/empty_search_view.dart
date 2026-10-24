import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class EmptySearchView extends StatelessWidget {
  const EmptySearchView({
    super.key,
    required this.query,
  });

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No visits match "$query"',
          style: AppTextStyles.errorSubtitle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
