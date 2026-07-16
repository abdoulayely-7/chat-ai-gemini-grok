class ChatMessage {
  const ChatMessage({required this.text, required this.isFromUser});

  final String text;
  final bool isFromUser;

  bool get isFromAssistant => !isFromUser;
}
