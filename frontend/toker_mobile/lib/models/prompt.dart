enum PromptCategory {
  aboutMe('À propos de moi'),
  myType('Mon type'),
  myWorld('Ton univers'),
  selfCare('Self-care'),
  personal('Plus personnel'),
  photoCaption('Légende photo'); // NEW: for photo captions

  final String label;
  const PromptCategory(this.label);
}

class Prompt {
  final String question;
  final String answer;
  final PromptCategory? category;

  Prompt({
    required this.question,
    required this.answer,
    this.category,
  });

  Prompt copyWith({
    String? question,
    String? answer,
    PromptCategory? category,
  }) {
    return Prompt(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'category': category?.name,
    };
  }

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] != null
          ? PromptCategory.values.firstWhere((e) => e.name == json['category'])
          : null,
    );
  }

  // Categorized prompts (Hinge-style)
  static const Map<PromptCategory, List<String>> categorizedQuestions = {
    PromptCategory.aboutMe: [
      'Dans mon groupe d\'amis je suis...',
      'Le truc le plus random que j\'adore...',
      'Mon talent caché c\'est...',
      'Un truc sur moi que personne ne devine...',
      'Ce qui me rend unique...',
    ],
    PromptCategory.myType: [
      'On s\'entendra si...',
      'Ce que je cherche chez quelqu\'un...',
      'Le meilleur premier date serait...',
      'Je suis attiré(e) par...',
    ],
    PromptCategory.myWorld: [
      'Ma passion secrète c\'est...',
      'Mon endroit préféré au monde...',
      'Je ne peux pas vivre sans...',
      'Ma définition d\'une bonne soirée...',
    ],
    PromptCategory.selfCare: [
      'Pour me détendre je...',
      'Mon rituel du matin c\'est...',
      'Ce qui me fait du bien...',
    ],
    PromptCategory.personal: [
      'Ma plus grande fierté...',
      'Le meilleur conseil qu\'on m\'ait donné...',
      'Si je pouvais dîner avec quelqu\'un...',
      'Ce qui me fait rire à coup sûr...',
    ],
    PromptCategory.photoCaption: [
      'Quand je me la joue sérieux',
      'Mode vacances activé',
      'Dimanche typique',
      'Ma passion en image',
      'Avec mes gens préférés',
      'Moment de fierté',
      'Juste moi étant moi',
      'Aventure du jour',
      'Mon endroit favori',
      'Vibes du moment',
      'En mode détente',
      'Souvenir inoubliable',
    ],
  };

  // Flat list for backward compatibility (text prompts only)
  static List<String> get availableQuestions {
    return categorizedQuestions.entries
        .where((entry) => entry.key != PromptCategory.photoCaption)
        .expand((entry) => entry.value)
        .toList();
  }

  // Photo caption prompts only
  static List<String> get photoCaptionPrompts {
    return categorizedQuestions[PromptCategory.photoCaption] ?? [];
  }

  // Get category for a question
  static PromptCategory? getCategoryForQuestion(String question) {
    for (final entry in categorizedQuestions.entries) {
      if (entry.value.contains(question)) {
        return entry.key;
      }
    }
    return null;
  }
}
