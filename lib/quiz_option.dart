class QuizOption {
  final int id;
  final String description;
  final bool isCorrect;
  final String? photoUrl;

  QuizOption({
    required this.id,
    required this.description,
    required this.isCorrect,
    this.photoUrl,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      photoUrl: json['photo_url'],
    );
  }
}