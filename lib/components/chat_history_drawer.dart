import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dot_chat/models/chat_session_model.dart';
import 'package:dot_chat/services/chat_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatHistoryDrawer extends StatelessWidget {
  final void Function(List<ChatMessage>, ChatSessionModel) onChatSelected;

  const ChatHistoryDrawer({super.key, required this.onChatSelected});

  Future<Box> openChatBox() async {
    return await Hive.openBox('chatBox');
  }

  Map<String, dynamic> convertToMapStringDynamic(Map<dynamic, dynamic> input) {
    return input.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
Widget build(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        SizedBox(
          height: 100,
          child: DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
            onTap: () async {
              ChatSessionModel newSession = await ChatService.createSession();
              onChatSelected([], newSession); 
              (context as Element).markNeedsBuild();
            },
            child: Row(
              children: [
                Icon(CupertinoIcons.pencil_ellipsis_rectangle),
                SizedBox(width: 10),
                Text(
          'New Chat',
          style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          
                IconButton(
                  icon: Icon(Icons.auto_delete_outlined),
                  onPressed: () {
                    ChatService.clearSessions();
                    (context as Element).markNeedsBuild();
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<ChatSessionModel>('chatBox').listenable(),
            builder: (context, box, _) {
              var sessions = ChatService.getSessions();
              return sessions.isEmpty
                  ? Center(child: Text("No chat history"))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(sessions[index].title),
                          onTap: () {
                            var messages = ChatService.getMessagesFromSession(sessions[index]);
                            onChatSelected(messages,sessions[index]); // Load session
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
            },
          ),
        ),
      ],
    ),
  );
}
}
