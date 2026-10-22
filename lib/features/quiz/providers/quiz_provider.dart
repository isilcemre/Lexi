import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/word_model.dart';
import '../../../core/models/quiz_result_model.dart';
import '../../../core/constants/enums.dart';
import '../../../core/services/spaced_repetition_service.dart';
import '../../languages/providers/language_provider.dart';
import 'package:uuid/uuid.dart';

// ─── Quiz Setup State ─────────────────────────────────────────────────

class QuizSetupState {
  final QuizMode mode;
  final WordType? wordTypeFilter;
  final List<String> selectedWordIds;
  final int cardCount; // 0 = all

  const QuizSetupState({
    this.mode = QuizMode.mixed,
    this.wordTypeFilter,
    this.selectedWordIds = const [],
    this.cardCount = 20,
  });

  QuizSetupState copyWith({
    QuizMode? mode,
    WordType? wordTypeFilter,
    List<String>? selectedWordIds,
    int? cardCount,
  }) {
    return QuizSetupState(
      mode: mode ?? this.mode,
      wordTypeFilter: wordTypeFilter ?? this.wordTypeFilter,
      selectedWordIds: selectedWordIds ?? this.selectedWordIds,
      cardCount: cardCount ?? this.cardCount,
    );
  }
}

final quizSetupProvider =
    StateProvider<QuizSetupState>((ref) => const QuizSetupState());

// ─── Active Quiz State ────────────────────────────────────────────────

class QuizState {
  final List<WordModel> words;
  final int currentIndex;
  final List<String> knownWordIds;
  final List<String> unknownWordIds;
  final List<String> unknownWordTexts;
  final bool isFlipped;
  final bool isFinished;
  final DateTime startTime;

  const QuizState({
    this.words = const [],
    this.currentIndex = 0,
    this.knownWordIds = const [],
    this.unknownWordIds = const [],
    this.unknownWordTexts = const [],
    this.isFlipped = false,
    this.isFinished = false,
    required this.startTime,
  });

  WordModel? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;
  bool get hasNext => currentIndex < words.length - 1;
  double get progress =>
      words.isEmpty ? 0 : currentIndex / words.length;

  QuizState copyWith({
    List<WordModel>? words,
    int? currentIndex,
    List<String>? knownWordIds,
    List<String>? unknownWordIds,
    List<String>? unknownWordTexts,
    bool? isFlipped,
    bool? isFinished,
    DateTime? startTime,
  }) {
    return QuizState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      knownWordIds: knownWordIds ?? this.knownWordIds,
      unknownWordIds: unknownWordIds ?? this.unknownWordIds,
      unknownWordTexts: unknownWordTexts ?? this.unknownWordTexts,
      isFlipped: isFlipped ?? this.isFlipped,
      isFinished: isFinished ?? this.isFinished,
      startTime: startTime ?? this.startTime,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref _ref;

  QuizNotifier(this._ref)
      : super(QuizState(startTime: DateTime.now()));

  void startQuiz(List<WordModel> words) {
    state = QuizState(
      words: words..shuffle(),
      startTime: DateTime.now(),
    );
  }

  void flipCard() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  Future<void> answerKnown() async {
    final word = state.currentWord;
    if (word == null) return;

    final updated = SpacedRepetitionService.updateAfterReview(
      word: word,
      knew: true,
    );
    await _ref.read(firestoreServiceProvider).updateWord(updated);

    final newKnown = [...state.knownWordIds, word.id];

    if (!state.hasNext) {
      state = state.copyWith(
        knownWordIds: newKnown,
        isFinished: true,
        currentIndex: state.currentIndex + 1,
      );
      await _saveResult();
    } else {
      state = state.copyWith(
        knownWordIds: newKnown,
        currentIndex: state.currentIndex + 1,
        isFlipped: false,
      );
    }
  }

  Future<void> answerUnknown() async {
    final word = state.currentWord;
    if (word == null) return;

    final updated = SpacedRepetitionService.updateAfterReview(
      word: word,
      knew: false,
    );
    await _ref.read(firestoreServiceProvider).updateWord(updated);

    final newUnknownIds = [...state.unknownWordIds, word.id];
    final newUnknownTexts = [...state.unknownWordTexts, word.word];

    if (!state.hasNext) {
      state = state.copyWith(
        unknownWordIds: newUnknownIds,
        unknownWordTexts: newUnknownTexts,
        isFinished: true,
        currentIndex: state.currentIndex + 1,
      );
      await _saveResult();
    } else {
      state = state.copyWith(
        unknownWordIds: newUnknownIds,
        unknownWordTexts: newUnknownTexts,
        currentIndex: state.currentIndex + 1,
        isFlipped: false,
      );
    }
  }

  Future<void> _saveResult() async {
    if (state.words.isEmpty) return;
    final languageId = state.words.first.languageId;
    final duration =
        DateTime.now().difference(state.startTime).inSeconds;
    final setup = _ref.read(quizSetupProvider);

    final result = QuizResultModel(
      id: const Uuid().v4(),
      languageId: languageId,
      date: DateTime.now(),
      totalWords: state.words.length,
      knownCount: state.knownWordIds.length,
      unknownCount: state.unknownWordIds.length,
      unknownWordIds: state.unknownWordIds,
      unknownWordTexts: state.unknownWordTexts,
      mode: setup.mode,
      durationSeconds: duration,
    );

    await _ref.read(firestoreServiceProvider).saveQuizResult(result);
  }

  void reset() {
    state = QuizState(startTime: DateTime.now());
  }
}

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});

// ─── Quiz Results ─────────────────────────────────────────────────────

final quizResultsProvider =
    StreamProvider.family<List<QuizResultModel>, String>(
        (ref, languageId) {
  return ref.watch(firestoreServiceProvider).streamQuizResults(languageId);
});
