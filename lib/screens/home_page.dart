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
  );
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;
  bool isBotTyping = false;
  final TextEditingController _textController = TextEditingController();
  final List<String> samplePrompts = [
    "How are you?",
    "Tell me a joke",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:  [
            Row(
              children: [
                IconButton(
                          icon: Icon(CupertinoIcons.line_horizontal_3_decrease),
                          onPressed: () {},
                        ),
                Text(
                  "DOT",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            Row(
              children: [
                IconButton(
                icon: Icon(CupertinoIcons.chat_bubble),
                onPressed: () {},
                          ),
                          IconButton(
                icon: Icon(CupertinoIcons.delete),
                onPressed: () {
                  setState(() {
                    messages.clear();
                  });
                },
                          ),
              ],
            ),
          ],
        ),
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
              child: Center(
                child: Column(
                  children: [
                    Image.asset('assets/dot.png', width: 100, height: 100),
                    const SizedBox(height: 5),
                    const Text(
                      "Welcome to Dot Chat!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Chat with Dot, your AI assistant.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Column(
                children: samplePrompts.map((prompt) {
                  return GestureDetector(
                    onTap: () {
                      _textController.text = prompt;
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _textController.text.length),
                      );
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      margin: EdgeInsets.only(bottom: 5),
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        prompt,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
                  ],
                ), 
              ),
            ),
          Expanded(
            child: DashChat(
              currentUser: currentUser,
              onSend: _sendMessage,
              messages: messages,
              typingUsers: isBotTyping ? [dot] : [],
              inputOptions: InputOptions(
                textController: _textController,
                alwaysShowSend: true,
                sendOnEnter: true,
                inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: "Type a message...",
                ),
              ),
              messageOptions: MessageOptions(
                showOtherUsersAvatar: false,
                messagePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                messageTextBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
                  return MarkdownBody(
                    data: message.text,
                    selectable: true,
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
    if (chatMessage.text.trim().isNotEmpty) {
      setState(() {
        messages.insert(0, chatMessage);
        isBotTyping = true;
      });

      List<Part> parts = [TextPart(chatMessage.text)];
      final responseStream = gemini.promptStream(parts: parts);

      responseStream.listen(
        (event) {
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
        onDone: () {
          setState(() {
            isBotTyping = false;
          });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message cannot be empty')),
      );
    }
  }
}
