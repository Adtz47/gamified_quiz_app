import 'package:quiz_app/quiz_question.dart';

class Quiz {
  final int id;
  final String title;
  final String topic;
  final String description;
  final int duration;
  final String correctAnswerMarks;
  final String negativeMarks;
  final bool shuffle;
  final bool showAnswers;
  final int questionsCount;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.topic,
    required this.description,
    required this.duration,
    required this.correctAnswerMarks,
    required this.negativeMarks,
    required this.shuffle,
    required this.showAnswers,
    required this.questionsCount,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      topic: json['topic'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      correctAnswerMarks: json['correct_answer_marks'] ?? '0.0',
      negativeMarks: json['negative_marks'] ?? '0.0',
      shuffle: json['shuffle'] ?? false,
      showAnswers: json['show_answers'] ?? false,
      questionsCount: json['questions_count'] ?? 0,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => QuizQuestion.fromJson(q))
          .toList() ?? [],
    );
  }
}