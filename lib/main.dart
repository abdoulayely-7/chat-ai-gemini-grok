import 'package:chat_ai_gemini/Screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Impossible de charger .env: $e');
  }

  final groqApiKey = dotenv.env['GROQ_API_KEY'];
  debugPrint(
    groqApiKey == null || groqApiKey.isEmpty
        ? 'GROQ_API_KEY non chargee.'
        : 'GROQ_API_KEY chargee: ${groqApiKey.substring(0, groqApiKey.length.clamp(0, 12))}...',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat IA',
      home: const ChatScreen(),
    );
  }
}
