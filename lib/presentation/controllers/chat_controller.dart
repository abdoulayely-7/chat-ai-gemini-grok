import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/domain/contracts/chat_gateway.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';
import 'package:flutter/foundation.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required this.chatGateway,
    AiProvider initialProvider = AiProvider.gemini,
  }) : _selectedProvider = initialProvider;

  final ChatGateway chatGateway;
  final List<ChatMessage> _messages = [];

  AiProvider _selectedProvider;
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  AiProvider get selectedProvider => _selectedProvider;
  bool get isLoading => _isLoading;

  Future<void> initialize() {
    return chatGateway.resetConversation(_selectedProvider);
  }

  Future<void> changeProvider(AiProvider? provider) async {
    if (provider == null || provider == _selectedProvider) {
      return;
    }

    _selectedProvider = provider;
    _messages.clear();
    notifyListeners();

    await chatGateway.resetConversation(provider);
  }

  Future<void> clearConversation() async {
    _messages.clear();
    notifyListeners();
    await chatGateway.resetConversation(_selectedProvider);
  }

  Future<void> sendMessage(String rawMessage) async {
    final userMessage = rawMessage.trim();
    if (userMessage.isEmpty || _isLoading) {
      return;
    }

    final history = List<ChatMessage>.from(_messages);
    _messages.add(ChatMessage(text: userMessage, isFromUser: true));
    _isLoading = true;
    notifyListeners();

    final response = await chatGateway.getChatResponse(
      provider: _selectedProvider,
      userMessage: userMessage,
      history: history,
    );

    _messages.add(ChatMessage(text: response, isFromUser: false));
    _isLoading = false;
    notifyListeners();
  }
}
