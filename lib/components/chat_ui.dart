import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dot_chat/models/chat_session_model.dart';
import 'package:dot_chat/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as flutter_gemini;
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatUi extends StatefulWidget {
  final List<ChatMessage> messages;
  const ChatUi({super.key, required this.messages});

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {

  ChatSessionModel? session;
  bool isBotTyping = false;
  final flutter_gemini.Gemini gemini = flutter_gemini.Gemini.instance;
  ChatUser currentUser = ChatUser(id: "0", firstName: "You");
  ChatUser dot = ChatUser(id: "1", firstName: "Dot");
  final List<String> samplePrompts = [
    "How are you?",
    "Tell me a joke",
    "What's the weather?",
    "What's the time?",
    "Can you help me?",
  ];

  void _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.text.trim().isNotEmpty) {
      setState(() {
        widget.messages.insert(0, chatMessage);
        isBotTyping = true;
      });

      if (widget.messages.length == 1 && session?.title == "New Chat") {
       session?.title = chatMessage.text;
       await session?.save(); 
       setState(() {}); 
      }
      ChatService.addMessageToSession(session,chatMessage); 

      List<flutter_gemini.Part> parts = [flutter_gemini.TextPart(chatMessage.text)];
      final responseStream = gemini.promptStream(
        parts: parts,
        );

      responseStream.listen(
        (event) {
          String generatedText = event!.content!.parts!
          .map((part) => (part as flutter_gemini.TextPart).text)
          .join(' ');
          if (widget.messages.first.user.id == dot.id) {
            setState(() {
              widget.messages.first.text += ' $generatedText ';
            });
          } else {
            setState(() {
              widget.messages.insert(0, ChatMessage(
                text: generatedText,
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
          ChatService.addMessageToSession(session, widget.messages.first);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (widget.messages.isEmpty)
            Expanded(
              flex: 3,
              child: Center(
                child: SingleChildScrollView(
                  child:  Column(
                      children: [
                        Image.asset('assets/dot.png', width: 30),
                        const Text(
                          "Welcome to Dot Chat!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Chat with Dot, your AI assistant.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Column(
                    children: samplePrompts.map((prompt) {
                      return GestureDetector(
                        onTap: () async{
                          ChatMessage chatMessage = ChatMessage(text: prompt, user: currentUser, createdAt: DateTime.now());
                          if (session == null)  { 
                            session = await ChatService.createSession();
                            setState(() {});
                          }
                          _sendMessage(chatMessage);
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
            ),
          Expanded(
            flex: 1,
            child: DashChat(
              currentUser: currentUser,
              onSend: _sendMessage,
              messages: widget.messages,
              typingUsers: isBotTyping ? [dot] : [],
              inputOptions: InputOptions(
                alwaysShowSend: true,
                sendOnEnter: true,
                inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.grey.shade50,
                  filled: true,
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
}