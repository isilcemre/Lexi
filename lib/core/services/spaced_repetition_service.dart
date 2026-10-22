import '../models/word_model.dart';
import '../constants/enums.dart';

/// SM-2 Spaced Repetition Algorithm
/// Quality: 0-5 scale
///   0-2: Incorrect (forgot)
///   3:   Correct but hesitant
///   4:   Correct
///   5:   Perfect recall
class SpacedRepetitionService {
  static const double _minEaseFactor = 1.3;
  static const double _defaultEaseFactor = 2.5;

  /// Update a word's SR parameters after a quiz response
  /// [knew] true = user knew the word, false = didn't know
  static WordModel updateAfterReview({
    required WordModel word,
    required bool knew,
  }) {
    final quality = knew ? 4 : 1;
    return _applySmTwo(word: word, quality: quality);
  }

  static WordModel _applySmTwo({
    required WordModel word,
    required int quality,
  }) {
    int newRepetitions = word.repetitions;
    int newInterval = word.interval;
    double newEaseFactor = word.easeFactor;

    if (quality >= 3) {
      // Correct answer
      if (newRepetitions == 0) {
        newInterval = 1;
      } else if (newRepetitions == 1) {
        newInterval = 3;
      } else {
        newInterval = (newInterval * newEaseFactor).round();
      }
      newRepetitions++;
    } else {
      // Incorrect — reset
      newRepetitions = 0;
      newInterval = 1;
    }

    // Update ease factor
    newEaseFactor = newEaseFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEaseFactor < _minEaseFactor) {
      newEaseFactor = _minEaseFactor;
    }

    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));
    final now = DateTime.now();

    // Determine new status
    var newStatus = word.status;
    if (quality >= 3) {
      if (newRepetitions >= 5) {
        newStatus = WordStatus.known;
      } else if (newRepetitions >= 1) {
        newStatus = WordStatus.learning;
      }
    }

    return word.copyWith(
      repetitions: newRepetitions,
      interval: newInterval,
      easeFactor: newEaseFactor,
      nextReviewDate: nextReviewDate,
      lastReviewedAt: now,
      status: newStatus,
      correctCount: quality >= 3 ? word.correctCount + 1 : word.correctCount,
      unknownCount: quality < 3 ? word.unknownCount + 1 : word.unknownCount,
      isUnknown: quality < 3 ? true : (word.correctCount >= 2 ? false : word.isUnknown),
    );
  }

  /// Words due for review today
  static List<WordModel> getDueWords(List<WordModel> words) {
    final now = DateTime.now();
    return words.where((w) {
      if (w.nextReviewDate == null) return false;
      return w.nextReviewDate!.isBefore(now) ||
          _isSameDay(w.nextReviewDate!, now);
    }).toList();
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Initial ease factor for new cards
  static double get defaultEaseFactor => _defaultEaseFactor;
}
