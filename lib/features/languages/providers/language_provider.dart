import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/language_model.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// ─── Language Providers ──────────────────────────────────────────────

final languagesProvider = StreamProvider<List<LanguageModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamLanguages();
});

final selectedLanguageIdProvider = StateProvider<String?>((ref) => null);

final selectedLanguageProvider = Provider<LanguageModel?>((ref) {
  final id = ref.watch(selectedLanguageIdProvider);
  if (id == null) return null;
  final languages = ref.watch(languagesProvider).value ?? [];
  if (languages.isEmpty) return null;
  try {
    return languages.firstWhere((l) => l.id == id);
  } catch (_) {
    return languages.first;
  }
});
