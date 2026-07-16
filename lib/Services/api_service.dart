import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  static final String apiKey = dotenv.env['API_KEY'] ?? '';

  final model = GenerativeModel(
    model: "gemini-1.5-flash-latest",
    apiKey: apiKey,
  );

  Future<String> getChatResponse(String userMessage) async {
    try {
      final content = [Content.text(userMessage)];
      final response = await model.generateContent(content);
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return 'L\'IA n\'a pas pu générer de réponse. Réessaie.';
      }
    } catch (e) {
      if (e is GenerativeAIException) {
        return 'Erreur de l\'IA: ${e.message}';
      } else {
        return 'Une erreur est survenue: $e';
      }
    }
  }
}
