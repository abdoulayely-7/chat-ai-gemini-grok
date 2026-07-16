import 'package:chat_ai_gemini/core/ai_provider.dart';
import 'package:chat_ai_gemini/domain/contracts/chat_gateway.dart';
import 'package:chat_ai_gemini/main.dart';
import 'package:chat_ai_gemini/models/chat_message.dart';
import 'package:chat_ai_gemini/presentation/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays sent and received messages', (
    WidgetTester tester,
  ) async {
    final controller = ChatController(chatGateway: _FakeChatGateway());

    await tester.pumpWidget(MyApp(controller: controller));
    await tester.pump();

    await tester.enterText(find.byType(EditableText), 'Bonjour');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text('Bonjour'), findsOneWidget);
    expect(find.text('Reponse: Bonjour'), findsOneWidget);
  });
}

class _FakeChatGateway implements ChatGateway {
  @override
  Future<String> getChatResponse({
    required AiProvider provider,
    required String userMessage,
    List<ChatMessage> history = const [],
  }) async {
    return 'Reponse: $userMessage';
  }

  @override
  Future<void> resetConversation(AiProvider provider) async {}
}
