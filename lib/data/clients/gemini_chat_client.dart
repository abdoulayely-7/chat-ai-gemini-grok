import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/domain/contracts/ai_chat_client.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiChatClient implements AiChatClient {
  GeminiChatClient({required this.apiKey, this.modelName = _defaultModelName});

  static const String _defaultModelName = 'gemini-1.5-flash-latest';

  final String apiKey;
  final String modelName;

  GenerativeModel? _model;
  ChatSession? _chatSession;

  @override
  AiProvider get provider => AiProvider.gemini;

  @override
  Future<void> resetConversation() async {
    _chatSession = _buildModel()?.startChat();
  }

  @override
  Future<String> sendMessage({
    required String userMessage,
    List<ChatMessage> history = const [],
  }) async {
    final model = _buildModel();
    if (model == null) {
      return 'Cle Gemini introuvable. Ajoute GEMINI_API_KEY dans le fichier .env.';
    }

    try {
      _chatSession ??= model.startChat();
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );
      final text = response.text?.trim();

      if (text != null && text.isNotEmpty) {
        return text;
      }

      return 'Gemini n a pas pu generer de reponse. Reessaie.';
    } on GenerativeAIException catch (error) {
      return 'Erreur Gemini: ${error.message}';
    } catch (error) {
      return 'Une erreur est survenue avec Gemini: $error';
    }
  }

  GenerativeModel? _buildModel() {
    if (apiKey.isEmpty) {
      return null;
    }

    return _model ??= GenerativeModel(model: modelName, apiKey: apiKey);
  }
}
