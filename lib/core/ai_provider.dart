enum AiProvider { gemini, groq }

extension AiProviderLabel on AiProvider {
  String get label {
    switch (this) {
      case AiProvider.gemini:
        return 'Gemini';
      case AiProvider.groq:
        return 'Groq';
    }
  }
}
