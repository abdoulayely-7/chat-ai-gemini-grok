import 'dart:convert';
import 'dart:io';

import 'package:chat_ai_gemini/Models/Message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

enum AiProvider { gemini, groq }

class ApiService {
  static String get _geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['API_KEY'] ?? '';
  static String get _groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const String _geminiModelName = 'gemini-1.5-flash-latest';
  static const String _groqModelName = 'llama-3.3-70b-versatile';

  late final GenerativeModel? _geminiModel = _geminiApiKey.isEmpty
      ? null
      : GenerativeModel(model: _geminiModelName, apiKey: _geminiApiKey);

  ChatSession? _geminiChat;

  void resetConversation(AiProvider provider) {
    if (provider == AiProvider.gemini) {
      _geminiChat = _geminiModel?.startChat();
    }
  }

  Future<String> getChatResponse({
    required AiProvider provider,
    required String userMessage,
    List<Message> history = const [],
  }) async {
    switch (provider) {
      case AiProvider.gemini:
        return _getGeminiChatResponse(userMessage);
      case AiProvider.groq:
        return _getGroqChatResponse(userMessage: userMessage, history: history);
    }
  }

  Future<String> _getGeminiChatResponse(String userMessage) async {
    if (_geminiModel == null) {
      return 'Clé Gemini introuvable. Ajoute GEMINI_API_KEY dans le fichier .env.';
    }

    try {
      _geminiChat ??= _geminiModel.startChat();
      final response = await _geminiChat!.sendMessage(
        Content.text(userMessage),
      );

      if (response.text != null && response.text!.trim().isNotEmpty) {
        return response.text!;
      }

      return 'Gemini n\'a pas pu générer de réponse. Réessaie.';
    } on GenerativeAIException catch (e) {
      return 'Erreur Gemini: ${e.message}';
    } catch (e) {
      return 'Une erreur est survenue avec Gemini: $e';
    }
  }

  Future<String> _getGroqChatResponse({
    required String userMessage,
    required List<Message> history,
  }) async {
    if (_groqApiKey.isEmpty) {
      return 'Clé Groq introuvable. Ajoute GROQ_API_KEY dans le fichier .env.';
    }

    final client = HttpClient();

    try {
      final request = await client.postUrl(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      );

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $_groqApiKey',
      );

      final messages = <Map<String, String>>[
        {
          'role': 'system',
          'content':
              'Tu es un assistant conversationnel utile, clair et concis.',
        },
        ...history.map(
          (message) => {
            'role': message.isUserMessage ? 'user' : 'assistant',
            'content': message.text,
          },
        ),
        {'role': 'user', 'content': userMessage},
      ];

      request.write(
        jsonEncode({
          'model': _groqModelName,
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      debugPrint('Groq status code: ${response.statusCode}');
      debugPrint('Groq response: $responseBody');

      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        final error = decoded['error'];
        if (error is Map<String, dynamic> && error['message'] is String) {
          return 'Erreur Groq: ${error['message']}';
        }

        return 'Erreur Groq: ${response.statusCode}';
      }

      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final firstChoice = choices.first;
        if (firstChoice is Map<String, dynamic>) {
          final message = firstChoice['message'];
          if (message is Map<String, dynamic>) {
            final content = message['content'];
            if (content is String && content.trim().isNotEmpty) {
              return content;
            }
          }
        }
      }

      return 'Groq n\'a pas pu générer de réponse. Réessaie.';
    } catch (e) {
      debugPrint('Groq exception: $e');
      return 'Une erreur est survenue avec Groq: $e';
    } finally {
      client.close(force: true);
    }
  }
}
