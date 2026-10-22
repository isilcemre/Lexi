import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';
import '../../../core/theme/app_colors.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(quizProvider);
    final total = quiz.words.length;
    final known = quiz.knownWordIds.length;
    final unknown = quiz.unknownWordIds.length;
    final pct = total == 0 ? 0.0 : (known / total) * 100;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color resultColor;
    String resultEmoji;
    String resultMessage;

    if (pct >= 80) {
      resultColor = AppColors.statusKnown;
      resultEmoji = '🎉';
      resultMessage = 'Excellent work!';
    } else if (pct >= 50) {
      resultColor = AppColors.statusLearning;
      resultEmoji = '💪';
      resultMessage = 'Good progress!';
    } else {
      resultColor = AppColors.statusUnknown;
      resultEmoji = '📚';
      resultMessage = 'Keep practicing!';
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quiz Result'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              ref.read(quizProvider.notifier).reset();
              final router = GoRouter.of(context);
              // Bu ekrana normalde word_list -> quiz_setup -> flashcard
              // -> (pushReplacement) result zinciriyle gelinir. İki kez
              // pop edince zaten stack'te duran orijinal word_list
              // sayfasına döneriz; böylece geri oku da korunur.
              if (router.canPop()) {
                context.pop();
                if (router.canPop()) {
                  context.pop();
                }
              } else {
                // Beklenmedik şekilde stack kısaysa güvenli fallback
                context.go('/home');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Result card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [resultColor.withAlpha(200), resultColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: resultColor.withAlpha(102),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(resultEmoji,
                      style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  Text(
                    resultMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Big percentage
                  Text(
                    '${pct.round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    'Success Rate',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total',
                    value: '$total',
                    icon: Icons.quiz_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Known',
                    value: '$known',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.statusKnown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Unknown',
                    value: '$unknown',
                    icon: Icons.cancel_rounded,
                    color: AppColors.statusUnknown,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            // Unknown words list
            if (quiz.unknownWordTexts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Words to Review',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'These words need more practice',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quiz.unknownWordTexts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.statusUnknown,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              quiz.unknownWordTexts[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],

            const SizedBox(height: 32),

            // Action buttons
            Column(
              children: [
                if (quiz.unknownWordTexts.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Retry only unknown words
                        final unknownWords = quiz.words
                            .where((w) => quiz.unknownWordIds.contains(w.id))
                            .toList();
                        ref
                            .read(quizProvider.notifier)
                            .startQuiz(unknownWords);
                        context.pushReplacement('/quiz/flashcard');
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry Unknown Words'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(quizProvider.notifier).reset();
                      final router = GoRouter.of(context);
                      // Bu ekrana normalde word_list -> quiz_setup -> flashcard
                      // -> (pushReplacement) result zinciriyle gelinir. İki kez
                      // pop edince zaten stack'te duran orijinal word_list
                      // sayfasına döneriz; böylece geri oku da korunur.
                      if (router.canPop()) {
                        context.pop();
                        if (router.canPop()) {
                          context.pop();
                        }
                      } else {
                        // Beklenmedik şekilde stack kısaysa güvenli fallback
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Home'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}