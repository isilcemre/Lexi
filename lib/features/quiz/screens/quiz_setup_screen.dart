import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/word_model.dart';
import '../../../features/words/providers/word_provider.dart';

class QuizSetupScreen extends ConsumerStatefulWidget {
  final String languageId;
  final String languageName;

  const QuizSetupScreen({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  QuizMode _selectedMode = QuizMode.mixed;
  WordType? _selectedWordType;
  int _cardCount = 20;

  @override
  Widget build(BuildContext context) {
    final allWords =
        ref.watch(wordsProvider(widget.languageId)).value ?? [];
    final unknownWords = ref.watch(unknownWordsProvider(widget.languageId));
    final dueWords = ref.watch(dueForReviewProvider(widget.languageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz — ${widget.languageName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selection
            Text('Word Selection',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Choose which words to practice',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),

            ...QuizMode.values.map((mode) {
              final isAvailable = _isModeAvailable(
                  mode, allWords, unknownWords, dueWords);
              final count = _getModeCount(
                  mode, allWords, unknownWords, dueWords);
              return _ModeCard(
                mode: mode,
                isSelected: _selectedMode == mode,
                isAvailable: isAvailable,
                wordCount: count,
                selectedWordType: _selectedWordType,
                onTypeChanged: (t) => setState(() => _selectedWordType = t),
                onSelected: isAvailable
                    ? () => setState(() => _selectedMode = mode)
                    : null,
              );
            }),

            const SizedBox(height: 24),

            // Card count
            if (_selectedMode != QuizMode.wordsIDontKnow &&
                _selectedMode != QuizMode.todaysReview) ...[
              Text('Number of Cards',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: [10, 20, 50, 0].map((count) {
                  final isSelected = _cardCount == count;
                  final label = count == 0 ? 'All' : '$count';
                  return GestureDetector(
                    onTap: () => setState(() => _cardCount = count),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(26)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _canStart(allWords, unknownWords, dueWords)
                        ? () => _startQuiz(allWords, unknownWords, dueWords)
                        : null,
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text('Start Quiz'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  bool _isModeAvailable(QuizMode mode, List<WordModel> all,
      List<WordModel> unknown, List<WordModel> due) {
    return switch (mode) {
      QuizMode.mixed => all.isNotEmpty,
      QuizMode.byWordType => all.isNotEmpty,
      QuizMode.selectManually => all.isNotEmpty,
      QuizMode.recentlyAdded => all.where((w) {
            return DateTime.now().difference(w.createdAt).inHours <= 24;
          }).isNotEmpty,
      QuizMode.wordsIDontKnow => unknown.isNotEmpty,
      QuizMode.todaysReview => due.isNotEmpty,
    };
  }

  int _getModeCount(QuizMode mode, List<WordModel> all,
      List<WordModel> unknown, List<WordModel> due) {
    return switch (mode) {
      QuizMode.mixed => all.length,
      QuizMode.byWordType => _selectedWordType != null
          ? all.where((w) => w.type == _selectedWordType).length
          : all.length,
      QuizMode.selectManually => all.length,
      QuizMode.recentlyAdded => all
          .where((w) =>
              DateTime.now().difference(w.createdAt).inHours <= 24)
          .length,
      QuizMode.wordsIDontKnow => unknown.length,
      QuizMode.todaysReview => due.length,
    };
  }

  bool _canStart(List<WordModel> all, List<WordModel> unknown,
      List<WordModel> due) {
    if (_selectedMode == QuizMode.byWordType && _selectedWordType != null) {
      return all.any((w) => w.type == _selectedWordType);
    }
    return _isModeAvailable(_selectedMode, all, unknown, due);
  }

  void _startQuiz(List<WordModel> all, List<WordModel> unknown,
      List<WordModel> due) {
    List<WordModel> words = switch (_selectedMode) {
      QuizMode.mixed => List.from(all),
      QuizMode.byWordType => _selectedWordType != null
          ? all.where((w) => w.type == _selectedWordType).toList()
          : List.from(all),
      QuizMode.selectManually => List.from(all),
      QuizMode.recentlyAdded => all
          .where((w) =>
              DateTime.now().difference(w.createdAt).inHours <= 24)
          .toList(),
      QuizMode.wordsIDontKnow => List.from(unknown),
      QuizMode.todaysReview => List.from(due),
    };

    if (_cardCount > 0 && words.length > _cardCount) {
      words.shuffle();
      words = words.sublist(0, _cardCount);
    }

    ref.read(quizSetupProvider.notifier).state =
        QuizSetupState(mode: _selectedMode, cardCount: _cardCount);
    ref.read(quizProvider.notifier).startQuiz(words);
    context.push('/quiz/flashcard');
  }
}

class _ModeCard extends StatelessWidget {
  final QuizMode mode;
  final bool isSelected;
  final bool isAvailable;
  final int wordCount;
  final WordType? selectedWordType;
  final ValueChanged<WordType?>? onTypeChanged;
  final VoidCallback? onSelected;

  const _ModeCard({
    required this.mode,
    required this.isSelected,
    required this.isAvailable,
    required this.wordCount,
    this.selectedWordType,
    this.onTypeChanged,
    this.onSelected,
  });

  IconData get _icon => switch (mode) {
        QuizMode.mixed => Icons.shuffle_rounded,
        QuizMode.byWordType => Icons.category_outlined,
        QuizMode.selectManually => Icons.checklist_rounded,
        QuizMode.recentlyAdded => Icons.new_releases_outlined,
        QuizMode.wordsIDontKnow => Icons.close_rounded,
        QuizMode.todaysReview => Icons.wb_sunny_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(13)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(26)
                            : (isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_icon,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mode.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : null,
                                  )),
                          Text(
                            '$wordCount word${wordCount == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 20),
                  ],
                ),

                // Word type sub-selector
                if (isSelected && mode == QuizMode.byWordType) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: WordType.values.map((type) {
                      final isSel = selectedWordType == type;
                      return GestureDetector(
                        onTap: () => onTypeChanged?.call(isSel ? null : type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary.withAlpha(26)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                            ),
                          ),
                          child: Text(
                            type.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSel
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                              fontWeight: isSel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
