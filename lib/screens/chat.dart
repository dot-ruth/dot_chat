import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dot_chat/components/chat_ui.dart';
import 'package:dot_chat/models/chat_session_model.dart';
import 'package:dot_chat/components/chat_history_drawer.dart';
import 'package:dot_chat/providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Chat extends StatefulWidget {
  List<ChatMessage> messages;
  ChatSessionModel? session;
  Chat({super.key, required this.messages, this.session});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
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
                   if (widget.session != null) {
                       widget.session!.messages.clear(); 
                       widget.session!.title="History Cleared";
                       await widget.session!.save(); 
                    }
                   setState(() {widget.messages.clear(); });
                 },
               ),
              ],
            ),
          ],
        ),
      ),
      drawer: ChatHistoryDrawer(),
      body:  ChatUi(messages: widget.messages, session: widget.session)
    );
  }
}