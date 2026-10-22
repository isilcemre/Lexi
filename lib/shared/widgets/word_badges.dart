import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';

class WordTypeBadge extends StatelessWidget {
  final WordType type;
  final bool small;

  const WordTypeBadge({super.key, required this.type, this.small = false});

  Color get _color {
    return switch (type) {
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
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final fontSize = small ? 10.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class WordStatusBadge extends StatelessWidget {
  final WordStatus status;

  const WordStatusBadge({super.key, required this.status});

  Color get _color {
    return switch (status) {
      WordStatus.newWord => AppColors.statusNew,
      WordStatus.learning => AppColors.statusLearning,
      WordStatus.known => AppColors.statusKnown,
    };
  }

  IconData get _icon {
    return switch (status) {
      WordStatus.newWord => Icons.fiber_new_rounded,
      WordStatus.learning => Icons.school_rounded,
      WordStatus.known => Icons.check_circle_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
