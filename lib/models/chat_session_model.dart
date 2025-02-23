import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:hive/hive.dart';
import 'chat_message_model.dart';

part 'chat_session_model.g.dart'; // Required for Hive TypeAdapter

@HiveType(typeId: 1)
class ChatSessionModel extends HiveObject {
  @HiveField(0)
  String id; 

  @HiveField(1)
  String title; 

  @HiveField(2)
  List<ChatMessageModel> messages; 

  @HiveField(3)
  DateTime createdAt; 

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  void addMessage(ChatMessage message) {
    messages.add(ChatMessageModel.fromChatMessage(message));
    save(); 
  }

  List<ChatMessage> getChatMessages() {
    return messages.map((msg) => msg.toChatMessage()).toList().reversed.toList();
  }
}
