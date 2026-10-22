import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/language_model.dart';
import '../models/word_model.dart';
import '../models/quiz_result_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _languages =>
      _db.collection('users').doc(_uid).collection('languages');

  CollectionReference get _words =>
      _db.collection('users').doc(_uid).collection('words');

  CollectionReference get _quizResults =>
      _db.collection('users').doc(_uid).collection('quizResults');

  // ─── Languages ───────────────────────────────────────────────────

  Stream<List<LanguageModel>> streamLanguages() {
    return _languages
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LanguageModel.fromFirestore(d)).toList());
  }

  Future<LanguageModel> addLanguage(String name, String emoji) async {
    final doc = await _languages.add({
      'name': name,
      'emoji': emoji,
      'createdAt': FieldValue.serverTimestamp(),
      'totalWords': 0,
      'newCount': 0,
      'learningCount': 0,
      'knownCount': 0,
    });
    final snap = await doc.get();
    return LanguageModel.fromFirestore(snap);
  }

  Future<void> deleteLanguage(String languageId) async {
    // Delete all words for this language
    final words = await _words
        .where('languageId', isEqualTo: languageId)
        .get();
    final batch = _db.batch();
    for (final doc in words.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_languages.doc(languageId));
    await batch.commit();
  }

  Future<void> updateLanguageStats(String languageId) async {
    final snap = await _words
        .where('languageId', isEqualTo: languageId)
        .get();
    
    int total = snap.docs.length;
    int newCount = 0, learningCount = 0, knownCount = 0;
    
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'newWord';
      if (status == 'newWord') { newCount++; }
      else if (status == 'learning') { learningCount++; }
      else if (status == 'known') { knownCount++; }
    }

    await _languages.doc(languageId).update({
      'totalWords': total,
      'newCount': newCount,
      'learningCount': learningCount,
      'knownCount': knownCount,
    });
  }

  // ─── Words ───────────────────────────────────────────────────────

  Stream<List<WordModel>> streamWords(String languageId) {
    return _words
        .where('languageId', isEqualTo: languageId)
        .orderBy('word', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => WordModel.fromFirestore(d)).toList());
  }

  Future<WordModel> addWord(WordModel word) async {
    final doc = await _words.add(word.toFirestore());
    await updateLanguageStats(word.languageId);
    final snap = await doc.get();
    return WordModel.fromFirestore(snap);
  }

  Future<void> updateWord(WordModel word) async {
    await _words.doc(word.id).update(word.toFirestore());
    await updateLanguageStats(word.languageId);
  }

  Future<void> deleteWord(WordModel word) async {
    await _words.doc(word.id).delete();
    await updateLanguageStats(word.languageId);
  }

  Future<List<WordModel>> getWordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids.map((id) => _words.doc(id).get());
    final snaps = await Future.wait(futures);
    return snaps
        .where((s) => s.exists)
        .map((s) => WordModel.fromFirestore(s))
        .toList();
  }

  Future<List<WordModel>> getRecentlyAddedWords(
      String languageId, int hours) async {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    final snap = await _words
        .where('languageId', isEqualTo: languageId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .get();
    return snap.docs.map((d) => WordModel.fromFirestore(d)).toList();
  }

  Future<List<WordModel>> getUnknownWords(String languageId) async {
    final snap = await _words
        .where('languageId', isEqualTo: languageId)
        .where('isUnknown', isEqualTo: true)
        .get();
    return snap.docs.map((d) => WordModel.fromFirestore(d)).toList();
  }

  Future<List<WordModel>> getDueForReview(String languageId) async {
    final snap = await _words
        .where('languageId', isEqualTo: languageId)
        .where('nextReviewDate',
            isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .get();
    return snap.docs.map((d) => WordModel.fromFirestore(d)).toList();
  }

  // ─── Quiz Results ─────────────────────────────────────────────────

  Stream<List<QuizResultModel>> streamQuizResults(String languageId) {
    return _quizResults
        .where('languageId', isEqualTo: languageId)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuizResultModel.fromFirestore(d)).toList());
  }

  Future<void> saveQuizResult(QuizResultModel result) async {
    await _quizResults.add(result.toFirestore());
  }
}
