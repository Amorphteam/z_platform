import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // OpenAI API Configuration
  // API key is loaded from environment variables for security
  static String get openAIApiKey {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY not found in environment variables. Please check your .env file.');
    }
    return apiKey;
  }

  // Claude API Configuration
  // API key is loaded from environment variables for security
  static String? get claudeApiKey {
    final apiKey = dotenv.env['CLAUDE_API_KEY'];
    return apiKey?.isEmpty == true ? null : apiKey;
  }
}
