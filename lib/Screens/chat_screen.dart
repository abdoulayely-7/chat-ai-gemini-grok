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
  final List<Message> _message = [];
  final ApiService _apiService = ApiService();

  // envoie un msg et affiche la réponse
  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;
    setState(() {
      //  ajout du message de l'utilisateur à la liste des messages
      _message.add(Message(text: userMessage, isUserMessage: true));
      //  point de suspension en attend la reponse
      _message.add(Message(text: '...', isUserMessage: false));
      _controller.clear();
    });

    FocusScope.of(context).unfocus();
    String botResponse;
    try {
      botResponse = await _apiService.getChatResponse(userMessage);
    } catch (e) {
      botResponse =
          'Une erreur est survenue lors de la récuperation de la réponse';
    }

    await Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        // Mise à jour du dernier message (remplacement du point de suspension)
        _message.removeLast();
        _message.add(Message(text: botResponse, isUserMessage: false));
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat avec Gemini')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _message.length,
              itemBuilder: (context, index) {
                final msg = _message[index];
                final isUser = msg.isUserMessage;
                final avatar = CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    isUser ? 'assets/avatar_user.png' : 'assets/avatar_bot.png',
                  ),
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
                      if (!isUser) SizedBox(width: 5),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(
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
                      if (isUser) SizedBox(width: 5),
                      if (isUser) avatar,
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
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
