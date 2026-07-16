import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/data/services/chat_service.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';
import 'package:flutter/foundation.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required this.chatService,
    AiProvider initialProvider = AiProvider.gemini,
  }) : _selectedProvider = initialProvider;

  final ChatService chatService;
  final List<ChatMessage> _messages = [];

  AiProvider _selectedProvider;
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  AiProvider get selectedProvider => _selectedProvider;
  bool get isLoading => _isLoading;

  Future<void> initialize() {
    return chatService.resetConversation(_selectedProvider);
  }

  Future<void> changeProvider(AiProvider? provider) async {
    if (provider == null || provider == _selectedProvider) {
      return;
    }

    _selectedProvider = provider;
    _messages.clear();
    notifyListeners();

    await chatService.resetConversation(provider);
  }

  Future<void> clearConversation() async {
    _messages.clear();
    notifyListeners();
    await chatService.resetConversation(_selectedProvider);
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

    final response = await chatService.getChatResponse(
      provider: _selectedProvider,
      userMessage: userMessage,
      history: history,
    );

    _messages.add(ChatMessage(text: response, isFromUser: false));
    _isLoading = false;
    notifyListeners();
  }
}
