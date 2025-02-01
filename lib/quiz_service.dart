import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:quiz_app/quiz.dart';

class QuizService {
  final String baseUrl = 'https://api.jsonserve.com/Uw5CrX';

  Future<Quiz> fetchQuiz() async {
    try {
      // Print for debugging
      print('Attempting to fetch quiz from: $baseUrl');

      // Add headers to match Postman
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Request timed out');
          throw TimeoutException('Connection timed out');
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Quiz.fromJson(data);
      } else {
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load quiz: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('SocketException: ${e.message}');
      if (e.message.contains('Failed host lookup')) {
        // Check if the device has internet connection
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            throw Exception('Device has internet, but cannot reach the quiz server. Please check the URL or try again.');
          }
        } catch (_) {
          throw Exception('No internet connection. Please check your connection and try again.');
        }
      }
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection and try again.');
    } on FormatException catch (e) {
      print('FormatException: ${e.toString()}');
      throw Exception('Invalid response format from server');
    } catch (e) {
      print('Unexpected error: ${e.toString()}');
      throw Exception('Error fetching quiz: $e');
    }
  }
}