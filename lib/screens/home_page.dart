import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dot_chat/components/chat_ui.dart';
import 'package:dot_chat/models/chat_session_model.dart';
import 'package:dot_chat/components/chat_history_drawer.dart';
import 'package:dot_chat/providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatMessage> messages = [];
  ChatSessionModel? session;

  void _loadChat(List<ChatMessage> selectedMessages,ChatSessionModel selectedSession) {
    setState(() {
    messages = selectedMessages; 
    session = selectedSession;
  });
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      key:_scaffoldKey,
      appBar: AppBar(
        backgroundColor: themeProvider.themeMode == ThemeMode.dark ? Colors.transparent: Colors.white,
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:  [
            Row(
              children: [
                IconButton(
                          icon: Icon(CupertinoIcons.line_horizontal_3_decrease),
                          onPressed: () {_scaffoldKey.currentState?.openDrawer();},
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
                  onPressed: () { themeProvider.toggleTheme();},
                  icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
        ),
                IconButton(
                icon: Icon(CupertinoIcons.delete),
                onPressed: () async {
                   if (session != null) {
                       session!.messages.clear(); 
                       session!.title="History Cleared";
                       await session!.save(); 
                    }
                   setState(() {messages.clear(); });
                 },
               ),
              ],
            ),
          ],
        ),
      ),
      drawer: ChatHistoryDrawer(onChatSelected: _loadChat),
      body: ChatUi(messages: messages, session: session),
    );
  }
}
