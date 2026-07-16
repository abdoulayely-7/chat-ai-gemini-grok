import 'dart:convert';
import 'dart:io';

import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/domain/contracts/ai_chat_client.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';
import 'package:flutter/foundation.dart';

class GroqChatClient implements AiChatClient {
  GroqChatClient({required this.apiKey, this.modelName = _defaultModelName});

  static const String _defaultModelName = 'llama-3.3-70b-versatile';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  final String apiKey;
  final String modelName;

  @override
  AiProvider get provider => AiProvider.groq;

  @override
  Future<void> resetConversation() async {}

  @override
  Future<String> sendMessage({
    required String userMessage,
    List<ChatMessage> history = const [],
  }) async {
    if (apiKey.isEmpty) {
      return 'Cle Groq introuvable. Ajoute GROQ_API_KEY dans le fichier .env.';
    }

    final client = HttpClient();

    try {
      final request = await client.postUrl(Uri.parse(_endpoint));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');

      request.write(
        jsonEncode({
          'model': modelName,
          'messages': _buildMessages(history, userMessage),
          'temperature': 0.7,
        }),
      );

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      debugPrint('Groq status code: ${response.statusCode}');
      debugPrint('Groq response: $responseBody');

      return _extractResponse(response.statusCode, responseBody);
    } catch (error) {
      debugPrint('Groq exception: $error');
      return 'Une erreur est survenue avec Groq: $error';
    } finally {
      client.close(force: true);
    }
  }

  List<Map<String, String>> _buildMessages(
    List<ChatMessage> history,
    String userMessage,
  ) {
    return <Map<String, String>>[
      {
        'role': 'system',
        'content': 'Tu es un assistant conversationnel utile, clair et concis.',
      },
      ...history.map(
        (message) => {
          'role': message.isFromUser ? 'user' : 'assistant',
          'content': message.text,
        },
      ),
      {'role': 'user', 'content': userMessage},
    ];
  }

  String _extractResponse(int statusCode, String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

    if (statusCode >= 400) {
      final error = decoded['error'];
      if (error is Map<String, dynamic> && error['message'] is String) {
        return 'Erreur Groq: ${error['message']}';
      }

      return 'Erreur Groq: $statusCode';
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

    return 'Groq n a pas pu generer de reponse. Reessaie.';
  }
}
