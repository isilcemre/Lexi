import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/word_model.dart';
import '../../../core/constants/enums.dart';
import '../../languages/providers/language_provider.dart';

// ─── Word Stream ──────────────────────────────────────────────────────

final wordsProvider =
    StreamProvider.family<List<WordModel>, String>((ref, languageId) {
  return ref.watch(firestoreServiceProvider).streamWords(languageId);
});

// ─── Search & Filter ──────────────────────────────────────────────────

final wordSearchQueryProvider = StateProvider<String>((ref) => '');

final wordTypeFilterProvider = StateProvider<WordType?>((ref) => null);

final wordStatusFilterProvider = StateProvider<WordStatus?>((ref) => null);

final filteredWordsProvider =
    Provider.family<List<WordModel>, String>((ref, languageId) {
  final words = ref.watch(wordsProvider(languageId)).value ?? [];
  final query = ref.watch(wordSearchQueryProvider).toLowerCase();
  final typeFilter = ref.watch(wordTypeFilterProvider);
  final statusFilter = ref.watch(wordStatusFilterProvider);

  return words.where((w) {
    final matchesQuery = query.isEmpty ||
        w.word.toLowerCase().contains(query) ||
        w.meanings.any((m) => m.toLowerCase().contains(query));
    final matchesType = typeFilter == null || w.type == typeFilter;
    final matchesStatus = statusFilter == null || w.status == statusFilter;
    return matchesQuery && matchesType && matchesStatus;
  }).toList();
});

// ─── Unknown Words ────────────────────────────────────────────────────

final unknownWordsProvider =
    Provider.family<List<WordModel>, String>((ref, languageId) {
  final words = ref.watch(wordsProvider(languageId)).value ?? [];
  return words.where((w) => w.isUnknown).toList();
});

// ─── Due for Review ───────────────────────────────────────────────────

final dueForReviewProvider =
    Provider.family<List<WordModel>, String>((ref, languageId) {
  final words = ref.watch(wordsProvider(languageId)).value ?? [];
  final now = DateTime.now();
  return words.where((w) {
    final reviewDate = w.nextReviewDate;
    if (reviewDate == null) return false;
    return reviewDate.isBefore(now) ||
        (reviewDate.day == now.day &&
            reviewDate.month == now.month &&
            reviewDate.year == now.year);
  }).toList();
});
