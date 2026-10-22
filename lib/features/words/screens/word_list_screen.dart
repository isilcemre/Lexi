import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/word_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/word_model.dart';
import '../widgets/word_list_item.dart';
import '../widgets/filter_bar.dart';

class WordListScreen extends ConsumerStatefulWidget {
  final String languageId;
  final String languageName;

  const WordListScreen({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  ConsumerState<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends ConsumerState<WordListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(filteredWordsProvider(widget.languageId));
    final unknownWords = ref.watch(unknownWordsProvider(widget.languageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(widget.languageName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  tooltip: 'Stats',
                  onPressed: () => context.push(
                    '/language/${widget.languageId}/words/stats?name=${Uri.encodeComponent(widget.languageName)}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.quiz_rounded),
                  tooltip: 'Quiz',
                  onPressed: () => context.push(
                    '/language/${widget.languageId}/words/quiz?name=${Uri.encodeComponent(widget.languageName)}',
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.list_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Words (${words.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text("Unknown (${unknownWords.length})"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Search & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) =>
                        ref.read(wordSearchQueryProvider.notifier).state = v,
                    decoration: InputDecoration(
                      hintText: 'Search words...',
                      prefixIcon:
                          const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref
                                    .read(wordSearchQueryProvider.notifier)
                                    .state = '';
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Filter chips
                  FilterBar(languageId: widget.languageId),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All Words tab
                  _WordListTab(
                    words: words,
                    languageId: widget.languageId,
                    languageName: widget.languageName,
                  ),
                  // Unknown Words tab
                  _UnknownWordsTab(
                    words: unknownWords,
                    languageId: widget.languageId,
                    languageName: widget.languageName,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_word',
        onPressed: () => context.push(
          '/language/${widget.languageId}/words/add',
        ),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
    );
  }
}

class _WordListTab extends StatelessWidget {
  final List<WordModel> words;
  final String languageId;
  final String languageName;

  const _WordListTab({
    required this.words,
    required this.languageId,
    required this.languageName,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextHint
                    : AppColors.lightTextHint),
            const SizedBox(height: 16),
            Text('No words found',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Try adjusting your filters',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: words.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return WordListItem(
          word: words[index],
          onTap: () => context.push(
            '/language/$languageId/words/detail',
            extra: words[index],
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 30 * index), duration: 300.ms);
      },
    );
  }
}

class _UnknownWordsTab extends StatelessWidget {
  final List<WordModel> words;
  final String languageId;
  final String languageName;

  const _UnknownWordsTab({
    required this.words,
    required this.languageId,
    required this.languageName,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 64, color: AppColors.statusKnown),
            const SizedBox(height: 16),
            Text("No unknown words! 🎉",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Keep up the great work",
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${words.length} word${words.length == 1 ? '' : 's'} to practice',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to quiz with unknown words mode
                  context.push(
                    '/language/$languageId/words/quiz?name=${Uri.encodeComponent(languageName)}',
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Practice'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: words.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return WordListItem(
                word: words[index],
                showUnknownBadge: true,
                onTap: () => context.push(
                  '/language/$languageId/words/detail',
                  extra: words[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
