import 'package:chat_ai_gemini/data/clients/gemini_chat_client.dart';
import 'package:chat_ai_gemini/data/clients/groq_chat_client.dart';
import 'package:chat_ai_gemini/data/services/chat_service.dart';
import 'package:chat_ai_gemini/presentation/controllers/chat_controller.dart';
import 'package:chat_ai_gemini/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Impossible de charger .env: $e');
  }

  final controller = ChatController(
    chatService: ChatService(
      clients: [
        GeminiChatClient(
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['API_KEY'] ?? '',
        ),
        GroqChatClient(apiKey: dotenv.env['GROQ_API_KEY'] ?? ''),
      ],
    ),
  );

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.controller, super.key});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat IA',
      home: ChatScreen(controller: controller),
    );
  }
}
