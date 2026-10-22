import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/word_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/word_badges.dart';
import '../../../features/languages/providers/language_provider.dart';
import '../providers/word_provider.dart';

class WordDetailScreen extends ConsumerWidget {
  final WordModel initialWord;

  const WordDetailScreen({super.key, required this.initialWord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Stream'den güncel veriyi oku, bulunamazsa initialWord'ü kullan
    final wordsAsync = ref.watch(wordsProvider(initialWord.languageId));
    final word = wordsAsync.when(
      data: (words) {
        try {
          return words.firstWhere((w) => w.id == initialWord.id);
        } catch (_) {
          return initialWord;
        }
      },
      loading: () => initialWord,
      error: (_, _) => initialWord,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              '/language/${word.languageId}/words/edit',
              extra: word,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: AppColors.accent),
            onPressed: () => _confirmDelete(context, ref, word),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word header card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(77),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: Colors.white.withAlpha(77),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  const SizedBox(height: 12),
                  if (word.meanings.length <= 1)
                    Text(
                      word.meaning,
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    ...word.meanings.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: entry.key == 0 ? 22 : 18,
                          fontWeight: entry.key == 0
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 24),

            // Info cards row
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.category_outlined,
                    label: 'Type',
                    child: WordTypeBadge(type: word.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Status',
                    child: WordStatusBadge(status: word.status),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Correct',
                    child: Text(
                      '${word.correctCount}×',
                      style: const TextStyle(
                        color: AppColors.statusKnown,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.cancel_outlined,
                    label: 'Missed',
                    child: Text(
                      '${word.unknownCount}×',
                      style: const TextStyle(
                        color: AppColors.statusUnknown,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.schedule_rounded,
                    label: 'Next review',
                    child: Text(
                      word.nextReviewDate == null
                          ? '—'
                          : _formatDate(word.nextReviewDate!),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            // Note section
            if (word.note != null && word.note!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Note',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      word.note!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ],

            // Added date
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Added ${_formatDate(word.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, WordModel word) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Word'),
        content: Text(
            'Are you sure you want to delete "${word.word}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(firestoreServiceProvider).deleteWord(word);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // İçeriği (badge / sayı / tarih) taşmaya karşı garantiye alır,
          // sığmazsa otomatik küçültür.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ],
      ),
    );
  }
}