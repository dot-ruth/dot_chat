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
  ChatUser currentUser = ChatUser(id: "0", firstName: "You");
  ChatUser dot = ChatUser(
      id: "1",
      firstName: "Dot",
      profileImage: 'assets/dot.png');
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;
  bool _showChat = false; // Controls visibility of chat UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Dot Chat"),
      ),
      body: _showChat ? _buildChatUI() : _buildIntroUI(), // Show either the intro screen or chat
    );
  }

  Widget _buildIntroUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/dot.png', width: 100, height: 100), // Chatbot logo
          const SizedBox(height: 20),
          const Text(
            "Welcome to Dot Chat!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Chat with Dot, your AI assistant.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showChat = true; // Switch to chat UI
              });
            },
            child: const Text("Start Chat"),
          ),
        ],
      ),
    );
  }

  Widget _buildChatUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      inputOptions: InputOptions(
        alwaysShowSend: true,
        sendOnEnter: true
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
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage);
    });

    try {
      List<Part> parts = [TextPart(chatMessage.text)];
      final responseStream = gemini.promptStream(parts: parts);

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
                (previousValue, element) => previousValue + (element as TextPart).text,
              ),
              user: dot,
              createdAt: DateTime.now(),
            ));
          });
        }
      });
    } catch (error) {
      print("Error in streaming response: $error");
    }
  }
}
