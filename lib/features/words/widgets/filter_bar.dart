import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/word_provider.dart';

class FilterBar extends ConsumerWidget {
  final String languageId;

  const FilterBar({super.key, required this.languageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeFilter = ref.watch(wordTypeFilterProvider);
    final statusFilter = ref.watch(wordStatusFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Status filters
          ...WordStatus.values.map((status) {
            final isSelected = statusFilter == status;
            final color = switch (status) {
              WordStatus.newWord => AppColors.statusNew,
              WordStatus.learning => AppColors.statusLearning,
              WordStatus.known => AppColors.statusKnown,
            };
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _FilterChip(
                label: status.label,
                isSelected: isSelected,
                color: color,
                onSelected: (selected) {
                  ref.read(wordStatusFilterProvider.notifier).state =
                      selected ? status : null;
                },
              ),
            );
          }),

          // Divider
          Container(
            width: 1,
            height: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Type filters
          ...WordType.values.map((type) {
            final isSelected = typeFilter == type;
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
              padding: const EdgeInsets.only(right: 6),
              child: _FilterChip(
                label: type.label,
                isSelected: isSelected,
                color: color,
                onSelected: (selected) {
                  ref.read(wordTypeFilterProvider.notifier).state =
                      selected ? type : null;
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
