import 'package:flutter/material.dart';
import '../../../core/models/word_model.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/word_badges.dart';

class WordListItem extends StatelessWidget {
  final WordModel word;
  final VoidCallback onTap;
  final bool showUnknownBadge;

  const WordListItem({
    super.key,
    required this.word,
    required this.onTap,
    this.showUnknownBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: switch (word.status) {
                  WordStatus.newWord => AppColors.statusNew,
                  WordStatus.learning => AppColors.statusLearning,
                  WordStatus.known => AppColors.statusKnown,
                },
              ),
            ),

            // Word info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          word.word,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      WordTypeBadge(type: word.type, small: true),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    word.meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // Unknown badge
            if (showUnknownBadge && word.isUnknown)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusUnknown.withAlpha(26),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${word.unknownCount}×',
                  style: const TextStyle(
                    color: AppColors.statusUnknown,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark
                  ? AppColors.darkTextHint
                  : AppColors.lightTextHint,
            ),
          ],
        ),
      ),
    );
  }
}
