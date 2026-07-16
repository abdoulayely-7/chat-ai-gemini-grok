import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/domain/contracts/ai_chat_client.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';

class ChatService {
  ChatService({required List<AiChatClient> clients})
    : _clients = {for (final client in clients) client.provider: client};

  final Map<AiProvider, AiChatClient> _clients;

  Future<String> getChatResponse({
    required AiProvider provider,
    required String userMessage,
    List<ChatMessage> history = const [],
  }) async {
    final client = _getClient(provider);
    return client.sendMessage(userMessage: userMessage, history: history);
  }

  Future<void> resetConversation(AiProvider provider) {
    final client = _getClient(provider);
    return client.resetConversation();
  }

  AiChatClient _getClient(AiProvider provider) {
    final client = _clients[provider];
    if (client == null) {
      throw UnsupportedError('Aucun client configure pour ${provider.label}.');
    }

    return client;
  }
}
