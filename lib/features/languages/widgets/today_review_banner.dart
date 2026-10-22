import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/language_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../words/providers/word_provider.dart';

class TodayReviewBanner extends ConsumerWidget {
  final List<LanguageModel> languages;

  const TodayReviewBanner({super.key, required this.languages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sum up all due words across all languages
    int totalDue = 0;
    for (final lang in languages) {
      totalDue += ref.watch(dueForReviewProvider(lang.id)).length;
    }

    if (totalDue == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.wb_sunny_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Review",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalDue word${totalDue == 1 ? '' : 's'} waiting for review',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }
}
