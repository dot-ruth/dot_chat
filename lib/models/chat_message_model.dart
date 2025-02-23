import 'package:hive/hive.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

part 'chat_message_model.g.dart'; // Required for Hive TypeAdapter

@HiveType(typeId: 0)
class ChatMessageModel extends HiveObject {
  @HiveField(1)
  String text;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String userName;

  @HiveField(4)
  DateTime createdAt;

  ChatMessageModel({
    required this.text,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  // Convert from ChatMessage
  factory ChatMessageModel.fromChatMessage(ChatMessage message) {
    return ChatMessageModel(
      text: message.text,
      userId: message.user.id,
      userName: message.user.firstName ?? "",
      createdAt: message.createdAt,
    );
  }

  // Convert to ChatMessage
  ChatMessage toChatMessage() {
    return ChatMessage(
      text: text,
      user: ChatUser(id: userId, firstName: userName),
      createdAt: createdAt,
    );
  }
}
