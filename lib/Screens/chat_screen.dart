import 'package:chat_ai_gemini/Models/Message.dart';
import 'package:chat_ai_gemini/Services/api_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ApiService _apiService = ApiService();
  AiProvider _selectedProvider = AiProvider.gemini;

  @override
  void initState() {
    super.initState();
    _apiService.resetConversation(_selectedProvider);
  }

  String get _providerLabel {
    switch (_selectedProvider) {
      case AiProvider.gemini:
        return 'Gemini';
      case AiProvider.groq:
        return 'Groq';
    }
  }

  void _changeProvider(AiProvider? provider) {
    if (provider == null || provider == _selectedProvider) return;

    setState(() {
      _selectedProvider = provider;
      _messages.clear();
    });

    _apiService.resetConversation(provider);
  }

  // envoie un msg et affiche la réponse
  void _sendMessage() async {
    final String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    final history = List<Message>.from(_messages);

    setState(() {
      _messages.add(Message(text: userMessage, isUserMessage: true));
      _messages.add(Message(text: '...', isUserMessage: false));
      _controller.clear();
    });

    FocusScope.of(context).unfocus();
    String botResponse;
    try {
      botResponse = await _apiService.getChatResponse(
        provider: _selectedProvider,
        userMessage: userMessage,
        history: history,
      );
    } catch (e) {
      botResponse =
          'Une erreur est survenue lors de la récuperation de la réponse';
    }

    await Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _messages.removeLast();
        _messages.add(Message(text: botResponse, isUserMessage: false));
      });
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec $_providerLabel'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<AiProvider>(
              value: _selectedProvider,
              onChanged: _changeProvider,
              items: const [
                DropdownMenuItem(
                  value: AiProvider.gemini,
                  child: Text('Gemini'),
                ),
                DropdownMenuItem(value: AiProvider.groq, child: Text('Groq')),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _apiService.resetConversation(_selectedProvider);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.isUserMessage;
                final avatar = const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/avatar_bot.png'),
                );
                final userAvatar = const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/avatar_user.png'),
                );
                final messageText = Text(msg.text);
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) avatar,
                      if (!isUser) const SizedBox(width: 5),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: messageText,
                        ),
                      ),
                      if (isUser) const SizedBox(width: 5),
                      if (isUser) userAvatar,
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Tapez votre message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
