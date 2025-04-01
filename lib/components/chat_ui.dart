import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dot_chat/ai/system_prompt.dart';
import 'package:dot_chat/models/chat_session_model.dart';
import 'package:dot_chat/providers/theme_provider.dart';
import 'package:dot_chat/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gpt_markdown/custom_widgets/selectable_adapter.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatUi extends StatefulWidget {
  final List<ChatMessage> messages;
  ChatSessionModel? session;
  ChatUi({super.key, required this.messages, this.session});

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  bool isBotTyping = false;
  final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      systemInstruction: Content('',[TextPart(systemPrompt)])
    );
  ChatUser currentUser = ChatUser(id: "0", firstName: "You");
  ChatUser dot = ChatUser(id: "1", firstName: "Dot");
  final List<String> samplePrompts = [
    "How are you?",
    "Tell me a joke",
    "What's the weather?",
    "What's the time?",
    "Can you help me?",
  ];

  Stream<String?> generateResponse(String prompt) async* {
    final stream = model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in stream) {
        yield chunk.text;
    }
  }

  void _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.text.trim().isNotEmpty) {
    setState(() {
      widget.messages.insert(0, chatMessage);
      isBotTyping = true;
    });

    if (widget.messages.length == 1 && (widget.session?.title == "New Chat" || widget.session?.title == "History Cleared")) {
      widget.session?.title = chatMessage.text;
      await widget.session?.save();
      setState(() {});
    }

    ChatService.addMessageToSession(widget.session, chatMessage);

    StringBuffer responseBuffer = StringBuffer();
    ChatMessage? botMessage;

    await for (final event in generateResponse(chatMessage.text)) {
      if (event != null) {
        responseBuffer.write(event);

        if (botMessage == null) {
          botMessage = ChatMessage(
            text: responseBuffer.toString(),
            user: dot,
            createdAt: DateTime.now(),
          );

          setState(() {
            widget.messages.insert(0, botMessage!);
          });
        } else {
          setState(() {
            botMessage!.text = responseBuffer.toString();
          });
        }
      }
    }

    setState(() {
      isBotTyping = false;
    });

    if (botMessage != null) {
      ChatService.addMessageToSession(widget.session, botMessage);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message cannot be empty')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return  Column(
        children: [
          if (widget.messages.isEmpty)
            Expanded(
              flex: 3,
              child: Center(
                child: SingleChildScrollView(
                  child:  Column(
                      children: [
                        Image.asset(themeProvider.themeMode == ThemeMode.dark ? 'assets/dot_dark.png' :'assets/dot.png', width: 30),
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
                          if (widget.session == null)  { 
                              widget.session = await ChatService.createSession();
                              setState(() {});
                          }
                          _sendMessage(chatMessage);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          margin: EdgeInsets.only(bottom: 5),
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    ),
                  fillColor: themeProvider.themeMode == ThemeMode.dark ? Colors.black : Colors.white,
                  filled: true,
                  hintText: "Type a message...",
                ),
              ),
              messageOptions: MessageOptions(
                containerColor:themeProvider.themeMode == ThemeMode.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                currentUserContainerColor: themeProvider.themeMode == ThemeMode.dark ? Colors.grey.shade700 : Colors.grey.shade400,
                showOtherUsersAvatar: false,
                showOtherUsersName: false,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                messagePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                messageTextBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
                  return SelectableAdapter(
                      selectedText: message.text,
                      child: GptMarkdown(
                        message.text,
                        style: TextStyle(
                            color: themeProvider.themeMode == ThemeMode.dark ?  Colors.white : Colors.black,
                          ),
                      ),
                    );
                },
              ),
            ),
          ),
        ],
      );
  }
}