import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';

// Contrat simple pour ajouter un nouveau provider sans modifier les autres.
abstract class AiChatClient {
  AiProvider get provider;

  Future<String> sendMessage({
    required String userMessage,
    List<ChatMessage> history = const [],
  });

  Future<void> resetConversation();
}
