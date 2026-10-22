import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/language_card.dart';
import '../widgets/add_language_dialog.dart';
import '../widgets/today_review_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(languagesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            expandedHeight: 120,
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Languages',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          languagesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (languages) {
              if (languages.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    onAdd: () => _showAddLanguage(context, ref),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TodayReviewBanner(languages: languages),
                            const SizedBox(height: 16),
                            Text(
                              '${languages.length} language${languages.length == 1 ? '' : 's'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }
                      final lang = languages[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LanguageCard(language: lang)
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 60 * index),
                              duration: 400.ms,
                            )
                            .slideY(begin: 0.3, end: 0),
                      );
                    },
                    childCount: languages.length + 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLanguage(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Language'),
      ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  void _showAddLanguage(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLanguageDialog(
        onAdd: (name, emoji) async {
          await ref.read(firestoreServiceProvider).addLanguage(name, emoji);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(51),
                    AppColors.secondary.withAlpha(51),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.translate_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 2000.ms, begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05)),
            const SizedBox(height: 28),
            Text(
              'Start your journey',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add a language to start building\nyour vocabulary collection.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Language'),
            ),
          ],
        ),
      ),
    );
  }
}
