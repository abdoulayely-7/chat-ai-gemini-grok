import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/presentation/controllers/chat_controller.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.controller, super.key});

  final ChatController controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  ChatController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final message = _textController.text;
    _textController.clear();
    FocusScope.of(context).unfocus();
    await _controller.sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Chat avec ${_controller.selectedProvider.label}'),
            actions: [
              DropdownButtonHideUnderline(
                child: DropdownButton<AiProvider>(
                  value: _controller.selectedProvider,
                  onChanged: _controller.changeProvider,
                  items: const [
                    DropdownMenuItem(
                      value: AiProvider.gemini,
                      child: Text('Gemini'),
                    ),
                    DropdownMenuItem(
                      value: AiProvider.groq,
                      child: Text('Groq'),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _controller.clearConversation,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount:
                      _controller.messages.length +
                      (_controller.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_controller.isLoading &&
                        index == _controller.messages.length) {
                      return const _TypingIndicator();
                    }

                    final message = _controller.messages[index];
                    return _MessageBubble(
                      text: message.text,
                      isFromUser: message.isFromUser,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _handleSubmit(),
                        decoration: const InputDecoration(
                          hintText: 'Tapez votre message...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.isFromUser});

  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 20,
      backgroundImage: AssetImage(
        isFromUser ? 'assets/avatar_user.png' : 'assets/avatar_bot.png',
      ),
    );

    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser) avatar,
          if (!isFromUser) const SizedBox(width: 5),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: isFromUser ? Colors.blue : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(text),
            ),
          ),
          if (isFromUser) const SizedBox(width: 5),
          if (isFromUser) avatar,
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const _MessageBubble(text: '...', isFromUser: false);
  }
}
