import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/enums.dart';

class WordModel {
  final String id;
  final String languageId;
  final String word;
  final List<String> meanings;
  final WordType type;
  final String? note;
  final WordStatus status;
  final bool isUnknown;
  final int unknownCount;
  final int correctCount;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;

  // Computed getters
  String get meaning => meanings.isNotEmpty ? meanings.first : '';
  String get allMeaningsText => meanings.join(', ');

  // Spaced Repetition fields (SM-2)
  final DateTime? nextReviewDate;
  final int interval; // days
  final double easeFactor;
  final int repetitions;

  WordModel({
    required this.id,
    required this.languageId,
    required this.word,
    required this.meanings,
    required this.type,
    this.note,
    this.status = WordStatus.newWord,
    this.isUnknown = false,
    this.unknownCount = 0,
    this.correctCount = 0,
    required this.createdAt,
    this.lastReviewedAt,
    this.nextReviewDate,
    this.interval = 1,
    this.easeFactor = 2.5,
    this.repetitions = 0,
  });

  factory WordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final meaningsRaw = data['meanings'];
    final List<String> meaningsList;
    if (meaningsRaw is List) {
      meaningsList = meaningsRaw.map((e) => e.toString()).toList();
    } else {
      meaningsList = [data['meaning'] ?? ''];
    }

    return WordModel(
      id: doc.id,
      languageId: data['languageId'] ?? '',
      word: data['word'] ?? '',
      meanings: meaningsList,
      type: WordType.fromString(data['type'] ?? 'other'),
      note: data['note'],
      status: WordStatus.fromString(data['status'] ?? 'newWord'),
      isUnknown: data['isUnknown'] ?? false,
      unknownCount: data['unknownCount'] ?? 0,
      correctCount: data['correctCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastReviewedAt: (data['lastReviewedAt'] as Timestamp?)?.toDate(),
      nextReviewDate: (data['nextReviewDate'] as Timestamp?)?.toDate(),
      interval: data['interval'] ?? 1,
      easeFactor: (data['easeFactor'] ?? 2.5).toDouble(),
      repetitions: data['repetitions'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'languageId': languageId,
      'word': word,
      'meaning': meaning,
      'meanings': meanings,
      'type': type.name,
      'note': note,
      'status': status.name,
      'isUnknown': isUnknown,
      'unknownCount': unknownCount,
      'correctCount': correctCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastReviewedAt':
          lastReviewedAt != null ? Timestamp.fromDate(lastReviewedAt!) : null,
      'nextReviewDate':
          nextReviewDate != null ? Timestamp.fromDate(nextReviewDate!) : null,
      'interval': interval,
      'easeFactor': easeFactor,
      'repetitions': repetitions,
    };
  }

  WordModel copyWith({
    String? id,
    String? languageId,
    String? word,
    List<String>? meanings,
    WordType? type,
    String? note,
    WordStatus? status,
    bool? isUnknown,
    int? unknownCount,
    int? correctCount,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewDate,
    int? interval,
    double? easeFactor,
    int? repetitions,
  }) {
    return WordModel(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      word: word ?? this.word,
      meanings: meanings ?? this.meanings,
      type: type ?? this.type,
      note: note ?? this.note,
      status: status ?? this.status,
      isUnknown: isUnknown ?? this.isUnknown,
      unknownCount: unknownCount ?? this.unknownCount,
      correctCount: correctCount ?? this.correctCount,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
    );
  }
}
