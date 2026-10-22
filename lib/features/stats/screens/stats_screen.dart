import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/words/providers/word_provider.dart';
import '../../../features/quiz/providers/quiz_provider.dart';
import '../../../core/constants/enums.dart';

class StatsScreen extends ConsumerWidget {
  final String languageId;
  final String languageName;

  const StatsScreen({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsProvider(languageId));
    final quizResultsAsync = ref.watch(quizResultsProvider(languageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('$languageName — Stats'),
      ),
      body: wordsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (words) {
          final newCount =
              words.where((w) => w.status == WordStatus.newWord).length;
          final learningCount =
              words.where((w) => w.status == WordStatus.learning).length;
          final knownCount =
              words.where((w) => w.status == WordStatus.known).length;

          // Type distribution
          final typeCounts = <WordType, int>{};
          for (final type in WordType.values) {
            typeCounts[type] = words.where((w) => w.type == type).length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview cards
                Text('Overview',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _BigStatCard(
                        value: '${words.length}',
                        label: 'Total Words',
                        icon: Icons.library_books_rounded,
                        gradient: const [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BigStatCard(
                        value: '${words.where((w) => w.isUnknown == true).length}',
                        label: 'To Practice',
                        icon: Icons.flag_rounded,
                        gradient: const [AppColors.accent, Color(0xFFFF9F9F)],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 12),

                // Status distribution
                Row(
                  children: [
                    Expanded(
                      child: _StatusCard(
                        label: 'NEW',
                        count: newCount,
                        color: AppColors.statusNew,
                        icon: Icons.fiber_new_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatusCard(
                        label: 'LEARNING',
                        count: learningCount,
                        color: AppColors.statusLearning,
                        icon: Icons.school_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatusCard(
                        label: 'KNOWN',
                        count: knownCount,
                        color: AppColors.statusKnown,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Status pie chart
                if (words.isNotEmpty) ...[
                  Text('Status Distribution',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _StatusPieChart(
                    newCount: newCount,
                    learningCount: learningCount,
                    knownCount: knownCount,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                ],

                // Word type distribution
                if (words.isNotEmpty) ...[
                  Text('Word Types',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _WordTypeList(typeCounts: typeCounts, total: words.length),
                  const SizedBox(height: 24),
                ],

                // Quiz history
                Text('Recent Quizzes',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                quizResultsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (results) {
                    if (results.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'No quizzes taken yet.\nStart your first quiz!',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return _QuizHistoryList(results: results);
                  },
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<Color> gradient;

  const _BigStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withAlpha(204), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatusCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
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
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withAlpha(180),
                letterSpacing: 0.5,
              )),
        ],
      ),
    );
  }
}

class _StatusPieChart extends StatefulWidget {
  final int newCount;
  final int learningCount;
  final int knownCount;

  const _StatusPieChart({
    required this.newCount,
    required this.learningCount,
    required this.knownCount,
  });

  @override
  State<_StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<_StatusPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total =
        widget.newCount + widget.learningCount + widget.knownCount;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: [
                  _buildSection(0, widget.newCount, total,
                      AppColors.statusNew, 'NEW'),
                  _buildSection(1, widget.learningCount, total,
                      AppColors.statusLearning, 'LEARNING'),
                  _buildSection(2, widget.knownCount, total,
                      AppColors.statusKnown, 'KNOWN'),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend('NEW', AppColors.statusNew, widget.newCount),
              const SizedBox(height: 10),
              _Legend('LEARNING', AppColors.statusLearning,
                  widget.learningCount),
              const SizedBox(height: 10),
              _Legend('KNOWN', AppColors.statusKnown, widget.knownCount),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildSection(
      int index, int count, int total, Color color, String label) {
    final isTouched = index == _touchedIndex;
    final pct = total == 0 ? 0.0 : (count / total) * 100;
    return PieChartSectionData(
      color: color,
      value: count.toDouble(),
      title: isTouched ? '${pct.round()}%' : '',
      radius: isTouched ? 55 : 45,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  final int count;

  const _Legend(this.label, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WordTypeList extends StatelessWidget {
  final Map<WordType, int> typeCounts;
  final int total;

  const _WordTypeList({required this.typeCounts, required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nonEmpty = typeCounts.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (nonEmpty.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
        itemCount: nonEmpty.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = nonEmpty[index];
          final type = entry.key;
          final count = entry.value;
          final pct = total == 0 ? 0.0 : (count / total);
          final color = switch (type) {
            WordType.noun => AppColors.noun,
            WordType.verb => AppColors.verb,
            WordType.adjective => AppColors.adjective,
            WordType.adverb => AppColors.adverb,
            WordType.pronoun => AppColors.pronoun,
            WordType.preposition => AppColors.preposition,
            WordType.conjunction => AppColors.conjunction,
            WordType.phrase => AppColors.phrase,
            WordType.idiom => AppColors.idiom,
            WordType.phrasalVerb => AppColors.phrasalVerb,
            WordType.collocation => AppColors.collocation,
          };

          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(type.label,
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(pct * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withAlpha(26),
                    color: color,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuizHistoryList extends StatelessWidget {
  final List<dynamic> results;

  const _QuizHistoryList({required this.results});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
        itemCount: results.length.clamp(0, 10),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = results[index];
          final pct = result.successRate;
          final color = pct >= 80
              ? AppColors.statusKnown
              : pct >= 50
                  ? AppColors.statusLearning
                  : AppColors.statusUnknown;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${pct.round()}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.totalWords} words · ${result.mode.label}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${result.knownCount} known, ${result.unknownCount} unknown',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(result.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }
}
