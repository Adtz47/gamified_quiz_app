// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/quiz_option.dart';
import '../quiz.dart';
import '../quiz_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  Quiz? quiz;
  int currentQuestionIndex = 0;
  double score = 0;
  bool isLoading = true;
  int streak = 0;
  int coins = 0;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final fetchedQuiz = await _quizService.fetchQuiz();
      setState(() {
        quiz = fetchedQuiz;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error loading quiz: $e';
      });
      print('Error loading quiz: $e'); // For debugging
    }
  }

  void _handleAnswer(int selectedIndex) {
    if (quiz == null) return;
    
    QuizOption selectedOption = quiz!.questions[currentQuestionIndex].options[selectedIndex];
    
    if (selectedOption.isCorrect) {
      setState(() {
        score += double.parse(quiz!.correctAnswerMarks);
        streak++;
        coins += streak * 5;
      });
      _showSuccessDialog(selectedOption);
    } else {
      setState(() {
        score -= double.parse(quiz!.negativeMarks);
        streak = 0;
      });
      _showFailureDialog(selectedOption);
    }
  }

  void _showSuccessDialog(QuizOption selectedOption) {
    if (quiz == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Correct!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You earned:'),
            SizedBox(height: 8),
            Text('• ${quiz!.correctAnswerMarks} marks'),
            Text('• ${streak * 5} coins'),
            if (streak > 1) Text('🔥 ${streak}x Streak Bonus!'),
            if (quiz!.questions[currentQuestionIndex].detailedSolution.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Explanation:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(quiz!.questions[currentQuestionIndex].detailedSolution),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextQuestion();
            },
            child: Text('Next Question'),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(QuizOption selectedOption) {
    if (quiz == null) return;
    
    QuizOption correctOption = quiz!.questions[currentQuestionIndex].options
        .firstWhere((option) => option.isCorrect);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.close, color: Colors.red),
            SizedBox(width: 8),
            Text('Incorrect'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correct answer:'),
            SizedBox(height: 8),
            Text(
              correctOption.description,
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            if (quiz!.questions[currentQuestionIndex].detailedSolution.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Explanation:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(quiz!.questions[currentQuestionIndex].detailedSolution),
            ],
            SizedBox(height: 8),
            Text(
              'Lost ${quiz!.negativeMarks} marks',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextQuestion();
            },
            child: Text('Next Question'),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    if (quiz == null) return;
    
    if (currentQuestionIndex < quiz!.questionsCount - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _showQuizCompletedDialog();
    }
  }

  void _showQuizCompletedDialog() {
    if (quiz == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz Completed! 🎊'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score: ${score.toStringAsFixed(1)}'),
            Text('Coins Earned: $coins'),
            Text('Highest Streak: $streak'),
            SizedBox(height: 16),
            Text('Topic: ${quiz!.topic}'),
            Text('Total Questions: ${quiz!.questionsCount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentQuestionIndex = 0;
                score = 0;
                streak = 0;
                coins = 0;
                _loadQuiz();
              });
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? 'Loading Quiz...' : (quiz?.title ?? 'Quiz')),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.yellow),
                SizedBox(width: 4),
                Text('$coins'),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadQuiz,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : quiz == null
                  ? Center(child: Text('No quiz data available'))
                  : Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Score: ${score.toStringAsFixed(1)}',
                                style: TextStyle(fontSize: 18),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: streak > 0 ? Colors.orange : Colors.grey,
                                  ),
                                  Text(
                                    'Streak: $streak',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: (currentQuestionIndex + 1) / quiz!.questionsCount,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Question ${currentQuestionIndex + 1}/${quiz!.questionsCount}',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                quiz!.questions[currentQuestionIndex].description,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Expanded(
                            child: ListView.builder(
                              itemCount: quiz!.questions[currentQuestionIndex].options.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: ElevatedButton(
                                    onPressed: () => _handleAnswer(index),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      quiz!.questions[currentQuestionIndex].options[index].description,
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}