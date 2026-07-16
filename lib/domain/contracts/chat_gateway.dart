import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';

abstract class ChatGateway {
  Future<String> getChatResponse({
    required AiProvider provider,
    required String userMessage,
    List<ChatMessage> history = const [],
  });

  Future<void> resetConversation(AiProvider provider);
}
