import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/language_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../words/providers/word_provider.dart';

class LanguageCard extends ConsumerWidget {
  final LanguageModel language;

  const LanguageCard({super.key, required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCount = ref.watch(dueForReviewProvider(language.id)).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(
        '/language/${language.id}/words?name=${Uri.encodeComponent(language.name)}',
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(isDark ? 10 : 20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Emoji + Language Name
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(51),
                          AppColors.secondary.withAlpha(51),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        language.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${language.totalWords} word${language.totalWords == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Due badge
                  if (dueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.secondary.withAlpha(77)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$dueCount',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'due',
                            style: TextStyle(
                              color:
                                  AppColors.secondary.withAlpha(180),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(duration: 2000.ms, 
                            begin: const Offset(0.97, 0.97),
                            end: const Offset(1.03, 1.03)),

                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ],
              ),

              if (language.totalWords > 0) ...[
                const SizedBox(height: 16),

                // Progress bar
                _StatusBar(language: language),

                const SizedBox(height: 10),

                // Status counts
                Row(
                  children: [
                    _StatusChip(
                      label: 'NEW',
                      count: language.newCount,
                      color: AppColors.statusNew,
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: 'LEARNING',
                      count: language.learningCount,
                      color: AppColors.statusLearning,
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: 'KNOWN',
                      count: language.knownCount,
                      color: AppColors.statusKnown,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final LanguageModel language;

  const _StatusBar({required this.language});

  @override
  Widget build(BuildContext context) {
    final total = language.totalWords;
    if (total == 0) return const SizedBox.shrink();

    final newRatio = language.newCount / total;
    final learningRatio = language.learningCount / total;
    final knownRatio = language.knownCount / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: Row(
          children: [
            Flexible(
              flex: (newRatio * 100).round(),
              child: Container(color: AppColors.statusNew),
            ),
            Flexible(
              flex: (learningRatio * 100).round(),
              child: Container(color: AppColors.statusLearning),
            ),
            Flexible(
              flex: (knownRatio * 100).round(),
              child: Container(color: AppColors.statusKnown),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
