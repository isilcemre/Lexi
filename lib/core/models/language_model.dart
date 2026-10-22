import 'package:cloud_firestore/cloud_firestore.dart';

class LanguageModel {
  final String id;
  final String name;
  final String emoji;
  final DateTime createdAt;
  final int totalWords;
  final int newCount;
  final int learningCount;
  final int knownCount;

  LanguageModel({
    required this.id,
    required this.name,
    this.emoji = '📖',
    required this.createdAt,
    this.totalWords = 0,
    this.newCount = 0,
    this.learningCount = 0,
    this.knownCount = 0,
  });

  factory LanguageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LanguageModel(
      id: doc.id,
      name: data['name'] ?? '',
      emoji: data['emoji'] ?? '📖',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalWords: data['totalWords'] ?? 0,
      newCount: data['newCount'] ?? 0,
      learningCount: data['learningCount'] ?? 0,
      knownCount: data['knownCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'emoji': emoji,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalWords': totalWords,
      'newCount': newCount,
      'learningCount': learningCount,
      'knownCount': knownCount,
    };
  }

  LanguageModel copyWith({
    String? id,
    String? name,
    String? emoji,
    DateTime? createdAt,
    int? totalWords,
    int? newCount,
    int? learningCount,
    int? knownCount,
  }) {
    return LanguageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      totalWords: totalWords ?? this.totalWords,
      newCount: newCount ?? this.newCount,
      learningCount: learningCount ?? this.learningCount,
      knownCount: knownCount ?? this.knownCount,
    );
  }
}
