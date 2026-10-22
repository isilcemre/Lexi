enum WordType {
  noun('Noun'),
  verb('Verb'),
  adjective('Adjective'),
  adverb('Adverb'),
  pronoun('Pronoun'),
  preposition('Preposition'),
  conjunction('Conjunction'),
  phrase('Phrase'),
  idiom('Idiom'),
  phrasalVerb('Phrasal Verb'),
  collocation('Collocation');

  final String label;
  const WordType(this.label);

  static WordType fromString(String value) {
    return WordType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WordType.noun,
    );
  }
}

enum WordStatus {
  newWord('NEW'),
  learning('LEARNING'),
  known('KNOWN');

  final String label;
  const WordStatus(this.label);

  static WordStatus fromString(String value) {
    return WordStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WordStatus.newWord,
    );
  }
}

enum QuizMode {
  mixed('Mixed'),
  byWordType('By Word Type'),
  selectManually('Select Manually'),
  recentlyAdded('Recently Added'),
  wordsIDontKnow("Words I Don't Know"),
  todaysReview("Today's Review");

  final String label;
  const QuizMode(this.label);
}
