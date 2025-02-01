import 'package:quiz_app/quiz_option.dart';

class QuizQuestion {
  final int id;
  final String description;
  final String topic;
  final String detailedSolution;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.description,
    required this.topic,
    required this.detailedSolution,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      topic: json['topic'] ?? '',
      detailedSolution: json['detailed_solution'] ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => QuizOption.fromJson(o))
          .toList() ?? [],
    );
  }
}