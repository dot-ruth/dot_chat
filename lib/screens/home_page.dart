import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatUser currentUser = ChatUser(id: "0", firstName: "You");
  ChatUser dot = ChatUser(
      id: "1",
      firstName: "Dot",
      profileImage: 'assets/dot.png');
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;
  bool isBotTyping = false;

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "DOT",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      leading: IconButton(
          icon: Icon(Icons.history), 
          onPressed: () {},
        ),
      actions: [
        IconButton(
        icon: Icon(CupertinoIcons.chat_bubble), 
        onPressed: () {}  ,
      )
      ],
    ),
    body: _buildChatUI(),
  );
}


Widget _buildChatUI() {
  return Container(
    color: Colors.white, 
    child: Column(
      children: [
        if (messages.isEmpty)
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/dot.png', width: 100, height: 100), 
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome to Dot Chat!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Chat with Dot, your AI assistant.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          flex: 2,
          child: DashChat(
            currentUser: currentUser,
            onSend: _sendMessage,
            messages: messages,
            typingUsers: isBotTyping ? [dot] : [],
            inputOptions: InputOptions(
              alwaysShowSend: true,
              sendOnEnter: true,
            ),
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
          ),
        ),
      ],
    ),
  );
}

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage);
      isBotTyping = true;
    });

      List<Part> parts = [TextPart(chatMessage.text)];
      final responseStream = gemini.promptStream(parts: parts);

      responseStream.listen((event) {
        if (messages.first.user.id == dot.id) {
          setState(() {
             messages.first.text += event!.content!.parts!.map((part) => (part as TextPart).text).join(' '); 
          });
        } else {
          setState(() {
            messages.insert(0, ChatMessage(
              text: event!.content!.parts!.map((part) => (part as TextPart).text).join(' '),
              user: dot,
              createdAt: DateTime.now(),
            ));
          });
        }
      },
      onDone:  () {
        setState(() {
          isBotTyping = false;
        });
      }
      );
  }

}
