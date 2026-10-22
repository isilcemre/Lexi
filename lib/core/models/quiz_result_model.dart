import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/enums.dart';

class QuizResultModel {
  final String id;
  final String languageId;
  final DateTime date;
  final int totalWords;
  final int knownCount;
  final int unknownCount;
  final List<String> unknownWordIds;
  final List<String> unknownWordTexts;
  final QuizMode mode;
  final int durationSeconds;

  QuizResultModel({
    required this.id,
    required this.languageId,
    required this.date,
    required this.totalWords,
    required this.knownCount,
    required this.unknownCount,
    required this.unknownWordIds,
    required this.unknownWordTexts,
    required this.mode,
    required this.durationSeconds,
  });

  double get successRate =>
      totalWords == 0 ? 0 : (knownCount / totalWords) * 100;

  factory QuizResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizResultModel(
      id: doc.id,
      languageId: data['languageId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalWords: data['totalWords'] ?? 0,
      knownCount: data['knownCount'] ?? 0,
      unknownCount: data['unknownCount'] ?? 0,
      unknownWordIds: List<String>.from(data['unknownWordIds'] ?? []),
      unknownWordTexts: List<String>.from(data['unknownWordTexts'] ?? []),
      mode: QuizMode.values.firstWhere(
        (e) => e.name == data['mode'],
        orElse: () => QuizMode.mixed,
      ),
      durationSeconds: data['durationSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'languageId': languageId,
      'date': Timestamp.fromDate(date),
      'totalWords': totalWords,
      'knownCount': knownCount,
      'unknownCount': unknownCount,
      'unknownWordIds': unknownWordIds,
      'unknownWordTexts': unknownWordTexts,
      'mode': mode.name,
      'durationSeconds': durationSeconds,
    };
  }
}
