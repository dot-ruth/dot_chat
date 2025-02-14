import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    ChatUser currentUser = ChatUser(id: "0",firstName:"You");
    ChatUser dot = ChatUser(
        id: "1",
        firstName: "Dot",
        profileImage: 'assets/dot.png'
        );
    List<ChatMessage> messages = []; 
    final Gemini gemini = Gemini.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("Dot Chat"),
        ),
        body: _buildUI(),
    );
  }

 Widget _buildUI() {
  return DashChat(
    currentUser: currentUser,
    onSend: _sendMessage,
    messages: messages,
    messageOptions: MessageOptions(
      messageTextBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
        return MarkdownBody(
          data: message.text,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: TextStyle(
              color: message.user.id == currentUser.id ? Colors.white : Colors.black,
            ),
          ),
        );
      },
    ),
  );
}




  void _sendMessage(ChatMessage chatMessage) {
  setState(() {
    messages.insert(0, chatMessage);
  });

  try {
    List<Part> parts = [TextPart(chatMessage.text)];
    final responseStream = gemini.promptStream(parts: parts );

    responseStream.listen((event) {
      if (messages.first.user.id == dot.id) {
        setState(() {
          messages.first.text += event!.content!.parts!.fold(
            '',
            (previousValue, element) => previousValue + (element as TextPart).text,
          ); 
        });
      } else {
        setState(() {
          messages.insert(0, ChatMessage(
            text: event!.content!.parts!.fold(
              '',
              (previousValue, element) => previousValue +(element as TextPart).text,
            ),
            user: dot,
            createdAt: DateTime.now()
          ));
        });
      }
    });
  } catch (error) {
    print("Error in streaming response: $error");
  }
}

  }